********************************************************************************
*Econ 3412 - Introduction to Econometrics
*Spring 2020
*Rec 5
*Sean Hyland
********************************************************************************

*Preamble

version 13.1 // I am using Stata version 13.1. This command ensures any programs that I use will also run correctly under more recent versions of Stata.
clear all
set more off
capture ssc install estout // installs required command for regression tables below.
capture log close // closes open log file, if there is one. 
global dir "/Users/`c(username)'/Documents/Recitation 5/" // Set directory
capture mkdir "${dir}" // Creates the folder if it does not already exist. 
log using "rec5.log", replace // writes results to a text file

********************************************************************************

*Q1: Course Evaluations and Beauty, continued

********************************************************************************

use https://wps.pearsoned.com/wps/media/objects/11422/11696965/aee/TeachingRatings.dta, clear

*(a)
eststo m1_a: reg course_eval beauty female, r
scalar rss_a = e(rss)
scalar df_a = e(df_r)

*(b)
eststo m1_b: reg course_eval beauty female minority age, r
scalar rss_b = e(rss)
scalar df_b = e(df_r)

*(c)
//Homoskedastic F-statistic 
di "F-statistic = " ((rss_a-rss_b)/rss_b)/((df_a-df_b)/df_b)
//Check:
test (minority=0) (age=0)

*(d)
eststo m1_d: qui reg course_eval beauty female minority age onecredit intro nnenglish, r
esttab m*, se stats(N r2 r2_a rmse, fmt(0 4)) mtitles compress
test (intro=0) (age=0)

********************************************************************************

* Q2: EE 6.2

********************************************************************************

use "https://wps.pearsoned.com/wps/media/objects/11422/11696965/data3eu/Growth.dta", clear
drop if country_name=="Malta"

*(a)
su

*(b)
regress growth tradeshare yearsschool rev_coups assasinations rgdp60, r

*(c)
di _b[_cons]+_b[tradeshare]*0.56+_b[yearsschool]*3.99+_b[rev_coups]*0.17+_b[assasinations]*0.28+_b[rgdp60]*3103.79
//OR
margins, atmeans 

*(d)
di _b[_cons]+_b[tradeshare]*(0.56+0.29)+_b[yearsschool]*3.99+_b[rev_coups]*0.17+_b[assasinations]*0.28+_b[rgdp60]*3103.79
//OR 
qui su tradeshare
local temp = `r(mean)'+`r(sd)' // temporarily save the value one SD above the mean
margins, atmeans at(tradeshare=`temp')

********************************************************************************

* Q5: AEE 7.1

********************************************************************************

use "https://wps.pearsoned.com/wps/media/objects/11422/11696965/data3eu/cps12.dta", clear

*(a)
eststo m5_a: regress ahe age, r 

*(b)
eststo m5_b: regress ahe age female bachelor, r
di "(Approximate) 95% is: [" _b[age]-1.96*_se[age] ", " _b[age]+1.96*_se[age] "]"

*(c,e)
esttab m5*, se stats(N r2 r2_a rmse, fmt(0 4)) mtitles compress

*(d)
margins, at(age=26 female=0 bachelor=0) at(age=30 female=1 bachelor=1)  

*(f)
test female=0 // asymptotically equivalent to the t-test on female
test bachelor=0 // asymptotically equivalent to the t-test on bachelor
test (female=0) (bachelor=0) // joint test

*(g)
regress age female bachelor
corr age female bachelor

*****************************************************************************

log close

*****************************************************************************
