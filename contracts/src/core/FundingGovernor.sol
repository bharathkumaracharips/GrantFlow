// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {GovernanceTimelock} from "./GovernanceTimelock.sol";
import {Errors} from "../libraries/Errors.sol";

/// @title FundingGovernor
/// @notice Decentralized proposal, voting, and timelocked execution for the Quadratic Funding protocol
contract FundingGovernor {
    enum ProposalState {
        Pending,
        Active,
        Defeated,
        Succeeded,
        Queued,
        Executed,
        Cancelled
    }

    struct Proposal {
        uint256 id;
        address proposer;
        address target;
        uint256 value;
        string signature;
        bytes data;
        uint64 startTime;
        uint64 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 eta;
        bool executed;
        bool cancelled;
    }

    GovernanceTimelock public immutable timelock;
    uint256 public constant VOTING_PERIOD = 3 days;
    uint256 public constant QUORUM_VOTES = 100_000 * 1e18;
    uint256 public nextProposalId = 1;

    mapping(uint256 => Proposal) private _proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(address => uint256) public votingPower;

    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, address target, string description);
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support, uint256 weight);
    event ProposalQueued(uint256 indexed proposalId, uint256 eta);
    event ProposalExecuted(uint256 indexed proposalId);

    constructor(address payable _timelock) {
        if (_timelock == address(0)) revert Errors.ZeroAddress();
        timelock = GovernanceTimelock(_timelock);
    }

    function setVotingPower(address voter, uint256 power) external {
        // Admin or token contract sets voting power
        require(msg.sender == address(timelock) || votingPower[msg.sender] > 0, "Unauthorized");
        votingPower[voter] = power;
    }

    function propose(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        string memory description
    ) external returns (uint256 proposalId) {
        proposalId = nextProposalId++;
        _proposals[proposalId] = Proposal({
            id: proposalId,
            proposer: msg.sender,
            target: target,
            value: value,
            signature: signature,
            data: data,
            startTime: uint64(block.timestamp),
            endTime: uint64(block.timestamp + VOTING_PERIOD),
            forVotes: 0,
            againstVotes: 0,
            eta: 0,
            executed: false,
            cancelled: false
        });

        emit ProposalCreated(proposalId, msg.sender, target, description);
    }

    function castVote(uint256 proposalId, bool support) external {
        Proposal storage proposal = _proposals[proposalId];
        require(block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime, "Voting not active");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        uint256 weight = votingPower[msg.sender];
        if (weight == 0) weight = 1e18; // Default 1 vote if unconfigured

        hasVoted[proposalId][msg.sender] = true;
        if (support) {
            proposal.forVotes += weight;
        } else {
            proposal.againstVotes += weight;
        }

        emit VoteCast(msg.sender, proposalId, support, weight);
    }

    function queue(uint256 proposalId) external {
        Proposal storage proposal = _proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(proposal.forVotes > proposal.againstVotes, "Proposal defeated");
        require(proposal.eta == 0, "Already queued");

        uint256 eta = block.timestamp + timelock.delay();
        proposal.eta = eta;

        timelock.queueTransaction(proposal.target, proposal.value, proposal.signature, proposal.data, eta);
        emit ProposalQueued(proposalId, eta);
    }

    function execute(uint256 proposalId) external payable {
        Proposal storage proposal = _proposals[proposalId];
        require(proposal.eta > 0 && block.timestamp >= proposal.eta, "Not ready");
        require(!proposal.executed, "Already executed");

        proposal.executed = true;
        timelock.executeTransaction{value: proposal.value}(
            proposal.target,
            proposal.value,
            proposal.signature,
            proposal.data,
            proposal.eta
        );

        emit ProposalExecuted(proposalId);
    }

    function getProposal(uint256 proposalId) external view returns (Proposal memory) {
        return _proposals[proposalId];
    }
}
