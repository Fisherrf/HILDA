clear all
capture log close
set more off
set mem 1g

set linesize 80
set matsize 800
set maxvar 10000
macro drop _all
 
cd "C:\Users\fisherrf\The University of Melbourne\Karinna Saxby - stigma_smoking\data"
glo data "C:\Users\fisherrf\The University of Melbourne\Karinna Saxby - hilda23\data"  // hilda data 
glo stigma_data "C:\Users\fisherrf\The University of Melbourne\Karinna Saxby - stigma_smoking\data" 
glo output_ss "C:\Users\fisherrf\The University of Melbourne\Karinna Saxby - stigma_smoking\outputs\social_support"


*wave spec:
{
*attitudes: 5,8,11,15,19
foreach v in e h k o s w {
use *mchscr xwaveid using "$data\Combined_`v'230u.dta", clear                   // NOTE: change line 21, 42-53, for sky news paper - also added wave w
	
	if "`v'"=="e" {
		g wave=5 
		}
	if "`v'"=="h" {
		g wave=8
		}
	if "`v'"=="k" {
		g wave=11
		}
	if "`v'"=="o" {
		g wave=15
		}
	if "`v'"=="s" {
		g wave=19
		}
		if "`v'"=="w" {
		g wave=23
		}
		
	keep xwaveid wave `v'mchscr

	/*g att_pos=0 if 	`v'mchscr>=1
	replace att_pos=1 if `v'mchscr==5 | `v'mchscr==6
	
	g att_456=0 if 	`v'mchscr>=1
	replace att_456=1 if `v'mchscr>=4 & `v'mchscr<.
	
	g no_ID=1 if att_pos!=. 
	
	g att_cont=`v'mchscr if `v'mchscr>=1
	
	collapse (sum) att_pos att_456 no_ID (mean) att_cont (min) wave
	*/
		
save "atts_wave_`v'.dta", replace

}
use "$data\atts_wave_e.dta", clear 
	foreach v in h k o s {
		append using "$data\atts_wave_`v'.dta"
		}
		
	g prop_pos=att_pos/no_ID 
	g prop_456=att_456/no_ID 
	
	set scheme white_tableau
	tw sc prop_pos wave 
	tw sc prop_456 wave
	
	g year=wave+2000
	
	
	tw sc att_cont year , ytitle("{bf:Homosexual couples should have}" "{bf:the same rights as heterosexual couples do}", size(medium)) xtitle("{bf:Year}", size(medium)) ylabel(,labsize(medium)) xlabel(,labsize(medium))

	tw sc prop_456 year , ytitle("{bf:% Agree that homosexual couples should have}" "{bf:the same rights as heterosexual couples do}", size(medium)) xtitle("{bf:Year}", size(medium)) ylabel(,labsize(medium)) xlabel(,labsize(medium)) xline(2017, lp(dash))
}
	
* wave 12
use "$data\Combined_l230u.dta", clear
drop if llssexor <0 // non-responding, no SCQ, multiple response, refused/not stated

g lgbo_12 = .  // Unsure,dont know, prefer not say, non-responding person, no scq, multiple response scq, refused not stated
replace lgbo_12 = 1 if llssexor==2  | llssexor==3 | llssexor==4  // Gay, lesbian, bisexual, other
replace lgbo_12 = 0 if llssexor==1 // Heterosexual or straight
g lgb_12 = .
replace lgb_12 = 1 if llssexor==2  | llssexor==3  // Gay, lesbian, bisexual
replace lgb_12 = 0 if llssexor==1 // Heterosexual or straight
g h_12 = .
replace h_12 = 1 if llssexor==1
g lg_12 = .
replace lg_12 = 1 if llssexor==2
g b_12 = .
replace b_12 = 1 if llssexor==3
g o_12 =.
replace o_12 = 1 if llssexor==4
g u_12 =.
replace u_12 = 1 if llssexor ==5
g pns_12 = .
replace pns_12 = 1 if llssexor==6

keep xwaveid lgbo_12 lgb_12 lg_12 h_12 b_12 o_12 u_12 pns_12
save "$data\lgb_wave_12.dta", replace

* wave 16
use "$data\Combined_p230u.dta"
drop if plssexor <0 // non-responding, no SCQ, multiple response, refused/not stated

g lgbo_16 = . 
replace lgbo_16 = 1 if plssexor==2  | plssexor==3 | plssexor==4
replace lgbo_16 = 0 if plssexor==1
g lgb_16 = .
replace lgb_16 = 1 if plssexor==2  | plssexor==3 
replace lgb_16 = 0 if plssexor==1  
g h_16 = .
replace h_16 = 1 if plssexor==1
g lg_16 = .
replace lg_16 = 1 if plssexor==2
g b_16 = .
replace b_16 = 1 if plssexor==3
g o_16 =.
replace o_16 = 1 if plssexor==4
g u_16 =.
replace u_16 = 1 if plssexor ==5
g pns_16 = .
replace pns_16 = 1 if plssexor==6

keep xwaveid lgbo_16 lgb_16 lg_16 h_16 b_16 o_16 u_16 pns_16
save "$data\lgb_wave_16.dta", replace

*wave 20
use "$data\Combined_t230u.dta", clear
drop if tlssexor <0 // non-responding, no SCQ, multiple response, refused/not stated

g lgbo_20 = . 
replace lgbo_20 = 1 if tlssexor==2  | tlssexor==3 | tlssexor==4
replace lgbo_20 = 0 if tlssexor==1
g lgb_20 = .
replace lgb_20 = 1 if tlssexor==2  | tlssexor==3 
replace lgb_20 = 0 if tlssexor==1 
g h_20 = .
replace h_20 = 1 if tlssexor==1
g lg_20 = .
replace lg_20 = 1 if tlssexor==2
g b_20 = .
replace b_20 = 1 if tlssexor==3
g o_20 =.
replace o_20 = 1 if tlssexor==4
g u_20 =.
replace u_20 = 1 if tlssexor ==5
g pns_20 = .
replace pns_20 = 1 if tlssexor==6

keep xwaveid lgbo_20 lgb_20 lg_20 h_20 b_20 o_20 u_20 pns_20
save "$data\lgb_wave_20.dta", replace


*********************
*** main cleaning ***
*********************

{
	// Wave 1 variables
	use xwaveid ahhrhid  aanatsi ahhssa1 ahhssa2 ahhssa3 ahhssa4 ahhwtrp ahgint ahgsex ///
		ahgage ahhiage aedhigh1 amrcurr atifditn atifditp ahglth aghgh aghbp aghmh aghpf aghre aghrht *ncdsp ///
		aghpf aghrp aghbp aghgh aghvt aghsf aghre aghmh aghsf6d aghpf aghmh agh1 aanatsi aesbrd ajbmo61 ///
		alssmoke ahifdip ahifdin ahhpers ahhadult aghmh aghsf *lga /// aherate
		ahhstate ahhsos aanbcob aes alsdrink alssmoke arg* ahhpno *cob* alosat* amhrea* *hhhqivw *hglth *hwtsc* ///
		alssupvl alssupac alssupcd alssuplf alssuplt alssupnh alssuppi alssuppv alssupsh alssuptp /// // social support index items
		using "$data\Combined_a230u.dta", clear		// was 160, then 180, now 190		
		
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
	foreach w in b c d e f g h i j k l m n o p q r s t u v w {		

		use xwaveid `w'anatsi* `w'hglth `w'hhrhid `w'hhssa1 `w'hhssa2 `w'hhssa3 `w'hhssa4 `w'hhwtrp `w'hgint `w'hgsex `w'hgage `w'hhiage `w'edhigh1 `w'mrcurr `w'tifditn `w'tifditp  `w'ghgh `w'ghbp `w'ghmh `w'ghpf `w'ghre `w'ghrht *hwtsc* ///
			`w'ghpf `w'ghrp `w'ghbp `w'ghgh `w'ghvt `w'ghsf `w'ghre `w'ghmh `w'ghsf6d `w'gh3a `w'ghpf `w'gh1  `w'anatsi `w'esbrd  `w'jbmo61 `w'hifdip `w'hifdin `w'hhpers `w'hhadult `w'ghmh *ncdsp *lga ///
			`w'hhstate `w'hhsos `w'anbcob `w'es `w'lsdrkf `w'lssmkf  `w'lstbcn `w'rg* `w'hhpno *cob* `w'losat* `w'mhrea* `w'hhhqivw  `w'hglth `w'levio /// 
			`w'lssupvl `w'lssupac `w'lssupcd `w'lssuplf `w'lssuplt `w'lssupnh `w'lssuppi `w'lssuppv `w'lssupsh `w'lssuptp /// // social support
			using "$data\Combined_`w'230u.dta", clear	
			
			rename `w'* *		// Strip off wave prefix
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
	forvalues i=2/23 {
		append using "$data\wave_`i'.dta"
	}
		
	sort xwaveid wave

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
	
	* personal disposable income
	gen income = tifditp - tifditn
	replace income = income/1000
	label var income "personal disposable income (thousands)"

	xtile hh_inc_q=hhincome, nq(4) // quartiles hh income
	
	*sexual orientation
	merge m:1 xwaveid using "$data\lgb_wave_12.dta", nogen 
	merge m:1 xwaveid using "$data\lgb_wave_16.dta", nogen  
	merge m:1 xwaveid using "$data\lgb_wave_20.dta", nogen  // add wave20


   * social support
   g social_loneliness = lssupvl 
   g social_confide = lssupac 
   g social_cheerup = lssupcd 
   g social_lotsfriends = lssuplf 
   g social_leanon = lssuplt 
   g social_helpneed = lssupnh
   g social_time = lssuppi
   g social_visit = lssuppv
   g social_helpneed2 = lssupsh 
   g social_talk = lssuptp

   save "$stigma_data\waves1_23.dta", replace

}


           /**************************************************
                          Preparing for Analysis
           **************************************************/
		   
		   
  /********************************
  *restricting to analytical sample
  ********************************/
		   
use "$stigma_data\waves1_23.dta", clear	

keep if wave >=12
keep if age0>=15	 // 56,788 rows
drop if hhwtsc ==-10 // 51,275 rows (no weight)
/* missing data no SCQ
g no_scq = 1 if ghmh ==-8 // same for everyone 
replace no_scq = 0 if ghmh >-8
ta no_scq
di 18885/205810 //9.18% no SCQ
*/
drop if ghmh == -8 // no SCQ - same obs no SCQ for ghgh (general health)
drop if ghmh == -5 // multiple response SCQ

drop if educ ==. // 90 rows
drop if cob_os ==. //27 rows
drop if rural ==. // 83 rows

bysort xwaveid: egen n_present = total(inlist(wave, 12, 16, 20))
gen miss_wave = (n_present == 0)
drop if miss_wave ==1 // people who were not in the data in wave 12, 16, or 20 (no sexual identity recorded)
drop n_present 
drop miss_wave

// identifiers
destring xwaveid, replace // person cross-wave identifier
destring hhrhid, replace // household cross-wave identifier
egen double HHID=group(hhrhid) // simple household id

// creating new variables
g year = wave+2000 // year

g age_group =. 
replace age_group = 1 if age0>=15 & age0<=24
replace age_group = 2 if age0>=25 & age0<=34
replace age_group = 3 if age0>=35 & age0<=44
replace age_group = 4 if age0>=45 & age0<=54
replace age_group = 5 if age0>=55 & age0<=64
replace age_group = 6 if age0>=65 & age0<=74
replace age_group = 7 if age0>=75
	
g ghsf6d_pct = ghsf6d*100 // health variables 
g losatyh_pct = losatyh*10
g losat_pct = losat*10
recode gh1 (1=5) (2=4) (3=3) (4=2) (5=1), gen(gh1_r)

// drop missing covariates before creating SS index
drop if educ ==. // 90 rows
drop if cob_os ==. //27 rows
drop if rural ==. // 83 rows

// social index
recode social_loneliness (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_loneliness_r)
recode social_confide (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_confide_r)
recode social_leanon (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_leanon_r)
recode social_helpneed (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_helpneed_r)
recode social_time (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_time_r)
recode social_visit (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_visit_r)

g social_index = .
replace social_index = social_cheerup + social_lotsfriends + social_helpneed2 + social_talk ///
                      + social_loneliness_r + social_confide_r + social_leanon_r  ///
					  + social_helpneed_r + social_visit_r + social_time_r ///
       if social_cheerup > 0 & social_lotsfriends > 0 & social_helpneed2 > 0 & social_talk > 0 ///
       & social_loneliness_r > 0 & social_confide_r > 0 & social_leanon_r > 0 & social_helpneed_r > 0 ///
	   & social_visit_r > 0 & social_time_r >0

replace social_index = social_index/10

drop if social_index ==.

//keeping only relevant variables 
keep age0 age_group male cob_os educ married ehi_quart state rural social* xwaveid HHID wave year pns* o* lgb* lg* b_* h_* u_* hhwtsc* ghmh ghgh losat_pct ghsf6d_pct gh1_r losatyh_pct 

  /********************************
       Main LGB Specification
  ********************************/
		   
/*
		g lgbo=0 	  if lgbo_12==0 | lgbo_16==0 | lgbo_20==0
		replace lgbo=1 if lgbo_12==1 | lgbo_16==1 | lgbo_20==1
		
		g lgb=0 	  if lgb_12==0 | lgb_16==0 | lgb_20==0
		replace lgb=1 if lgb_12==1 | lgb_16==1 | lgb_20==1
		
		g h= .
        replace h = 1 if h_12==1 | h_16==1 | h_20==1
		
		g lg=.
		replace lg=1 if lg_12==1 | lg_16==1 | lg_20==1
		
		g b=.
		replace b=1 if b_12==1 | b_16==1 | b_20==1
		
		g o=. 
		replace o=1 if o_12==1 | o_16==1 | o_20==1
		
		g u= .
		replace u=1 if u_12==1 | u_16==1 | u_20==1
		
		g pns=.
		replace pns=1 if pns_12==1 | pns_16==1 | pns_20==1
*/		

// precoding 

* LGB
g ever_lgb = 0
foreach w in 12 16 20 {
    replace ever_lgb = 1 if lgb_`w' == 1
}

* LG
g ever_lg = 0
foreach w in 12 16 20 {
    replace ever_lg = 1 if lg_`w' == 1
}

* B 
g ever_b = 0
foreach w in 12 16 20 {
    replace ever_b = 1 if b_`w' == 1
}

* Other
g ever_o = 0
foreach w in 12 16 20 {
    replace ever_o = 1 if o_`w' == 1
}

* Unsure
g ever_u = 0
foreach w in 12 16 20 {
    replace ever_u = 1 if u_`w' == 1
}

* Prefer not to say
g ever_pns = 0
foreach w in 12 16 20 {
    replace ever_pns = 1 if pns_`w' == 1
}

* ever non-heterosexual
g ever_nonhetero = ever_lgb ==1 | ever_o ==1 | ever_u ==1 | ever_pns ==1

* Main specification: LGB vs Heterosexual Strict
g lgb = .
replace lgb = 1 if ever_lgb ==1
replace lgb = 0 if ever_nonhetero==0



    /********************************
       Supplementary specifications
    ********************************/

// Supplementary specification 1: LGBO Strict vs Heterosexual Strict
gen ever_nonlgbo = 0
foreach w in 12 16 20 {
    replace ever_nonlgbo = 1 if ///
        h_`w' == 1 | u_`w' == 1 | pns_`w' == 1 
}

// Supplementary specification 2: LGBO vs Heterosexual Strict
g lgbo= .
replace lgbo = 1 if ever_lgb==1 | ever_o==1 
replace lgbo = 0 if ever_nonhetero ==0 // control group: only heterosexual 

gen lgbo_strict = .
replace lgbo_strict = 1 if lgbo == 1 & ever_nonlgbo == 0
replace lgbo_strict = 0 if ever_nonhetero==0


// Supplementary specification 3: LGB Strict vs Heterosexual Strict
g ever_nonlgb = 0
foreach w in 12 16 20 {
    replace ever_nonlgb = 1 if ///
        h_`w' == 1 | u_`w' == 1 | pns_`w' == 1 | o_`w'==1
}

gen lgb_strict = .
replace lgb_strict = 1 if lgb == 1 & ever_nonlgb == 0
replace lgb_strict = 0 if ever_nonhetero==0

// Supplementary specification 4: Prefer not to say only
g ever_nonpns = 0
foreach w in 12 16 20 {
    replace ever_nonpns = 1 if ///
        h_`w' == 1 | u_`w' == 1 | lgb_`w'==1 | o_`w'==1
}

gen pns_strict = .
replace pns_strict = 1 if ever_pns == 1 & ever_nonpns == 0
replace pns_strict = 0 if ever_nonhetero==0


// Supplementary specification 5: Unsure/dont know only
g ever_nonu = 0
foreach w in 12 16 20 {
    replace ever_nonu = 1 if ///
        h_`w' == 1 |  pns_`w'== 1 | lgb_`w'==1 | o_`w'==1
}

gen u_strict = .
replace u_strict = 1 if ever_u == 1 & ever_nonu == 0
replace u_strict = 0 if ever_nonhetero==0


// labelling all variables
label define lgb_la 0 "Heterosexual" 1 "LGB" 
label values lgb lgb_la
label define lgbo_la 0 "Heterosexual" 1 "LGBO"
label values lgbo lgbo_la
label define lgb_strict_la 0 "Heterosexual" 1 "Strictly LGB"
label values lgb_strict lgb_strict_la
label define lgb_12_la 0 "Heterosexual" 1 "LGB 2012 Cohort"
label values lgb_12 lgb_12_la

label define age_group_label 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65-74" 7 "75+"
label values age_group age_group_label

label var ghmh "Mental Health"
label var ghsf6d_pct "Health State Classification"
label var losatyh_pct "Health Satisfaction"
label var losat_pct "Life Satisfaction"
label var gh1 "Self-Assessed Health"
label var ghgh "General Health"
label var gh1_r "Self-Assessed Health"

label var state "State"
label var male "Male"
label var ehi_quart "Equivalised Household Income"
label var married "Married or De Facto"
label var rural "Rural"

label var social_index "Social Support Index"



/*
/****************************************
        missing values imputation
****************************************/	

ta wave no_scq

*Individuals with missing MHI
codebook xwaveid if no_scq==1 & lgb==0	//7,271 hetero
codebook xwaveid if no_scq==1 & lgb==1	//340 LGB


*	Missing data table
tab no_scq
tab lgb no_scq
tab male no_scq
tab married no_scq	// 8 missing observations in married
tab age_g no_scq
tab cob_os no_scq	//50 missing observations in cob_os
tab educ no_scq		//96 missing observations (3 individuals) in educ
tab ehi_quart no_scq	
tab state no_scq
tab rural no_scq

* I have missings in educ and cob_os so will create dummies
replace educ=99 if educ==.
replace cob_os=99 if cob_os==.
replace married=99 if married==.
replace rural=99 if rural==.

logit no_scq i.male i.cob_os i.educ i.ehi_quart i.state

g no_scq_2 = ghmh 
replace no_scq_2 = . if ghmh <0


*multiple imputation 
mi set flong

* Register variables to be imputed
mi register imputed no_scq_2

* Register variables to be held constant across imputations (no missing values)
mi register regular lgb age_group male ehi_quart state educ cob_os rural

* Imputation - PMM, knn(5)
mi impute pmm no_scq_2 lgb age_g male married ehi_quart state educ cob_os rural, knn(5) add(50) noisily rseed(64321) replace


*missing indicator method (mode categorical, mean numeric)
ta educ
replace educ = 2 if educ ==. // 90 rows

ta cob_os  
replace cob_os =0 if cob_os ==. // 52 rows 

ta rural  
replace rural = 0 if rural ==. // 85 rows 

sum educ if educ < .
scalar m_educ = r(mean)
replace educ = m_educ if missing(educ)

sum cob_os if cob_os==
scalar m_educ = r(mean)
replace educ = m_educ if missing(educ)
		   
*/		

		
		
           /****************************************
                         Descriptives
           ****************************************/			 
svyset [pweight=hhwtsc]

ta age_group, gen(age_group)
	ta educ, gen(educ)
	ta ehi_quart, gen(ehi_quart)
	ta state, gen(state)

// descriptives table
preserve
drop if lgb_12==.
drop if hhwtsc ==0 // 13 lgb and 174 heterosexual in wave 20

desctable age0 i.age_group i.male i.educ i.married i.cob_os i.ehi_quart i.state rural if wave==12, ///
	filename($output_ss\desc_lgb12_wave12) stats(svymean svysemean) group(lgb_12)

	mean age0 age_group1 age_group2 age_group3 age_group4 age_group5 age_group6 age_group7 ///
		 male educ1 educ2 educ3 married cob_os ///
		 ehi_quart1 ehi_quart2 ehi_quart3 ehi_quart4 ///
		 rural state1 state2 state3 state4 state5 state6 state7 state8 [pw=hhwtsc] if lgb_12 ==0 & wave==12
		
	mean age0 age_group1 age_group2 age_group3 age_group4 age_group5 age_group6 age_group7 ///
		 male educ1 educ2 educ3 married cob_os ///
		 ehi_quart1 ehi_quart2 ehi_quart3 ehi_quart4 ///
		 rural state1 state2 state3 state4 state5 state6 state7 state8 [pw=hhwtsc] if lgb_12 ==1 & wave==12
		
restore			 
			
// pns manual calculation 
unique(xwaveid) if pns_strict ==1 // 313 strictly prefer not to say
unique(xwaveid) if ever_pns ==1 // 961 ever prefer not to say
di 961 - 313 // 648/961 (67.4%) who identified as prefer not to say disclosed sexual identity later

// unsure manual calculator
unique(xwaveid) if u_strict==1
unique(xwaveid) if ever_u ==1
di 453 - 141 // 312/453 (68.87%) who identified as unsure/don't know disclosed an identity later
		
// percentage of non-responders to questions	
ta year ghmh, row // set to if lgb==1 for lgb group
ta year ghgh, row
ta year losat_pct, row 
ta year social_index, row

// outcome vars insert in descriptives seperately as unique refusal rates
preserve
drop if lgb==.
drop if hhwtsc ==0 


mean ghmh [pw=hhwtsc] if lgb==1 & wave ==20 & ghmh >=0
mean ghgh [pw=hhwtsc] if lgb==1 & wave ==20 & ghgh >=0
mean losat_pct [pw=hhwtsc] if lgb==1 & wave ==20 & losat_pct >=0=+

mean ghmh [pw=hhwtsc] if lgb==0 & wave ==20 & ghmh >=0
mean ghgh [pw=hhwtsc] if lgb==0 & wave ==20 & ghgh >=0
mean losat_pct [pw=hhwtsc] if lgb==0 & wave ==20 & losat_pct >=0

restore		

preserve 
drop if lgb==.
drop if hhwtsc ==0
drop if social_index ==.

mean social_index [pw=hhwtsc] if lgb ==1 & wave ==20
mean social_index [pw=hhwtsc] if lgb ==0 & wave ==20

restore
	
            /****************************************
                Model 1: Two Way Interaction      
            ****************************************/	
 
*control specifications 
glo xinf1 i.age_group male
glo xinf2 i.age_group male cob_os i.educ i.ehi_quart rural i.state 


*note: swap out interaction term for lgb group specifications
*note: swap out $xinf for control specifications
*note: change graph graph name and export name for different specifications
/*
foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year i.lgb_year [pw=hhwtsc] if `v'>=0, a($xinf6) cl(HHID)
	
	cap drop ad 
    cap drop ad*	
    cap drop year1
	
	coefplot ., keep(*lgb_year*) vert gen(ad)
	
	format adb adll1 adul1  %12.0f
	br adat adb adll1 adul1  if adat!=. // copy to excel
	
    cap g year1=adat+2011

    local vlabel : variable label `v'
	
twoway ///
    rarea adll1 adul1 year1, fcolor("216 191 216") lcolor("216 191 216") fi(inten30) || ///
    line adb year1, lpattern(solid) lwidth(medthick) lcolor("128 0 128") || ///
    , ///
    xline(2017, lpattern(dash) lcolor("0 0 128")) ///
    xline(2020, lpattern(dash) lcolor("199 21 133")) ///
    text(-12 2013.15 "Marriage Equality", place(e) size(small) color("0 0 128")) ///
    text(-12 2020.15 "COVID-19", place(e) size(small) color("199 21 133")) ///
    yline(0, lpattern(dash) lcolor("150 150 150")) ///
    xtitle("") ///
    ytitle("") ///
    title("Mean Difference in `vlabel'", size(medium) margin(small)) ///
    xlabel(2012 2014 2016 2018 2020 2023, labsize(small) nogrid) ///
    ylabel(1(-2)-13, labsize(small)) yscale(r(1 -13)) ///
    legend(off) ///
    graphregion(fcolor(white)) ///
    name(graph`v'_lgb_noss, replace)

    graph export "$output_ss/`v'_lgb_noss.png", replace		

}	
*/

set scheme s1color

foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year i.lgb_year [pw=hhwtsc] if `v'>=0 & ss_med ==1, a($xinf1) cl(HHID)
	
	cap drop ad 
    cap drop ad*	
    cap drop year1
	
	coefplot ., keep(*lgb_year*) vert gen(ad)
	
	format adb adll1 adul1  %12.0f
	br adat adb adll1 adul1  if adat!=. // copy to excel
	
    cap g year1=adat+2011

    local vlabel : variable label `v'
	

twoway ///
    rarea adll1 adul1 year1, fcolor("128 0 0%30") lcolor("128 0 0") lwidth(none) || ///  
    line adb year1, lpattern(solid) lwidth(medthick) lcolor("128 0 0") || /// 
	scatter adb year1, msymbol(square) mcolor("128 0 0") msize(medium) || ///
	scatteri -10 2011.8 -10 2015.3 -12 2015.3 -12 2011.8 -10 2011.8, recast(area) color(white) lcolor(black) lwidth(thin) || ///
    scatteri -10.5 2012.2, msymbol(pipe) mcolor("255 165 0") mlwidth(thick) msize(large) || /// Marriage Equality legend box
    scatteri -11.5 2012.2, msymbol(pipe) mcolor("204 85 0") mlwidth(thick) msize(large) || /// COVID-19 legend box
    , ///
    xline(2017, lpattern(dash) lcolor("255 165 0") lwidth(thick)) /// Dark orange
    xline(2020, lpattern(dash) lcolor("204 85 0") lwidth(thick)) /// Bright orange
	text(-10.5 2012.4 "Marriage Equality", place(e) size(vsmall) color(black)) ///
    text(-11.5 2012.4 "COVID-19", place(e) size(vsmall) color(black)) ///
    yline(0, lpattern(dash) lcolor(black)) ///
    xtitle("") ///
    ytitle("Coefficient", size(small)) ///
    title("Mean Difference in `vlabel'", size(medium)) ///
    xlabel(2012(1)2023, angle(45) labsize(small) grid) ///
	legend(off) ///
    ylabel(2(-2)-12, labsize(small) grid) yscale(r(2 -12)) ///
    graphregion(fcolor(white)) ///
    name(graph`v'_lgb_noss, replace)

}
   graph export "$output_ss/`v'_lgb_noss.png", replace		
}	


/*	
	margins ,  at(lgb=(0) year=(2012(1)2023)) saving("$output_health\margins`v'_res_het.dta", replace) 
	margins ,  at(lgb_year=(2012(1)2023)) saving("$output_health\margins`v'_res_lgb.dta", replace) // nb dafault is asobserved
}
*/

graph combine  graphghmh_lgb_noss graphghgh_lgb_noss  graphlosat_pct_lgb_noss, ///
            rows(3) cols(1) iscale(1.2) imargins(0 2 0 2) ///
    graphregion(color(white) margin(small)) ///
    xsize(3) ysize(7)  ///
	name(grc1leg, replace)
    graph export "$output_ss/combined_lgb_noss.png", replace width(2000)
	
	
	

	
/*********************
   Inequalities
**********************/
set scheme s1color
graph set window fontface "Arial"
local labsz    vsmall
local tilesz   small
local msz      small

foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year#i.lgb_12 [pw=hhwtsc] if `v'>=0, a($xinf1) cl(HHID)
    margins, over(year) dydx(lgb_12)
    local vlabel : variable label `v'

    marginsplot, xdimension(year)  ///
        ci1opts(legend(off) recast(rarea) fcolor(gs5%45) lwidth(none)) ///
        plotopts(lcolor(gs2) lwidth(medium) lpattern(solid) ///
                 msymbol(circle) msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
        legend(on order(0 " " 0 " ") ///
               position(7) ring(0) rows(1) size(1.5) ///
               symxsize(0) symysize(0) keygap(0) colgap(0) ///
               region(lcolor(none) fcolor(white) margin(small))) ///
        xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
        ylabel(2(-2)-12, labsize(`labsz') grid glcolor(gs13)) yscale(r(2 -12)) ///
        title("`vlabel'", size(`tilesz') margin(small)) ///
        yline(0, lcolor(black) lpattern(dash) lwidth(med)) ///
        ytitle("Coefficient", size(`labsz')) ///
        xtitle("", size(`labsz')) ///
        plotregion(margin(tiny)) graphregion(margin(4 4 4 4) fcolor(white)) ///
        name(ineq2_`v', replace)
}

// Stack the three panels and KEEP the blank legend
grc1leg ineq2_ghmh ineq2_ghgh ineq2_losat_pct, ///
    rows(3) cols(1) imargin(1 1 1 1) ///
    legendfrom(ineq2_ghmh) ///
    title("{bf:LGB–Heterosexual Inequalities (2012 Cohort)}", size(small) span) ///
    graphregion(color(white) margin(small)) name(fig_ineq2, replace)

gr draw fig_ineq2, xsize(3.5) ysize(6) name(fig_ineq2_b, replace)


/**********************
  Predicted values
**********************/
set scheme s1color
graph set window fontface "Arial"
local labsz    vsmall
local tilesz   small
local msz      small

foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year#i.lgb_12[pw=hhwtsc] if `v'>=0, a($xinf1) cl(HHID)
    margins lgb_12, over(year)
    local vlabel : variable label `v'

    if ("`v'"=="ghmh") {
        local legcmd legend(on order(3 "Heterosexual" 4 "LGB(2012 Cohort)") ///
            position(7) ring(0) rows(1) size(1.5) ///
            symxsize(1.8) symysize(0.30) keygap(0.35) colgap(0.55) ///
            region(lcolor(none) fcolor(white) margin(small)))
    }
    else local legcmd legend(off)

    marginsplot, xdimension(year) ///
        ci1opts(legend(off) recast(rarea) fcolor(gs10%70) lcolor(gs10) lwidth(none)) ///
        ci2opts(legend(off) recast(rarea) fcolor(gs10%70) lcolor(gs10) lwidth(none)) ///
        plot1opts(lcolor(gs2) lwidth(medium) lpattern(solid) ///
                  msymbol(circle) msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(medthin)) ///
        plot2opts(lcolor(gs2) lwidth(medium) lpattern(solid)  ///
                  msymbol(circle) msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
        `legcmd' ///
        xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
        ylabel(, labsize(`labsz') grid glcolor(gs13)) ///
        title("`vlabel'", size(`tilesz') margin(small)) ///
        ytitle("Predicted Value", size(`labsz')) ///
        xtitle("", size(`labsz')) ///
        plotregion(margin(tiny)) graphregion(fcolor(white) margin(4 4 4 4)) ///
        name(predi2_`v', replace)
}

grc1leg predi2_ghmh predi2_ghgh predi2_losat_pct, ///
    rows(3) cols(1) imargin(1 1 1 1) ///
    legendfrom(predi2_ghmh) position(6) ring(3) ///
    title("{bf:Predicted Outcomes}", size(small) span) ///
    graphregion(color(white) margin(small)) name(fig_pred2, replace)

gr draw fig_pred2, xsize(3.5) ysize(6) name(fig_pred2_b, replace)


// Final side-by-side (now aligned)
graph combine fig_pred2_b fig_ineq2_b, ///
    rows(1) cols(2) imargin(1 1 1 1) graphregion(color(white)) ///
	xsize(5.5) ysize(6)
	
graph export "$output_ss/model1_xinf1_lgb12.png", replace width(4000) height(3000)



/****************************************************
   LOOP over LGB specs × absorption sets
   LGB specs: lgb, lgb_strict, lgb_12, lgbo
   Absorb:    xinf1, xinf2
****************************************************/

set scheme s1color
graph set window fontface "Arial"

local labsz    vsmall
local tilesz   small
local msz      small

local outcomes "ghmh ghgh losat_pct"
local lgbvars  "lgb lgb_strict lgb_12 lgbo"
local absorbs  "xinf1 xinf2"

foreach L of local lgbvars {

    * Skip if this LGB variable is not in the data
    capture confirm variable `L'
    if _rc {
        di as txt ">> Skipping `L' (variable not found)"
        continue
    }

    * -------- Title string per spec (NO absorb shown) --------
    local TITLE ""
    if      "`L'"=="lgb"         local TITLE "LGB–Heterosexual Inequalities"
    else if "`L'"=="lgbo"        local TITLE "LGBO–Heterosexual Inequalities"
    else if "`L'"=="lgb_strict"  local TITLE "LGB (Strict)–Heterosexual Inequalities"
    else if "`L'"=="lgb_12"      local TITLE "LGB–Heterosexual Inequalities (2012 Cohort)"
    else                         local TITLE "`L'–Heterosexual Inequalities"

    * -------- Legend label for the LGB series (used in predicted plots) --------
    local LLEG ""
    if      "`L'"=="lgb"         local LLEG "LGB"
    else if "`L'"=="lgbo"        local LLEG "LGBO"
    else if "`L'"=="lgb_strict"  local LLEG "LGB (Strict)"
    else if "`L'"=="lgb_12"      local LLEG "LGB (2012 Cohort)"
    else                         local LLEG "`L'"

    foreach A of local absorbs {

        di as res "===== Running: LGB=`L'  |  Absorb=`A' ====="

        * Absorption option for reghdfe
        local absorbopt a($`A')

        /*********************
           INEQUALITIES (dydx(`L') over year)
        *********************/
        foreach v of local outcomes {
            eststo drop _all
            quietly reghdfe `v' i.year#i.`L' [pw=hhwtsc] if `v'>=0, `absorbopt' cl(HHID)

            margins, over(year) dydx(`L')
            local vlabel : variable label `v'
            if "`vlabel'"=="" local vlabel "`v'"

            marginsplot, xdimension(year)  ///
                ci1opts(legend(off) recast(rarea) fcolor(gs5%45) lwidth(none)) ///
                plotopts(lcolor(gs2) lwidth(medium) lpattern(solid) ///
                         msymbol(circle) msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
                legend(on order(0 " " 0 " ") position(7) ring(0) rows(1) size(*0.65) ///
                       symxsize(0) symysize(0) keygap(0) colgap(0) ///
                       region(lcolor(none) fcolor(white) margin(small))) ///
                xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
                ylabel(2(-2)-12, labsize(`labsz') grid glcolor(gs13)) yscale(r(2 -12)) ///
                yline(0, lcolor(black) lpattern(dash) lwidth(med)) ///
                title("`vlabel'", size(`tilesz') margin(small)) ///
                ytitle("Coefficient", size(`labsz')) xtitle("", size(`labsz')) ///
                plotregion(margin(tiny)) graphregion(margin(4 4 4 4) fcolor(white)) ///
                name(ineq_`v'_`L'_`A', replace)
        }

        grc1leg ineq_ghmh_`L'_`A' ineq_ghgh_`L'_`A' ineq_losat_pct_`L'_`A', ///
            rows(3) cols(1) imargin(1 1 1 1) ///
            legendfrom(ineq_ghmh_`L'_`A') ///
            title("{bf:`TITLE'}", size(small) span) ///
            graphregion(color(white) margin(small)) name(fig_ineq_`L'_`A', replace)

        gr draw fig_ineq_`L'_`A', xsize(3.5) ysize(6) name(fig_ineq_b_`L'_`A', replace)


        /*********************
           PREDICTED OUTCOMES (levels of `L' by year)
        *********************/
        foreach v of local outcomes {
            eststo drop _all
            quietly reghdfe `v' i.year#i.`L' [pw=hhwtsc] if `v'>=0, `absorbopt' cl(HHID)

            margins `L', over(year)
            local vlabel : variable label `v'
            if "`vlabel'"=="" local vlabel "`v'"

            if ("`v'"=="ghmh") {
                local legcmd legend(on order(3 "Heterosexual" 4 "`LLEG'") ///
                    position(7) ring(0) rows(1) size(*0.65) ///
                    symxsize(1.35) symysize(0.30) keygap(0.35) colgap(0.55) ///
                    region(lcolor(none) fcolor(white) margin(small)))
            }
            else local legcmd legend(off)

            marginsplot, xdimension(year) ///
                ci1opts(legend(off) recast(rarea) fcolor(gs10%70) lcolor(gs10) lwidth(none)) ///
                ci2opts(legend(off) recast(rarea) fcolor(gs10%70) lcolor(gs10) lwidth(none)) ///
                plot1opts(lcolor(gs2) lwidth(medium) lpattern(solid) ///
                          msymbol(circle) msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(medthin)) ///
                plot2opts(lcolor(gs2) lwidth(medium) lpattern(solid)   ///
                          msymbol(circle) msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
                `legcmd' ///
                xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
                ylabel(, labsize(`labsz') grid glcolor(gs13)) ///
                title("`vlabel'", size(`tilesz') margin(small)) ///
                ytitle("Predicted Value", size(`labsz')) xtitle("", size(`labsz')) ///
                plotregion(margin(tiny)) graphregion(fcolor(white) margin(4 4 4 4)) ///
                name(predi_`v'_`L'_`A', replace)
        }

        grc1leg predi_ghmh_`L'_`A' predi_ghgh_`L'_`A' predi_losat_pct_`L'_`A', ///
            rows(3) cols(1) imargin(1 1 1 1) ///
            legendfrom(predi_ghmh_`L'_`A') position(6) ring(3) ///
            title("{bf:Predicted Outcomes}", size(small) span) ///
            graphregion(color(white) margin(small)) name(fig_pred_`L'_`A', replace)

        gr draw fig_pred_`L'_`A', xsize(3.5) ysize(6) name(fig_pred_b_`L'_`A', replace)


        /*********************
           SIDE-BY-SIDE EXPORT (filename encodes spec + absorb)
        *********************/
        graph combine fig_pred_b_`L'_`A' fig_ineq_b_`L'_`A', ///
            rows(1) cols(2) imargin(1 1 1 1) graphregion(color(white)) ///
            xsize(5.5) ysize(6) name(fig_comb_`L'_`A', replace)

        graph export "$output_ss/model_`L'_`A'.png", replace width(4000) height(3000)
    }
}


/****************************************************
  SOCIAL SUPPORT–STRATIFIED WORKFLOW (3 columns)
  LGB specs: lgb, lgb_strict, lgb_12, lgbo
  Absorb:    xinf1, xinf2  (named x1/x2 inside graph names)
****************************************************/


*social support specifications
// binary
xtile ss_med = social_index, n(2)
replace ss_med = 0 if ss_med==1
replace ss_med =1 if ss_med==2
//tertiles
xtile ss_tert = social_index, n(3)
//custom
g ss_custom1 = 1 if social_index <4.3 
replace ss_custom1 = 0 if social_index >=4.3
g ss_custom2 = 0 if social_index <=3.7
replace ss_custom2 = 1 if social_index >3.7


set scheme s1color
graph set window fontface "Arial"

local labsz    vsmall
local tilesz   small
local msz      small

local outcomes "ghmh ghgh losat_pct"
local lgbvars  "lgb lgb_strict lgb_12 lgbo"
local absorbs  "xinf1 xinf2"

foreach L of local lgbvars {

    capture confirm variable `L'
    if _rc {
        di as txt ">> Skipping `L' (variable not found)"
        continue
    }

    /* Titles (spec only, no absorb) */
    local TITLE_Ineq ""
    if      "`L'"=="lgb"         local TITLE_Ineq "LGB–Heterosexual Inequalities"
    else if "`L'"=="lgbo"        local TITLE_Ineq "LGBO–Heterosexual Inequalities"
    else if "`L'"=="lgb_strict"  local TITLE_Ineq "LGB (Strict)–Heterosexual Inequalities"
    else if "`L'"=="lgb_12"      local TITLE_Ineq "LGB–Heterosexual Inequalities (2012 Cohort)"
    else                         local TITLE_Ineq "`L'–Heterosexual Inequalities"

    local TITLE_Pred "Predicted Outcomes"
    local TITLE_Diff "Difference in Inequalities"

    /* Legend label for LGB series in predicted plots */
    local LLEG ""
    if      "`L'"=="lgb"         local LLEG "LGB"
    else if "`L'"=="lgbo"        local LLEG "LGBO"
    else if "`L'"=="lgb_strict"  local LLEG "LGB (Strict)"
    else if "`L'"=="lgb_12"      local LLEG "LGB (2012 Cohort)"
    else                         local LLEG "`L'"

    foreach A of local absorbs {

        di as res "===== Running (SS‑strat): LGB=`L'  |  Absorb=`A' ====="

        /* Absorb option + short tag for names (xinf1->x1, xinf2->x2) */
        local absorbopt a($`A')
        local Ashort = subinstr("`A'","xinf","x",.)

        /*********************
          COLUMN 2: INEQUALITIES (dydx(`L') by ss_med over year)
        *********************/
        foreach v of local outcomes {
            eststo drop _all
            quietly reghdfe `v' i.year#i.`L'#i.ss_med [pw=hhwtsc] if `v'>=0, `absorbopt' cl(HHID)

            margins ss_med, over(year) dydx(`L')

            local vlabel : variable label `v'
            if "`vlabel'"=="" local vlabel "`v'"
            /* short outcome code for safe graph names */
            local ocode "MH"
            if "`v'"=="ghgh"       local ocode "GH"
            else if "`v'"=="losat_pct" local ocode "LS"

            marginsplot, xdimension(year)  ///
                ci1opts(legend(off) recast(rarea) fcolor(gs12%65) lwidth(none)) ///
                ci2opts(legend(off) recast(rarea) fcolor(gs5%45)  lwidth(none))  ///
                plot1opts(lcolor(gs2) lwidth(medium) lpattern(solid) ///
                          msymbol(circle)  msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(medthin)) ///
                plot2opts(lcolor(gs2) lwidth(medium) lpattern(solid)   ///
                          msymbol(triangle) msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(medthin)) ///
                legend(`=cond("`v'"=="ghmh","on","off")' ///
                       order(3 "Low Social Support" 4 "High Social Support") ///
                       position(7) ring(0) rows(2) size(*0.40) ///
                       symxsize(1.45) symysize(0.30) keygap(0.35) colgap(0.55) ///
                       region(lcolor(none) fcolor(white) margin(small))) ///
                xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
                ylabel(2(-2)-12, labsize(`labsz') grid glcolor(gs13)) yscale(r(2 -12)) ///
                yline(0, lcolor(black) lpattern(dash) lwidth(med)) ///
                title("`vlabel'", size(`tilesz') margin(small)) ///
                ytitle("Coefficient", size(`labsz')) xtitle("", size(`labsz')) ///
                plotregion(margin(tiny)) graphregion(margin(4 4 4 4) fcolor(white)) ///
                name(iss_`ocode'_`L'_`Ashort', replace)
        }

        /* Stack INEQUALITIES with shared legend */
        grc1leg iss_MH_`L'_`Ashort' iss_GH_`L'_`Ashort' iss_LS_`L'_`Ashort', ///
            rows(3) cols(1) imargin(1 1 1 1) ///
            legendfrom(iss_MH_`L'_`Ashort') position(6) ring(3) ///
            title("{bf:`TITLE_Ineq'}", size(small) span) ///
            graphregion(color(white) margin(small)) name(Fiss_`L'_`Ashort', replace)

        gr draw Fiss_`L'_`Ashort', xsize(3.5) ysize(6) name(FissB_`L'_`Ashort', replace)


        /*********************
          COLUMN 1: PREDICTED OUTCOMES by ss_med × `L' over year (4 series)
        *********************/
        foreach v of local outcomes {
            eststo drop _all
            quietly reghdfe `v' i.year#i.`L'#i.ss_med [pw=hhwtsc] if `v'>=0, `absorbopt' cl(HHID)

            margins `L'#ss_med, over(year)

            local vlabel : variable label `v'
            if "`vlabel'"=="" local vlabel "`v'"
            local ocode "MH"
            if "`v'"=="ghgh"       local ocode "GH"
            else if "`v'"=="losat_pct" local ocode "LS"

            if ("`v'"=="ghmh") {
                local legcmd legend(on order(5 "Low Social Support, Hetero" 7 "Low Social Support, `LLEG'" 6 "High Social Support, Hetero" 8 "High Social Support, `LLEG'") ///
                    position(7) ring(0) rows(2) size(*0.40) ///
                    symxsize(1.45) symysize(0.30) keygap(0.35) colgap(0.55) ///
                    region(lcolor(none) fcolor(white) margin(small)))
            }
            else local legcmd legend(off)

            marginsplot, xdimension(year) ///
                ci1opts(legend(off) recast(rarea) fcolor(gs10%70) lwidth(none)) ///
                ci2opts(legend(off) recast(rarea) fcolor(gs10%70) lwidth(none)) ///
                ci3opts(legend(off) recast(rarea) fcolor(gs10%70) lwidth(none)) ///
                ci4opts(legend(off) recast(rarea) fcolor(gs10%70) lwidth(none)) ///
                plot1opts(lcolor(gs2) lwidth(medium) lpattern(solid)       ///
                          msymbol(circle)   msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(medthin)) ///
                plot2opts(lcolor(gs2) lwidth(medium) lpattern(solid)       ///
                          msymbol(circle)   msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
                plot3opts(lcolor(gs2) lwidth(medium) lpattern(solid)   ///
                          msymbol(triangle) msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(medthin)) ///
                plot4opts(lcolor(gs2) lwidth(medium) lpattern(solid)         ///
                          msymbol(triangle) msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
                `legcmd' ///
                xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
                ylabel(, labsize(`labsz') grid glcolor(gs13)) ///
                title("`vlabel'", size(`tilesz') margin(small)) ///
                ytitle("Predicted Value", size(`labsz')) xtitle("", size(`labsz')) ///
                plotregion(margin(tiny)) graphregion(fcolor(white) margin(4 4 4 4)) ///
                name(pss_`ocode'_`L'_`Ashort', replace)
        }

        /* Stack PREDICTED with shared legend */
        grc1leg pss_MH_`L'_`Ashort' pss_GH_`L'_`Ashort' pss_LS_`L'_`Ashort', ///
            rows(3) cols(1) imargin(1 1 1 1) ///
            legendfrom(pss_MH_`L'_`Ashort') position(6) ring(3) ///
            title("{bf:`TITLE_Pred'}", size(small) span) ///
            graphregion(color(white) margin(small)) name(Fpss_`L'_`Ashort', replace)

        gr draw Fpss_`L'_`Ashort', xsize(3.5) ysize(6) name(FpssB_`L'_`Ashort', replace)


  /*********************
  COLUMN 3: DIFFERENCE IN INEQUALITIES (High SS – Low SS)
*********************/
tempfile diffs
capture postutil clear
postfile results str20 outcome int year double coef se t pval ci_lo ci_hi using `diffs', replace

local years 2012/2023

foreach v of local outcomes {
    quietly reghdfe `v' i.year#i.`L'#i.ss_med [pw=hhwtsc] if `v'>=0, `absorbopt' cl(HHID)

    foreach yr of numlist `years' {
        quietly lincom (1.`L'#1.ss_med#`yr'.year - 0.`L'#1.ss_med#`yr'.year) ///
                       - (1.`L'#0.ss_med#`yr'.year - 0.`L'#0.ss_med#`yr'.year)

        post results ("`v'") (`yr') ///
            (r(estimate)) (r(se)) (r(estimate)/r(se)) ///
            (2*ttail(e(df_r), abs(r(estimate)/r(se)))) ///
            (r(estimate) - invttail(e(df_r),0.025)*r(se)) ///
            (r(estimate) + invttail(e(df_r),0.025)*r(se))
    }
}
postclose results

/* Switch to the diffs dataset for plotting, then come back */
preserve
use `diffs', clear
order outcome year coef se ci_lo ci_hi pval
rename (coef ci_lo ci_hi) (diff lo hi)
replace outcome = "Mental Health"     if outcome=="ghmh"
replace outcome = "General Health"    if outcome=="ghgh"
replace outcome = "Life Satisfaction" if outcome=="losat_pct"

/* Make three panels without extra preserve/restore */
foreach o in "Mental Health" "General Health" "Life Satisfaction" {
    local ocode = cond("`o'"=="Mental Health","MH", ///
                 cond("`o'"=="General Health","GH","LS"))

    twoway ///
        (rbar lo hi year if outcome=="`o'", barwidth(0.6) fcolor(gs10%70) lcolor(none)) ///
        (scatter diff year if outcome=="`o'", msymbol(c) mcolor(black) msize(small)), ///
        yline(0, lcolor(black) lpattern(dash)) ///
        xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
        ylabel(-6(2)10, labsize(`labsz') grid glcolor(gs13)) yscale(r(-6 10)) ///
        ytitle("Coefficient", size(`labsz')) xtitle("", size(small)) ///
        title("`o'", size(`tilesz') margin(small)) ///
        legend(on order(0 " " 0 " ") position(7) ring(0) rows(2) size(*0.4) ///
               symxsize(1.45) symysize(0.30) keygap(0.35) colgap(0.55) ///
               region(lcolor(none) fcolor(white) margin(small))) ///
        plotregion(margin(tiny)) graphregion(margin(4 4 4 4) fcolor(white)) ///
        name(dss_`ocode'_`L'_`Ashort', replace)
}

/* Stack DIFF panels; borrow legend footprint from the MH diff */
grc1leg dss_MH_`L'_`Ashort' dss_GH_`L'_`Ashort' dss_LS_`L'_`Ashort', ///
    rows(3) cols(1) imargin(1 1 1 1) ///
    legendfrom(dss_`ocode'_`L'_`Ashort') position(6) ring(3) ///
    title("{bf:`TITLE_Diff'}", size(small) span) ///
    graphregion(color(white) margin(small)) name(Fdss_`L'_`Ashort', replace)

gr draw Fdss_`L'_`Ashort', xsize(3.5) ysize(6) name(FdssB_`L'_`Ashort', replace)

 /* ---- FINAL 3-COLUMN COMBINE & EXPORT ---- */
        capture mkdir "$output_ss"
        local combname FssComb_`L'_`Ashort'

        graph combine FpssB_`L'_`Ashort' FissB_`L'_`Ashort' FdssB_`L'_`Ashort', ///
            rows(1) cols(3) imargin(1 1 1 1) graphregion(color(white)) ///
            xsize(7.2) ysize(6) name(`combname', replace)

        graph export "$output_ss/model_ss_`L'_`Ashort'.png", ///
            replace width(4200) height(3000)

        /* Return to the main analysis dataset for the outer loop */
        restore

	}
  }




dss_MH_`L'_`Ashort'


f ("`v'"=="ghmh") {
                local legcmd legend(on order(5 "Low Social Support, Hetero" 7 "Low Social Support, `LLEG'" 6 "High Social Support, Hetero" 8 "High Social Support, `LLEG'") ///
                    position(7) ring(0) rows(2) size(*0.40) ///
                    symxsize(1.45) symysize(0.30) keygap(0.35) colgap(0.55) ///
                    region(lcolor(none) fcolor(white) margin(small)))


}





























	
	


          /**************************************************
           Model 2: Three Way Interaction with Social Support   
          **************************************************/	

*social support specifications
// binary
xtile ss_med = social_index, n(2)
replace ss_med = 0 if ss_med==1
replace ss_med =1 if ss_med==2
//tertiles
xtile ss_tert = social_index, n(3)
//custom
g ss_custom1 = 1 if social_index <4.3 
replace ss_custom1 = 0 if social_index >=4.3
g ss_custom2 = 0 if social_index <=3.7
replace ss_custom2 = 1 if social_index >3.7


/**********************
     Inequalities:  
**********************/
set scheme s1color
graph set window fontface "Arial"
local labsz    vsmall
local tilesz   small
local lwd      medthin
local msz      small
local legsz    small   // keep for titles/axes; legend uses vsmall below

foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year#lgb#ss_med [pw=hhwtsc] if `v'>=0, cl(HHID)
    margins ss_med, over(year) dydx(lgb) at(ss_med=(0))
    local vlabel : variable label `v'

    if ("`v'"=="ghmh") {
        local legcmd legend(on order(3 "Low Social Support" 4 "High Social Support") ///
            position(7) ring(0) rows(2) size(1.5) ///
            symxsize(1.8) symysize(0.30) keygap(0.35) colgap(0.55) ///
            region(lcolor(none) fcolor(white) margin(small))) 
    }
    else local legcmd legend(off)

    marginsplot, xdimension(year)  ///
	    ci1opts(legend(off) recast(rarea) fcolor(gs12%65) lwidth(none)) ///
        ci2opts(legend(off) recast(rarea) fcolor(gs5%45)  lwidth(none))  ///
        plotopts(  lcolor(gs2) lwidth(medium) lpattern(solid) ///
                   msymbol(circle) msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
        plot2opts( lcolor(gs2) lwidth(medium) lpattern(solid) ///
                   msymbol(triangle)  msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
        `legcmd' ///
        xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
        ylabel(2(-2)-12, labsize(`labsz') grid glcolor(gs13)) yscale(r(2 -12)) ///
        title("`vlabel'", size(`tilesz') margin(small)) ///
        yline(0, lcolor(black) lpattern(dash) lwidth(med)) ///
        ytitle("Coefficient", size(`labsz')) ///
        xtitle("", size(`labsz')) ///
        plotregion(margin(tiny)) graphregion(margin(4 4 4 4) fcolor(white)) ///
        name(ineq_`v', replace)
}

* One legend 
grc1leg ineq_ghmh ineq_ghgh ineq_losat_pct, ///
    rows(3) cols(1) imargin(1 1 1 1) ///
    legendfrom(ineq_ghmh) position(6) ring(3) ///
    title("{bf:LGB–Heterosexual Inequalities}", size(small) span) ///
    graphregion(color(white) margin(small)) name(fig_ineq, replace) 

gr draw fig_ineq, xsize(3) ysize(6.25)	///
name(fig_ineq_b, replace)


/**********************
  Predicted Outcomes
**********************/
set scheme s1color
graph set window fontface "Arial"
local labsz    vsmall
local tilesz   small
local lwd      medthin
local msz      small
local legsz    small

foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year#i.lgb#i.ss_med [pw=hhwtsc] if `v'>=0, cl(HHID)
    margins lgb#ss_med, over(year)
    local vlabel : variable label `v'

    if ("`v'"=="ghmh") {
        local legcmd legend(on order(5 "Low Social Support, Hetero" 7 "Low Social Support, LGB" 6 "High Social Support, Hetero" 8 "High Social Support, LGB") ///
            position(7) ring(0) rows(2) size(1.5) /// ← was `legsz` before, now slightly bigger than before
            symxsize(1.8) symysize(0.30) keygap(0.35) colgap(0.55) ///
            region(lcolor(none) fcolor(white) margin(small))) 
    }
    else local legcmd legend(off)

    marginsplot, xdimension(year) ///
        ci1opts(legend(off) recast(rarea) fcolor(gs10%70) lcolor(gs10) lwidth(none)) ///
        ci2opts(legend(off) recast(rarea) fcolor(gs10%70) lcolor(gs10) lwidth(none)) ///
        ci3opts(legend(off) recast(rarea) fcolor(gs10%70) lcolor(gs10) lwidth(none)) ///
        ci4opts(legend(off) recast(rarea) fcolor(gs10%70) lcolor(gs10) lwidth(none)) ///
        plot1opts(lcolor(gs2) lwidth(medium) lpattern(solid)     ///
                  msymbol(circle)       msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(medthin)) ///
        plot2opts(lcolor(gs2) lwidth(medium) lpattern(solid)      ///
                  msymbol(circle)  msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
        plot3opts(lcolor(gs2) lwidth(medium) lpattern(solid) ///
                  msymbol(triangle) msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(medthin)) ///
        plot4opts(lcolor(gs2) lwidth(medium) lpattern(solid)       ///
                  msymbol(triangle)  msize(`msz') mcolor(black) mlcolor(gs2) mlwidth(medthin)) ///
        `legcmd' ///
        xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
        ylabel(, labsize(`labsz') grid glcolor(gs13)) ///
        title("`vlabel'", size(`tilesz') margin(small)) ///
        ytitle("Predicted Value", size(`labsz')) ///
        xtitle("", size(`labsz')) ///
        plotregion(margin(tiny)) graphregion(fcolor(white) margin(4 4 4 4)) ///
        name(predi_`v', replace)
}


grc1leg predi_ghmh predi_ghgh predi_losat_pct, ///
    rows(3) cols(1) imargin(1 1 1 1) ///
    legendfrom(predi_ghmh) position(6) ring(3) ///
    title("{bf:Predicted Outcomes}", size(small) span) ///
    graphregion(color(white) margin(small)) name(fig_pred, replace)

gr draw fig_pred, xsize(3) ysize(6.25)	///
name(fig_pred_b, replace)	
	

/**********************
  Lincom Contrasts
**********************/	
	
//Loop lincoms for all outcomes and years 
capture postutil clear
postfile results str20 outcome int year double coef se t pval ci_lo ci_hi using ineq_diffs, replace

local outcomes ghmh ghgh losat_pct
local years 2012/2023

foreach v of local outcomes {
    * Estimate model once for this outcome
    quietly reghdfe `v' i.year#i.lgb#i.ss_med [pw=hhwtsc] if `v'>=0, cl(HHID)

    foreach yr of numlist `years' {
        quietly lincom (1.lgb#1.ss_med#`yr'.year - 0.lgb#1.ss_med#`yr'.year) ///
                       - (1.lgb#0.ss_med#`yr'.year - 0.lgb#0.ss_med#`yr'.year)

        post results ("`v'") (`yr') ///
            (r(estimate)) (r(se)) (r(estimate)/r(se)) (2*ttail(e(df_r), abs(r(estimate)/r(se)))) ///
            (r(estimate) - invttail(e(df_r),0.025)*r(se)) ///
            (r(estimate) + invttail(e(df_r),0.025)*r(se))
    }
}

postclose results


/**********************
Inequality Differences
**********************/	

use ineq_diffs, clear
order outcome year coef se ci_lo ci_hi pval
replace outcome = "Mental Health" if outcome == "ghmh"
replace outcome = "General Health" if outcome == "ghgh"
replace outcome = "Life Satisfaction" if outcome == "losat_pct"
rename (coef ci_lo ci_hi) (diff lo hi)
list, abbrev(16)

* one figure per outcome
levelsof outcome, local(outs)

foreach o of local outs {
    preserve
    keep if outcome == "`o'"
    sort year

    local olabel "`o'"
    local gname = subinstr("`o'"," ","_",.)

  twoway ///
    (rbar lo hi year, ///
        barwidth(0.6) fcolor(gs10%70) lcolor(none)) ///
    (scatter diff year, msymbol(c) mcolor(black) msize(small)), ///
    yline(0, lcolor(black) lpattern(dash)) ///
    xlabel(2012(1)2023, angle(45) labsize(vsmall) grid glcolor(gs13)) ///
    ylabel(-6(2)10, labsize(vsmall) grid glcolor(gs13)) yscale(r(-6 10)) ///
    ytitle("Coefficient", size(vsmall)) ///
    xtitle("", size(small)) ///
    title("`olabel'", size(small) margin(small)) ///
    legend(on order(0 " " 0 " ") ///
        position(7) ring(0) rows(2) size(1.5) ///
        symxsize(0) symysize(0) keygap(0) colgap(0) ///
        region(lcolor(none) fcolor(white) margin(small))) ///
    plotregion(margin(tiny)) graphregion(margin(4 4 4 4) fcolor(white)) ///
    name(diff_`gname', replace)
	
    restore
}


* stack the three panels with one outer legendless layout (to match your style)
grc1leg diff_Mental_Health diff_General_Health diff_Life_Satisfaction, ///
    rows(3) cols(1) imargin(1 1 1 1) ///
    title("{bf:Difference in Inequalities}", size(small) span) ///
    graphregion(color(white) margin(small)) name(fig_diff, replace) 

gr draw fig_diff, xsize(4) ysize(5) name(fig_diff_b, replace)

* Combine with your existing two figure stacks (predictions + inequalities)
graph combine fig_pred_b fig_ineq_b fig_diff_b, ///
    rows(1) cols(3) imargin(1 1 1 1) graphregion(color(white))

graph export "$output_ss/model2_xinf0.png", replace width(2600)










	
	
	
	
/*
*regression
foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year i.lgb_year [pw=hhwtsc] if `v'>=0 & ss_med==1, a($xinf6) cl(HHID)
	
	cap drop ad 
    cap drop ad*	
    cap drop year1
	
	coefplot ., keep(*lgb_year*) vert gen(ad)
	
	format adb adll1 adul1  %12.0f
	br adat adb adll1 adul1  if adat!=. // copy to excel
	
    cap g year1=adat+2011

    local vlabel : variable label `v'
	
twoway ///
    rarea adll1 adul1 year1, fcolor("128 0 0%30") lcolor("128 0 0") lwidth(none) || ///  
    line adb year1, lpattern(solid) lwidth(medthick) lcolor("128 0 0") || /// 
	scatter adb year1, msymbol(square) mcolor("128 0 0") msize(medium) || ///
	scatteri -10 2011.8 -10 2015.3 -12 2015.3 -12 2011.8 -10 2011.8, recast(area) color(white) lcolor(black) lwidth(thin) || ///
    scatteri -10.5 2012.2, msymbol(pipe) mcolor("255 165 0") mlwidth(thick) msize(large) || /// Marriage Equality legend box
    scatteri -11.5 2012.2, msymbol(pipe) mcolor("204 85 0") mlwidth(thick) msize(large) || /// COVID-19 legend box
    , ///
    xline(2017, lpattern(dash) lcolor("255 165 0") lwidth(thick)) /// Dark orange
    xline(2020, lpattern(dash) lcolor("204 85 0") lwidth(thick)) /// Bright orange
	text(-10.5 2012.4 "Marriage Equality", place(e) size(vsmall) color(black)) ///
    text(-11.5 2012.4 "COVID-19", place(e) size(vsmall) color(black)) ///
    yline(0, lpattern(dash) lcolor(black)) ///
    xtitle("") ///
    ytitle("Coefficient", size(small)) ///
    title("Mean Difference in `vlabel'", size(small)) ///
    xlabel(2012(1)2023, angle(45) labsize(small) grid) ///
	legend(off) ///
    ylabel(2(-2)-12, labsize(small) grid) yscale(r(2 -12)) ///
    graphregion(fcolor(white)) ///
    name(graph`v'_lgb_lowss, replace)
    graph export "$output_ss/`v'_lgb_lowss.png", replace		
}

/*
shaded CI inequality
* ---- Inequalities: black lines, triangle vs diamond, no CIs ----
set scheme s1color
graph set window fontface "Arial"
local labsz    small
local tilesz   small
local lwd      medthin
local msz      medium
local legsz    small

foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year#i.lgb#i.ss_med [pw=hhwtsc] if `v'>=0, a($xinf6) cl(HHID)
    margins ss_med, over(year) dydx(lgb) at(ss_med=(0))
    local vlabel : variable label `v'

    if ("`v'"=="ghmh") {
        local legcmd legend(on order(1 "Low Social Support" 2 "High Social Support") ///
            position(7) ring(0) rows(2) size(`legsz') ///
            symxsize(1.8) symysize(0.6) keygap(0.3) colgap(0.8) ///
            region(lcolor(none) fcolor(white) margin(small)))
    }
    else local legcmd legend(off)

    marginsplot, xdimension(year) noci ///
        plotopts(  lcolor(gs2) lwidth(medium) lpattern(solid) ///
                   msymbol(triangle) msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(med)) ///
        plot2opts( lcolor(gs2) lwidth(medium) lpattern(solid) ///
                   msymbol(diamond) msize(`msz') mcolor(white) mlcolor(gs2) mlwidth(med)) ///
        `legcmd' ///
        xlabel(2012(1)2023, angle(45) labsize(`labsz') grid glcolor(gs13)) ///
        ylabel(2(-2)-12, labsize(`labsz') grid glcolor(gs13)) yscale(r(2 -12)) ///
        yline(0, lcolor(black) lpattern(dash) lwidth(med)) ///
        title("`vlabel'", size(`tilesz') margin(small)) ///
        ytitle("Coefficient", size(`labsz')) ///
        xtitle("", size(`labsz')) ///
        plotregion(margin(tiny)) graphregion(margin(8 8 8 8) fcolor(white)) ///
        name(ineq_`v', replace)
}
*/
*/	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	






*rcap version
foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year i.lgb_year [pw=hhwtsc] if `v'>=0 & ss_med==1, a($xinf6) cl(HHID)
	
	cap drop ad 
    cap drop ad*	
    cap drop year1
	
	coefplot ., keep(*lgb_year*) vert gen(ad)
	
	format adb adll1 adul1  %12.0f
	br adat adb adll1 adul1  if adat!=. // copy to excel
	
    cap g year1=adat+2011

    local vlabel : variable label `v'
	
twoway ///
    rcap adll1 adul1 year1, lcolor(red) lwidth(medthick) || ///
    line adb year1, lcolor(black) lwidth(medthick) lpattern(solid) || ///
    scatter adb year1, msymbol(square) mcolor(black) msize(medium) || ///
	scatteri -10 2011.8 -10 2015.3 -12 2015.3 -12 2011.8 -10 2011.8, recast(area) color(white) lcolor(black) lwidth(thin) || ///
    scatteri -10.5 2012.2, msymbol(square) mcolor(gs4%25) msize(medium) || /// Marriage Equality legend box
    scatteri -11.5 2012.2, msymbol(square) mcolor(gs4%55) msize(medium) || /// COVID-19 legend box
    , ///
    xline(2017, lwidth(4) lcolor(gs4%25)) ///
    xline(2020, lwidth(4) lcolor(gs4%55)) ///
    text(-10.5 2012.4 "Marriage Equality", place(e) size(vsmall) color(black)) ///
    text(-11.5 2012.4 "COVID-19", place(e) size(vsmall) color(black)) ///
    yline(0, lpattern(dash) lcolor(black)) ///
    xtitle("") ///
    ytitle("Coefficient", size(small)) ///
    title("Low Social Support", size(medsmall) margin(small)) ///
    xlabel(2012(1)2023, angle(45) labsize(small) grid) ///
	legend(off) ///
    ylabel(2(-2)-12, labsize(small) grid) yscale(r(2 -12)) ///
    graphregion(fcolor(white)) ///
    name(graph`v'_lgb_lowss, replace)

   graph export "$output_ss/`v'_lgb_lowss.png", replace		

}	


*rarea second version
foreach v in ghmh ghgh losat_pct {
    eststo m_`v': reghdfe `v' i.year i.lgb_year [pw=hhwtsc] if `v'>=0 & ss_med==2, a($xinf6) cl(HHID)
	
	cap drop ad 
    cap drop ad*	
    cap drop year1
	
	coefplot ., keep(*lgb_year*) vert gen(ad)
	
	format adb adll1 adul1  %12.0f
	br adat adb adll1 adul1  if adat!=. // copy to excel
	
    cap g year1=adat+2011

    local vlabel : variable label `v'
	
twoway ///
    rarea adll1 adul1 year1, fcolor("128 0 0%30") lcolor("128 0 0") lwidth(none) || ///  
    line adb year1, lpattern(solid) lwidth(medthick) lcolor("128 0 0") || /// 
	scatter adb year1, msymbol(square) mcolor("128 0 0") msize(medium) || ///
	scatteri -10 2011.8 -10 2015.3 -12 2015.3 -12 2011.8 -10 2011.8, recast(area) color(white) lcolor(black) lwidth(thin) || ///
    scatteri -10.5 2012.2, msymbol(pipe) mcolor("255 165 0") mlwidth(thick) msize(large) || /// Marriage Equality legend box
    scatteri -11.5 2012.2, msymbol(pipe) mcolor("204 85 0") mlwidth(thick) msize(large) || /// COVID-19 legend box
    , ///
    xline(2017, lpattern(dash) lcolor("255 165 0") lwidth(thick)) /// Dark orange
    xline(2020, lpattern(dash) lcolor("204 85 0") lwidth(thick)) /// Bright orange
	text(-10.5 2012.4 "Marriage Equality", place(e) size(vsmall) color(black)) ///
    text(-11.5 2012.4 "COVID-19", place(e) size(vsmall) color(black)) ///
    yline(0, lpattern(dash) lcolor(black)) ///
    xtitle("") ///
    ytitle("Coefficient", size(small)) ///
    title("High Social Support", size(medsmall) margin(small)) ///
    xlabel(2012(1)2023, angle(45) labsize(small) grid) ///
	legend(off) ///
    ylabel(2(-2)-12, labsize(small) grid) yscale(r(2 -12)) ///
    graphregion(fcolor(white)) ///
    name(graph`v'_lgb_highss, replace)

    graph export "$output_ss/`v'_lgb_highss.png", replace		

}	

	


// combine into 3x2 graph (3 outcomes, 2 social support categorisations)
* Mental Health
graph combine graphghmh_lgb_lowss graphghmh_lgb_highss, ///
    cols(2) rows(1) ///
    title("Mean Difference in Mental Health", size(medium) margin(medium)) ///
    iscale(0.9) imargins(0 0 0 0) ///
    graphregion(color(white) margin(small)) ///
    name(combined_ghmh, replace) ///
    xsize(5) ysize(3)

* General Health
graph combine graphghgh_lgb_lowss graphghgh_lgb_highss, ///
    cols(2) rows(1) ///
    title("Mean Difference in General Health", size(medium) margin(medium)) ///
    iscale(0.9) imargins(0 0 0 0) ///
    graphregion(color(white) margin(small)) ///
    name(combined_ghgh, replace) ///
    xsize(5) ysize(3)

* Life Satisfaction
graph combine graphlosat_pct_lgb_lowss graphlosat_pct_lgb_highss, ///
    cols(2) rows(1) ///
    title("Mean Difference in Life Satisfaction", size(medium) margin(medium)) ///
    iscale(0.9) imargins(0 0 0 0) ///
    graphregion(color(white) margin(small)) ///
    name(combined_losat, replace) ///
    xsize(5) ysize(3)

* Combine all three rows vertically
graph combine combined_ghmh combined_ghgh combined_losat, ///
    rows(3) cols(1) ///
    iscale(0.7) imargins(0 0 0 0) ///
    graphregion(color(white) margin(zero)) ///
    name(final_combined, replace) ///
    xsize(5) ysize(7)
	graph export "$output_ss/combined_lgb_ss.png", replace width(2000)
	
	

graph combine  graphghmh_t1 graphghmh_t2 graphghmh_t3 graphghgh_t1 graphghgh_t2 graphghgh_t3, ///
            rows(2) cols(3) iscale(0.5) imargins(0 0 0 0) ///
    graphregion(color(white) margin(small)) ///
    xsize(5) ysize(4)  ///
	name(grc1leg, replace)	

twoway rarea adll1 adul1 year1, color(navy*0.15) lcolor(navy*0.15) ||  ///
       line adb year1, lpattern(solid) lwidth(medthick) lcolor(navy) ///
        yline(0, lpattern(dash) lcolor(gs8)) ///
        xtitle("Year", size(small)) ///
        ytitle("Mean Difference in `vlabel'", size(small)) ///
        title("Mean Difference in `vlabel' by LGB Status", size(medsmall)) ///
        subtitle("High Social Support", size(small)) ///
        xlabel(2012(2)2023, labsize(small) angle(vertical)) ///
        ylabel(-10(2)10, labsize(small) nogrid) ///
        legend(off) ///
        graphregion(fcolor(white) margin(5 5 5 5)) ///
        plotregion(margin(5 5 5 5)) ///
        name(graph`v'_high, replace)

graph combine graphghmh_xinf1 graphghmh_xinf2 graphghmh_xinf3 graphghmh_xinf4, ///
    cols(4) rows(1) ///
    title("{bf:{ul:Mental Health}}", size(large)) ///
    iscale(1) imargins(0 0 0 0) ///
    graphregion(color(white) margin(small)) ///
    name(combined_ghmh, replace) ///
    xsize(5) ysize(3)


* Mental Health
graph combine graphghmh_low graphghmh_high, ///
    cols(2) rows(1) ///
    title("{bf:{ul:Mean Difference in Mental Health}}", size(medium) margin(medium)) ///
    iscale(1) imargins(0 0 0 0.5) ///
    graphregion(color(white) margin(small)) ///
    name(combined_ghmh, replace) ///
    xsize(5) ysize(3)

* General Health
graph combine graphghgh_low graphghgh_high, ///
    cols(2) rows(1) ///
    title("{bf:{ul:Mean Difference in General Health}}", size(medium) margin(medium)) ///
    iscale(1) imargins(0 0 0 0.5) ///
    graphregion(color(white) margin(small)) ///
    name(combined_ghgh, replace) ///
    xsize(5) ysize(3)

* Life Satisfaction
graph combine graphlosat_pct_low graphlosat_pct_high, ///
    cols(4) rows(1) ///
    title("{bf:{ul:Mean Difference in Life Satisfaction}}", size(medium) margin(medium)) ///
    iscale(1) imargins(0 0 0 0.5) ///
    graphregion(color(white) margin(small)) ///
    name(combined_losat, replace) ///
    xsize(5) ysize(3)

* Combine all three rows vertically
graph combine combined_ghmh combined_ghgh combined_losat, ///
    rows(3) cols(1) ///
    iscale(0.7) imargins(0 0 0 0) ///
    graphregion(color(white) margin(zero)) ///
    name(final_combined, replace) ///
    xsize(5) ysize(7)



* marginal effects temporal trends
preserve
foreach v in social_loneliness {
use "$output_health\margins`v'_res_het.dta", clear
	ren _margin het_beta 
	ren _ci_lb het_ll
	ren _ci_ub het_ul

	merge 1:1 _at using "$output_health\margins`v'_res_lgb.dta"
	ren _margin lgb_beta 
	ren _ci_lb  lgb_ll
	ren _ci_ub  lgb_ul
	
	g year=_at+2011
	
	format het_beta het_ll het_ul lgb_beta lgb_ll lgb_ul %12.1f
	order year het_* lgb* // copy to excel 
	
	if "`v'" == "ghmh" local vlabel "Mental Health"
    else if "`v'" == "ghsf6d_pct" local vlabel "Overall Health"
    else if "`v'" == "losat_pct" local vlabel "Life Satisfaction"

	
	twoway 	rarea het_ll het_ul year , vertical fcolor(gs12%40)  lcolor(gs12) || ///
			line  het_beta year , lpattern(solid) lcolor(black) ||  ///
			rarea lgb_ll lgb_ul year , vertical fcolor(gs12%20) lcolor(gs12) || ///
			line  lgb_beta year , lpattern(dash) lcolor(black)  ///
			yline(0) xlab(2012(3) 2023) ///
			ytitle("`vlabel'", size(medsmall)) title("Loneliness") ///
			xtitle("") ///
			legend(order(2 "Heterosexual" 4 "LGB") position(6) cols(3)) ///
			graphregion(fcolor(white)) ///
		   	name(graph`v'margins, replace)
	        graph export "$output_health\`v'_margins.png", replace
}
restore


/*
* LG vs B stratification inequailities temporal trends
foreach v in ghmh 
     reghdfe ghmh i.year i.lg_year i.b_year  [pw=hhwtscm] if ghmh >=0   , a($xinf3) cl(HHID)
	
	cap drop ad 
    cap drop ad*	
    cap drop year1
	
	coefplot ., keep(*lg_year* *b_year*) vert gen(ad)
	
	format adb adll1 adul1  %12.2f
	br adat adb adll1 adul1  if adat!=. // copy to excel
	
	cap g lg_d = 1 if adat >=1 & adat <=12
	cap g b_d = 1 if adat >12 & adat <=24
	
    cap g year1= adat+2011 if lg_d ==1
	cap replace year1 = adat+1999 if b_d==1

    local vlabel : variable label ghmh
	
	twoway ///
    rarea adll1 adul1 year1 if lg_d == 1, vertical fcolor(navy%20) lcolor(navy) || ///
    line  adb year1 if lg_d == 1, lpattern(solid) lcolor(navy) || ///
    rarea adll1 adul1 year1 if b_d == 1, vertical fcolor(maroon%20) lcolor(maroon) || ///
    line  adb year1 if b_d == 1, lpattern(solid) lcolor(maroon) ///
    yline(0) xlab(2012(2)2023, labsize(small)) ///
    ytitle("") ///
    title("Mean Difference in `vlabel'", size(small)) ///
    subtitle("(Low Community Belonging)", size(vsmall)) ///
    xtitle("") ///
    legend(order(2 "Lesbian/Gay" 4 "Bisexual") ///
           size(small) ring(0) pos(11)) ///
    graphregion(fcolor(white)) ///
    name(graph`v'_smoke, replace)
*/
	
	
	
*continious stigma

replace stig_med = 0 if stig_med ==1
replace stig_med = 1 if stig_med ==2

g stig_year = stig_med*year //high stigma no lgb
g lgb_stig_year = stig_year*lgb // high stigma + lgb

g no10_demeaned = total_nov_sa3_sum - .384

*regression
foreach v in ghmh ghgh {
    eststo m_`v': reghdfe `v' i.year i.lgb_year i.stig_year i.lgb_stig_year [pw=hhwtsc] if `v'>=0, a($xinf6) cl(HHID)
	
	cap drop ad 
    cap drop ad*	
    cap drop year1
	
	coefplot ., keep(*lgb_stig_year*) vert gen(ad)
	
	format adb adll1 adul1  %12.1f
	br adat adb adll1 adul1  if adat!=. // copy to excel
	
    cap g year1=adat+11

    local vlabel : variable label `v'
	

twoway rarea adll1 adul1 year1, color(navy*0.15) lcolor(navy*0.15) ||  ///
       line adb year1, lpattern(solid) lwidth(medthick) lcolor(navy) ///
        yline(0, lpattern(dash) lcolor(gs8)) ///
        xtitle("Year", size(vsmall)) ///
        ytitle("") ///
        title("Mean Difference in `vlabel'", size(vsmall)) ///
        subtitle("(High Social Support)", size(tiny)) ///
        xlabel(12(1)23, labsize(vsmall) nogrid) ///
        ylabel(2(-1)-10, labsize(vsmall)) ///
        legend(off) ///
        graphregion(fcolor(white)) ///
        name(graph`v'_2, replace)
		
	graph export "$output_health\`v'_inequalities.png", replace
}


* stigma

*model 1 (no lgb direct effect)
reghdfe ghmh c.no10#i.year o.no10#o2012.year c.no10#i.year#i.lgb [pw=hhwtsc] if ghmh >=0, a($xinf7 ib2012.year)

*model 2 (lgb direct effects)
reghdfe ghmh lgb c.no10#i.year o.no10#o2012.year c.no10#i.year#i.lgb [pw=hhwtsc] if ghmh >=0, a($xinf7 ib2012.year)

*model 3 (full model)
reghdfe ghmh lgb c.no10#i.year o.no10#o2012.year c.no10#i.year#i.lgb [pw=hhwtsc] if ghmh >=0, a($xinf7 ib2012.year)


g no10 = total_nov_sa3_sum*10
g no10_demean = no10-3.84

g no10_year = no10*year
g no10_lgb_year = lgb_year * no10

reghdfe ghmh i.year i.lgb_year lgb i.no10_year i.no10_lgb_year [pw=hhwtsc] if ghmh>=0, a($xinf7)

reghdfe ghmh ib2012.year c.no10#i.year lgb lgb#i.year c.no10#i.year#lgb [pw=hhwtsc] if ghmh>=0, a($xinf7) 








reghdfe outcome ib2012.year c.no10#i.year o.n10#o2012.year c.no10#i.year#i.group o.no10#o2012.year#o1.group if outcome>=0, a(i.region)



/*	
/******************************************************
*merging marriage equality results to hilda by Sa3 2011
******************************************************/

*sa3
import excel "$stigma_data\CG_SA3_2011_CED_2017.xlsx", sheet(Table 3) clear   
   drop in 1/7
   keep A B C D E 
   rename A sa3_code_2011
   rename B sa3_name_2011
   rename C ced_code_2017
   rename D ced_name_2017
   rename E ratio
   
   destring ratio, replace
   
   gen rownum = _n
   drop if rownum>595
   
   drop rownum
   
   save"SA32011_CED2017.dta", replace   // cleaned sa3 2011 to ced 2017 correspondence
  
  
*sa3 ME merge
use "$stigma_data\me_res_ced_2017.dta", clear
   keep CED_name CED_CODE17 No N 
   g total_nov = No/N
   drop No N
   rename CED_CODE17 ced_code_2017
   tostring ced_code_2017, replace
   save "ms_res_ced_2017_cleaned.dta", replace //cleaned raw marriage equaility results 2017
   
   merge 1:m ced_code_2017 using  "$stigma_data\SA32011_CED2017.dta"
   
   sort sa3_code_2011
   order sa3_code_2011 ratio ced_code_2017 total_nov
   
   bys sa3_code_2011: g total_nov_sa3 = ratio*total_nov
   bys sa3_code_2011: egen total_nov_sa3_sum = total(total_nov_sa3) //final weighted average for each sa3_2011
	
   duplicates drop sa3_code_2011, force // make unique sa3_2011's
   
   drop ratio total_nov CED_name ced_name_2017 sa3_name_2011 _merge total_nov_sa3 
   
   save "SA32011_CED2017_votes.dta", replace  
	


use "$stigma_data\waves1_23.dta", clear	
   	g sa3=hhssa3 if hhssa3>0
	tostring sa3, g(sa3_code_2011)
	
	merge m:1 sa3_code_2011 using "SA32011_CED2017_votes.dta" // sa3 marriage equaility merge

	drop if _merge!=3 // 158 obs with no location (300 total??)

	save "$stigma_data/ron_hilda_me.dta", replace 	
		
*/		
	
