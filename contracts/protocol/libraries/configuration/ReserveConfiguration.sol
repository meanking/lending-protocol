// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../types/DataTypes.sol";

/**
 * @title ReserveConfiguration library
 * @notice Implements the bitmap logic to handle the reserve configuration
 */
library ReserveConfiguration {
    uint256 constant private ACTIVE_MASK           = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF;
    uint256 constant private FROZEN_MASK           = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF;
    uint256 constant private BORROWING_MASK        = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF;
    uint256 constant private STABLE_BORROWING_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFF;
    uint256 constant private RESERVE_FACTOR_MASK   = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFF;

    uint256 constant private RESERVE_FACTOR_START_BIT_POSITION = 64;

    /**
     * @dev Gets the configuration flags of the reserve
     * @param self The reserve configuration
     * @return The state flags representing active, frozen, borrowing enabled, stableRate Borrowing enabled
     */
    function getFlags(DataTypes.ReserveConfigurationMap storage self) internal view returns(bool, bool, bool, bool) {
        uint256 dataLocal = self.data;

        return (
            (dataLocal & ~ACTIVE_MASK) != 0,
            (dataLocal & ~FROZEN_MASK) != 0,
            (dataLocal & ~BORROWING_MASK) != 0,
            (dataLocal & ~STABLE_BORROWING_MASK) != 0
        );
    }

    /**
     * @dev Gets the reserve factor of the reserve
     * @param self The reserve configuration
     * @return The reserve factor
     */
    function getReserveFactor(DataTypes.ReserveConfigurationMap storage self) internal view returns (uint256) {
        return (self.data & ~RESERVE_FACTOR_MASK) >> RESERVE_FACTOR_START_BIT_POSITION;
    }
}