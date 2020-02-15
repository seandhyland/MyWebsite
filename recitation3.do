********************************************************************************
* Program: Recitation 3
* Exercises: SW AEE 4.1; SW AEE 4.2; PS3Q3, continued. 
* Author: Sean Hyland
* Last Updated: Spring 2020
********************************************************************************

*Preliminaries

version 13.0 // Stata commands may differ by version, this ensures consistency
clear // Clear Memory
set mem 100m // Set Memory
set more off // Prevents Stata from pausing when the results window is filled up
capture log close // Close a log if one is open

* Set directories for log files, data, and output using globals
* This assumes you have saved 'Hedge Fund, Market Data.xlsx' in the following
* directory. You will need to modify if you saved it elsewhere. 
global dir "/Users/`c(username)'/Documents/Recitation 3/" 
	
// Open a log file. The "${logdir}" calls the filepath from the global above. 
log using "${dir}rec3.log", replace

********************************************************************************

*Q3: SW AEE 4.1

********************************************************************************

use https://wps.pearsoned.com/wps/media/objects/11422/11696965/data3eu/cps12.dta, clear
regress ahe age
display _b[_cons]+_b[age]*26 // for 26 year-old
display _b[_cons]+_b[age]*30 // for 30 year-old
// or alternatively:
margins, at(age = (26 30)) post
	di  _b[2._at]-_b[1._at]

********************************************************************************

*Q4: SW AEE 4.2

********************************************************************************

use https://wps.pearsoned.com/wps/media/objects/11422/11696965/aee/TeachingRatings.dta, clear
scatter course_eval beauty
gr drop _all // close the graph window
regress course_eval beauty
summarize beauty
display _b[_cons]+_b[beauty]*`r(mean)' 
	// predicted value at the mean
display _b[_cons]+_b[beauty]*(`r(mean)'+`r(sd)') 
	// predicted value one SD above the mean
margins, at(beauty = (0 `r(sd)')) post
	di  _b[2._at]-_b[1._at]
summarize course_eval	

********************************************************************************

*Q5: Market Returns Exercise, Continued

********************************************************************************

import excel "${dir}/Hedge Fund, Market Data.xlsx", clear firstrow
gen exsptr=sp_tr-riskfree
gen exhedge=hedge-riskfree
//Compare R2s
regress exhedge exsptr if exsptr>0
regress exhedge exsptr if exsptr<=0
//Graphical analysis
twoway (scatter exhedge exsptr if exsptr>0) ///
	(lfit exhedge exsptr if exsptr>0) ///
	(scatter exhedge exsptr if exsptr<=0) ///
	(lfit exhedge exsptr if exsptr<=0), xline(0, lp(dash) lc(black))
* What is going on? Note:
* R2=1-SSR/SST=1-((N-2)*SER^2)/SST=1-(SER^2)/(SST/(N-2))=1-(SER^2)/(SST/(N-2))
* Then if SERs are similar, but R2's are different, it is driven by the 
* dispersion in the raw variable. This can be seen in the graph. 
su exhedge if exsptr<=0
su exhedge if exsptr>0
tw (hist exhedge if exsptr<=0, lc(blue) fc(none)) ( hist exhedge if exsptr>0)

********************************************************************************

log close

********************************************************************************
