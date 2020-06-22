/*
 * Copyright 2019-2020, Offchain Labs, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity ^0.5.3;

import "./NodeGraph.sol";
import "./Staking.sol";
import "./ArbContractProxy.sol";


contract ArbRollup is NodeGraph, Staking {

    // invalid path proof
    string constant PLACE_LEAF = "PLACE_LEAF";

    // invalid leaf
    string constant MOVE_LEAF = "MOVE_LEAF";

    // invalid path proof
    string constant RECOV_PATH_PROOF = "RECOV_PATH_PROOF";
    // Invalid conflict proof
    string constant RECOV_CONFLICT_PROOF = "RECOV_CONFLICT_PROOF";
    // Proof must be of nonzero length
    string constant RECVOLD_LENGTH = "RECVOLD_LENGTH";
    // invalid leaf
    string constant RECOV_DEADLINE_LEAF = "RECOV_DEADLINE_LEAF";
    // Node is not passed deadline
    string constant RECOV_DEADLINE_TIME = "RECOV_DEADLINE_TIME";

    // invalid staker location proof
    string constant MAKE_STAKER_PROOF = "MAKE_STAKER_PROOF";

    // Type is not invalid
    string constant CONF_INV_TYPE = "CONF_INV_TYPE";
    // Node is not passed deadline
    string constant CONF_TIME = "CONF_TIME";
    // There must be at least one staker
    string constant CONF_HAS_STAKER = "CONF_HAS_STAKER";

    // Only callable by owner
    string constant ONLY_OWNER = "ONLY_OWNER";

    string public constant VERSION = "3";

    address payable owner;

    mapping(address => address) incomingCallProxies;
    mapping(address => address) public supportedContracts;

    event ConfirmedAssertion(
        bytes32[] logsAccHash
    );

    event ConfirmedValidAssertion(
        bytes32 indexed nodeHash
    );

    function init(
        bytes32 _vmState,
        uint128 _gracePeriodTicks,
        uint128 _arbGasSpeedLimitPerTick,
        uint64 _maxExecutionSteps,
        uint64[2] calldata _maxTimeBoundsWidth,
        uint128 _stakeRequirement,
        address payable _owner,
        address _challengeFactoryAddress,
        address _globalInboxAddress
    )
        external
    {
        NodeGraph.init(
            _vmState,
            _gracePeriodTicks,
            _arbGasSpeedLimitPerTick,
            _maxExecutionSteps,
            _maxTimeBoundsWidth,
            _globalInboxAddress
        );
        Staking.init(
            _stakeRequirement,
            _challengeFactoryAddress
        );
        owner = _owner;
    }

    function forwardContractMessage(address _sender, bytes calldata _data) external payable {
        address arbContractAddress = incomingCallProxies[msg.sender];
        require(arbContractAddress != address(0), "Non interface contract can't send message");

        globalInbox.forwardEthMessage.value(msg.value)(arbContractAddress, _sender);
        globalInbox.forwardContractTransactionMessage(arbContractAddress, _sender, msg.value, _data);
    }

    function spawnCallProxy(address _arbContract) external {
        ArbVMContractProxy proxy = new ArbVMContractProxy(address(this));
        incomingCallProxies[address(proxy)] = _arbContract;
        supportedContracts[_arbContract] = address(proxy);
    }

    function placeStake(
        bytes32[] calldata proof1,
        bytes32[] calldata proof2
    )
        external
        payable
    {
        bytes32 location = RollupUtils.calculateLeafFromPath(latestConfirmed(), proof1);
        bytes32 leaf = RollupUtils.calculateLeafFromPath(location, proof2);
        require(isValidLeaf(leaf), PLACE_LEAF);
        createStake(location);
    }

    function moveStake(
        bytes32[] calldata proof1,
        bytes32[] calldata proof2
    )
        external
    {
        bytes32 stakerLocation = getStakerLocation(msg.sender);
        bytes32 newLocation = RollupUtils.calculateLeafFromPath(stakerLocation, proof1);
        bytes32 leaf = RollupUtils.calculateLeafFromPath(newLocation, proof2);
        require(isValidLeaf(leaf), MOVE_LEAF);
        updateStakerLocation(msg.sender, newLocation);
    }

    function recoverStakeConfirmed(bytes32[] calldata proof) external {
        _recoverStakeConfirmed(msg.sender, proof);
    }

    function recoverStakeOld(address payable stakerAddress, bytes32[] calldata proof) external {
        require(proof.length > 0, RECVOLD_LENGTH);
        _recoverStakeConfirmed(stakerAddress, proof);
    }

    function recoverStakeMooted(
        address payable stakerAddress,
        bytes32 node,
        bytes32[] calldata latestConfirmedProof,
        bytes32[] calldata stakerProof
    )
        external
    {
        bytes32 stakerLocation = getStakerLocation(msg.sender);
        require(
            latestConfirmedProof[0] != stakerProof[0] &&
            RollupUtils.calculateLeafFromPath(node, latestConfirmedProof) == latestConfirmed() &&
            RollupUtils.calculateLeafFromPath(node, stakerProof) == stakerLocation,
            RECOV_CONFLICT_PROOF
        );
        refundStaker(stakerAddress);
    }

    // Kick off if successor node whose deadline has passed
    function recoverStakePassedDeadline(
        address payable stakerAddress,
        uint256 deadlineTicks,
        bytes32 disputableNodeHashVal,
        uint256 childType,
        bytes32 vmProtoStateHash,
        bytes32[] calldata proof
    )
        external
    {
        bytes32 stakerLocation = getStakerLocation(msg.sender);
        bytes32 nextNode = RollupUtils.childNodeHash(
            stakerLocation,
            deadlineTicks,
            disputableNodeHashVal,
            childType,
            vmProtoStateHash
        );
        bytes32 leaf = RollupUtils.calculateLeafFromPath(nextNode, proof);
        require(isValidLeaf(leaf), RECOV_DEADLINE_LEAF);
        require(block.number >= RollupTime.blocksToTicks(deadlineTicks), RECOV_DEADLINE_TIME);

        refundStaker(stakerAddress);
    }

    // fields
     // beforeVMHash
     // beforeInboxTop
     // prevPrevLeafHash
     // prevDataHash
     // afterInboxTop
     // importedMessagesSlice
     // afterVMHash
     // messagesAccHash
     // logsAccHash

    function makeAssertion(
        bytes32[9] calldata _fields,
        uint256 _beforeInboxCount,
        uint256 _prevDeadlineTicks,
        uint32 _prevChildType,
        uint64 _numSteps,
        uint128[4] calldata _timeBounds,
        uint256 _importedMessageCount,
        bool _didInboxInsn,
        uint64 _numArbGas,
        bytes32[] calldata _stakerProof
    )
        external
    {
        NodeGraphUtils.AssertionData memory assertData = NodeGraphUtils.AssertionData(
            _fields[0],
            _fields[1],
            _beforeInboxCount,

            _fields[2],
            _prevDeadlineTicks,
            _fields[3],
            _prevChildType,

            _numSteps,
            _timeBounds,
            _importedMessageCount,

            _fields[4],

            _fields[5],

            _fields[6],
            _didInboxInsn,
            _numArbGas,
            _fields[7],
            _fields[8]
        );

        (bytes32 prevLeaf, bytes32 newValid) = makeAssertion(assertData);

        bytes32 stakerLocation = getStakerLocation(msg.sender);
        require(RollupUtils.calculateLeafFromPath(stakerLocation, _stakerProof) == prevLeaf, MAKE_STAKER_PROOF);
        updateStakerLocation(msg.sender, newValid);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, ONLY_OWNER);
        _;
    }

    function ownerShutdown() external onlyOwner {
        selfdestruct(msg.sender);
    }


    function _recoverStakeConfirmed(address payable stakerAddress, bytes32[] memory proof) private {
        bytes32 stakerLocation = getStakerLocation(msg.sender);
        require(RollupUtils.calculateLeafFromPath(stakerLocation, proof) == latestConfirmed(), RECOV_PATH_PROOF);
        refundStaker(stakerAddress);
    }

    function confirm(
        bytes32 initalProtoStateHash,
        uint256[] memory branches,
        uint256[] memory deadlineTicks,
        bytes32[] memory challengeNodeData,
        bytes32[] memory logsAcc,
        bytes32[] memory vmProtoStateHashes,
        uint256[] memory messagesLengths,
        bytes memory messages,
        address[] memory stakerAddresses,
        bytes32[] memory stakerProofs,
        uint256[] memory stakerProofOffsets
    )
        public
    {
        return _confirm(ConfirmData(
            initalProtoStateHash,
            branches,
            deadlineTicks,
            challengeNodeData,
            logsAcc,
            vmProtoStateHashes,
            messagesLengths,
            messages,
            stakerAddresses,
            stakerProofs,
            stakerProofOffsets
        ));
    }

    struct ConfirmData {
        bytes32 initalProtoStateHash;
        uint256[] branches;
        uint256[] deadlineTicks;
        bytes32[] challengeNodeData;
        bytes32[] logsAcc;
        bytes32[] vmProtoStateHashes;
        uint256[] messagesLengths;
        bytes messages;
        address[] stakerAddresses;
        bytes32[] stakerProofs;
        uint256[] stakerProofOffsets;
    }

    function _confirm(ConfirmData memory data) private {
        _verifyDataLength(data);

        uint256 nodeCount = data.branches.length;
        bytes32[] memory nodeHashes = new bytes32[](nodeCount);
        uint[] memory messageCounts = new uint[](nodeCount);

        NodeData memory nodeData = _getInitialNodeData(data);
        for (uint256 nodeIndex = 0; nodeIndex < nodeCount; nodeIndex++) {
                ( nodeData, messageCounts[nodeIndex] ) = _computeNodeData(nodeData, nodeIndex, data);
                nodeHashes[nodeIndex] = nodeData.nodeHash;
        }

        require(nodeData.messagesOffset == data.messages.length, "Didn't read all messages");
        // If last node is after deadline, then all nodes are
        require(RollupTime.blocksToTicks(block.number) >= data.deadlineTicks[nodeCount - 1], CONF_TIME);

        uint activeCount = checkAlignedStakers(
            nodeData.nodeHash,
            data.deadlineTicks[nodeCount - 1],
            data.stakerAddresses,
            data.stakerProofs,
            data.stakerProofOffsets
        );
        require(activeCount > 0, CONF_HAS_STAKER);
        confirmNode(nodeData.nodeHash);

        // Send all messages is a single batch
        globalInbox.sendMessages(data.messages, messageCounts, nodeHashes);

        if (nodeData.validNum > 0) {
            emit ConfirmedAssertion(
                data.logsAcc
            );
        }
    }

    struct NodeData {
        uint256 validNum;
        uint256 invalidNum;
        uint256 messagesOffset;
        bytes32 vmProtoStateHash;
        bytes32 nodeHash;
    }

    function _getInitialNodeData(
        ConfirmData memory data
    ) 
        private view returns (NodeData memory)
    {
        return NodeData(
            0,
            0,
            0,
            data.initalProtoStateHash,
            latestConfirmed());
    }

    function _computeNodeData(
        NodeData memory nodeData,
        uint256 nodeIndex,
        ConfirmData memory data
    ) 
        private returns (NodeData memory, uint) 
    {
        uint256 branchType = data.branches[nodeIndex];
        bytes32 nodeDataHash;
        uint msgCount;

        if (branchType == VALID_CHILD_TYPE) {
            bytes32 lastMsgHash;
            uint256 messageLength = data.messagesLengths[nodeData.validNum];
            (lastMsgHash, msgCount) = Protocol.generateLastMessageHash(
                data.messages,
                nodeData.messagesOffset,
                messageLength
            );
            nodeDataHash = RollupUtils.validDataHash(
                lastMsgHash,
                data.logsAcc[nodeData.validNum]
            );
            nodeData.messagesOffset += messageLength;
            nodeData.vmProtoStateHash = data.vmProtoStateHashes[nodeData.validNum];
            nodeData.validNum++;
        } else {
            msgCount = 0;
            nodeDataHash = data.challengeNodeData[nodeData.invalidNum];
            nodeData.invalidNum++;
        }

        nodeData.nodeHash = RollupUtils.childNodeHash(
            nodeData.nodeHash,
            data.deadlineTicks[nodeIndex],
            nodeDataHash,
            branchType,
            nodeData.vmProtoStateHash
        );

        if (branchType == VALID_CHILD_TYPE) {
            emit ConfirmedValidAssertion(nodeData.nodeHash);
        }
        
        return (nodeData, msgCount);
    }

    function _verifyDataLength(ConfirmData memory data) private pure{
        uint256 nodeCount = data.branches.length;
        uint256 validNodeCount = data.messagesLengths.length;
        require(data.vmProtoStateHashes.length == validNodeCount);
        require(data.logsAcc.length == validNodeCount);
        require(data.deadlineTicks.length == nodeCount);
        require(data.challengeNodeData.length == nodeCount - validNodeCount);
    }
}
