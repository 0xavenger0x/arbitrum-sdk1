/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from 'ethers'
import { Provider } from '@ethersproject/providers'
import type { IRollupAdmin, IRollupAdminInterface } from '../IRollupAdmin'

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'uint256',
        name: 'id',
        type: 'uint256',
      },
    ],
    name: 'OwnerFunctionCalled',
    type: 'event',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'nodeNum',
        type: 'uint256',
      },
      {
        internalType: 'bytes32',
        name: 'beforeSendAcc',
        type: 'bytes32',
      },
      {
        internalType: 'bytes',
        name: 'sendsData',
        type: 'bytes',
      },
      {
        internalType: 'uint256[]',
        name: 'sendLengths',
        type: 'uint256[]',
      },
      {
        internalType: 'uint256',
        name: 'afterSendCount',
        type: 'uint256',
      },
      {
        internalType: 'bytes32',
        name: 'afterLogAcc',
        type: 'bytes32',
      },
      {
        internalType: 'uint256',
        name: 'afterLogCount',
        type: 'uint256',
      },
    ],
    name: 'forceConfirmNode',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bytes32',
        name: 'expectedNodeHash',
        type: 'bytes32',
      },
      {
        internalType: 'bytes32[3][2]',
        name: 'assertionBytes32Fields',
        type: 'bytes32[3][2]',
      },
      {
        internalType: 'uint256[4][2]',
        name: 'assertionIntFields',
        type: 'uint256[4][2]',
      },
      {
        internalType: 'bytes',
        name: 'sequencerBatchProof',
        type: 'bytes',
      },
      {
        internalType: 'uint256',
        name: 'beforeProposedBlock',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'beforeInboxMaxCount',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'prevNode',
        type: 'uint256',
      },
    ],
    name: 'forceCreateNode',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address[]',
        name: 'stacker',
        type: 'address[]',
      },
    ],
    name: 'forceRefundStaker',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address[]',
        name: 'stackerA',
        type: 'address[]',
      },
      {
        internalType: 'address[]',
        name: 'stackerB',
        type: 'address[]',
      },
    ],
    name: 'forceResolveChallenge',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'pause',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: '_outbox',
        type: 'address',
      },
    ],
    name: 'removeOldOutbox',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'resume',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'newArbGasSpeedLimitPerBlock',
        type: 'uint256',
      },
    ],
    name: 'setArbGasSpeedLimitPerBlock',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'newBaseStake',
        type: 'uint256',
      },
    ],
    name: 'setBaseStake',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'newChallengeExecutionBisectionDegree',
        type: 'uint256',
      },
    ],
    name: 'setChallengeExecutionBisectionDegree',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'newConfirmPeriod',
        type: 'uint256',
      },
    ],
    name: 'setConfirmPeriodBlocks',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'newExtraTimeBlocks',
        type: 'uint256',
      },
    ],
    name: 'setExtraChallengeTimeBlocks',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'newAdminFacet',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'newUserFacet',
        type: 'address',
      },
    ],
    name: 'setFacets',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: '_inbox',
        type: 'address',
      },
      {
        internalType: 'bool',
        name: '_enabled',
        type: 'bool',
      },
    ],
    name: 'setInbox',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'newPeriod',
        type: 'uint256',
      },
    ],
    name: 'setMinimumAssertionPeriod',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IOutbox',
        name: '_outbox',
        type: 'address',
      },
    ],
    name: 'setOutbox',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'newOwner',
        type: 'address',
      },
    ],
    name: 'setOwner',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'newSequencer',
        type: 'address',
      },
    ],
    name: 'setSequencer',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'newSequencerInboxMaxDelayBlocks',
        type: 'uint256',
      },
    ],
    name: 'setSequencerInboxMaxDelayBlocks',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'newSequencerInboxMaxDelaySeconds',
        type: 'uint256',
      },
    ],
    name: 'setSequencerInboxMaxDelaySeconds',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'newStakeToken',
        type: 'address',
      },
    ],
    name: 'setStakeToken',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address[]',
        name: '_validator',
        type: 'address[]',
      },
      {
        internalType: 'bool[]',
        name: '_val',
        type: 'bool[]',
      },
    ],
    name: 'setValidator',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'whitelist',
        type: 'address',
      },
      {
        internalType: 'address[]',
        name: 'user',
        type: 'address[]',
      },
      {
        internalType: 'bool[]',
        name: 'val',
        type: 'bool[]',
      },
    ],
    name: 'setWhitelistEntries',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'whitelist',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'newWhitelist',
        type: 'address',
      },
      {
        internalType: 'address[]',
        name: 'targets',
        type: 'address[]',
      },
    ],
    name: 'updateWhitelistConsumers',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'beacon',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'newImplementation',
        type: 'address',
      },
    ],
    name: 'upgradeBeacon',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
]

export class IRollupAdmin__factory {
  static readonly abi = _abi
  static createInterface(): IRollupAdminInterface {
    return new utils.Interface(_abi) as IRollupAdminInterface
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IRollupAdmin {
    return new Contract(address, _abi, signerOrProvider) as IRollupAdmin
  }
}
