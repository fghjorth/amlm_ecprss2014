// DAY 3

clear

set more off, perm

use "Z:\Data\wvs5_ecprmlm" 

codebook jdgcbrb plccbrb, tab(100)

alpha jdgcbrb plccbrb, gen(expcorrup)

xtset country

xtreg expcorrup c_ticpi_2009, mle

xtreg IT c_ticpi_2009 c_gdppc_2009 i.gndr i.eisced i.ctzcntr yrbrn expcorrup, mle 

eststo full

xtreg IT c_ticpi_2009 c_gdppc_2009 i.gndr i.eisced i.ctzcntr yrbrn if e(sample), mle

eststo reduced

esttab reduced full // compare models with and without expcorrup to assess mediation

estimates restore full

eststo remle

xtreg IT c_ticpi_2009 c_gdppc_2009 i.gndr i.eisced i.ctzcntr yrbrn expcorrup, fe

eststo fe

hausman fe remle, eq(1:1)
hausman fe remle, eq(1:1) sigmamore

recode gndr ctzcntr (2=0)
tab eisced, gen(dedu)

quietly xtreg IT c_ticpi_2009 c_gdppc_2009 gndr dedu2-dedu8 ctzcntr yrbrn expcorrup, mle 

eststo remledummy

esttab remle remledummy

quietly xtreg IT c_ticpi_2009 c_gdppc_2009 gndr dedu2-dedu8 ctzcntr yrbrn expcorrup, fe

eststo fedummy

foreach var of varlist gndr dedu2-dedu8 ctzcntr yrbrn expcorrup {
egen M`var' = mean(`var') if e(sample), by(country)
}

quietly xtreg IT c_ticpi_2009 c_gdppc_2009 gndr dedu2-dedu8 ctzcntr yrbrn expcorrup Mgndr Mdedu2-Mdedu8 Mctzcntr Myrbrn Mexpcorrup, mle 

eststo hybridCM

esttab fedummy remledummy hybridCM

testparm M* //test if all group mean parameters = 0

foreach var of varlist gndr dedu2-dedu8 ctzcntr yrbrn expcorrup {
gen dev_`var' = `var'-M`var'
}

quietly xtreg IT c_ticpi_2009 c_gdppc_2009 gndr dedu2-dedu8 ctzcntr yrbrn expcorrup Mgndr Mdedu2-Mdedu8 Mctzcntr Myrbrn Mexpcorrup dev_gndr dev_dedu2-dev_dedu8 dev_ctzcntr dev_yrbrn dev_expcorrup, mle 

eststo hybridCMC

esttab fedummy remledummy hybridCM hybridCMC

clear

//use ESS5_id-pweight n1_gdp_2009 using "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\ESSMDW5e2_F1", clear

use ESS5_id-pweight n1_gdp_2009 using "/Users/frederikhjorth/Dropbox/ECPRmultilevel/Day1/ESSMDW5e2_F1", clear


codebook stflife hinctnta agea maritalb mnactic eisced NUTS1

egen nuts1 = group(NUTS1) // numeric NUTS1 indicator

quietly xtmixed stflife || nuts1:, mle

estat icc // calculate ICC

eststo lifesat_nuts

quietly xtmixed stflife if e(sample), mle

eststo lifesat_null

lrtest lifesat_null lifesat_nuts // LR test of null and multilevel models

quietly xtmixed stflife hinctnta agea c.agea#c.agea maritalb mnactic eisced || nuts1:, mle

eststo ri

ssc install coefplot, replace

coefplot ri, drop(_cons) msize(small) scheme(s1mono)

estat sum

margins, at(agea=(14(5)101))
marginsplot, recastci(rarea) recast(line) 

xtmixed stflife hinctnta agea c.agea#c.agea maritalb mnactic eisced || nuts1:hinctnta, covariance(unstructured) mle

eststo rc

lrtest rc ri // test whether slopes vary significantly across regions

predict ebs ebi, reffects // empirical bayes slope deviations

replace ebs = _b[stflife:hinctnta] + ebs

gen lngdp = ln(n1_gdp_2009)

global ms = _b[stflife:hinctnta]

egen pickone = tag(nuts1)

twoway (scatter ebs lngdp) (lowess ebs lngdp), yline($ms) //plot without labels

twoway (scatter ebs lngdp mlabel(NUTS1)) (lowess ebs lngdp), yline($ms) //plot without labels

// ASSIGNMENTS

clear

use "Z:\Data\wvs5_ecprmlm"

xtset country

xtreg crvctwr imsmetn c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust, mle

eststo remle

xtset crvctwr imsmetn c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust, fe

eststo fe

hausman fe remle, eq(1:1) sigmamore

xtmixed crvctwr imsmetn c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust || country:imsmetn, mle

eststo ex2_rc

xtmixed crvctwr imsmetn c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust || country:, mle

eststo ex2_ri

lrtest ex2_ri ex2_rc
