

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
*   family structure
********************************************************************

* wife_ & husb_
use "Original/ind_release_chn_20130109.dta", clear	
keep if (a2001==1|a2001==2) & a2003==2
renvars _all ,prefix(wife_) 
save "CleaningSteps/wife.dta",replace

use "Original/ind_release_chn_20130109.dta", clear	
keep if (a2001==1|a2001==2) & a2003==1
renvars _all ,prefix(husb_) 
save "CleaningSteps/husb.dta",replace

* child, c1_, c2_
use "Original/ind_release_chn_20130109.dta", clear	
keep if (a2001==6) 
sort hhid
by hhid: gen cnum=_n
save "CleaningSteps/child.dta",replace

use "CleaningSteps/child.dta",clear
keep if cnum==1
keep hhid pline province a2000 a2001 a2003 a2004 a2005 a2006 a2011 a2012 a2025 a3000 a3001
renvars _all ,prefix(c1_) 
save "CleaningSteps/c1.dta",replace

use "CleaningSteps/child.dta",clear
keep if cnum==2
keep hhid pline province a2000 a2001 a2003 a2004 a2005 a2006 a2011 a2012 a2025 a3000 a3001
renvars _all ,prefix(c2_) 
save "CleaningSteps/c2.dta",replace

* merge







