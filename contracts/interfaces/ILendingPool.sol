// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILendingPool {
    /**
     * @dev Emitted on deposit()
     * @param reserve The address of the underlying asset of the reserve
     * @param user The address initiating the deposit
     * @param onBehalfOf The beneficiary of the deposit, receiving the pTokens
     * @param amount The amount deposited
     * @param referral The referral code used
     **/
    event Deposit(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint16 indexed referral
    );

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
    ) external;
}