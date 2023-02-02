* This do file has solutions to ECON-5243 Problem Set 1, at The University of Oklahoma
* Author: Ian He
* Date: Feb 1, 2023
***********************************************************************

clear all

* File paths
global localdir "D:\phd\ECON-5243"

global dtadir   "$localdir\Data"
global figdir   "$localdir\Figures"



***********************************************************************
**# Problem 1. Create a "propulation" of random observations
clear

* (a)
set obs 10000
set seed 1
gen U = runiform()

* (b)
gen S = invnormal(U)

* (c)
gen X = rnormal(15, 5)

* (d)
summarize U S X

* (e)
histogram X, percent ///
    xtitle("X") ytitle("Percent") ///
    xlabel(, labsize(small)) ylabel(, nogrid angle(0) labsize(small)) ///
    fcolor(navy) lcolor(navy) ///
    yline(0(2)8, lc(gs13) lp(shortdash)) ///
    plotregion(fcolor(white) lcolor(white)) ///
    graphregion(fcolor(white) lcolor(white))
graph export "$figdir\PS1_hist_X.pdf", replace

save "$dtadir\PS1_population.dta", replace



***********************************************************************
**# Problem 2. Sampling
use "$dtadir\PS1_population.dta", clear

* (a)
gen sample6 = (_n<=5000)
gen sample5 = (_n<=1000)
gen sample4 = (_n<=500)
gen sample3 = (_n<=100)
gen sample2 = (_n<=50)
gen sample1 = (_n<=10)

* (b)
** Histograms for six samples
forvalues s = 1/6 {
	histogram X if sample`s'==1, percent bin(30) ///
		xtitle("X") ytitle("Percent") ///
		xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) ///
		fcolor(navy) lcolor(navy) ///
		name(sample`s', replace) ///
		title("Sample `s'", color(black) size(medlarge) position(11)) ///
		plotregion(fcolor(white) lcolor(white)) ///
		graphregion(fcolor(white) lcolor(white))

	graph save "$figdir\Sample`s'.gph", replace
}

graph combine "$figdir\Sample1.gph" "$figdir\Sample2.gph" "$figdir\Sample3.gph" "$figdir\Sample4.gph" "$figdir\Sample5.gph" "$figdir\Sample6.gph", ///
	graphregion(fcolor(white) lcolor(white)) ///
	name(sample_hist, replace) cols(3)
graph export "$figdir\PS1_hist_samples.pdf", replace

** Histogram for population
histogram X, percent bin(30) ///
    xtitle("X") ytitle("Percent") ///
    xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) ///
    fcolor(navy) lcolor(navy) ///
    plotregion(fcolor(white) lcolor(white)) ///
    graphregion(fcolor(white) lcolor(white))
graph export "$figdir\PS1_hist_X_bin30.pdf", replace

* (c)
forvalues s = 1/6 {
	sum X if sample`s'==1
}



***********************************************************************
**# Problem 3. Model of entrepreneurial survival
use "$dtadir\PS1_population.dta", clear

* (a)
local FE = "10"
gen surviver = (X>=`FE')

** average accounting profits
sum X if surviver==1 // X captures the accounting profits
display `r(mean)'

** survival fraction
sum surviver
display `r(mean)'

* (b)
local FE = "20"
drop surviver
gen surviver = (X>=`FE')

sum X if surviver==1
display `r(mean)'

sum surviver
display `r(mean)'



***********************************************************************
**# Problem 4. Profits in the health insurance industry
use "$dtadir\PS1_population.dta", clear

* (a)
gen P1 = 16
gen profit_a = P1 - X

sum profit_a
display `r(mean)'

* (b)
gen buyer = (X>=P1)
gen profit_b = P1 - X if buyer==1

sum profit_b
display `r(mean)'

egen num_buyer = total(buyer)
display num_buyer[1]

* (c)
gen P2 = 18
gen P3 = 22

gen buyer2 = (X>=P2)
gen buyer3 = (X>=P3)

gen profit_c1 = P2 - X if buyer2==1
gen profit_c2 = P3 - X if buyer3==1

sum profit_c1 profit_c2

egen num_buyer_c1 = total(buyer2)
egen num_buyer_c2 = total(buyer3)
display num_buyer_c1[1]
display num_buyer_c2[1]
