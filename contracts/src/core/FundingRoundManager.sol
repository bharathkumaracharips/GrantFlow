// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IFundingRoundManager} from "../interfaces/IFundingRoundManager.sol";
import {IProjectRegistry} from "../interfaces/IProjectRegistry.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {ProtocolConstants} from "../libraries/ProtocolConstants.sol";

/// @title FundingRoundManager
/// @notice Manages lifecycle, schedules, enrollment, and parameters for quadratic funding rounds
contract FundingRoundManager is IFundingRoundManager {
    address public admin;
    IProjectRegistry public immutable projectRegistry;
    uint256 public nextRoundId = 1;

    mapping(uint256 => RoundConfig) private _rounds;
    mapping(uint256 => mapping(uint256 => bool)) private _roundProjects;
    mapping(address => bool) public roundOperators;

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    modifier onlyAdminOrOperator() {
        if (msg.sender != admin && !roundOperators[msg.sender]) revert Errors.Unauthorized();
        _;
    }

    constructor(address _admin, address _registry) {
        if (_admin == address(0) || _registry == address(0)) revert Errors.ZeroAddress();
        admin = _admin;
        projectRegistry = IProjectRegistry(_registry);
    }

    function setRoundOperator(address operator, bool allowed) external onlyAdmin {
        roundOperators[operator] = allowed;
    }

    function createRound(
        string calldata title,
        address token,
        uint64 regStart,
        uint64 regEnd,
        uint64 roundStart,
        uint64 roundEnd,
        uint256 minDonation,
        uint256 maxDonation,
        uint256 maxMatchingCapBps
    ) external override onlyAdminOrOperator returns (uint256 roundId) {
        if (token == address(0)) revert Errors.ZeroAddress();
        if (bytes(title).length == 0) revert Errors.ZeroAmount();
        if (regStart >= regEnd || regEnd > roundStart || roundStart >= roundEnd) {
            revert Errors.InvalidTimestamps();
        }
        if (minDonation > maxDonation && maxDonation > 0) revert Errors.DonationTooHigh();
        if (maxMatchingCapBps > ProtocolConstants.BPS_DENOMINATOR) revert Errors.FeeTooHigh();

        roundId = nextRoundId++;
        _rounds[roundId] = RoundConfig({
            id: roundId,
            title: title,
            token: token,
            regStartTime: regStart,
            regEndTime: regEnd,
            roundStartTime: roundStart,
            roundEndTime: roundEnd,
            minDonation: minDonation,
            maxDonation: maxDonation,
            maxMatchingCapBps: maxMatchingCapBps,
            state: RoundState.Registration
        });

        emit Events.RoundCreated(roundId, title, token, regStart, regEnd, roundStart, roundEnd);
    }

    function enrollProject(uint256 roundId, uint256 projectId) external override {
        RoundConfig storage round = _rounds[roundId];
        if (round.id == 0) revert Errors.RoundNotActive();
        if (block.timestamp < round.regStartTime || block.timestamp > round.regEndTime) {
            revert Errors.InvalidTimestamps();
        }
        if (!projectRegistry.isProjectApproved(projectId)) revert Errors.ProjectNotApproved();
        if (_roundProjects[roundId][projectId]) revert Errors.ProjectAlreadyRegistered();

        _roundProjects[roundId][projectId] = true;
        emit Events.ProjectEnrolledInRound(roundId, projectId);
    }

    function setRoundState(uint256 roundId, RoundState newState) external override onlyAdminOrOperator {
        RoundConfig storage round = _rounds[roundId];
        if (round.id == 0) revert Errors.RoundNotActive();
        round.state = newState;
        emit Events.RoundStateChanged(roundId, uint8(newState));
    }

    function getRound(uint256 roundId) external view override returns (RoundConfig memory) {
        return _rounds[roundId];
    }

    function isProjectEnrolled(uint256 roundId, uint256 projectId) external view override returns (bool) {
        return _roundProjects[roundId][projectId];
    }

    function isDonationPeriodActive(uint256 roundId) external view override returns (bool) {
        RoundConfig storage round = _rounds[roundId];
        if (round.state == RoundState.Cancelled) return false;
        return block.timestamp >= round.roundStartTime && block.timestamp <= round.roundEndTime;
    }
}
