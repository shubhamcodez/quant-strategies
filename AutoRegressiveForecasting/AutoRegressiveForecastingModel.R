library(rutils)
# Calculate the VTI daily percentage returns
retp <- na.omit(rutils::etfenv$returns$VTI)
nrows <- NROW(retp)
# Define the response and predictor matrices
respv <- retp
orderp <- 5
predm <- lapply(1:orderp, rutils::lagit, input=respv)
predm <- rutils::do_call(cbind, predm)
# Add constant column for intercept coefficient phi0
predm <- cbind(rep(1, nrows), predm)
colnames(predm) <- c("phi0", paste0("lag", 1:orderp))

# Define the look-back interval
look_back <- 100

# Perform rolling forecasting, similar to the slide:
# Rolling Autoregressive Forecasting Model.
# 
# You can adapt code from the files:
# strategies_autoregressive2.pdf
# strategies_autoregressive2.R
tday <- nrows
fcasts <- sapply((look_back + 1):nrows, function(tday) {
  # Subset the returns for the look-back window
  startp <- max(1,tday - look_back)
  rangev <- startp:(tday-1)
  
  volvti <- sd(retp[rangev,])
  
  predinv <- MASS::ginv(predm[rangev,])
  coeff <- predinv %*% respv[rangev]
  
  out_of_sample_fcast <- predm[tday,] %*% coeff
  
  resids <- (predm[rangev,] %*% coeff) - respv[rangev,]
  vars <- sum(resids^2)/(NROW(predm[rangev,])-NROW(coeff))
  predm2 <- crossprod(predm[rangev,])
  covar <- vars*MASS::ginv(predm2)
  
  fstderr <- sqrt(predm[tday,] %*% covar %*% t(predm[tday,]))
  coeffsd <- sqrt(diag(covar))
  c(volvti, out_of_sample_fcast,fstderr,coeffsd)
})

fcasts = t(fcasts)
# Add column names to the matrix
colnames(fcasts) <- c("volvti", "fcasts", "fstderr","phi0","lag1","lag2","lag3","lag4","lag5")

dim(fcasts)
# You should get the following output:
# [1] 4930    9
# Coerce fcasts to a time series using zoo::index(retp) and xts::xts().

### write your code here
fcasts <- xts::xts(fcasts, order.by = index(retp[(look_back+1):length(retp)]))

# Convert xts object to data frame with required columns
fcasts_df <- data.frame(index = index(fcasts), volvti = fcasts$volvti, fstderr = fcasts$fstderr)

# Plotting the trailing volatility of returns and standard error of forecasts
dygraph(fcasts_df, x = "index") %>%
  dySeries("volvti", label = "Volatility of Returns") %>%
  dyAxis("y", label = "Volatility") %>%
  dySeries("fstderr", label = "Standard Error of Forecasts", axis = "y2") %>%
  dyAxis("y2", label = "Standard Error") %>%
  dyOptions(stackedGraph = TRUE) %>%
  dyRangeSelector()

library(rutils)

# Load the S&P500 stock returns
load(file="sp500_returns.RData") #make sure the data is in same directory as this file
# Calculate the log VTI returns
retvti <- na.omit(rutils::etfenv$returns$VTI)
# Subset (select) the stock returns retstock after the start date of VTI
retp <- retstock[zoo::index(retvti)]
nrows <- NROW(retp)
ncols <- NCOL(retp)
# Calculate date index
datev <- zoo::index(retvti)

# Define cutoff between in-sample and out-of-sample intervals
cutoff <- nrows %/% 2
datev[cutoff]
insample <- 1:cutoff
outsample <- (cutoff+1):nrows

volv <- sapply(retp, function(x) sd(na.omit(x)))

# You should get the following outputs:
sum(is.na(volv))
# [1] 0
mean(volv)
# [1] 0.02473875
range(volv)
# [1] 0.01080959 0.26642352
tail(volv)
#       EXPD       EXPE        SII        EMN        EMR        CAT 
# 0.01879951 0.02989018 0.03173259 0.02022835 0.01765717 0.01983509


# Calculate the name of the most volatile stock.
# You can use the functions names() and which.max().
most_volatile_stock <- names(volv[which.max(volv)])
most_volatile_stock

# You should get the following output:
# [1] "SHLDQ"


# Sort volv and find the names and volatilities of 
# the 5 most volatile stocks.
# You can use the functions tail() and sort().

sorted_volv <- sort(volv, decreasing = FALSE)
volh <- tail(sorted_volv,5)
# You should get the following outputs:
volh
#      LVLT       KODK        BTU       MRNA      SHLDQ
# 0.05801669 0.05986655 0.06122649 0.06767544 0.26642352

weightv <- lapply(retp[insample, ], function(x) {
  clean_data <- na.omit(x)
  if (NROW(clean_data) > 12) {
    return(mean(clean_data) / sd(clean_data))
  } else {
    return(NULL)
  }
})

weightv <- unlist(na.omit(weightv))
# You should get the following outputs:
sum(is.na(weightv))
# [1] 0
NROW(weightv)
# [1] 652
mean(weightv)
# [1] 0.01776569
range(weightv)
# [1] -0.09953347  0.42019957
head(weightv)
#         SO          PNC          VFC         ORLY          KEY         STLD
# 0.012848422  0.006131990  0.035341623  0.041250782 -0.008703933  0.015833969
tail(weightv)
#       EXPD         EXPE          SII          EMN          EMR          CAT
# 0.0152436254 0.0002909805 0.0013713565 0.0272583602 0.0180253774 0.0166236497

# De-mean the weights so their sum is equal to 0.
# Then scale the weights so the sum of squares is equal to 1.

mean_weight <- mean(weightv)
weightv <- weightv - mean_weight

weightv <- weightv / sqrt(sum(weightv^2))

# You should get the following outputs:
round(mean(weightv), 9)
# [1] 0
sum(weightv^2)
# [1] 1

equal_weighted_returns <- rowMeans(retp, na.rm = TRUE)

# Coerce the index into an xts time series using xts::xts()
indeks <- xts::xts(equal_weighted_returns, order.by = as.Date(datev))

# You should get the following outputs:
mean(indeks)
# [1] 0.0002657381
sd(indeks)
# [1] 0.01355222
head(indeks)
#                   Index
# 2003-09-10  0.010000000
# 2003-09-11  0.005216538
# 2003-09-12  0.004404957
# 2003-09-15 -0.002427879
# 2003-09-16  0.011695105
# 2003-09-17 -0.002584300
tail(indeks)
#                  Index
# 2023-08-25  0.004337266
# 2023-08-28  0.007942392
# 2023-08-29  0.012637333
# 2023-08-30  0.002067118
# 2023-08-31 -0.003181132
# 2023-09-01  0.005054850


# Select from retp the stock columns with names 
# present in weightv.  Call it rets.
# You can use the function names().
rets <- retp[, names(weightv)]

# You should get the following outputs:
dim(rets)
# [1] 5030  652
sum(is.na(rets))
# [1] 392346
all.equal(names(weightv), colnames(rets))
# [1] TRUE
head(names(rets))
# [1] "SO"   "PNC"  "VFC"  "ORLY" "KEY"  "STLD"
tail(names(rets))
# [1] "EXPD" "EXPE" "SII"  "EMN"  "EMR"  "CAT"


# Multiply the columns of rets by weightv.
# You can use the functions lapply(), NCOL(), 
# and do.call().
retw <- do.call(cbind, lapply(1:NCOL(rets), function(i) rets[, i] * weightv[i]))

# You should get the following outputs:
dim(retw)
# [1] 5030  652
sum(is.na(retw))
# [1] 392346
# Calculate the strategy pnls equal to the row means 
# of retw. 


pnls <- rowMeans(retw, na.rm = TRUE)
pnls <- xts::xts(pnls, order.by = datev)

# You should get the following outputs:
mean(pnls)
# [1] 4.884049e-06
sd(pnls)
# [1] 8.127646e-05
head(pnls)
#                 Strategy
# 2003-09-10 -6.417704e-21
# 2003-09-11 -1.889535e-05
# 2003-09-12 -5.490459e-05
# 2003-09-15  2.488513e-05
# 2003-09-16 -8.316862e-05
# 2003-09-17  3.838694e-05
tail(pnls)
#                 Strategy
# 2023-08-25  5.021292e-05
# 2023-08-28 -1.956739e-05
# 2023-08-29 -1.103979e-05
# 2023-08-30  3.414933e-05
# 2023-08-31 -1.029785e-05
# 2023-09-01 -4.195169e-05


# Scale the strategy pnls so that they have the same
# in-sample volatility as the variable indeks.
# This is equivalent to rescaling the weights using 
# only in-sample data.

insample_vol <- sd(indeks[insample])

# Scale the strategy pnls to match the in-sample volatility of indeks
pnls <- pnls_xts * (insample_vol / sd(pnls_xts[insample]))

# You should get the following outputs:
sd(pnls)
# [1] 0.01105488

# Combine the indeks with the strategy returns pnls.

### write your code here
wealthv <- cbind(indeks, scaled_pnls)
colnames(wealthv) <- c("Index","Strategy")
# You should get the following outputs:
tail(wealthv)
#                  Index      Strategy
# 2023-08-25  0.004337266  0.006829748
# 2023-08-28  0.007942392 -0.002661473
# 2023-08-29  0.012637333 -0.001501585
# 2023-08-30  0.002067118  0.004644847
# 2023-08-31 -0.003181132 -0.001400669
# 2023-09-01  0.005054850 -0.005706091

# Calculate the in-sample Sharpe and Sortino ratios.
in_sample_ratios <- sqrt(252) * sapply(wealthv[insample, ], function(x) {
  c(Sharpe = mean(x) / sd(x), Sortino = mean(x) / sd(x[x < 0]))
})

# Calculate out-of-sample Sharpe and Sortino ratios for Index and Strategy

in_sample_ratios
# You should get the following outputs:
#             Index  Strategy
# Sharpe  0.3180733 1.159588
# Sortino 0.3813211 1.536591

# Calculate the out-of-sample Sharpe and Sortino ratios.

out_sample_ratios <- sqrt(252) * sapply(wealthv[outsample, ], function(x) {
  c(Sharpe = mean(x) / sd(x), Sortino = mean(x) / sd(x[x < 0]))
})
out_sample_ratios
# You should get the following outputs:
#             Index  Strategy
# Sharpe  0.3053246 0.743460
# Sortino 0.3607129 1.119018

# This demonstrates that a portfolio of stocks with 
# the best in-sample Sharpe ratios, also outperforms 
# the equal-weight portfolio out-of-sample.
# Calculate cumulative sum of the portfolio returns
wealthv_cumulative <- cumsum(wealthv)
in_sample_end <- tail(index(retp[insample,]),1)
in_sample_end  
# Plotting the cumulative sum of stock portfolio returns using dygraph
dygraph(wealthv_cumulative) %>%
  dySeries("Index", label = "Index") %>%
  dySeries("Strategy", label = "Strategy") %>%
  dyEvent(in_sample_end, label = "Insample", strokePattern = "solid", color = "red") %>%
  dyRangeSelector()
# Plot a dygraph of the cumulative stock portfolio returns, 
# both in-sample and out-of-sample.

# Your plot should be similar to portf_stocks_weighted_out_sample.png
# Plot out-of-sample period only
dygraph(cumsum(wealthv[outsample, ])) %>%
  dySeries("Index", label = "Index") %>%
  dySeries("Strategy", label = "Strategy") %>%
  dyRangeSelector()