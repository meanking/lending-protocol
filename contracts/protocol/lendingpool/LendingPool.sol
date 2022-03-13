// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/ILendingPoolAddressesProvider.sol";
import "../../interfaces/ILendingPool.sol";
import "../libraries/logic/ValidationLogic.sol";
import "./LendingPoolStorage.sol";

/**
 * @title LendingPool contract
 * @dev Main point of interaction with an Platypus protocol's market
 * - Users can:
 *   # Deposit
 *   # Withdraw
 *   # Borrow
 *   # Repay
 *   # Swap their loans between variable and stable rate
 *   # Enable/disable their deposits as collateral rebalance stable rate borrow positions
 *   # Liquidate positions
 *   # Execute Flash Loans
 * - To be covered by a proxy contract, owned by the LendingPoolAddressesProvider of the specific market
 * - All admin functions are callable by the LendingPoolConfigurator contract defined also in the
 *   LendingPoolAddressesProvider
 **/
contract LendingPool is ILendingPool, LendingPoolStorage {
    modifier whenNotPaused() {
        _whenNotPaused();
        _;
    }

    modifier onlyLendingPoolConfigurator() {
        _onlyLendingPoolConfigurator();
        _;
    }

    function _whenNotPaused() internal view {
        require(!_paused, "ERROR: LP is paused");
    }

    function _onlyLendingPoolConfigurator() internal view {
        require(
            _addressesProvider.getLendingPoolConfigurator() == msg.sender, 
            "ERROR: Caller not configurator"
        );
    }

    /**
     * @dev Function is invoked by the proxy contract when the LendingPool contract is added to the
     * LendingPoolAddressesProvider of the market.
     * - Caching the address of the LendingPoolAddressesProvider in order to reduce gas consumption
     *   on subsequent operations
     * @param provider The address of the LendingPoolAddressesProvider
     **/
    function initialize(ILendingPoolAddressesProvider provider) public {
        _addressesProvider = provider;
    }

    /**
     * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying pTokens.
     * - E.g. User deposits 100 USDC and gets in return 100 pUSDC
     * @param _asset The address of the underlying asset to deposit
     * @param _amount The amount to be deposited
     * @param _onBehalfOf The address that will receive the pTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of pTokens
     *   is a different wallet
     * @param _referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without any middle-man
     **/
    function deposit(
        address _asset, 
        uint256 _amount, 
        address _onBehalfOf, 
        uint16 _referralCode
    ) external override whenNotPaused {
        DataTypes.ReserveData storage reserve = _reserves[_asset];
        
        ValidationLogic.validateDeposit(reserve, _amount);

        address pToken = reserve.pTokenAddress;
    }
}