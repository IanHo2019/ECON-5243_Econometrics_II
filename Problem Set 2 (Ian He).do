* This do file has solutions to ECON-5243 Problem Set 2, at The University of Oklahoma
* Author: Ian He
* Date: Feb 11, 2023
***********************************************************************

clear all

* File paths
global localdir "D:\phd\ECON-5243"

global dtadir   "$localdir\Data"
global tabdir   "$localdir\Tables"



***********************************************************************
**# Problem 2. Law of Iterated Expectations in STATA
set obs 1000
set seed 1

* Create three variables
gen X = rnormal(5,1)
gen U = rnormal(0,1)
gen Y = X + U

* Show E[E(Y|X)] = E(Y)
summarize X
local Xbar = `r(mean)'

reg Y X

gen Yhat = _b[_cons] + `Xbar' * _b[X]

display Yhat[1]

summarize Y // Yhat should be equal to mean of Y.



***********************************************************************
**# Problem 4. Multivariate OLS by hand
clear

set obs 7

gen y = 2
replace y = 1 in 2
replace y = 6 in 3
replace y = 1 in 4
replace y = 3 in 5
replace y = 3 in 6
replace y = 4 in 7

gen x1 = 1
replace x1 = 0 in 2
replace x1 = 3 in 3
replace x1 = 2 in 4
replace x1 = 4 in 5
replace x1 = 2 in 6
replace x1 = 3 in 7

gen x2 = 0
replace x2 = 1 in 2
replace x2 = 1 in 3
replace x2 = -1 in 4
replace x2 = 0 in 5
replace x2 = 0 in 6
replace x2 = 0 in 7

save "$dtadir\PS2_OLS_data.dta", replace

** Export as excel for coding in MATLAB
export excel "$dtadir\PS2_problem4_data.xls", firstrow(variables) replace


* (1)
use "$dtadir\PS2_OLS_data.dta", clear

gen x1y = x1 * y
gen x1sq = (x1)^2

egen tot_x1y = total(x1y)
egen tot_x1sq = total(x1sq)
display tot_x1y[1]/tot_x1sq[1]

** Note: you need install 'estout' package for using 'eststo' command.
eststo reg1: reg y x1, nocons


* (2)
eststo reg2: reg y x1 x2, nocons

dis _se[x1]^2
dis _se[x2]^2


* (3)
eststo reg3: reg y x1 x2

dis _se[_cons]^2
dis _se[x1]^2
dis _se[x2]^2


* (4)
egen y_m = mean(y)
egen x1_m = mean(x1)
egen x2_m = mean(x2)

gen ystar = y - y_m
gen x1star = x1 - x1_m
gen x2star = x2 - x2_m

eststo reg4: reg ystar x1star x2star

dis _se[_cons]^2
dis _se[x1star]^2
dis _se[x2star]^2

* Compare results
estout reg2 reg3 reg4, ///
	varlabels(_cons "Constant") label ///
	coll(none) cells(b(star fmt(4)) var(par fmt(4))) ///
	starlevels(* .1 ** .05 *** .01) ///
	stats(N r2, nostar labels("Observations" "R-Square") fmt(0 4))

* Export a table to LaTeX
local digit = 4

estout reg2 reg3 reg4 using "$tabdir\PS2_reg_comparison.tex", ///
	varlabels(_cons "Constant") label mlab(none) coll(none) ///
	cells(b(fmt(`digit')) var(par fmt(`digit'))) sty(tex) ///
	preh("\begin{tabular}{p{0.15\textwidth}p{0.15\textwidth}p{0.15\textwidth}p{0.15\textwidth}}" "\hline \hline" ///
		"& (2) & (3) & (4) \\" ///
		"Dependent var. & y_i & y_i & y_i^* \\ \hline" ) ///
	postfoot("\hline\hline" "\end{tabular}") replace



***********************************************************************
* If you are using Microsoft Word to report your regression results, 'estout' is not helpful to you. I recommend 'asdoc' and 'outreg2' packages.
* Disadvantages: (1) both packages cannot report variances of estimates. (2) we cannot set up the statistics (e.g., r2 and nob) flexibly.

** asdoc
use "$dtadir\PS2_OLS_data.dta", clear

egen y_m = mean(y)
egen x1_m = mean(x1)
egen x2_m = mean(x2)

gen ystar = y - y_m
gen x1star = x1 - x1_m
gen x2star = x2 - x2_m

asdoc reg y x1 x2, nocons ///
	nest replace title(OLS Estimates Comparison) ///
	dec(4) save($tabdir\PS2_reg_comparison_a.doc)
	
asdoc reg y x1 x2, ///
	nest append dec(4) save($tabdir\PS2_reg_comparison_a.doc)

asdoc reg ystar x1star x2star, ///
	nest append dec(4) save($tabdir\PS2_reg_comparison_a.doc)


** outreg2
reg y x1 x2, nocons
outreg2 using "$tabdir\PS2_reg_comparison_b.doc", replace ///
	stats(coef se) noaster nor2 noobs ///
	title("OLS Estimates Comparison") ctitle(y_i)

reg y x1 x2
outreg2 using "$tabdir\PS2_reg_comparison_b.doc", append ///
	stats(coef se) noaster dec(4) nor2 noobs ctitle(y_i)

reg ystar x1star x2star
outreg2 using "$tabdir\PS2_reg_comparison_b.doc", append ///
	stats(coef se) noaster dec(4) nor2 noobs ctitle(y_i^*)
