********************************************************************************
*Econ 3412 - Introduction to Econometrics
*Spring 2020
*Rec 6
*Sean Hyland
********************************************************************************

*Preamble

version 13.1 // I am using Stata version 13.1. This command ensures any programs that I use will also run correctly under more recent versions of Stata.
clear all
set more off
capture ssc install estout // installs required command for regression tables below.
capture log close // closes open log file, if there is one. 
global dir "/Users/`c(username)'/Documents/Recitation 6/" // Set directory
capture mkdir "${dir}" // Creates the folder if it does not already exist. 
log using "rec6.log", replace // writes results to a text file

********************************************************************************

*Q4: AEE 8.1

********************************************************************************

use "https://wps.pearsoned.com/wps/media/objects/11422/11696965/aee/TeachingRatings.dta", clear
use "D:/UN3412_Intro_to_Econometrics/Recitations/Recitation 6/TeachingRatings.dta" 



*(a)
eststo m1_a: reg course_eval beauty intro onecredit female minority nnenglish, r

*(b)
gen age_sq = age^2
eststo m1_b: qui reg course_eval beauty intro onecredit female minority nnenglish age age_sq, r
esttab m1_a m1_b, se stats(N r2 r2_a rmse, fmt(0 4)) mtitles compress
test age_sq
test age age_sq

*(c)
gen beauty_female = beauty*female
eststo m1_c: qui reg course_eval beauty intro onecredit female minority nnenglish beauty_female, r
esttab m1_a m1_c, se stats(N r2 r2_a rmse, fmt(0 4)) mtitles compress

*(d) Effect of a two SD increase in beauty among men
qui su beauty
di "Pre-surgery beauty: " `r(mean)'-`r(sd)'
di "Post-surgery beauty: " `r(mean)'+`r(sd)'
//Compute the expected increase in course evaluations, with 95% CI, as
di "The expected change in Course evaluations among men: " 2*`r(sd)'*_b[beauty]
di "The 95% CI on the expected change among men: [" 2*`r(sd)'*(_b[beauty]-1.96*_se[beauty]) ", " 2*`r(sd)'*(_b[beauty]+1.96*_se[beauty]) "]"
// OR
lincom	2*`r(sd)'*beauty // Command to compute LINear COMbination of coefficients

*(e) Effect of a two SD increase in beauty among women
//Compute the expected increase in course evaluations, with 95% CI, as
qui su beauty
di "The expected change in Course evaluations: " 2*`r(sd)'*(_b[beauty]+_b[beauty_female])
// However the 95% CI on the expected change requires the standard error of the sum of beauty and beauty_female
// Solution 1: Augment regression to include male dummy and male_beauty interaction terms, rather than female, then proceed as above
gen male = 1-female
gen beauty_male = beauty*male
eststo m1_e: reg course_eval beauty intro onecredit male minority nnenglish beauty_male, r
qui su beauty
di "The 95% CI on the expected change among women: [" 2*`r(sd)'*(_b[beauty]-1.96*_se[beauty]) ", " 2*`r(sd)'*(_b[beauty]+1.96*_se[beauty]) "]"
// Solution 2: We could have used our earlier regression, and the lincom command
est restore m1_c // restores the earlier regression results to memory
qui su beauty
lincom	2*`r(sd)'*[beauty+beauty_female] 

*****************************************************************************

log close

*****************************************************************************
