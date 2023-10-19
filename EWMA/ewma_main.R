# Summary: Simulate the Hampel strategy to find 
# the best values of the look-back and threshold 
# parameters.

# Calculate VTI percentage returns
closep <- log(quantmod::Cl(rutils::etfenv$VTI))
colnames(closep) <- "VTI"
retp <- rutils::diffit(closep)
# Define look-back window
look_back <- 11
# Define threshold value
threshv <- 2.5

sim_hampel <- function(look_back, threshv){
  nrows <- NROW(closep)
  medianv <- HighFreq::roll_mean(closep, look_back, method="nonparametric")
  madv <- HighFreq::roll_var(closep, look_back=look_back, method="nonparametric")
  zscores <- ifelse(madv > 0, ((closep - medianv)/madv), 0)
  zscores[1:look_back, ] <- 0
  range(zscores)
  posv <- rep(NA_integer_, nrows)
  posv[1] <- 0
  posv[zscores > threshv] <- (-1)
  posv[zscores < -threshv] <- 1
  posv <- zoo::na.locf(posv)
  posv <- rutils::lagit(posv)
  ntrades <- sum(abs(rutils::diffit(posv)) > 0)
  retv <- rutils::diffit(closep)
  pnls <- retv*posv
}

# Run sim_hampel() as follows:
pnls <- sim_hampel(look_back=look_back, threshv=threshv)

# You should get the following outputs:
class(pnls)
# [1] "xts" "zoo"
dim(pnls)
# [1] 4915    1
sqrt(252)*mean(pnls)/sd(pnls)
# [1] 0.4243437

threshv <- seq(0.8, 3.0, 0.2)

# Perform an lapply() loop over the thresholds, 
# with look_back = 11.  Collapse the list into an
# xts time series called pnls.
# You can use the functions do.call() and cbind().

### write your code here
pnls <- lapply(threshv, function(threshold) {
  sim_hampel(look_back=look_back, threshv=threshold)
}) # end lapply

pnls <- do.call(cbind, pnls)

# You should get the following outputs:
class(pnls)
# [1] "xts" "zoo"
dim(pnls)
# [1] 4987  12


# Calculate the ratios: sqrt(252)*mean(pnls)/sd(pnls)
# for all the columns of pnls.
# You can use the functions sapply(), mean(), sd(), 
# names(), and paste0().

### write your code here
sharper <- sqrt(252)*sapply(pnls, function(xtsv){ 
  mean(xtsv)/sd(xtsv)
}) # end sapply

names(sharper) <- paste0("thresh=", threshv)

# You should get the following output:
sharper
# thresh=0.8   thresh=1 thresh=1.2 thresh=1.4 thresh=1.6 thresh=1.8   thresh=2 
#  0.1625175  0.2530911  0.3105731  0.4288339  0.2882965  0.3259635  0.4626788 
# thresh=2.2 thresh=2.4 thresh=2.6 thresh=2.8   thresh=3 
#  0.4585613  0.4657205  0.4127812  0.2974800  0.3627275 

# Plot sharper using plot().
# Your plot should be similar to strat_hampel_thresholds.png
plot(threshv, sharper, type = "l")


# Calculate the threshold value that produces the 
# maximum ratio.
# You can use the functions which.max() and max().

sharper_max <- threshv[which.max(sharper)]
sharper_max
# You should get the following output:
# [1] 2.4

# Calculate the second largest sharper value.
# You can use the function sort().
# Or you can use the functions which.max() and max().


sharp_sort <- sort(sharper, decreasing = TRUE)
max2 <- unname(sharp_sort[2])
# You should get the following output:
max2
# [1] 0.4626788

# Calculate the threshold value that produces the 
# second largest sharper value.
# You can use the function which().

sharp2 <- unname(which(sharper == max2))
sharp2 <- threshv[sharp2]
sharp2
# You should get the following output:
# [1] 2.0

look_backs <- 3:15

# Perform an lapply() loop over the look_backs, 
# with threshold = 2.4.  Collapse the list into an
# xts time series called pnls.
# You can use the functions do.call() and cbind().

### write your code here
threshv <- 2.4
pnls <- lapply(look_backs, function(look) {
  sim_hampel(look_back=look, threshv=threshv)
}) # end lapply

pnls <- do.call(cbind, pnls)

# You should get the following outputs:
class(pnls)
# [1] "xts" "zoo"
dim(pnls)
# [1] 4915   13


# Calculate the ratios: sum(x)/sd(x)
# for all the columns of pnls.
# You can use the functions sapply(), mean(), sd(), 
# names(), and paste0().

### write your code here
sharper <- sqrt(252)*sapply(pnls, function(xtsv){ 
  mean(xtsv)/sd(xtsv)
})
names(sharper) <- paste0("look_back=", look_backs)


# You should get the following output:
sharper
# look_back=3  look_back=4  look_back=5  look_back=6  look_back=7  look_back=8  look_back=9 
#  0.23739881   0.07259361   0.32013614   0.22043306   0.35153403   0.47232560   0.45304148 
# look_back=10 look_back=11 look_back=12 look_back=13 look_back=14 look_back=15 
#  0.51875039   0.46572054   0.10049611   0.39874745   0.35612289   0.37753432 

# Calculate the look_back value that produces the 
# maximum ratio.
# You can use the functions which.max() and max().

sharper_max <- look_backs[which.max(sharper)]
sharper_max
# You should get the following output:
# [1] 10

# Calculate the Hampel pnls for the optimal parameters 
# using function sim_hampel().

### write your code here
look_back <- 10
threshv <- 2.4

pnls <- sim_hampel(look_back=look_back, threshv=threshv)

# Plot dygraph of Hampel strategy pnls.

library(dygraphs)
wealthv <- cbind(retp, pnls)
colnames(wealthv) <- c("VTI", "Strategy")

colorv <- c("blue", "red")
endd <- rutils::calc_endpoints(wealthv, interval="weeks")
dygraphs::dygraph(cumsum(wealthv)[endd], main="VTI Hampel Strategy") %>%
  dyOptions(colors=colorv, strokeWidth=1) %>%
  dyLegend(show="always", width=480)

