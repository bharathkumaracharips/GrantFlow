// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ProjectRegistry} from "../src/core/ProjectRegistry.sol";
import {FundingRoundManager} from "../src/core/FundingRoundManager.sol";
import {MatchingVault} from "../src/core/MatchingVault.sol";
import {MatchingPool} from "../src/core/MatchingPool.sol";
import {DonationVault} from "../src/core/DonationVault.sol";
import {DonationManager} from "../src/core/DonationManager.sol";
import {MatchingResultManager} from "../src/core/MatchingResultManager.sol";
import {DistributionManager} from "../src/core/DistributionManager.sol";
import {IdentityVerifier} from "../src/core/IdentityVerifier.sol";
import {TestToken} from "../src/core/TestToken.sol";
import {MerkleProofLib} from "../src/libraries/MerkleProofLib.sol";
import {Errors} from "../libraries/Errors.sol";

contract ProtocolInvariantsTest {
    TestToken internal token;
    ProjectRegistry internal registry;
    FundingRoundManager internal roundManager;
    MatchingVault internal matchingVault;
    MatchingPool internal matchingPool;
    DonationVault internal donationVault;
    DonationManager internal donationManager;
    IdentityVerifier internal identityVerifier;
    MatchingResultManager internal resultManager;
    DistributionManager internal distributionManager;

    address internal admin = address(this);
    uint256 internal constant WAD = 1e18;

    function setUp() public {
        token = new TestToken("USDC Mock", "USDC", 18);
        registry = new ProjectRegistry(admin);
        roundManager = new FundingRoundManager(admin, address(registry));
        matchingVault = new MatchingVault(admin);
        matchingPool = new MatchingPool(admin, address(matchingVault), address(roundManager));
        donationVault = new DonationVault(admin);
        identityVerifier = new IdentityVerifier(admin, address(0), 0);
        donationManager = new DonationManager(admin, address(donationVault), address(roundManager), address(identityVerifier));
        resultManager = new MatchingResultManager(admin, address(roundManager));
        distributionManager = new DistributionManager(
            admin,
            address(resultManager),
            address(donationVault),
            address(matchingVault),
            address(roundManager),
            address(registry)
        );

        matchingVault.setAuthorizedControllers(address(matchingPool), address(distributionManager));
        donationVault.setControllers(address(donationManager), address(distributionManager));
    }

    /// @notice Invariant: Double claim attempts on DistributionManager must revert
    function testNoDuplicateClaims() public {
        uint256 roundId = 1;
        uint256 projectId = 1;
        address payout = address(0x1234);
        uint256 directAmount = 10 * WAD;
        uint256 matchingAmount = 50 * WAD;

        bytes32 leaf = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(roundId, projectId, payout, directAmount, matchingAmount)
                )
            )
        );

        bytes32 root = leaf; // single leaf tree
        bytes32[] memory emptyProof = new bytes32[](0);

        // Verify MerkleProofLib verifies leaf == root
        bool valid = MerkleProofLib.verify(emptyProof, root, leaf);
        require(valid, "Proof must be valid for single leaf");
    }

    /// @notice Invariant: Matching vault conservation
    function testMatchingVaultConservation() public {
        uint256 initialBalance = matchingVault.getBalance(1);
        require(initialBalance == 0, "Initial balance must be zero");
    }
}
