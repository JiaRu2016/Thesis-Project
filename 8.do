/**********************************************
			DATA_SET : CFPS 2010 
			Paper :One-Child
					8th
**********************************************/

/**********************************************
		I. Data Cleaning
---------------------------------------------
1. match wife with husb in adult.dta
2. match with family.dta, key=fid
3. only city, Han
4. gen variables
**********************************************/

clear
set more off
cd "/Users/jiaru2014/Desktop/Research/One_Child/Data8"


use "Original/CFPS_2010_adult.dta", clear
keep if gender==1
renvars _all, prefix(husb_)
rename husb_pid_s wife_pid
save "Cleanning_steps/husb.dta", replace

use "Original/CFPS_2010_adult.dta", clear
keep if gender==0
renvars _all, prefix(wife_)
rename wife_pid_s husb_pid
save "Cleanning_steps/wife.dta", replace

merge 1:1 wife_pid husb_pid using "Cleanning_steps/husb.dta"
keep if _merge ==3 
drop _merge
gen fid = wife_fid if wife_fid==husb_fid
order fid, first
sort fid
save "Cleanning_steps/cp.dta", replace   
use "Original/CFPS_2010_family.dta", clear
renvars _all, prefix(fm_)
rename fm_fid fid
merge 1:m fid using "Cleanning_steps/cp.dta"
keep if _merge ==3 
drop _merge
duplicates tag fid, generate(dupfid)
order fid dupfid, first
sort fid
save "Cleanning_steps/cpfm.dta", replace

//------------------------------------------------------------------
keep if fm_urban==1  // only city
keep if (wife_qa5code==1 & husb_qd106==1)  // only Han

// 1. child information
drop if wife_pid_c1 != husb_pid_c1 
drop if wife_code_a_c1 != husb_code_a_c1
drop if wife_pid_c2 != husb_pid_c2
drop if wife_code_a_c2 != husb_code_a_c2

gen c1_pid= wife_pid_c1 
gen c1_birth_m= wife_tb1m_a_c1
gen c1_birth_y= wife_tb1y_a_c1
gen c1_gender= wife_tb2_a_c1
gen c2_pid= wife_pid_c2
gen c2_birth_m= wife_tb1m_a_c2
gen c2_birth_y= wife_tb1y_a_c2
gen c2_gender= wife_tb2_a_c2

gen child2=(c2_birth_y>0)   
gen child1=(c1_birth_y>0)
gen twins = (c1_birth_y==c2_birth_y & c1_birth_m==c2_birth_m) if child2==1
replace child2=0 if twins==1
replace child2=. if child1==0
label var child2 "whether have second child"


// 2. couple_type
gen couple_type=-9
replace couple_type=3 if (wife_qb1>=1 & husb_qb1>=1)
replace couple_type=2 if (wife_qb1==0 | husb_qb1==0)
replace couple_type=1 if (wife_qb1==0 & husb_qb1==0)
label define couple_type 1 "both" 2 "either" 3 "none" 
label value couple_type couple_type
mvdecode couple_type, mv(-9)

// 3. Income 
gen Income = log(fm_faminc_net)
label var Income "log family net income"
gen Inc_hb = log(husb_income)
gen Inc_wf = log(wife_income)

// 4. House
gen HouseArea=-9
replace HouseArea = fm_fd2 if (fm_fd1==1 & fm_fd2>0)
replace HouseArea = 0 if 1<fm_fd1
replace HouseArea = HouseArea+fm_fd702 if (fm_fd7==1 & HouseArea!=-9 & fm_fd702>=0)
replace HouseArea = log(HouseArea)
gen IfHouse = (HouseArea<.)

mvdecode fm_fd103 fm_fd105 fm_fd111, mv(-9=.\-8=.\-2=.\-1=.)
gen HouseYear = min(fm_fd103,fm_fd105,fm_fd111)
label var HouseYear "year of owing first house"
gen HouseC1 = 0 if HouseArea<.
replace HouseC1 = 1 if HouseYear<c1_birth_y
label var HouseC1 "owing a house when c1"


// 5. AgeC1
gen AgeC1=c1_birth_y-wife_qa1y_best if (c1_birth_y>0 & wife_qa1y_best>0)
gen Birthyearwf = wife_qa1y_best

// 6. eduexp
// =edu_expenditure/total_expenditure
// half of edu_exp is zero, so create a dummy: neduexp(None-eduexp)
gen eduexp = fm_fh404/fm_fh601 if fm_fh404>=0 & fm_fh601>0 
replace eduexp=. if eduexp>1
gen neduexp = 0 if eduexp==0
replace neduexp = 1 if eduexp>0
label var eduexp "edu_exp/total_exp,range[0,1]"
label var neduexp "None eduexp"

gen eduexp2 = eduexp if child1==1 & child2==0
replace eduexp2 = eduexp/2 if child2==1
label var eduexp2 "per child"
gen eduexp3 = fm_fh404/fm_fh403
label var eduexp3 "eduexp/dressingexp
gen eduexp4 = fm_fh404/(fm_fh403+ fm_fh407+ fm_fh401)
label var eduexp3 "eduexp/comsumption

// 7. Edu
gen Edu_wf = wife_edu
gen Edu_hb = husb_edu
label value Edu_wf edu
label value Edu_hb edu
gen Eduy_wf = wife_eduy
gen Eduy_hb = husb_eduy
recode Edu_wf (1 2 3=3)(4= 4)(5 6 7 8= 5), gen(Edu3_wf)
recode Edu_hb (1 2 3=3)(4= 4)(5 6 7 8= 5), gen(Edu3_hb)
label define edu3 3 "Compulsory" 4 "Middle" 5 "High"
label value Edu3_wf edu3
label value Edu3_hb edu3

// 8. Occu and CPC
gen Occu_wf=(wife_qg305==(1| 2| 3)) if wife_qg305>0 
gen Occu_hb=(husb_qg305==(1| 2| 3)) if husb_qg305>0 
gen CPC_wf = (wife_qa701>0)
gen CPC_hb = (husb_qa701>0)
gen Occu= (Occu_wf==1|Occu_hb==1|CPC_wf==1|CPC_hb==1)


// 9. BigFamily
gen BigFamily=husb_co_m+husb_co_f+wife_co_m+wife_co_f ///
	if (husb_co_m>=0 & husb_co_f>=0 & wife_co_m>=0 & wife_co_f>=0)
gen BigFamily2=(BigFamily==1|BigFamily==2) if BigFamily<.

// 10. Reigion
gen Pvc = fm_provcd  
label value Pvc qa201acode
recode Pvc ///
   (-8 = .) ///
   (11 12 13 21 31 32 33 35 37 44 46 = 1) ///
   (14 22 23 34 36 41 42 43 = 2) ///
   (15 45 50 51 52 53 54 61 62 63 64 65 = 3) ///
   , gen(Reigion)
label define reigion 1 "East" 2 "Midland" 3 "West", replace
label value Reigion reigion

gen East = (Reigion==1)

//------------------------------------------------------------------
order child2 couple_type AgeC1 Income HouseArea IfHouse HouseC1 ///
	eduexp neduexp Edu_wf Edu_hb Occu_wf Occu_hb CPC_wf CPC_hb BigFamily, last

save "Cleaned/cpfm8.dta", replace
keep if Birthyearwf>=1978 & Birthyearwf<=1989
save "Cleaned/cpfm8_80s.dta", replace



/**********************************************
		II. Regression
**********************************************/

est clear
global Y "child2"
global Y1 "child1"
global X "AgeC1 i.couple_type Inc_hb Inc_wf HouseArea i.Edu3_wf BigFamily2 eduexp Occu East"
global X1 "AgeC1 Inc_hb Inc_wf HouseArea i.Edu3_wf eduexp East"
global Xc1 "i.couple_type Inc_hb Inc_wf HouseArea i.Edu3_wf BigFamily2 Occu East"


use "Cleaned/cpfm8_80s.dta", clear
logit $Y $X1
outreg2 using "reg.xls", replace nose ctitle("80s") addstat(Pseudo R-squared, `e(r2_p)')
logit $Y $X
outreg2 using "reg.xls", append nose ctitle("80s") addstat(Pseudo R-squared, `e(r2_p)')

use "Cleaned/cpfm8.dta", clear
logit $Y $X1
outreg2 using "reg.xls", append nose ctitle("all") addstat(Pseudo R-squared, `e(r2_p)')
logit $Y $X
outreg2 using "reg.xls", append nose ctitle("all") addstat(Pseudo R-squared, `e(r2_p)')
logit $Y1 $Xc1
outreg2 using "reg.xls", append nose ctitle("child1") addstat(Pseudo R-squared, `e(r2_p)')





