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
vim1<-lmer(wm~1+(1|id),data=pefr.long,REML=F)

summary(vim1)

(vim1.psi<-attr(summary(vim1)$varcor$id,"stddev")^2)

(vim1.theta<-attr(summary(vim1)$varcor,"sc")^2)

(vim1.icc<-vim1.psi/(vim1.psi+vim1.theta)) # ICC


#2.6.2

require(lmerTest)

rand(vim1) #likelihood ratio test

summary(fem1<-lm(wm~factor(id),data=pefr.long))

anova(fem1,lm(wm~1,data=pefr.long)) #F-test


#2.9

pefr.long$occ2<-ifelse(pefr.long$occasion==2,1,0)

summary(cem1<-lmer(wm~occ2+(1|id),data=pefr.long,REML=F)) #crossed effects model

#2.10.3

se.bf<-sqrt(vim1.theta/length(pefr.long$id)) #fixed effects model se

se.ols<-summary(lm(wm~1,data=pefr.long))$coefficients[1,2] #ols se

require(arm)
se.b<-se.fixef(vim1) #RE model se

barplot(c(se.bf,se.ols,se.b),names=c("SE(B.F)","SE(B.OLS)","SE(B)"))

#2.11.1

ranef(vim1) #ML intercept estimates 

#2.11.2

(vim1.ebr<-vim1.psi/(vim1.psi+vim1.theta/2)) # empirical bayes shrinkage factor R

ebests<-ranef(vim1)$id*vim1.ebr

ebests

### Chapter 3
rm(list=(ls(all=T)))

sm<-read.dta("http://www.stata-press.com/data/mlmus3/smoking.dta")

#3.4.1
summary(vim2<-lmer(birwt~smoke+male+mage+hsgrad+somecoll+collgrad+married+black+kessner2+kessner3+novisit+pretri2+pretri3+(1|momid),data=sm,REML=F))

#3.5
summary(vim2null<-lmer(birwt~1+(1|momid),data=sm,REML=F))

vim2totvar<-attr(summary(vim2)$varcor$momid,"stddev")^2+attr(summary(vim2)$varcor,"sc")^2

vim2nulltotvar<-attr(summary(vim2null)$varcor$momid,"stddev")^2+attr(summary(vim2null)$varcor,"sc")^2

(vim2rsq<-(vim2totvar-vim2nulltotvar)/vim2nulltotvar)

#3.7.5

as.numeric(sm$smoke)
sm$mn_smok<-NA
sm$dev_smok<-NA
momids<-unique(sm$momid)

mean(as.numeric(sm$smoke[sm$momid==sm$momid[1]])-1,na.rm=T)

for (i in 1:nrow(sm)){
  sm$mn_smok[i]<-mean(as.numeric(sm$smoke[sm$momid==sm$momid[i]])-1,na.rm=T)
  sm$dev_smok[i]<-as.numeric(sm$smoke[i])-1-sm$mn_smok[i]
}

summary(vim3<-lmer(birwt~dev_smok+mn_smok+male+mage+hsgrad+somecoll+collgrad+married+black+kessner2+kessner3+novisit+pretri2+pretri3+(1|momid),data=sm,REML=F))
