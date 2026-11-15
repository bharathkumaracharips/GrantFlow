// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MatchingCalculator} from "../src/core/MatchingCalculator.sol";
import {FixedPointMath} from "../src/libraries/FixedPointMath.sol";

contract MatchingCalculatorTest {
    MatchingCalculator internal calculator;
    uint256 internal constant WAD = 1e18;

    function setUp() public {
        calculator = new MatchingCalculator();
    }

    function testSingleContributorZeroMatching() public {
        uint256[] memory contributions = new uint256[](1);
        contributions[0] = 100 * WAD;

        (uint256 direct, uint256 demand) = calculator.calculateProjectMatchingDemand(contributions);
        require(direct == 100 * WAD, "direct mismatch");
        require(demand == 0, "single contributor should have 0 matching demand");
    }

    function testMultipleContributorsQuadraticGain() public {
        // 10 contributors donating 1 WAD each
        uint256[] memory contributions = new uint256[](10);
        for (uint256 i = 0; i < 10; i++) {
            contributions[i] = 1 * WAD;
        }

        (uint256 direct, uint256 demand) = calculator.calculateProjectMatchingDemand(contributions);
        require(direct == 10 * WAD, "direct should be 10 WAD");
        // sum(sqrt(1)) = 10. (10)^2 = 100 WAD. demand = 100 - 10 = 90 WAD.
        require(demand == 90 * WAD, "demand should be 90 WAD");
    }

    function testAllocationConservation() public {
        MatchingCalculator.ProjectInput[] memory inputs = new MatchingCalculator.ProjectInput[](2);

        // Project 1: 5 donors x 1 WAD -> demand = (5)^2 - 5 = 20 WAD
        inputs[0].projectId = 1;
        inputs[0].contributions = new uint256[](5);
        for (uint256 i = 0; i < 5; i++) {
            inputs[0].contributions[i] = 1 * WAD;
        }

        // Project 2: 3 donors x 1 WAD -> demand = (3)^2 - 3 = 6 WAD
        inputs[1].projectId = 2;
        inputs[1].contributions = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            inputs[1].contributions[i] = 1 * WAD;
        }

        uint256 pool = 1000 * WAD;
        MatchingCalculator.ProjectScore[] memory results = calculator.calculateAllocations(inputs, pool, 5000);

        uint256 totalAllocated = results[0].matchingAllocation + results[1].matchingAllocation;
        require(totalAllocated == pool, "Total allocated must strictly equal pool");
    }
}
