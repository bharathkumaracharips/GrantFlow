// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FixedPointMath} from "../libraries/FixedPointMath.sol";

/// @title MatchingCalculator
/// @notice On-chain reference implementation of Quadratic Funding calculation logic
contract MatchingCalculator {
    using FixedPointMath for uint256;

    struct ProjectInput {
        uint256 projectId;
        uint256[] contributions; // WAD amounts per unique identity
    }

    struct ProjectScore {
        uint256 projectId;
        uint256 directTotal;
        uint256 matchingDemand;
        uint256 matchingAllocation;
    }

    /// @notice Calculates the matching demand for a single project
    function calculateProjectMatchingDemand(uint256[] calldata contributions) public pure returns (uint256 directTotal, uint256 matchingDemand) {
        if (contributions.length == 0) return (0, 0);

        uint256 sumSqrt = 0;
        for (uint256 i = 0; i < contributions.length; i++) {
            directTotal += contributions[i];
            sumSqrt += contributions[i].sqrtWad();
        }

        // Raw score = (sumSqrt)^2 in WAD
        uint256 rawScore = sumSqrt.mulWad(sumSqrt);
        if (rawScore > directTotal) {
            matchingDemand = rawScore - directTotal;
        } else {
            matchingDemand = 0;
        }
    }

    /// @notice Allocates a fixed matching pool proportionally across projects with an optional max cap
    function calculateAllocations(
        ProjectInput[] calldata inputs,
        uint256 matchingPoolTotal,
        uint256 maxMatchingCapBps
    ) external pure returns (ProjectScore[] memory results) {
        uint256 n = inputs.length;
        results = new ProjectScore[](n);
        if (n == 0 || matchingPoolTotal == 0) return results;

        uint256 totalDemand = 0;
        for (uint256 i = 0; i < n; i++) {
            (uint256 direct, uint256 demand) = calculateProjectMatchingDemand(inputs[i].contributions);
            results[i].projectId = inputs[i].projectId;
            results[i].directTotal = direct;
            results[i].matchingDemand = demand;
            totalDemand += demand;
        }

        if (totalDemand == 0) return results;

        uint256 cap = maxMatchingCapBps > 0 ? (matchingPoolTotal * maxMatchingCapBps) / 10_000 : matchingPoolTotal;
        uint256 distributed = 0;

        for (uint256 i = 0; i < n; i++) {
            if (results[i].matchingDemand > 0) {
                uint256 share = (matchingPoolTotal * results[i].matchingDemand) / totalDemand;
                if (share > cap) {
                    share = cap;
                }
                results[i].matchingAllocation = share;
                distributed += share;
            }
        }

        // Reconcile dust if any remains
        if (distributed < matchingPoolTotal && distributed > 0) {
            uint256 dust = matchingPoolTotal - distributed;
            results[0].matchingAllocation += dust;
        }
    }
}
