// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../types/DataTypes.sol";
import "../configuration/ReserveConfiguration.sol";
import "../math/MathUtils.sol";
import "../math/WadRayMath.sol";
import "../math/PercentageMath.sol";
import "../../../interfaces/IStableDebtToken.sol";
import "../../../interfaces/IVariableDebtToken.sol";

/**
 * @title ReserveLogic library
 * @notice Implements the logic to update the reserves state
 */
library ReserveLogic {
    using WadRayMath for uint256;
    using PercentageMath for uint256;
    using ReserveLogic for DataTypes.ReserveData;
    using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

    /**
     * @dev Updates the liquidity cumulative index and variable borrow index.
     * @param reserve the reserve object
     */
    function updateState(DataTypes.ReserveData storage reserve) internal {
        uint256 scaledVariableDebt = IVariableDebtToken(reserve.variableDebtTokenAddress).scaledTotalSupply();
        uint256 previousVariableBorrowIndex = reserve.variableBorrowIndex;
        uint256 previousLiquidityIndex = reserve.liquidityIndex;
        uint40 lastUpdatedTimestamp = reserve.lastUpdateTimestamp;

        (uint256 newLiquidityIndex, uint256 newVariableBorrowIndex) = _updateIndexes(
            reserve,
            scaledVariableDebt,
            previousLiquidityIndex,
            previousVariableBorrowIndex,
            lastUpdatedTimestamp
        );

        _mintToTreasury(
            reserve, 
            scaledVariableDebt,
            previousVariableBorrowIndex, 
            newLiquidityIndex, 
            newVariableBorrowIndex, 
            lastUpdatedTimestamp
        );
    }

    struct MintToTreasuryLocalVars {
        uint256 currentStableDebt;
        uint256 principalStableDebt;
        uint256 previousStableDebt;
        uint256 currentVariableDebt;
        uint256 previousVariableDebt;
        uint256 avgStableRate;
        uint256 cumulatedStableInterest;
        uint256 totalDebtAccrued;
        uint256 amountToMint;
        uint256 reserveFactor;
        uint40 stableSupplyUpdatedTimestamp;
    }

    /**
     * @dev Mints part of the repaid interest to the reserve treasury as a function of the reserveFactor for the specific asset
     * @param _reserve The reserve to be updated
     * @param _scaledVariableDebt The current scaled total variable debt
     * @param _previousVariableBorrowIndex The variable borrow index before the last accumulation of the interest
     * @param _newLiquidityIndex The new liquidity index
     * @param _newVariableBorrowIndex The variable borrow index after the last accumulation of the interest
     * @param _timestamp Timestamp
     */
    function _mintToTreasury(
        DataTypes.ReserveData storage _reserve,
        uint256 _scaledVariableDebt,
        uint256 _previousVariableBorrowIndex,
        uint256 _newLiquidityIndex,
        uint256 _newVariableBorrowIndex,
        uint40 _timestamp
    ) internal {
        MintToTreasuryLocalVars memory vars;

        vars.reserveFactor = _reserve.configuration.getReserveFactor();

        if (vars.reserveFactor == 0) {
            return;
        }

        // fetching the principal, total stable debt and the avg stable rate
        (
            vars.principalStableDebt,
            vars.currentStableDebt,
            vars.avgStableRate,
            vars.stableSupplyUpdatedTimestamp
        ) = IStableDebtToken(_reserve.stableDebtTokenAddress).getSupplyData();

        // calculate the last principal variable debt
        vars.previousVariableDebt = _scaledVariableDebt.rayMul(_previousVariableBorrowIndex);
        
        // calculate the new total supply after accumulation of the index
        vars.currentVariableDebt = _scaledVariableDebt.rayMul(_newVariableBorrowIndex);

        // calculate the stable debt until the last timestamp update
        vars.cumulatedStableInterest = MathUtils.calculateCompoundedInterest(
            vars.avgStableRate, 
            vars.stableSupplyUpdatedTimestamp, 
            _timestamp
        );

        // debt occrued is the sum of the current debt minus the sum of the debt at the last update
        vars.totalDebtAccrued = vars.currentVariableDebt + vars.currentStableDebt - vars.previousVariableDebt - vars.previousStableDebt;

        vars.amountToMint = vars.totalDebtAccrued.percentMul(vars.reserveFactor);

        if (vars.amountToMint != 0) {
            
        }
    }
    
    /**
     * @dev Updates the reserve indexes and the timestamp of the update
     * @param _reserve The reserve to be updated
     * @param _scaledVariableDebt The scaled variable debt
     * @param _liquidityIndex The last stored liquidity index
     * @param _variableBorrowIndex The last stored variable borrow index
     * @param _timestamp Timestamp
     */
    function _updateIndexes(
        DataTypes.ReserveData storage _reserve,
        uint256 _scaledVariableDebt,
        uint256 _liquidityIndex,
        uint256 _variableBorrowIndex,
        uint40 _timestamp
    ) internal returns (uint256, uint256) {
        uint256 currentLiquidityRate = _reserve.currentLiquidityRate;

        uint256 newLiquidityIndex = _liquidityIndex;
        uint256 newVariableBorrowIndex = _variableBorrowIndex;
        
        if (currentLiquidityRate > 0) {
            uint256 cumulatedLiquidityInterest = MathUtils.calculateLinearInterest(currentLiquidityRate, _timestamp);
            newLiquidityIndex = cumulatedLiquidityInterest.rayMul(_liquidityIndex);
            require(newLiquidityIndex <= type(uint128).max, "ERROR: Liquidity index overflow");

            _reserve.liquidityIndex = uint128(newLiquidityIndex);

            // as the liquidity rate might come only from stable rate loans, we need to ensure that there is actual variable debt before accumulating
            if (_scaledVariableDebt != 0) {
                uint256 cumulatedVariableBorrowInterest = MathUtils.calculateCompoundedInterest(_reserve.currentVariableBorrowRate, _timestamp, block.timestamp);

                newVariableBorrowIndex = cumulatedVariableBorrowInterest.rayMul(_variableBorrowIndex);
                require(newVariableBorrowIndex <= type(uint128).max, "ERROR: Borrow index overflow");

                _reserve.variableBorrowIndex = uint128(newVariableBorrowIndex);
            }
        }

        _reserve.lastUpdateTimestamp = uint40(block.timestamp);
        return (newLiquidityIndex, newVariableBorrowIndex);
    }
}