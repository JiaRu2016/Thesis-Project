
/**********************************************
			    CGSS_2013
			    paper: 9th
**********************************************/

/**********************************************
		I. Data Cleaning
----------------------------------------------
Only one dataset
**********************************************/

clear
set more off

cd "/Users/jiaru2014/Desktop/Research/One_Child/Data9/CGSS_2013"

******************************************************
use "Original/cgss2013.dta", clear

gen gender = a2  //1=male 2=female

// 1. only 80s -->> Obs:1700
gen Birthy = a3a   // Birth year or Age
keep if Birthy>=1980 & Birthy<=1989 //only 80s
*tab Birthy

// 2. Married & MarriAge
gen married = 1 if a70>=1990 & a70<=2013
replace married = 0 if a70==9997
gen MarriAge = a70-Birthy if a70>=1990 & a70<=2013
*hist MarriAge; tab married

// 3. gen Y
gen child=a37a
gen boy=a37b
gen girl=a37c

// 4. Edu
recode a7a a72 (-3 -2 -1 14=.)(1 2 3 4=0)(5 7 8 =1)(6 9 10=2)(11 12 13=3), gen(Edu Edu_s)
gen w_Edu=Edu if gender==2
replace  w_Edu=Edu_s if gender==1
gen h_Edu=Edu if gender==1
replace h_Edu=Edu_s if gender==2
drop Edu Edu_s
label define Edu 0 "Compulsory" 1 "mid1" 2 "mid2" 3 "Undergraduate"
label value w_Edu h_Edu Edu
*tab w_Edu h_Edu

// 5. Income
gen w_Inc=log(a8a) if gender==2 & a8a<=9e6
replace  w_Inc=log(a75a) if gender==1  & a75a<=9e6
gen h_Inc=log(a8a) if gender==1 & a8a<=9e6
replace  h_Inc=log(a75a) if gender==2 & a75a<=9e6
*scatter w_Inc h_Inc


