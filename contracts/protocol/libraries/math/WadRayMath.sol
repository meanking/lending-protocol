// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library WadRayMath {
    uint256 internal constant WAD = 1e18;
    uint256 internal constant halfWAD = WAD / 2;

    uint256 internal constant RAY = 1e27;
    uint256 internal constant halfRAY = RAY / 2;

    uint256 internal constant WAD_RAY_RATIO = 1e9;

    /// @return Oneray, 1e27
    function ray() internal pure returns (uint256) {
        return RAY;
    }

    function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }

        require(a <= (type(uint256).max - halfRAY) / b, "ERROR: Multiplication overflow");

        return (a * b + halfRAY) / RAY;
    } 
}