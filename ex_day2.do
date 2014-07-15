// DAY 2

clear

set more off, perm

use "Z:\Data\wvs5_ecprmlm" // this takes a while to load

codebook IT c_ticpi_2009 c_gdppc_2009 yrbrn ctzcntr eisced ppltrst pplfair pplhlp

alpha ppltrst pplfair pplhlp, gen(soctrust) // social trust scale

ssc install estout, replace // get the estout package

replace c_gdppc_2009 = round(c_gdppc_2009,1) // correct rounding error in gdp data

reg IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust // naive OLS model

eststo OLS

reg IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust, cluster(country) // OLS w clustered se's

eststo OLSrob

esttab OLS OLSrob, se // compare models

xtset country

quietly xtreg IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust, mle

eststo MLMmle

quietly xtreg IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust, re

eststo MLMre

quietly xtreg IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust, fe

eststo MLMfe

esttab MLMmle MLMre MLMfe // compare maximum likelihood (mle), gls (re), and fixed effects (fe)

xtreg IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust, mle

gen tempincluded = e(sample)

graph dot (mean) tempincluded, over(country,sort(tempincluded)) // graph how many r's included by country

xtreg IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust hinctnta, mle

gen tempincluded_hh = e(sample)

graph dot (mean) tempincluded_hh, over(country,sort(tempincluded_hh))

local xvarlist "c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust" // save list of iv's
reg IT `xvarlist'
// foreach var in `xvarlist' { // commented out - this takes a TON of time
// if (substr("`var'",1,2)=="i.") continue
// acprplot `var', lowess name(acpr_`var')
// }

xtmixed IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust || country: , mle

predict res, r

hist res, graphregion(color(white)) // inspect residuals

xtmixed IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust || country: , mle var

estat icc

display .15/(.15+3.1) // manual icc computation

ssc install mlt, replace // install outlier detection package

mltcooksd

pause on
levelsof cntry, local(ct)
foreach con of local ct {
di "" ""
di "Omitted panel: `con'"
xtmixed IT c_ticpi_2009 c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust || country: if "`con'"!=cntry, mle noretable
pause
}
pause off

// ASSIGNMENTS

codebook crvctwr imsmetn 

xtmixed crvctwr imsmetn c_gdppc_2009 yrbrn i.gndr i.ctzcntr i.eisced soctrust || country:, mle

save "Z:\Data\wvs5_ecprmlm", replace
