// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/ILendingPoolAddressesProvider.sol";
import "../libraries/logic/ReserveLogic.sol";
import "../libraries/types/DataTypes.sol";

contract LendingPoolStorage {
    using ReserveLogic for DataTypes.ReserveData;

    ILendingPoolAddressesProvider internal _addressesProvider;

    mapping(address => DataTypes.ReserveData) internal _reserves;

    bool internal _paused;
}