# Dual EWMA Volatility-based Trading Strategy

This repository contains the R script `ewvol.R` implementing a trading strategy based on Dual Exponentially Weighted Moving Average (EWMA) volatilities. The strategy includes a weekend-only trading approach for VTI ETF and an optimal trading strategy derived from the Dual EWMA volatilities.

## Weekend-Only Trading Strategy

The script simulates a calendar strategy that holds the VTI ETF only over the weekends. The following steps are performed:

1. **Data Preparation:**
   - Calculate daily open and close prices.
   - Determine Friday indexes and corresponding open and close prices.
   - Calculate daily returns.

2. **Weekend Trading:**
   - Buy VTI on Fridays at the closing price.
   - Sell VTI on Mondays at the opening price.

3. **Results:**
   - Cumulative wealth over time for the weekend-only strategy.

## Dual EWMA Volatility-based Trading Strategy

The script also implements an optimal trading strategy based on Dual EWMA volatilities. The following steps are performed:

1. **Volatility Calculation:**
   - Calculate fast and slow trailing volatilities using Dual EWMA method.

2. **Optimal Strategy:**
   - Buy VTI when slow volatility is above fast volatility.
   - Sell VTI short when fast volatility is above slow volatility.

3. **Results:**
   - Cumulative wealth over time for the optimal Dual EWMA strategy.

## How to Use

1. Clone this repository to your local machine:

   ```bash
   git clone <repository-url>
