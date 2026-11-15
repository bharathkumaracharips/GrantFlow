// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IMatchingPool} from "../interfaces/IMatchingPool.sol";
import {IMatchingVault} from "../interfaces/IMatchingVault.sol";
import {IFundingRoundManager} from "../interfaces/IFundingRoundManager.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";

interface IERC20Approve {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title MatchingPool
/// @notice Handles sponsor deposits, accounting, and escrow interactions with MatchingVault
contract MatchingPool is IMatchingPool {
    address public admin;
    IMatchingVault public immutable matchingVault;
    IFundingRoundManager public immutable roundManager;

    mapping(uint256 => uint256) private _roundMatchingTotal;
    mapping(uint256 => mapping(address => uint256)) private _sponsorBalances;
    mapping(uint256 => address[]) private _roundSponsors;

    constructor(address _admin, address _vault, address _roundManager) {
        if (_admin == address(0) || _vault == address(0) || _roundManager == address(0)) {
            revert Errors.ZeroAddress();
        }
        admin = _admin;
        matchingVault = IMatchingVault(_vault);
        roundManager = IFundingRoundManager(_roundManager);
    }

    function depositMatchingFunds(uint256 roundId, uint256 amount) external override {
        if (amount == 0) revert Errors.ZeroAmount();
        IFundingRoundManager.RoundConfig memory round = roundManager.getRound(roundId);
        if (round.id == 0 || round.state == IFundingRoundManager.RoundState.Cancelled) {
            revert Errors.RoundNotActive();
        }

        if (_sponsorBalances[roundId][msg.sender] == 0) {
            _roundSponsors[roundId].push(msg.sender);
        }

        _sponsorBalances[roundId][msg.sender] += amount;
        _roundMatchingTotal[roundId] += amount;

        // Pull funds into this contract first, approve vault, then deposit
        bool pulled = IERC20Approve(round.token).transferFrom(msg.sender, address(this), amount);
        if (!pulled) revert Errors.TransferFailed();

        IERC20Approve(round.token).approve(address(matchingVault), amount);
        matchingVault.depositFunds(roundId, round.token, amount);

        emit Events.MatchingDeposited(roundId, msg.sender, amount);
    }

    function refundSponsorsIfCancelled(uint256 roundId) external override {
        IFundingRoundManager.RoundConfig memory round = roundManager.getRound(roundId);
        if (round.state != IFundingRoundManager.RoundState.Cancelled) {
            revert Errors.InvalidStateTransition();
        }

        uint256 sponsorAmount = _sponsorBalances[roundId][msg.sender];
        if (sponsorAmount == 0) revert Errors.ZeroAmount();

        _sponsorBalances[roundId][msg.sender] = 0;
        _roundMatchingTotal[roundId] -= sponsorAmount;

        matchingVault.releaseFunds(roundId, round.token, msg.sender, sponsorAmount);
        emit Events.MatchingWithdrawn(roundId, msg.sender, sponsorAmount);
    }

    function getRoundMatchingBalance(uint256 roundId) external view override returns (uint256) {
        return _roundMatchingTotal[roundId];
    }

    function getSponsorBalance(uint256 roundId, address sponsor) external view returns (uint256) {
        return _sponsorBalances[roundId][sponsor];
    }
}
