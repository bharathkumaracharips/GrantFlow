// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IDonationManager} from "../interfaces/IDonationManager.sol";
import {IDonationVault} from "../interfaces/IDonationVault.sol";
import {IFundingRoundManager} from "../interfaces/IFundingRoundManager.sol";
import {IIdentityVerifier} from "../interfaces/IIdentityVerifier.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";

interface IERC20Transfer {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title DonationManager
/// @notice Processes donor contributions, validates identity nullifiers, and deposits into DonationVault
contract DonationManager is IDonationManager {
    address public admin;
    IDonationVault public immutable donationVault;
    IFundingRoundManager public immutable roundManager;
    IIdentityVerifier public identityVerifier;

    // roundId => projectId => total donations
    mapping(uint256 => mapping(uint256 => uint256)) private _projectTotals;
    // roundId => projectId => donor nullifier => contributed
    mapping(uint256 => mapping(uint256 => mapping(bytes32 => bool))) private _nullifierDonated;
    // roundId => projectId => unique donor count
    mapping(uint256 => mapping(uint256 => uint256)) private _projectDonorCount;

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    constructor(address _admin, address _vault, address _roundManager, address _verifier) {
        if (_admin == address(0) || _vault == address(0) || _roundManager == address(0)) {
            revert Errors.ZeroAddress();
        }
        admin = _admin;
        donationVault = IDonationVault(_vault);
        roundManager = IFundingRoundManager(_roundManager);
        identityVerifier = IIdentityVerifier(_verifier);
    }

    function setIdentityVerifier(address _verifier) external onlyAdmin {
        identityVerifier = IIdentityVerifier(_verifier);
    }

    function donate(
        uint256 roundId,
        uint256 projectId,
        uint256 amount,
        bytes32 identityNullifier,
        bytes calldata identityProof
    ) external override {
        if (amount == 0) revert Errors.ZeroAmount();
        if (identityNullifier == bytes32(0)) revert Errors.InvalidIdentityNullifier();

        IFundingRoundManager.RoundConfig memory round = roundManager.getRound(roundId);
        if (!roundManager.isDonationPeriodActive(roundId)) revert Errors.RoundNotActive();
        if (!roundManager.isProjectEnrolled(roundId, projectId)) revert Errors.ProjectNotApproved();

        if (round.minDonation > 0 && amount < round.minDonation) revert Errors.DonationTooLow();
        if (round.maxDonation > 0 && amount > round.maxDonation) revert Errors.DonationTooHigh();

        // Verify Sybil resistance identity if verifier is configured
        if (address(identityVerifier) != address(0)) {
            (bool isValid, ) = identityVerifier.verifyIdentity(msg.sender, identityNullifier, identityProof);
            if (!isValid) revert Errors.InactiveIdentity();
        }

        if (!_nullifierDonated[roundId][projectId][identityNullifier]) {
            _nullifierDonated[roundId][projectId][identityNullifier] = true;
            _projectDonorCount[roundId][projectId] += 1;
        }

        _projectTotals[roundId][projectId] += amount;

        // Pull tokens from donor into this contract, approve vault, then deposit
        bool success = IERC20Transfer(round.token).transferFrom(msg.sender, address(this), amount);
        if (!success) revert Errors.TransferFailed();

        IERC20Transfer(round.token).approve(address(donationVault), amount);
        donationVault.deposit(roundId, projectId, round.token, amount);

        emit Events.DonationSubmitted(roundId, projectId, msg.sender, identityNullifier, amount);
    }

    function getDonationTotal(uint256 roundId, uint256 projectId) external view override returns (uint256) {
        return _projectTotals[roundId][projectId];
    }

    function getDonorCount(uint256 roundId, uint256 projectId) external view override returns (uint256) {
        return _projectDonorCount[roundId][projectId];
    }
}
