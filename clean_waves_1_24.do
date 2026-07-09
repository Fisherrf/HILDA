
*********************
*** main cleaning ***
*********************

 
{
	// Wave 1 variables
	use xwaveid ahhrhid  aanatsi ahhssa1 ahhssa2 ahhssa3 ahhssa4 ahhwtrp ahgint ahgsex ///
		ahgage ahhiage aedhigh1 amrcurr atifditn atifditp ahglth aghgh aghbp aghmh aghpf aghre aghrht *ncdsp ///
		aghpf aghrp aghbp aghgh aghvt aghsf aghre aghmh aghsf6d aghpf aghmh agh1 aanatsi aesbrd ajbmo61 ///
		alssmoke ahifdip ahifdin ahhpers ahhadult aghmh aghsf *lga /// aherate
		ahhstate ahhsos aanbcob aes alsdrink alssmoke arg* ahhpno *cob* alosat* amhrea* *hhhqivw *hglth *helth *hwtsc* ///
		using "$data\Combined_a240u.dta", clear		// was 160, then 180, now 190		
	rename a* *		// Strip off wave prefix
	gen wave = 1		// Create wave indicator (1, 2 ...) 
	
	rename lsdrink lsdrkf
	label define lsdrkf 1 "has never drunk alcohol" 2 "no longer drinks" 3 "drinks rarely" 4 "drinks less than once a week" 5 "drinks 1-2 days/week" 6 "drinks 3-4 days/week" 7 "drinks 4-5 days/week" 8 "drinks daily"
	label values lsdrkf lsdrkf
	
	rename lssmoke lssmkf
	label define lssmkf 1 "has never smoked" 2 "no longer smoke" 3 "smokes"
	label values lssmkf lssmkf
	
	* household disposable income
	gen hhincome = hifdip - hifdin
	replace hhincome = hhincome/1000
	label var hhincome "household disposable income (thousands)"

	gen hhchild = hhpers - hhadult
	label var hhchild "number of children in household"
	gen ehi = hhincome/(1+0.5*(hhadult-1)+0.3*hhchild)
	label var ehi "equivalised household income (thousands)"

	** income quintile based on EHI by wave
	sort ehi
	gen rank = _n/_N
	gen ehiq2 = [rank >= 0.2 & rank < 0.4]
	gen ehiq3 = [rank >= 0.4 & rank < 0.6]
	gen ehiq4 = [rank >= 0.6 & rank < 0.8]
	gen ehiq5 = [rank >= 0.8]
	
	sort xwaveid
	gen ehiqall   = 1  +  ehiq2        +  2*ehiq3        +  3*ehiq4  +  4*ehiq5
	
	** income quartile based on EHI by wave
	sort ehi
	
	sort xwaveid
	gen     ehi_quart = 1 if [rank < 0.25 ]
	replace ehi_quart = 2 if [rank >= 0.25 & rank < 0.5]
	replace ehi_quart = 3 if [rank >= 0.5 & rank < 0.75]
	replace ehi_quart = 4 if [rank >= 0.75]
	
drop rank
save "$data\wave_1.dta", replace

local i=2
	foreach w in b c d e f g h i j k l m n o p q r s t u v w x {		

		use xwaveid `w'anatsi* `w'hglth `w'hhrhid `w'hhssa1 `w'hhssa2 `w'hhssa3 `w'hhssa4 `w'hhwtrp `w'hgint `w'hgsex `w'hgage `w'hhiage `w'edhigh1 `w'mrcurr `w'tifditn `w'tifditp  `w'ghgh `w'ghbp `w'ghmh `w'ghpf `w'ghre `w'ghrht *hwtsc* ///
			`w'ghpf `w'ghrp `w'ghbp `w'ghgh `w'ghvt `w'ghsf `w'ghre `w'ghmh `w'ghsf6d `w'gh3a `w'ghpf `w'gh1  `w'anatsi `w'esbrd  `w'jbmo61 `w'hifdip `w'hifdin `w'hhpers `w'hhadult `w'ghmh *ncdsp *lga ///
			`w'hhstate `w'hhsos `w'anbcob `w'es `w'lsdrkf `w'lssmkf  `w'lstbcn `w'rg* `w'hhpno *cob* `w'losat* `w'mhrea* `w'hhhqivw  `w'hglth `w'helth `w'levio ///
			using "$data\Combined_`w'240u.dta", clear	
	
			rename `w'* *		// Strip off wave prefix (this messed up for x)
	
			cap ren waveid xwaveid
			gen wave = `i'		// Create wave indicator (a=1, b=2, ..., s=2019)
			recode lsdrkf 3=8 4=7 5=6 6=5 7=4 8=3
			label define lsdrkf 1 "has never drunk alcohol" 2 "no longer drinks" 3 "drinks rarely" 4 "drinks less than once a week" 5 "drinks 1-2 days/week" 6 "drinks 3-4 days/week" 7 "drinks 4-5 days/week" 8 "drinks daily"
			label values lsdrkf lsdrkf
			
			/*
			recode lssmkf 4=3 5=3 // change "yes i smoke less often than weekly=5" to "smokes=3" OR "no longer smoke==2" //4=2 5=2 is for appendix
			label define lssmkf 1 "has never smoked" 2 "no longer smoke" 3 "smokes"
			label values lssmkf lssmkf
			*/
			
			* household disposable income
			gen hhincome = hifdip - hifdin
			replace hhincome = hhincome/1000
			label var hhincome "household disposable income (thousands)"

			gen hhchild = hhpers - hhadult
			label var hhchild "number of children in household"
			gen ehi = hhincome/(1+0.5*(hhadult-1)+0.3*hhchild)
			label var ehi "equivalised household income (thousands)"

			** income quintile based on EHI by wave
			sort ehi
			gen rank = _n/_N
			gen ehiq2 = [rank >= 0.2 & rank < 0.4]
			gen ehiq3 = [rank >= 0.4 & rank < 0.6]
			gen ehiq4 = [rank >= 0.6 & rank < 0.8]
			gen ehiq5 = [rank >= 0.8]
			
			sort xwaveid
			gen ehiqall   = 1  +  ehiq2        +  2*ehiq3        +  3*ehiq4  +  4*ehiq5
			
			** income quartile based on EHI by wave
			sort ehi
			
			sort xwaveid
			gen     ehi_quart = 1 if [rank < 0.25 ]
			replace ehi_quart = 2 if [rank >= 0.25 & rank < 0.5]
			replace ehi_quart = 3 if [rank >= 0.5 & rank < 0.75]
			replace ehi_quart = 4 if [rank >= 0.75]
			
		drop rank
			
			g pv=0 if levio==1
			replace pv=1 if levio==2 
			la var pv "Victim physical violence"
			
	save "$data\wave_`i'.dta", replace
	local i=`i'+1
	}
	
use "$data\wave_1.dta", clear
	forvalues i=2/24 {
		append using "$data\wave_`i'.dta"
	}
		
	sort xwaveid wave
	

/*
	* Merge final interview status (fstatus) and death information for each wave:
	merge m:1 xwaveid using "raw_data\Master_t200u.dta", keepusing (hhsm *fstatus xhhstrat yodeath isdeath aadeath yrenter yrleft) gen(fstatusmerge)
	
drop if fstatusmerge ~= 3 
drop fstatusmerge
*/	

	*general data cleaning:
	
	* weight
	rename hhwtrp weight
	g  sc_weight=hhwtsc
	
	* sex
	rename hgsex male
	recode male 2=0
	label define male 0 "female" 1 "male"
	label values male male
	label var male "=1 if male"

	* in labour force
	gen lf = 1 if esbrd == 1 | esbrd == 2
	replace lf = 0 if lf == .
	label var lf "=1 if in labour force"
	label define lf 1 "in labour force" 0 "not in labour force"
	label values lf lf

	* age
	rename hgage age0

	* married
	gen married = 1 if mrcurr == 1 | mrcurr == 2
	replace married = 0 if married == . & mrcurr > 0
	label var married "=1 if married or de facto"
	label define married 1 "married or de facto" 0 "not married"
	label values married married

	* indigenous
	gen indig = 1 if anatsi == 2 | anatsi == 3 | anatsi == 4
	replace indig = 0 if indig == . & anbcob > 0
	label var indig "=1 if indigenous or Torres Strait Islander"
	label define indig 1 "indigenous or TSI" 0 "not indigenous"
	label values indig indig

	* education
	gen degree = 1 if edhigh1 <= 3
	replace degree = 0 if degree == . & edhigh1 ~= 10
	label var degree "=1 if has a bachelor or higher degree"

	gen oth_psq = 1 if edhigh1 == 4 | edhigh1 == 5
	replace oth_psq = 0 if oth_psq == . & edhigh1 ~= 10
	label var oth_psq "=1 if has other non-degree post-school qualifications"

	gen yr12 = 1 if edhigh1 == 8
	replace yr12 = 0 if yr12 == . & edhigh1 ~= 10
	label var yr12 "=1 if completed year 12"

	// or something like the following
	gen educ = 1 if edhigh1 == 9
	replace educ = 2 if edhigh1 == 8 | edhigh1 == 5
	replace educ = 3 if edhigh1 == 4 | edhigh1 == 3 | edhigh1 == 2 | edhigh1 == 1
	tab edhigh1 educ, m
	label var educ "highest education"
	label define educ 1 "less than Yr 12" 2 "Yr 12 or equivalent" 3 "Bachelor or above"
	label values educ educ

	* spouse in labour force
	*vlookup hhpxid, gen(sp_lf) key(xwaveid) value(lf)
	*replace sp_lf = 0 if married == 0
	*label var sp_lf "=1 if married and the spouse in lf"

	* state of residence
	rename hhstate state

	* rural/urban
	gen rural = 0 if hhsos == 0 | hhsos == 1
	replace rural = 1 if hhsos == 2 | hhsos == 3 | hhsos == 4
	label var rural "=1 if rural"
	label define rural 1 "rural" 0 "urban"
	label values rural rural

	* cob
	gen cob_os = 1 if anbcob == 2 | anbcob == 3
	replace cob_os = 0 if anbcob == 1
	label var cob_os "=1 if born overseas"

	gen cob_n_en = 1 if anbcob == 3
	replace cob_n_en = 0 if anbcob == 1 | anbcob == 2
	label var cob_n_en "=1 if born in non-English speaking foeign country"

	// or something like the following
	rename anbcob cob
	replace cob = . if cob < 0

	* occupation
	* (drew this info might be of interest for peer effects aspect)
	gen trade = 1 if jbmo61 == 3
	replace trade = 0 if trade == . & jbmo61 ~= -7
	label var trade "=1 if tradesperson or related worker"

	gen cle_s = 1 if jbmo61 == 4 | jbmo61 == 5 | jbmo61 == 6
	replace cle_s = 0 if cle_s == . & jbmo61 ~= -7
	label var cle_s "=1 if clerical, sales or service worker"

	gen prd_tr = 1 if jbmo61 == 7
	replace prd_tr = 0 if prd_tr == . & jbmo61 ~= 7
	label var prd_tr "=1 if production or transport worker"

	gen labour = 1 if jbmo61 == 8
	replace labour = 0 if labour == . & jbmo61 ~= -7
	label var labour "=1 if labourer or related worker"

	// or something like the following
	rename jbmo61 occuptn
	replace occuptn = . if occuptn < 0

	gen whtcollar = 1 if occuptn == 4 | occuptn == 5 | occuptn == 6
	replace whtcollar = 0 if whtcollar == .
	label var whtcollar "=1 if white collar (not professional/manager)"

	gen bluecollar = 1 if occuptn == 3 | occuptn == 7 | occuptn == 9
	replace bluecollar = 0 if bluecollar == .
	label var bluecollar "=1 if blue collar"
	
	* personal disposable income
	gen income = tifditp - tifditn
	replace income = income/1000
	label var income "personal disposable income (thousands)"

	xtile hh_inc_q=hhincome, nq(4) // quartiles hh income
	
	* long term health condition
	
	g lth=0 if hglth==2
	replace lth=1 if hglth==1
	 
	merge m:1 xwaveid using "$data\lgb_wave_12.dta", nogen 
	merge m:1 xwaveid using "$data\lgb_wave_16.dta", nogen  
	merge m:1 xwaveid using "$data\lgb_wave_20.dta", nogen   
	merge m:1 xwaveid using "$data\lgb_wave_24.dta", nogen  
	
	
	foreach v in lgb lgbo {
		g `v'=0 	  if `v'_12==0 | `v'_16==0 | `v'_20==0 | `v'_24==0
		replace `v'=1 if `v'_12==1 | `v'_16==1 | `v'_20==1 | `v'_24==1
	}

	merge m:1 xwaveid using "$data\tgd_wave_22.dta"	, nogen  // add wave 22 tgd
	merge m:1 xwaveid using "$data\tgd_wave_23.dta"	, nogen  // add wave 22 tgd
	merge m:1 xwaveid using "$data\tgd_wave_24.dta"	, nogen  // add wave 22 tgd
		
	gen tgd_ever = 0 if tgd_22==0 & tgd_23==0 & tgd_24==0
	replace tgd_ever=1 if tgd_22==1 | tgd_23==1 & tgd_24==1

	
	g age_g=1 if hhiage>=15 & hhiage<=24
	replace age_g=2 if hhiage>=25 & hhiage<=34
	replace age_g=3 if hhiage>=35 & hhiage<=44
	replace age_g=4 if hhiage>=45 & hhiage<=54
	replace age_g=5 if hhiage>=55 & hhiage<=64
	replace age_g=6 if hhiage>=65 & hhiage<=74
	replace age_g=7 if hhiage>=75
	
	tab age_g, gen(ageg_d)
	gen age2= age0*age0

	ren hhslga lga_code_2011
	ren lga_code_2011 lgacode_2011
	
	g smoke=0 if lssmkf>0
	replace smoke=1 if lssmkf==3
save "$data\waves1_24.dta", replace
	 
}
