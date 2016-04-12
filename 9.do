
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
save "Cleaning_Steps/final.dta", replace

/**********************************************
		II. Generate Xs Ys
**********************************************/

use "Cleaning_Steps/final.dta", clear


