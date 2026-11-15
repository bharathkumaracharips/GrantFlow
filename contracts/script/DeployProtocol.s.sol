// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TestToken} from "../src/core/TestToken.sol";
import {ProjectRegistry} from "../src/core/ProjectRegistry.sol";
import {FundingRoundManager} from "../src/core/FundingRoundManager.sol";
import {MatchingVault} from "../src/core/MatchingVault.sol";
import {MatchingPool} from "../src/core/MatchingPool.sol";
import {DonationVault} from "../src/core/DonationVault.sol";
import {DonationManager} from "../src/core/DonationManager.sol";
import {IdentityVerifier} from "../src/core/IdentityVerifier.sol";
import {MatchingResultManager} from "../src/core/MatchingResultManager.sol";
import {DistributionManager} from "../src/core/DistributionManager.sol";
import {GovernanceTimelock} from "../src/core/GovernanceTimelock.sol";
import {FundingGovernor} from "../src/core/FundingGovernor.sol";
import {ProjectReviewManager} from "../src/core/ProjectReviewManager.sol";
import {DisputeManager} from "../src/core/DisputeManager.sol";

contract DeployProtocol {
    struct ProtocolDeployment {
        address token;
        address projectRegistry;
        address fundingRoundManager;
        address matchingVault;
        address matchingPool;
        address donationVault;
        address identityVerifier;
        address donationManager;
        address matchingResultManager;
        address distributionManager;
        address governanceTimelock;
        address fundingGovernor;
        address projectReviewManager;
        address disputeManager;
    }

    function run(address deployer) external returns (ProtocolDeployment memory d) {
        // 1. Deploy Test Payment Token
        TestToken token = new TestToken("USDC Mock", "USDC", 18);
        d.token = address(token);

        // 2. Deploy Registries and Lifecycle Managers
        ProjectRegistry registry = new ProjectRegistry(deployer);
        d.projectRegistry = address(registry);

        FundingRoundManager roundManager = new FundingRoundManager(deployer, address(registry));
        d.fundingRoundManager = address(roundManager);

        // 3. Deploy Vaults
        MatchingVault matchingVault = new MatchingVault(deployer);
        d.matchingVault = address(matchingVault);

        MatchingPool matchingPool = new MatchingPool(deployer, address(matchingVault), address(roundManager));
        d.matchingPool = address(matchingPool);

        DonationVault donationVault = new DonationVault(deployer);
        d.donationVault = address(donationVault);

        IdentityVerifier identityVerifier = new IdentityVerifier(deployer, address(0), 0);
        d.identityVerifier = address(identityVerifier);

        DonationManager donationManager = new DonationManager(
            deployer,
            address(donationVault),
            address(roundManager),
            address(identityVerifier)
        );
        d.donationManager = address(donationManager);

        // 4. Deploy Optimistic Matching Result & Distribution Managers
        MatchingResultManager resultManager = new MatchingResultManager(deployer, address(roundManager));
        d.matchingResultManager = address(resultManager);

        DistributionManager distributionManager = new DistributionManager(
            deployer,
            address(resultManager),
            address(donationVault),
            address(matchingVault),
            address(roundManager),
            address(registry)
        );
        d.distributionManager = address(distributionManager);

        // 5. Wire Vault Access Permissions
        matchingVault.setAuthorizedControllers(address(matchingPool), address(distributionManager));
        donationVault.setControllers(address(donationManager), address(distributionManager));

        // 6. Deploy Governance & Review/Dispute Modules
        GovernanceTimelock timelock = new GovernanceTimelock(deployer, 2 days);
        d.governanceTimelock = address(timelock);

        FundingGovernor governor = new FundingGovernor(payable(address(timelock)));
        d.fundingGovernor = address(governor);

        ProjectReviewManager reviewManager = new ProjectReviewManager(deployer, address(registry));
        d.projectReviewManager = address(reviewManager);

        DisputeManager disputeManager = new DisputeManager(deployer, address(registry));
        d.disputeManager = address(disputeManager);

        // Grant review manager permissions in registry
        registry.setReviewer(address(reviewManager), true);
    }
}
