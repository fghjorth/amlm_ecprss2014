// Exercises day 1

clear

//WVS data
use "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\wvs5"

describe

// data browser opened using data -> data editor (browse)

//QoG data
use "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\qog_std_cs_20dec13"

describe

//Merge
use "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\wvs5"

clonevar ccode = s003

merge m:1 ccode using "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\qog_std_cs_20dec13"

tab s003 if _merge==1
tab ccode if _merge==2

// Open Allan Scruggs
use "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\allan_scruggs"

keep if year==1999

describe

tab country

//doedit "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\lookupid"

include "C:\Users\fh\Dropbox\ECPRmultilevel_fh\lookupid_edited"

rename id_new s003

save "C:\Users\fh\Dropbox\ECPRmultilevel_fh\allan_scruggs_iso"

use "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\wvs5"

merge m:1 s003 using "C:\Users\fh\Dropbox\ECPRmultilevel_fh\allan_scruggs_iso"

//save "C:\Users\fh\Dropbox\ECPRmultilevel_fh\wvs5_allan_scruggs_iso"

// ESS5

clear

use "C:\Users\fh\Dropbox\ECPRmultilevel\Day1\ESSMDW5e2_F1"

describe

tab inwyye

tab cntry

egen country = group(cntry)

xtset country

codebook trstlgl-trstun, tab(100)

alpha trstlgl trstplc trstplt trstprt, casewise item

//run forach loop getting alpha by country
levelsof cntry, local(cname)
foreach coname of local cname {
qui: alpha trstlgl trstplc trstplt trstprt if cntry=="`coname'", casewise item
display "`coname': " `r(alpha)' "(alpha)" 
}
//looks fine

alpha trstlgl trstplc trstplt trstprt, gen(IT) min(2)

sum IT

hist IT, graphregion(color(white))

mean IT, over(country)

graph dot (mean) IT, over(country,sort(IT)) graphregion(color(white))

xtreg IT, mle

xtreg IT, fe

xtreg IT, re

xttest0

display e(sigma_e)^2

display e(sigma_u)^2

display e(sigma_u)^2/(e(sigma_e)^2+e(sigma_u)^2)

//ASSIGNMENTS

//probably varies btw countries: gay rights
tab freehms

xtreg freehms, re

xttest0

display e(sigma_u)^2/(e(sigma_e)^2+e(sigma_u)^2)

//probably doesn't vary btw countries (???): how often job prevents time w family

xtreg jbprtfp, re

xttest0

display e(sigma_u)^2/(e(sigma_e)^2+e(sigma_u)^2)
