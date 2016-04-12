
/**********************************************
			     CFPS 2012 
					9th
**********************************************/

/**********************************************
		I. Data Cleaning
**********************************************/

clear
set more off
set maxvar 8000
cd "/Users/jiaru2014/Desktop/Research/One_Child/Data9/CFPS2012"


// 1. familyconf.dta   match wife and husb, gen "cp.dta"

use "Original/cfps2012famconf.dta", clear
rename tb2_a_p gender
keep if gender==1  // gender==male
renvars _all, prefix(husb_)
rename husb_pid_s wife_pid
save "Cleaning_Steps/husb.dta", replace

use "Original/cfps2012famconf.dta", clear
rename tb2_a_p gender
keep if gender==0  // gender==female
renvars _all, prefix(wife_)
rename wife_pid_s husb_pid
save "Cleaning_Steps/wife.dta", replace

merge m:m wife_pid husb_pid using "Cleaning_Steps/husb.dta"

keep if _merge ==3 
drop _merge
gen fid = wife_fid12 if wife_fid12==husb_fid12
order fid, first
sort fid
save "Cleaning_Steps/cp.dta", replace

// 2. familyecon.dta  merge usinig "cp.dta", gen "cpfe.dta"

use "Original/cfps2012famecon.dta", clear
renvars _all, prefix(fe_)  // fe_ "FamilyEcon"
rename fe_fid12 fid
merge 1:m fid using "Cleaning_Steps/cp.dta"
keep if _merge ==3 
drop _merge
save "Cleaning_Steps/cpfe.dta", replace

// 3. adult.dta  merge

use "Original/cfps2012adult.dta", clear
keep if cfps2010_gender==1    // male
renvars _all, prefix(ah_) // ah: adult_husb
rename ah_pid husb_pid
save "Cleaning_Steps/ah.dta" , replace   

use "Original/cfps2012adult.dta", clear
keep if cfps2010_gender==0    // female
renvars _all, prefix(aw_) // aw: adult_wife
rename aw_pid wife_pid
save "Cleaning_Steps/aw.dta" , replace   

use "Cleaning_Steps/cpfe.dta", clear
merge m:1 wife_pid using "Cleaning_Steps/aw.dta"
keep if _merge ==3 
drop _merge
merge m:1 husb_pid using "Cleaning_Steps/ah.dta"
keep if _merge ==3 
drop _merge

save "Cleaning_Steps/cpfead.dta", replace  // fc_fe_adult

// 4. child.dta  

use "Cleaning_Steps/cpfead.dta", clear
drop if wife_pid_c1!=husb_pid_c1  
gen c1_pid=wife_pid_c1
drop if wife_pid_c2!=husb_pid_c2  
gen c2_pid=wife_pid_c2
drop if c1_pid==-8  // drop if no child_1
save "Cleaning_Steps/cpfead_1.dta", replace

use "Original/cfps2012child.dta",clear
renvars _all, prefix(c1_)
rename c1_pid_f husb_pid
rename c1_pid_m wife_pid
save "Cleaning_Steps/c1.dta", replace

use "Cleaning_Steps/cpfead_1.dta", clear
merge m:m wife_pid husb_pid using "Cleaning_Steps/c1.dta"
drop if _merge==2
rename _merge child1info
recode child1info (1=0)(3=1) //(1="no")(3="yes")
save "Cleaning_Steps/final2012.dta", replace

// 5. siblings. From 2010 data set

use "Original/CFPS_2010_adult", clear
keep pid gender qb1
keep if gender==1
rename pid husb_pid
rename qb1 husb_Sib
save  "Cleaning_Steps/sib_husb.dta", replace

use "Original/CFPS_2010_adult", clear
keep pid gender qb1
keep if gender==0
rename pid wife_pid
rename qb1 wife_Sib
save  "Cleaning_Steps/sib_wife.dta", replace


use "Cleaning_Steps/final2012.dta", clear
merge m:1 husb_pid using "Cleaning_Steps/sib_husb.dta"
drop _merge
merge m:1 wife_pid using "Cleaning_Steps/sib_wife.dta"
drop _merge

save "Cleaning_Steps/final.dta", replace


/**********************************************
		II. Generate Xs Ys
**********************************************/

use "Cleaning_Steps/final.dta", clear

// 0. keep only urban
keep if fe_urban12==1

// 1. Y: child2
gen c1_y = wife_tb1y_a_c1
gen c1_m = wife_tb1m_a_c1
gen c2_y = wife_tb1y_a_c2 
gen c2_m = wife_tb1m_a_c2

gen child2 = (c2_y>0) if c1_y>0
replace child2 = 0 if c1_y==c2_y & c1_m==c2_m & child2==1

// X

// 2. couple_type

gen couple_type = .
replace couple_type = 1 if wife_Sib==0 | husb_Sib==0
replace couple_type = 0 if wife_Sib==0 & husb_Sib==0
replace couple_type = 2 if wife_Sib>0 & husb_Sib>0

// 3. AgeC1

gen wife_birth_y = wife_tb1y_a_p
gen AgeC1 = c1_y-wife_birth_y

// 4. Income

// 5. Wealth

// 6. Edu

// 7. ImpQ

// 8. FamilyStructurea
