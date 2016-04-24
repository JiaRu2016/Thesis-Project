
/**********************************************
			    CGSS_2013
			    paper: 9th
**********************************************/

/**********************************************
		I. Data Cleaning
**********************************************/

clear
set more off

cd "/Users/jiaru2014/Desktop/Research/One_Child/Data9/CGSS_2013"

********************************************************************
use "Original/cgss2013.dta", clear

* Basic Informations

// gender
gen gender = a2  //1=male 2=female

// Han
recode a4 (-3 -2 -1=.)(1=1)(2/8=0), gen(Han)

// Birth_year or Age
gen Birthy = a3a   

// only 80s -->> Obs:1700
keep if Birthy>=1980 & Birthy<=1989 //only 80s
*tab Birthy

// Married & MarriAge
gen married = 1 if a70>=1990 & a70<=2013
replace married = 0 if a70==9997
gen MarriAge = a70-Birthy if a70>=1990 & a70<=2013
*hist MarriAge; tab married

// HuKou


********************************************************************
* Y: child_ideal & child_fact

gen child_ideal=a37a
gen boy_ideal=a37b
gen girl_ideal=a37c

gen child_fact = a68a
gen boy_fact = a681
gen girl_fact = a682

********************************************************************
* X

// 1. No couple_type !!!

// 2. AgeC1

// 4. Edu (3-level)
recode a7a a72 (-3 -2 -1 14=.)(1 2 3 4=0)(5 7 8 =1)(6 9 10=2)(11 12 13=3), gen(Edu Edu_s)
gen w_Edu=Edu if gender==2
replace  w_Edu=Edu_s if gender==1
gen h_Edu=Edu if gender==1
replace h_Edu=Edu_s if gender==2
drop Edu Edu_s
label define Edu 0 "Compulsory" 1 "mid1" 2 "mid2" 3 "Undergraduate"
label value w_Edu h_Edu Edu
*tab w_Edu h_Edu

// 5. Income (w_Inc, h_Inc, household_Income)
gen w_Inc=log(a8a) if gender==2 & a8a<=9e6
replace  w_Inc=log(a75a) if gender==1  & a75a<=9e6
gen h_Inc=log(a8a) if gender==1 & a8a<=9e6
replace  h_Inc=log(a75a) if gender==2 & a75a<=9e6
*scatter w_Inc h_Inc
gen Inc=log(a62) if a62<=2e6
* hist Inc

// 6. House (Belongs to whom? a128 a124 a121 a122 a125)
gen HouseProperty=.
replace HouseProperty=1 if (a121==1| a124==1) & a122==0 & a125==0
replace HouseProperty=2 if (a125 ==1| a122 ==1) & a121==0 & a124==0
replace HouseProperty=3 if a121==1 & a122==1

gen HousePr=2 if gender==2 & HouseProperty==1  // wife's House
replace HousePr=1 if gender==2 & HouseProperty==2  //husb's
replace HousePr=2 if gender==1 & HouseProperty==2  //wife's
replace HousePr=1 if gender==1 & HouseProperty==1  //husb's
replace HousePr=3 if HouseProperty==3  // both 
replace HousePr=0 if a121==0 & a124==0 & a122==0 & a125==0 
drop HouseProperty

label define HousePr 1 "Husb's" 2 "Wife's" 3 "both" 0 "none"
label value HousePr HousePr
*tab HousePr
gen HouseNum=a65
*tab HouseNum HousePr ?????
// Car
recode a66 (-3 -2 -1=.)(1=1)(2=0), gen(Car)
*tab Car

// 7. Occupation
recode a59j a87 (-3 -2 -1=.)(1 3 6=1)(2 4 5 7=0), gen(GovSOE GovSOE_s)
replace GovSOE=1 if a59k==1
replace GovSOE_s=1 if a88==1
gen w_GovSOE = GovSOE_s if gender==1
replace w_GovSOE = GovSOE if gender==2
gen h_GovSOE = GovSOE if gender==1
replace h_GovSOE = GovSOE_s if gender==2
drop GovSOE GovSOE_s
*tab w_GovSOE h_GovSOE
gen GovSOE=.
replace GovSOE=1 if w_GovSOE==1|h_GovSOE==1
replace GovSOE=0 if w_GovSOE==0 & h_GovSOE==0
tab GovSOE

// 8. Bigfamily
