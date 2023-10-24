# Summary: Simulate a calendar strategy that holds 
# VTI only over the weekends.

## Run the setup code below

# Calculate the daily open and close prices,
# and the daily close-to-close returns.

library(rutils)
ohlc <- rutils::etfenv$VTI
nrows <- NROW(ohlc)
openp <- quantmod::Op(ohlc)
closep <- quantmod::Cl(ohlc)
retp <- rutils::diffit(closep)

## End of setup code


# 1. (20pts)
# Calculate the close prices on Fridays (closef) 
# and the open prices on the following business 
# day (openn).
# 
# You can use the functions zoo::index(), 
# weekdays(), which(), NROW(), and min(). 

### Write your code here
friday_indexes <- zoo::index(ohlc)[weekdays(zoo::index(ohlc)) == "Friday"]
closef <- data.frame(VTI.Close = numeric(length(friday_indexes)))
openn <- data.frame(VTI.Open = numeric(length(friday_indexes)))
date <- data.frame()
for (i in 1:length(friday_indexes)) {
  idx <- which(zoo::index(ohlc) == friday_indexes[i])
  closef[i, "VTI.Close"] <- closep[idx]
  if (idx < nrows) {
    openn[i, "VTI.Open"] <- openp[idx + 1]
    } 
  else {
    openn[i, "VTI.Open"] <- openp[idx]  
  }
}
closef <- zoo::zoo(closef, order.by = friday_indexes)
openn <- zoo::zoo(openn, order.by = friday_indexes)

# You should get the following outputs:
tail(closef)
#             VTI.Close
# 2023-07-28    227.66
# 2023-08-04    222.90
# 2023-08-11    221.80
# 2023-08-18    217.01
# 2023-08-25    218.59
# 2023-09-01    224.68

tail(openn)
#             VTI.Open
# 2023-07-31   228.12
# 2023-08-07   223.72
# 2023-08-14   221.32
# 2023-08-21   217.41
# 2023-08-28   219.57
# 2023-09-01   225.34


# 2. (20pts)
# Calculate the strategy pnls as the difference 
# between the open prices on the following business 
# day (openn), minus the close prices on Fridays 
# (closef). 
# Combine (cbind) the strategy pnls with the daily 
# VTI returns (retp).  Set the NA values to zero.

# You can use the functions zoo::coredata(), 
# xts::xts(), zoo::index(), cbind(), colnames(), 
# is.na(), cumsum(),and dygraphs::dygraph().

### Write your code here
strategy_pnls = zoo::coredata(openn) - zoo::coredata(closef)
#strategy_pnls[is.na(strategy_pnls)] <- 0
strategy_pnls_xts <- xts(strategy_pnls, order.by = zoo::index(openn))
retp_xts <- xts::xts(data.frame(VTI_Returns = retp), order.by = index(retp))
wealthv <- cbind(retp_xts,strategy_pnls_xts,fill=0)
colnames(wealthv) <- c("VTI", "weekend")
wealthv[is.na(wealthv)] <- 0

# You should get the following outputs:
head(wealthv)
#               VTI weekend
# 2003-09-10  0.000   0.000
# 2003-09-11  0.315   0.000
# 2003-09-12  0.135   0.000
# 2003-09-15 -0.260   0.035
# 2003-09-16  0.775   0.000
# 2003-09-17 -0.175   0.000

tail(wealthv)
#              VTI weekend
# 2023-08-25  1.48    0.00
# 2023-08-28  1.40    0.98
# 2023-08-29  3.20    0.00
# 2023-08-30  0.99    0.00
# 2023-08-31 -0.24    0.00
# 2023-09-01  0.74    0.66

# Plot the cumulative wealths.
# Your plot should be similar to seasonal_weekend.png

### Write your code here
dygraph(cumsum(wealthv), main = "Weekend Strategy") %>%
  dySeries("VTI", label = "VTI", col = "blue") %>%
  dySeries("weekend", label = "weekend", col = "red") %>%
  dyRangeSelector()



############## Part II
# Summary: Simulate a moving average strategy using 
# fast and slow trailing volatilities.

## Run the setup code below

library(rutils)
retp <- na.omit(rutils::etfenv$returns$VTI)
datev <- zoo::index(retp)
nrows <- NROW(retp)
lambdaf <- 0.8 # Slow lambda
lambdas <- 0.9 # Fast lambda

## End of setup code

# 1. (20pts) 
# Calculate the fast (volf) and slow (vols) trailing 
# volatilities of retp using lambdaf and lambdas.
# You can use the functions HighFreq::run_var()
# and sqrt(). 

### Write your code here
library(HighFreq)
volf <- sqrt(HighFreq::run_var(retp,lambda = lambdaf))
vols <- sqrt(HighFreq::run_var(retp,lambda = lambdas))


# You should get the following outputs:
tail(volf)
#               [,1]
# [5025,] 0.007459582
# [5026,] 0.007261596
# [5027,] 0.008141910
# [5028,] 0.007533820
# [5029,] 0.007059998
# [5030,] 0.006519159

tail(vols)
#               [,1]
# [5025,] 0.007386905
# [5026,] 0.007249131
# [5027,] 0.008115285
# [5028,] 0.007607753
# [5029,] 0.007174899
# [5030,] 0.006707272


# Create a function called sim_volma(), which simulates 
# a moving average strategy using fast and slow trailing 
# volatilities.
# Buy VTI if the slow volatility is above the fast volatility.
# Sell VTI short if the fast volatility is above the slow volatility.
# Adapt code from the slide: 
#   Simulation Function for the Dual EWMA Crossover Strategy

### Write your code here
sim_volma <- function(lambdaf, lambdas) {
if (lambdaf >= lambdas) return(NA)
  # Calculate the EWMA prices
  ewmaf <- HighFreq::run_var(retp, lambda=lambdaf)
  ewmas <- HighFreq::run_var(retp, lambda=lambdas)
  # Calculate the positions, either: -1, 0, or 1
  indic <- sign(ewmaf - ewmas)
  posv <- rep(NA_integer_, nrows)
  posv[1] <- 0
  posv <- ifelse(indic>0,-1, posv)
  posv <- ifelse(indic<0, 1, posv)
  posv <- zoo::na.locf(posv, na.rm=FALSE)
  posv <- xts::xts(posv, order.by=zoo::index(retp))
  # Lag the positions to trade on next day
  posv <- rutils::lagit(posv, lagg=1)
  # Calculate the PnLs of strategy
  pnls <- retp*posv
  # Calculate the strategy returns
  pnls <- cbind(posv, pnls)
  colnames(pnls) <- c("positions", "pnls")
  pnls
} # end sim_ewma2

# You should get the following output:

pnls <- sim_volma(lambdaf=lambdaf, lambdas=lambdas)
head(pnls)
#            positions         pnls
# 2003-09-10         0  0.000000000
# 2003-09-11         0  0.000000000
# 2003-09-12        -1 -0.002756932
# 2003-09-15        -1  0.005316442
# 2003-09-16        -1 -0.015764374
# 2003-09-17        -1  0.003538038

tail(pnls)
#            positions         pnls
# 2023-08-25        -1 -0.006793691
# 2023-08-28        -1 -0.006384262
# 2023-08-29        -1 -0.014441336
# 2023-08-30        -1 -0.004425874
# 2023-08-31         1 -0.001071142
# 2023-09-01         1  0.003299009


# 2. (20pts) 
# Create a function called calc_sharpe(), which calls 
# sim_volma() to simulate a moving average strategy 
# using trailing volatilities, and calculates the Sharpe 
# ratio.
# Adapt code from the slide: 
#   Dual EWMA Strategy Performance Matrix

### Write your code here
calc_sharpe <- function(lambdaf, lambdas) {
  if (lambdaf >= lambdas) return(NA)
  pnls <- sim_volma(lambdaf=lambdaf, lambdas=lambdas)[, "pnls"]
  sqrt(252)*mean(pnls)/sd(pnls)
}  # end calc_sharpe

# You should get the following output:
sharper <- calc_sharpe(lambdaf=lambdaf, lambdas=lambdas)
sharper
# [1] 0.4987907


# Create two vectors of lambdas (run this):
lambdafv <- seq(from=0.8, to=0.99, by=0.01)
lambdasv <- seq(from=0.8, to=0.99, by=0.01)


# Calculate a matrix of Sharpe ratios for the vectors 
# lambdafv and lambdasv.
# You can perform two sapply() loops over the lambda 
# vectors.

### Write your code here
sharpem <- sapply(lambdasv, function(lambdas) {
  sapply(lambdafv, function(lambdaf) {
    calc_sharpe(lambdaf, lambdas)
  })
})

colnames(sharpem) <- format(lambdasv, nsmall = 2)
rownames(sharpem) <- format(lambdafv, nsmall = 2)

# You should get the following output:
round(sharpem, 2)
#      0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89  0.9 0.91 0.92 0.93 0.94  0.95 0.96 0.97 0.98 0.99
# 0.8   NA 0.39 0.43 0.52 0.56 0.56 0.48 0.48 0.48 0.48 0.50 0.47 0.52 0.48 0.46  0.42 0.55 0.63 0.36 0.46
# 0.81  NA   NA 0.51 0.55 0.61 0.52 0.49 0.46 0.48 0.47 0.44 0.54 0.48 0.46 0.37  0.43 0.54 0.54 0.20 0.42
# 0.82  NA   NA   NA 0.61 0.53 0.49 0.47 0.50 0.44 0.46 0.49 0.51 0.49 0.41 0.39  0.46 0.50 0.46 0.25 0.41
# 0.83  NA   NA   NA   NA 0.48 0.46 0.47 0.45 0.47 0.46 0.51 0.48 0.45 0.36 0.42  0.50 0.48 0.44 0.27 0.43
# 0.84  NA   NA   NA   NA   NA 0.47 0.45 0.46 0.44 0.50 0.51 0.45 0.36 0.40 0.44  0.45 0.44 0.34 0.21 0.31
# 0.85  NA   NA   NA   NA   NA   NA 0.45 0.43 0.52 0.48 0.50 0.46 0.36 0.40 0.44  0.41 0.34 0.24 0.28 0.30
# 0.86  NA   NA   NA   NA   NA   NA   NA 0.50 0.49 0.48 0.45 0.38 0.38 0.42 0.41  0.40 0.39 0.15 0.23 0.35
# 0.87  NA   NA   NA   NA   NA   NA   NA   NA 0.47 0.49 0.38 0.40 0.39 0.43 0.39  0.39 0.26 0.11 0.20 0.36
# 0.88  NA   NA   NA   NA   NA   NA   NA   NA   NA 0.39 0.41 0.41 0.43 0.37 0.39  0.29 0.18 0.09 0.14 0.37
# 0.89  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA 0.38 0.39 0.44 0.36 0.35  0.24 0.13 0.12 0.12 0.33
# 0.9   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA 0.45 0.37 0.38 0.24  0.13 0.03 0.13 0.17 0.38
# 0.91  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA 0.36 0.25 0.16  0.02 0.05 0.10 0.22 0.34
# 0.92  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA 0.17 0.08  0.05 0.04 0.12 0.36 0.38
# 0.93  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA 0.00 -0.03 0.13 0.17 0.37 0.39
# 0.94  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA  0.09 0.11 0.23 0.34 0.33
# 0.95  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA    NA 0.17 0.38 0.37 0.33
# 0.96  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA    NA   NA 0.32 0.38 0.30
# 0.97  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA    NA   NA   NA 0.26 0.27
# 0.98  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA    NA   NA   NA   NA 0.34
# 0.99  NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA   NA    NA   NA   NA   NA   NA


# 3. (20pts) 
# Calculate the PnLs for the optimal strategy.
# Adapt code from the slide: 
#   Optimal Dual EWMA Strategy

### Write your code here
whichv <- which(sharpem == max(sharpem, na.rm=TRUE), arr.ind=TRUE)
lambdaf <- lambdafv[whichv[1]]
lambdas <- lambdasv[whichv[2]]
volma_opt <- sim_volma(lambdaf=lambdaf, lambdas=lambdas)
pnls <- volma_opt[, "pnls"]
wealthv <- cbind(retp, pnls)
colnames(wealthv)[2] <- "MA Strat"
# Calculate the Sharpe and Sortino ratios
sharper <- sqrt(252)*sapply(wealthv, function(x) (mean(x)/sd(x)))

# You should get the following output:
sharper
#       VTI  MA Strat 
# 0.3990216 0.6312733 


# Plot a dygraph of the optimal strategy with shading.
# Don't use end dates.
# Your plot should be similar to ewvol_optim.png

### Write your code here
posv <- volma_opt[, "positions"]
crossd <- (rutils::diffit(posv) != 0)
shadev <- posv[crossd]
crossd <- c(zoo::index(shadev), end(posv))
shadev <- ifelse(drop(zoo::coredata(shadev)) == 1, "lightgreen", "antiquewhite")
# Plot Optimal Dual EWMA strategy
dyplot <- dygraphs::dygraph(cumsum(wealthv), main=paste("Optimal Dual EWMA Strategy, Sharpe", paste(paste(names(sharper), round(sharper, 3), sep="="), collapse=", "))) %>%
  dyOptions(colors=c("blue", "red"), strokeWidth=2)
# Add shading to dygraph object
for (i in 1:NROW(shadev)) {
  dyplot <- dyplot %>% dyShading(from=crossd[i], to=crossd[i+1], color=shadev[i])
}  # end for
# Plot the dygraph object
dyplot

