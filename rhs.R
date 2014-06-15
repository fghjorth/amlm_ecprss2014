# Reproducing Rabe-Hesketh & Skrondal (RHS) in R

# Ch 2

#2.3
require(foreign)
pefr<-read.dta("http://www.stata-press.com/data/mlmus3/pefr.dta")

pefr$mean_wm <- (pefr$wm1+pefr$wm2)/2

summary(pefr$mean_wm)
sd(pefr$mean_wm)

require(ggplot2)
ggplot(pefr) +
  geom_point(aes(x=id,y=wm1,colour=1)) +
  geom_point(aes(x=id,y=wm2,colour=2)) +
  geom_hline(yintercept=mean(pefr$mean_wm)) +
  theme_bw() +
  theme(legend.position="none")

#2.5.1
pefr.long<-data.frame(id=rep(pefr$id,2),wp=c(pefr$wp1,pefr$wp2),wm=c(pefr$wm1,pefr$wm2),occasion=c(rep(1,nrow(pefr)),rep(2,nrow(pefr))))

#2.5.2
require(lme4)
vim1<-lmer(wm~1+(1|id),data=pefr.long)

summary(vim1)

(vim1.psi<-attr(summary(vim1)$varcor$id,"stddev")^2)

(vim1.theta<-attr(summary(vim1)$varcor,"sc")^2)

(vim1.icc<-vim1.psi/(vim1.psi+vim1.theta)) # ICC


#2.6.2

require(lmerTest)

rand(vim1) #likelihood ratio test

anova(lm(wm~factor(id),data=pefr.long),lm(wm~1,data=pefr.long)) #F-test


