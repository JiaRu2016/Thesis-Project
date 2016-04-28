

/**********************************************
			    CHFS_2011
			    paper: 9th
**********************************************/

/**********************************************
		I. Data Cleaning
**********************************************/

clear
set more off

cd "/Users/jiaru2014/Desktop/Research/One_Child/Data9/CHFS_2011"

********************************************************************
*   1. construst family structure
********************************************************************

* wife_ & husb_
use "Original/ind_release_chn_20130109.dta", clear	
keep if (a2001==1|a2001==2) & a2003==2
renvars _all ,prefix(wife_)
rename wife_hhid hhid 
duplicates drop hhid, force
save "CleaningSteps/wife.dta",replace

use "Original/ind_release_chn_20130109.dta", clear	
keep if (a2001==1|a2001==2) & a2003==1
renvars _all ,prefix(husb_) 
rename husb_hhid hhid
duplicates drop hhid, force
save "CleaningSteps/husb.dta",replace

* child, c1_, c2_
use "Original/ind_release_chn_20130109.dta", clear	
keep if (a2001==6) 
sort hhid a2005
by hhid: gen cnum=_n
save "CleaningSteps/child.dta",replace

use "CleaningSteps/child.dta",clear
keep if cnum==1
keep hhid pline province a2000 a2001 a2003 a2004 a2005 a2006 a2011 a2012 a2025 a3000 a3001
renvars _all ,prefix(c1_) 
rename c1_hhid hhid
duplicates drop hhid, force
save "CleaningSteps/c1.dta",replace

use "CleaningSteps/child.dta",clear
keep if cnum==2
keep hhid pline province a2000 a2001 a2003 a2004 a2005 a2006 a2011 a2012 a2025 a3000 a3001
renvars _all ,prefix(c2_) 
rename c2_hhid hhid
duplicates drop hhid, force
save "CleaningSteps/c2.dta",replace

* merge
use "CleaningSteps/wife.dta",replace
merge 1:1 hhid using "CleaningSteps/husb.dta"
keep if _merge==3
drop _merge

merge 1:m hhid using "CleaningSteps/c1.dta"
drop _merge

merge 1:m hhid using "CleaningSteps/c2.dta"
drop _merge


* merge hh.dta
merge 1:1 hhid using "Original/hh_release_chn_20130109.dta"
keep if _merge==3
drop _merge


save "CleaningSteps/cpc.dta",replace

********************************************************************
*  2. generate variables
********************************************************************


use "CleaningSteps/cpc.dta", clear

// child2
gen child1=(c1_pline!=.)
gen child2=(c2_pline!=.) if child1==1

// AgeC1, Age
gen w_Age = wife_a2005
gen h_Age = husb_a2005
gen AgeC1=c1_a2005-wife_a2005

// couple_type

gen w_Sib=wife_a2028+wife_a2029
gen h_Sib=husb_a2028+husb_a2029

gen couple_type=1 if w_Sib==0 | h_Sib==0
replace couple_type=0 if w_Sib==0 & h_Sib==0
replace couple_type=2 if w_Sib>0 & h_Sib>0 & w_Sib<. & h_Sib<.

// . Income
gen w_Inc=log(wife_a3020+wife_a3022+wife_a3023)
gen h_Inc=log(husb_a3020+husb_a3022+husb_a3023)

// . House

//  . Edu
recode wife_a2012 (1 2 3=1)(4 5=2)(6 7 8 9=3), gen(w_Edu)
recode husb_a2012 (1 2 3=1)(4 5=2)(6 7 8 9=3), gen(h_Edu)
label define Edu 1 "Elementary" 2 "Middle" 3 "high"
label value w_Edu h_Edu Edu

// . Impq

// . Occupation
recode wife_a3014 (1 2 5=1)(3 4 6=0), gen(w_GOVSOE)
recode husb_a3014 (1 2 5=1)(3 4 6=0), gen(h_GOVSOE)
gen GOVSOE=. 
replace GOVSOE=1 if (w_GOVSOE==1 | h_GOVSOE==1)
replace GOVSOE=0 if (w_GOVSOE==0 & h_GOVSOE==0)


// . Bigfamily

