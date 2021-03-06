// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title LendingPoolAddressesProvider contract
 * @dev Main registry of addresses part of or connected to the protocol, including permissioned roles
 * - Acting also as factory of proxies and admin of those, so with right to change its implementations
 * - Owned by the Platypus Governance
 **/
interface ILendingPoolAddressesProvider {
    function getLendingPoolConfigurator() external view returns (address);
}