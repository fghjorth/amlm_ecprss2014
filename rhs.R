# Reproducing Rabe-Hesketh & Skrondal (RHS) in R

# Ch 2

require(foreign)
pefr<-read.dta("http://www.stata-press.com/data/mlmus3/pefr.dta")

pefr$mean_wm <- (pefr$wm1+pefr$wm2)/2

summary(pefr$mean_wm)
sd(pefr$mean_wm)
