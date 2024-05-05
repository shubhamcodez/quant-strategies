# Factor Modeling and Portfolio Optimization
=============================================

## Project Overview
This project develops a fundamental factor model using ten factors: 20-Day ADV, Growth, Volatility, Profitability, Dividend Yield, Value, Market Sensitivity, Medium-Term Momentum, Short-Term Momentum, and Liquidity. The model aims to capture changing market conditions and improve portfolio efficiency.

## What is a Fundamental Factor Model?
A fundamental factor model is a statistical model that explains the returns of a portfolio or asset by identifying the underlying factors that drive its performance. This approach assumes that a portfolio's returns can be attributed to various underlying factors, such as macroeconomic variables, industry-specific factors, or company-specific characteristics. By identifying and quantifying these factors, a fundamental factor model aims to provide a more accurate and robust explanation of a portfolio's performance.

In a fundamental factor model, the returns of a portfolio or asset are expressed as a linear combination of various factors, plus an error term. The factors are typically chosen based on economic theory and empirical evidence and may include variables such as:

* Macroeconomic factors (e.g. GDP growth, inflation, interest rates)
* Industry-specific factors (e.g. industry growth, industry sentiment)
* Company-specific factors (e.g. earnings growth, dividend yield)
* Market-specific factors (e.g. market sentiment, market volatility)

The coefficients of the factors in the model represent the sensitivity of the portfolio or asset to each factor, and can be used to understand the drivers of its performance. By analyzing the factor coefficients and the error term, investors and researchers can gain insights into the underlying factors that drive a portfolio's returns, and make more informed investment decisions.

## Key Features
#### Fundamental Factor Model
* Uses ten key factors: 20-Day ADV, Growth, Volatility, Profitability, Dividend Yield, Value, Market Sensitivity, Medium-Term Momentum, Short-Term Momentum, and Liquidity
#### Factor Orthogonalization
* Reduces factor correlations and improves diversification
#### Cross-Sectional Regression
* Estimates factor loadings and computes returns using the following regression equation:
R_i = α + β_1 \* 20DayADV_i + β_2 \* Growth_i + β_3 \* Volatility_i + β_4 \* Profitability_i + β_5 \* DividendYield_i + β_6 \* Value_i + β_7 \* MarketSensitivity_i + β_8 \* MediumTermMomentum_i + β_9 \* ShortTermMomentum_i + β_10 \* Liquidity_i + ε_i

where:

* R_i is the return of asset i
* α is the intercept or constant term
* β_1 to β_10 are the factor loadings or coefficients, which represent the sensitivity of the asset's return to each factor
* 20DayADV_i to Liquidity_i are the values of the ten factors for asset i
* ε_i is the error term, which represents the portion of the asset's return that is not explained by the factors

#### Portfolio Optimization and Performance Evaluation
* QLIKE random portfolio tests, minimum variance portfolio tests, and cluster analysis on high and low turnover factors
* Achieved an annual return of 21% and a Sharpe ratio of 1.109, with a robust R-squared of 0.11

In this section, we employ various portfolio optimization and performance evaluation methodologies to assess the efficacy of our fundamental factor model.

##### QLIKE Test Statistic
We implement a QLIKE test statistic based on random portfolios to evaluate the model's ability to explain portfolio returns. The QLIKE statistic measures the model's explanatory power, and we compare it to a benchmark portfolio to assess performance.

##### Minimum Variance Portfolios
We construct minimum variance portfolios using the factor covariance matrix and idiosyncratic volatilities estimated from our model. We then evaluate the performance of these portfolios relative to a benchmark portfolio, assessing the model's ability to minimize risk.

##### Factor Covariance Matrix and Idiosyncratic Volatilities
We estimate the factor covariance matrix and idiosyncratic volatilities using our model, exploring different half-lives to assess estimation sensitivity.

##### Performance Evaluation
We evaluate the model's performance under QLIKE, MSE, and minimum variance portfolios for both clusters. We assess the model's ability to explain returns and construct portfolios with minimal risk, providing insights into its effectiveness.

By implementing these methodologies, we comprehensively evaluate our fundamental factor model's effectiveness in explaining returns and constructing optimal portfolios, providing a robust assessment of its performance.

## Dataset
* Please reach out via email for more information
  
## Columns
* ID
* Date
* Total Return
* Specific Risk
* 20-Day ADV
* Growth
* Volatility
* Profitability
* Dividend Yield
* Value
* Market Sensitivity
* Medium-Term Momentum
* Short-Term Momentum
* Liquidity

## License
MIT License

## Author
Shubham Singh

## Instructor
Guiseppe Paleologo
