import { createPublicClient, http, Address, Hash } from 'viem';
import { sepolia } from 'viem/chains';

export interface ProtocolDeploymentConfig {
  projectRegistry: Address;
  fundingRoundManager: Address;
  donationManager: Address;
  matchingPool: Address;
  matchingResultManager: Address;
  distributionManager: Address;
  disputeManager: Address;
}

export class QuadraticFundingClient {
  public publicClient;
  public config: ProtocolDeploymentConfig;

  constructor(rpcUrl: string, config: ProtocolDeploymentConfig) {
    this.config = config;
    this.publicClient = createPublicClient({
      chain: sepolia,
      transport: http(rpcUrl),
    });
  }

  public getAddresses(): ProtocolDeploymentConfig {
    return this.config;
  }
}
