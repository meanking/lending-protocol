// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./IScaledBalanceToken.sol";

/// @title IVariableDebtToken
/// @notice Defines the basic interface for a variable debt token

interface IVariableDebtToken is IScaledBalanceToken {
    
    /// @dev Emitted after the mint action
    /// @param _from The address performing the mint
    /// @param _onBehalfOf the address of the user on which behalf minting has been performed
    /// @param _value The last index o the reserve
    
    event Mint(
        address indexed _from, 
        address indexed _onBehalfOf, 
        uint256 _value, 
        uint256 _index
    );

    /// @dev Mints debt token to the `onBehalfOf` address
    /// @param _user The address receiving the borrowed underlying, being the delegatee in case
    /// @param _onBehalfOf The address receiving the debt tokens
    /// @param _amount The amount of debt being minted
    /// @param _index The variable debt index of the reserve
    /// @return `true` if the previous balance of the user is 0

    function mint(
        address _user,
        address _onBehalfOf,
        uint256 _amount,
        uint256 _index
    ) external returns (bool);

    /// @dev Emitted when variable debt is burnt
    /// @param _user The user which debt has been burned
    /// @param _amount The amount of debt being burned
    /// @param _index The index of the user

    event Burn(address indexed _user, uint256 _amount, uint256 _index);

    /// @dev Burns user variable debt
    /// @param _user The user which debt is burnt
    /// @param _index The variable debt index of the reserve

    function burn(
        address _user,
        uint256 _amount,
        uint256 _index
    ) external;
}