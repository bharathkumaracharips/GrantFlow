// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title FixedPointMath
/// @notice Arithmetic operations on fixed-point numbers with 18 decimals (WAD)
library FixedPointMath {
    uint256 internal constant WAD = 1e18;
    uint256 internal constant HALF_WAD = 0.5e18;

    error DivisionByZero();
    error MulOverflow();

    /// @notice Multiplies two WAD numbers with rounding to nearest
    function mulWad(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0 || y == 0) return 0;
        return (x * y + HALF_WAD) / WAD;
    }

    /// @notice Divides two WAD numbers with rounding to nearest
    function divWad(uint256 x, uint256 y) internal pure returns (uint256) {
        if (y == 0) revert DivisionByZero();
        return (x * WAD + (y / 2)) / y;
    }

    /// @notice Calculates the integer square root of a WAD value using the Babylonian method
    /// @dev sqrt(x * 1e18) returned as WAD (scaled by 1e18)
    function sqrtWad(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        // x * 1e18 to preserve precision after sqrt
        uint256 xx = x * WAD;
        uint256 z = (xx + 1) / 2;
        uint256 y = xx;
        while (z < y) {
            y = z;
            z = (xx / z + z) / 2;
        }
        return y;
    }

    /// @notice Standard integer square root for unscaled numbers
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}
