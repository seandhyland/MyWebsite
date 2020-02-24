********************************************************************************
* Program: Recitation 4
* Exercises: SW AEE 5.2; SW AEE 5.3; SW AEE 6.1; SW AEE 6.2.
* Author: Sean Hyland
* Last Updated: Spring 2020
********************************************************************************

*Preliminaries

version 13.0 // Stata commands may differ by version, this ensures consistency
clear // Clear Memory
set mem 100m // Set Memory
set more off // Prevents Stata from pausing when the results window is filled up
capture log close // Close a log if one is open

*Load a new program, which we'll use to compare short and long regressions
capture ssc install estout
est drop _all // drops any stored regression estimates

* Set directories for log files, data, and output using globals
global dir "/Users/`c(username)'/Documents/Recitation 4/" 
capture mkdir "${dir}" // Creates the folder if it does not already exist. 
	
// Open a log file. The "${logdir}" calls the filepath from the global above. 
log using "${dir}rec4.log", replace

********************************************************************************

*Q1: SW AEE 5.2

********************************************************************************

use https://wps.pearsoned.com/wps/media/objects/11422/11696965/aee/TeachingRatings.dta, clear

regress course_eval beauty, r

*10,5 and 1% critical values for the standard normal distribution are 
di invnormal(0.950)
di invnormal(0.975)
di invnormal(0.995)

*Two-tailed p-value of T-statistic for null that the true slope is zero:
di 2*(1-normal(_b[beauty]/_se[beauty]))

********************************************************************************

*Q2: SW AEE 5.3

********************************************************************************

use https://wps.pearsoned.com/wps/media/objects/11422/11696965/aee/CollegeDistance.dta, clear

*(a)
eststo m2_a: regress ed dist, r

*(b)
di "95% confidence interval: [" _b[dist]-1.96*_se[dist], _b[dist]+1.96*_se[dist] "]"

*(c)
eststo m2_c: regress ed dist if female==1, r
	// Save the coefficients and standard errors, for part (e)
	scalar b_f = _b[dist]
	scalar se_f = _se[dist]

*(d)
eststo m2_d: regress ed dist if female==0, r
	// Save the coefficients and standard errors, for part (e)
	scalar b_m = _b[dist]
	scalar se_m = _se[dist]

*(e)
di "t_diff=" (b_f-b_m)/(se_f^2+se_m^2)^0.5

*Regression table
esttab m2*, mtitles("All" "Females" "Males")


********************************************************************************

*Q3: SW AEE 6.1

********************************************************************************

use https://wps.pearsoned.com/wps/media/objects/11422/11696965/aee/TeachingRatings.dta, clear

*(a)
eststo m3_a: regress course_eval beauty, r
su beauty
margins, at(beauty=(0 `r(sd)')) post
summarize course_eval	
di  (_b[2._at]-_b[1._at])/(`r(sd)')

*(b)
eststo m3_b: reg course_eval beauty intro onecredit female minority nnenglish, r
su beauty
margins, at(beauty=(0 `r(sd)')) post
summarize course_eval	
di  (_b[2._at]-_b[1._at])/(`r(sd)')

*(d)
est restore m3_b
su beauty
display _b[_cons]+_b[beauty]*`r(mean)' +_b[intro]*0 +_b[onecredit]*0 +_b[female]*0 +_b[minority]*1 +_b[nnenglish]*0
//OR
margins, at(beauty=`r(mean)' intro=0 onecredit=0 female=0 minority=1 nnenglish=0)

*Regression table
esttab m3* 

********************************************************************************

*Q4: SW AEE 6.2

********************************************************************************

use https://wps.pearsoned.com/wps/media/objects/11422/11696965/aee/CollegeDistance.dta, clear

*(a)
eststo m4_a: regress ed dist

*(b)
eststo m4_b: regress ed dist bytest female black hispanic incomehi ownhome dadcoll cue80 stwmfg80

*(d)
di "Note, adjustment factor = " (e(N)-1)/(e(N)-1-e(df_m))

*(g),(h)
margins, at(dist=(2 4) bytest=58 female=0 black=1 hispanic=0 incomehi=1 ownhome=1 dadcoll=0 cue80=7.5 stwmfg80=9.75)
di "Note the difference is equal to (4-2)*_b[dist]="(4-2)*_b[dist]

*Regression table
esttab m4*, mtitles("All" "Females" "Males")
 
********************************************************************************

log close

********************************************************************************
