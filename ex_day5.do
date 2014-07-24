clear

set more off, perm

// NESTED RE MODELS

// get ESS5 data
//use ESS5_id-pweight n1_gdp_2009 using "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\ESSMDW5e2_F1", clear

use ESS5_id-pweight n1_gdp_2009 using "/Users/frederikhjorth/Dropbox/ECPRmultilevel/Day1/ESSMDW5e2_F1", clear

egen nuts1 = group(NUTS1) // numeric NUTS1 indicator

estat icc // calculate ICC

xtmixed stflife hinctnta agea c.agea#c.agea maritalb mnactic eisced || nuts1:, mle

egen cntry1 = group(cntry) // numeric country indicator

xtmixed stflife hinctnta agea c.agea#c.agea maritalb mnactic eisced || cntry1: || nuts1:, mle

estat icc // calculate ICC

clear

// CROSSED RE MODELS

// open replication data
insheet using "/Users/frederikhjorth/Dropbox/ECPRmultilevel_fh/AJPS_democraticdeficit_allmodels_replicationdata.csv"

//inspect key variables
codebook haveliberalpolicy rescaleopinion rescalenytbypolicygroupfull issuefull ostatefull


// simple logits, ignoring level 2
logit haveliberalpolicy rescaleopinion rescalenytbypolicygroupfull 
logit haveliberalpolicy rescaleopinion rescalenytbypolicygroupfull c.rescaleopinion#c.rescalenytbypolicygroupfull

//multilevel logits: random intercept

xtmelogit haveliberalpolicy rescaleopinion rescalenytbypolicygroupfull c.rescaleopinion#c.rescalenytbypolicygroupfull || issuefull:,

xtmelogit haveliberalpolicy rescaleopinion rescalenytbypolicygroupfull c.rescaleopinion#c.rescalenytbypolicygroupfull || ostatefull:, 

xtmelogit haveliberalpolicy rescaleopinion rescalenytbypolicygroupfull c.rescaleopinion#c.rescalenytbypolicygroupfull || ostatefull: || issuefull:,

//crossed random-intercept (Laplacian approximation)
xtmelogit haveliberalpolicy rescaleopinion rescalenytbypolicygroupfull c.rescaleopinion#c.rescalenytbypolicygroupfull || _all:R.issuefull || ostatefull:, intpoints(1)

xtmelogit haveliberalpolicy rescaleopinion rescalenytbypolicygroupfull c.rescaleopinion#c.rescalenytbypolicygroupfull rescaleewmfull powerfulfullstrongbalance || _all:R.issuefull || ostatefull:, intpoints(1)


//save estimates from Laplacian approximation to use as starting values in mle using adaptive quadrature
//note: even when using this trick, this estimation is VERY time-consuming
matrix a = e(b)

//estimate using 3 integration points, starting values saved from previous model
xtmelogit haveliberalpolicy rescaleopinion rescalenytbypolicygroupfull c.rescaleopinion#c.rescalenytbypolicygroupfull || _all:R.issuefull || ostatefull:, intpoints(3) from(a,copy) refineopts(iterate(0))
