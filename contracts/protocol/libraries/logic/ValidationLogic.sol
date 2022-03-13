// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ReserveLogic.sol";
import "../configuration/ReserveConfiguration.sol";
import "../types/DataTypes.sol";

/**
 * @title ReserveLogic library
 * @notice Implements functions to validate the different actions of the protocol
 */
library ValidationLogic {
    using ReserveLogic for DataTypes.ReserveData;
    using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

    /**
     * @dev Validates a deposit action
     * @param reserve The reserve object on which the user is depositing
     * @param amount The amount to be deposited
     */
    function validateDeposit(
        DataTypes.ReserveData storage reserve, 
        uint256 amount
    ) external view {
        (bool isActive, bool isFrozen, , ) = reserve.configuration.getFlags();

        require(amount != 0, "ERROR: VL invalid amount");
        require(isActive, "ERROR: VL no active reserve");
        require(!isFrozen, "ERROR: VL reserve frozen");
    }
}