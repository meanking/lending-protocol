// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title PercentageMath library
 * @notice Provides functions to perform percentage calculations
 * @dev Percentages are defined by default with 2 decimals of precision (100.00). The precision is indicated by PERCENTAGE_FACTOR
 * @dev Operations are rounded half up
 */
library PercentageMath {
    uint256 constant public PERCENTAGE_FACTOR = 1e4;
    uint256 constant public HALF_PERCENT = PERCENTAGE_FACTOR / 2;

    /**
     * @dev Executes a percentage multiplication
     * @param _value The value of which the percentage needs to be calculated
     * @param _percentage THe percentage of the value to be calculated
     * @return The percentage of value
     */
    function percentMul(uint256 _value, uint256 _percentage) internal pure returns (uint256) {
        if (_value == 0 || _percentage == 0) {
            return 0;
        }

        require(_value <= (type(uint256).max - HALF_PERCENT) / _percentage, "Platypus: math mul overflow");
        
        return (_value * _percentage + HALF_PERCENT) / PERCENTAGE_FACTOR;
    }

    /**
     * @dev Executes a percentage division
     * @param _value The value of which the percentage needs to be calculated
     * @param _percentage The percentage of the value to be calculated
     * @return The value divided the percentage
     */
    function percentDiv(uint256 _value, uint256 _percentage) internal pure returns (uint256) {
        require(_percentage != 0, "Platypus: math div by zero");
        uint256 halfPercentage = _percentage / 2;

        require(_value <= (type(uint256).max - halfPercentage) / PERCENTAGE_FACTOR, "Platypus: math mul overflow");

        return (_value * PERCENTAGE_FACTOR + halfPercentage) / _percentage;
    }
}