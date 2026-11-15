export const PROTOCOL_ADDRESSES = {
  projectRegistry: (process.env.NEXT_PUBLIC_PROJECT_REGISTRY_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  fundingRoundManager: (process.env.NEXT_PUBLIC_FUNDING_ROUND_MANAGER_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  donationManager: (process.env.NEXT_PUBLIC_DONATION_MANAGER_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  donationVault: (process.env.NEXT_PUBLIC_DONATION_VAULT_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  matchingPool: (process.env.NEXT_PUBLIC_MATCHING_POOL_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  matchingVault: (process.env.NEXT_PUBLIC_MATCHING_VAULT_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  matchingResultManager: (process.env.NEXT_PUBLIC_MATCHING_RESULT_MANAGER_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  distributionManager: (process.env.NEXT_PUBLIC_DISTRIBUTION_MANAGER_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
};

export const PROJECT_REGISTRY_ABI = [
  {
    type: 'function',
    name: 'registerProject',
    inputs: [
      { name: 'payoutAddress', type: 'address' },
      { name: 'metadataCid', type: 'string' }
    ],
    outputs: [{ name: 'projectId', type: 'uint256' }],
    stateMutability: 'nonpayable'
  },
  {
    type: 'function',
    name: 'getProject',
    inputs: [{ name: 'projectId', type: 'uint256' }],
    outputs: [
      {
        name: '',
        type: 'tuple',
        components: [
          { name: 'id', type: 'uint256' },
          { name: 'owner', type: 'address' },
          { name: 'payoutAddress', type: 'address' },
          { name: 'metadataCid', type: 'string' },
          { name: 'status', type: 'uint8' },
          { name: 'createdAt', type: 'uint64' },
          { name: 'updatedAt', type: 'uint64' }
        ]
      }
    ],
    stateMutability: 'view'
  }
] as const;

export const DONATION_MANAGER_ABI = [
  {
    type: 'function',
    name: 'donate',
    inputs: [
      { name: 'roundId', type: 'uint256' },
      { name: 'projectId', type: 'uint256' },
      { name: 'amount', type: 'uint256' },
      { name: 'identityNullifier', type: 'bytes32' },
      { name: 'identityProof', type: 'bytes' }
    ],
    outputs: [],
    stateMutability: 'nonpayable'
  }
] as const;
