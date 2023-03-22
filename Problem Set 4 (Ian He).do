* This do file has solutions to ECON-5243 Problem Set 4, at The University of Oklahoma
* Author: Ian He
* Date: Mar 22, 2023
***********************************************************************
* Let me clarify something at the beginning: The following coding is used to solve Problem Set 4 in a "correct" way required by Mu-Jeung Yang. I totally disagree a lot of requirements in this problem set, because in pracrice I never used (and will never use) those stupid methods/commands. For example,
* (1) In Problem 2.4, it's inefficient to export our regression results to MS Excel.
* (2) In Problem 2.5, all the three methods (to running a fixed-effect model) are outdated and slow. Luckily we have a relatively small dataset in that case; if we have a big dataset (e.g., Chinese Customs database), then all the three methods will kill your hope for research.
* (3) In Problem 2.9, we can use the "predict" command with the "residuals" option to get the residuals directly.
* Anyway, it's easy to find a good researcher with thousands of publications, but hard to find a good professor with ability to teach just one good lecture.

clear all

* File paths
global localdir "D:\phd\ECON-5243"

global dtadir   "$localdir\Data"
global tabdir   "$localdir\Tables"
global figdir   "$localdir\Figures"



***********************************************************************
**# Problem 1: Data Management
***********************************************************************
clear

** 1.1 Create "pre-period" data
set obs 1000

gen ID = _n

forvalues i = 11/99{
	gen var`i' = runiform()
}

save "$dtadir\HW6_Ex3_preperiod.dta", replace


** 1.2 Create "post-period" data
forvalues i = 11/99{
	replace var`i' = var`i' + 15
}

save "$dtadir\HW6_Ex3_postperiod.dta", replace


** 1.3 Combining datasets using "append" & long data format
* (a)
use "$dtadir\HW6_Ex3_preperiod.dta", clear

gen period = 0

append using "$dtadir\HW6_Ex3_postperiod.dta"

replace period = 1 if period == .

* (b)
isid ID period // Observations are identified at ID-period level.


* (c)
sort ID period

forvalues i = 11/99{
	by ID: gen diff_var`i' = var`i' - var`i'[_n-1]
}


** 1.4 Combining datasets using "merge" & wide data format
* (a)
use "$dtadir\HW6_Ex3_preperiod.dta", clear

forvalues i = 11/99{
	rename var`i' var`i'_0
}

save "$dtadir\HW6_Ex3_postperiod_rename.dta", replace

* (b)
use "$dtadir\HW6_Ex3_postperiod.dta", clear

forvalues i = 11/99{
	rename var`i' var`i'_1
}

* (c)
merge 1:1 ID using "$dtadir\HW6_Ex3_postperiod_rename.dta"
drop _merge

* (d) Wildcards cannot be used in "reshape" command, but we still have a way to save our time: https://www.stata.com/support/faqs/data-management/problems-with-reshape/
unab vars: *_1
local stubs: subinstr local vars "_1" "_", all

reshape long `stubs', i(ID) j(period)

* (e)
sort ID period

forvalues i = 11/99{
	by ID: gen diff_var`i' = var`i'_ - var`i'_[_n-1]
}



***********************************************************************
**# Problem 2: CAPM and APT
***********************************************************************

** 2.1 Data download and pre-processing

* Risk-free rate
* Data (1969--2022): https://fred.stlouisfed.org/series/DGS1
import excel "$dtadir\DGS1.xls", sheet("FRED Graph") cellrange(A11:B65) firstrow clear

gen fyear = yofd(observation_date)
gen r_f = DGS1/100

keep fyear r_f

save "$dtadir\riskfree.dta", replace

* CCM data (1961--2022)
use if _n==1 using "$dtadir\CCM.dta", clear

use GVKEY LINKPRIM fyear csho prcc_f bkvlps conml sic using "$dtadir\CCM.dta", clear

* Definition for primary link marker: https://www.crsp.org/products/documentation/link-history-data
keep if LINKPRIM == "P"
drop if fyear == .

duplicates drop
isid GVKEY fyear

merge m:1 fyear using "$dtadir\riskfree.dta"
drop if _merge != 3
drop _merge


** 2.2 Variable construction

* Market capitalization
gen mcap = prcc_f * csho
label var mcap "Firm market capitalization (annual)"

bysort fyear: egen total_mcap = total(mcap)
gen weight = mcap/total_mcap

* Firm stock excess returns
sort GVKEY fyear
bysort GVKEY: gen sret_1y = (prcc_f[_n+1] - prcc_f)/prcc_f
label var sret_1y "Stock return (annual)"

gen sret_exc = sret_1y - r_f
label var sret_exc "Excess stock return (annual)"

* Market excess returns
bysort fyear: egen mret = total(weight * sret_1y)
label var mret "Market return (annual)"

gen mret_exc = mret - r_f
label var mret_exc "Market excess return (annual)"

save "$dtadir\PS4_CAPM_data.dta", replace


** 2.3 Scatterplot for Apple, Inc.
twoway (lfit sret_exc mret_exc if conml=="Apple Inc", lc(orange) lwidth(medthick)) ///
	(scatter sret_exc mret_exc if conml=="Apple Inc", mc(navy) mlabel(fyear) mlabs(vsmall) mlabc(navy)), ///
	title("Apple Inc") legend(off) ///
	xtitle("Market excess return (annual)") ///
	ytitle("Firm excess stock return (annual)") ///
	xlabel(, labsize(small)) ylabel(, nogrid labsize(small)) ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white))
graph export "$figdir\PS4_Apple_Inc.pdf", replace


** 2.4 CAPM regressions for different companies
reg sret_exc mret_exc if conml=="Apple Inc", robust
outreg2 using "$tabdir\PS4_CAPM_reg.xls", replace ///
	label stats(coef se) dec(3) ///
	title("OLS Estimates Comparison") ctitle(Apple)

reg sret_exc mret_exc if conml=="The Kraft Heinz Co", robust
outreg2 using "$tabdir\PS4_CAPM_reg.xls", append ///
	label stats(coef se) dec(3) ///
	title("OLS Estimates Comparison") ctitle(Kraft Heinz)

reg sret_exc mret_exc if conml=="General Electric Co", robust
outreg2 using "$tabdir\PS4_CAPM_reg.xls", append ///
	label stats(coef se) dec(3) ///
	title("OLS Estimates Comparison") ctitle(GE)


** 2.5 Pooled CAPM regressions
use "$dtadir\PS4_CAPM_data.dta", clear

gen sic2 = substr(sic, 1, 2)

* Method 1: including a series of dummies directly
* This is a stupid method!
tab sic2, gen(sic2_)
tab sic, gen(sic4_)

eststo reg1_1: qui reg sret_exc mret_exc, robust
eststo reg1_2: qui reg sret_exc mret_exc sic2_*, robust
eststo reg1_3: qui reg sret_exc mret_exc sic4_*, robust

estout reg1*, keep(mret_exc _cons) ///
	varlabels(_cons "Constant") label ///
	coll(none) cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) ///
	stats(N r2, nostar labels("Observations" "R-Square") fmt("%9.0fc" 3))

* Method 2: xi command
* This method is not stupid, but not popular.
eststo reg2_1: xi: qui reg sret_exc mret_exc, robust
eststo reg2_2: xi: qui reg sret_exc mret_exc i.sic2, robust
eststo reg2_3: xi: qui reg sret_exc mret_exc i.sic, robust

estout reg2*, keep(mret_exc _cons) ///
	varlabels(_cons "Constant") label ///
	coll(none) cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) ///
	stats(N r2, nostar labels("Observations" "R-Square") fmt("%9.0fc" 3))

* Method 3: areg with absorb()
* This method was popular before the birth of "reghdfe"
eststo reg3_1: qui reg sret_exc mret_exc, robust
eststo reg3_2: qui areg sret_exc mret_exc, absorb(sic2) vce(r)
eststo reg3_3: qui areg sret_exc mret_exc, absorb(sic) vce(r)

estout reg3*, keep(mret_exc _cons) ///
	varlabels(_cons "Constant") label ///
	coll(none) cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) ///
	stats(N r2, nostar labels("Observations" "R-Square") fmt("%9.0fc" 3))

* Comparison and report the results in LaTeX
estout reg1* reg2* reg3*, keep(mret_exc _cons) ///
	varlabels(_cons "Constant") label ///
	coll(none) cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) ///
	stats(N r2, nostar labels("Observations" "R-Square") fmt("%9.0fc" 3))

local digit = 3
estout reg1* using "$tabdir\PS4_pooled_reg.tex", keep(mret_exc) ///
	label varlabels(_cons "Constant") mlab(none) coll(none) ///
	cells(b(star fmt(`digit')) se(par fmt(`digit'))) ///
	starlevels(* .1 ** .05 *** .01) sty(tex) ///
	preh("\begin{tabular}{p{0.3\textwidth}p{0.15\textwidth}p{0.15\textwidth}p{0.15\textwidth}}" "\hline \hline" ///
		"& (1) & (2) & (3) \\" ///
		"& OLS & FE & FE \\ \hline" ) ///
	prefoot("\hline" ///
		"SIC2 FE      &  & \checkmark &  \\ " ///
		"SIC4 FE      &  &  & \checkmark \\ ") ///
	stats(N r2_a, nostar labels("Observations" "Adjusted R-Squared") fmt("%9.0fc" 3)) ///
	postfoot("\hline\hline" ///
		"\end{tabular}") replace


** 2.6 Construct Fama-French factor (SML)
use "$dtadir\PS4_CAPM_data.dta", clear

* Percentile
bysort fyear: egen pct10 = pctile(mcap), p(10)
bysort fyear: egen pct90 = pctile(mcap), p(90)

gen high_pct = (mcap > pct90)
gen low_pct = (mcap < pct10)

* Average stock returns
bysort fyear: egen av_sret_h = mean(sret_1y) if high_pct==1
bysort fyear: egen av_sret_l = mean(sret_1y) if low_pct==1

* SML factor
bysort fyear: egen rL = min(av_sret_h)
bysort fyear: egen rS = min(av_sret_l)

gen SML = rS - rL

sum SML


** 2.7 Fama-French factor (HML)
gen BTM = bkvlps/prcc_f

* Percentile
bysort fyear: egen BTM10 = pctile(BTM), p(10)
bysort fyear: egen BTM90 = pctile(BTM), p(90)

gen high_BTM = (BTM > BTM90)
gen low_BTM = (BTM < BTM10)

* Average stock returns
bysort fyear: egen av_BTM_h = mean(BTM) if high_BTM==1
bysort fyear: egen av_BTM_l = mean(BTM) if low_BTM==1

* HML factor
bysort fyear: egen rH = min(av_BTM_h)
bysort fyear: egen rLow = min(av_BTM_l)

gen HML = rH - rLow

sum HML


** 2.8 Multivariate regression
eststo mul_reg: reg sret_exc mret_exc SML HML, robust

estout mul_reg, ///
	varlabels(_cons "Constant") label ///
	coll(none) cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) ///
	stats(N r2, nostar labels("Observations" "R-Square") fmt("%9.0fc" 3))

local digit = 3
estout mul_reg using "$tabdir\PS4_multivar_reg.tex", ///
	label varlabels(_cons "Constant") mlab(none) coll(none) ///
	cells(b(star fmt(`digit')) se(par fmt(`digit'))) ///
	starlevels(* .1 ** .05 *** .01) sty(tex) ///
	preh("\begin{tabular}{p{0.25\textwidth}p{0.2\textwidth}}" "\hline \hline" ///
		"Outcome var. & Firm excess returns \\ \hline" ) ///
	prefoot("\hline") ///
	stats(N r2_a, nostar labels("Observations" "Adjusted R-Squared") fmt("%9.0fc" 3)) ///
	postfoot("\hline\hline" ///
		"\end{tabular}") replace


** 2.9 Partitioned regression
eststo part_reg1: reg sret_exc SML HML, robust
predict xr_i_hat, xb
gen resid1 = sret_exc - xr_i_hat

eststo part_reg2: reg mret_exc SML HML if sret_1y!=., robust // I use "if" to make sure the regression in each step uses the same sample; otherwise, the FWL theorem won't hold.
predict xr_m_hat, xb
gen resid2 = mret_exc - xr_m_hat

eststo part_reg3: reg resid1 resid2, robust

estout mul_reg part_reg*, ///
	varlabels(_cons "Constant") label ///
	coll(none) cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) ///
	stats(N r2, nostar labels("Observations" "R-Square") fmt("%9.0fc" 3))


***********************************************************************
**# Problem 3: The Impact of Marketing Spending on Firm Profits
clear

** 3.1 Simulating the true data
set obs 100000

* Market spending
set seed 1
gen X1 = rnormal(0, 3)

* Management quality
set seed 2
gen Z2 = rnormal()
gen X2 = 1/2 * X1 + 1/2 * Z2

* Profit
set seed 3
gen Z3 = rnormal()
gen Y = 15 - 0.5*X1 + 2*X2 + Z3

reg Y X1 X2, robust


** 3.2 Omitting the management quality variable
reg Y X1, robust


** 3.3 Introducing a noisy proxy variable for management quality
gen X2M = 1/2*X1 + 2*Z2

reg Y X1 X2M, robust


** 3.4 Perfectly measure management quality, but with high marketing correlation
gen X2alt = 1/2*X1 + 0.001*Z2
gen Yalt = 15 - 0.5*X1 + 2*X2alt

reg Yalt X1 X2alt, robust