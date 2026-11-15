export interface Project {
  id: bigint;
  owner: `0x${string}`;
  payoutAddress: `0x${string}`;
  metadataCid: string;
  status: 'Pending' | 'Approved' | 'Suspended' | 'Rejected';
}

export interface RoundConfig {
  id: bigint;
  title: string;
  token: `0x${string}`;
  regStartTime: bigint;
  regEndTime: bigint;
  roundStartTime: bigint;
  roundEndTime: bigint;
  minDonation: bigint;
  maxDonation: bigint;
  maxMatchingCapBps: bigint;
  state: 'Created' | 'Registration' | 'Active' | 'Ended' | 'Calculation' | 'Finalized' | 'Cancelled';
}

export interface Contribution {
  donor: `0x${string}`;
  identityNullifier: `0x${string}`;
  projectId: bigint;
  amount: bigint;
}

export interface MatchingEstimate {
  projectId: bigint;
  directTotal: bigint;
  matchingDemand: bigint;
  estimatedMatching: bigint;
  uniqueContributors: number;
}
