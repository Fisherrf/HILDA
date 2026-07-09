clear all
capture log close
set more off
set mem 1g

set linesize 80
set matsize 800
set maxvar 32767
macro drop _all

cd "C:\Users\fisherrf\The University of Melbourne\Yuting Zhang - chronic conditions"
glo data "C:\Users\fisherrf\The University of Melbourne\Yuting Zhang - chronic conditions\data"
glo output "C:\Users\fisherrf\The University of Melbourne\Yuting Zhang - chronic conditions\output"
glo hilda_data "C:\Users\fisherrf\The University of Melbourne\Karinna Saxby - hilda23\data"

*********************
*** main cleaning ***
*********************

{
	// Wave 1 variables
	use xwaveid ahhrhid aanatsi ahhssa1 ahhssa2 ahhssa3 ahhssa4 ahhwtrp ahgint ahgsex ///
		ahgage ahhiage aedhigh1 amrcurr atifditn atifditp ahglth aghgh aghbp aghmh aghpf aghre aghrht *ncdsp ///
		aghpf aghrp aghbp aghgh aghvt aghsf aghre aghmh aghsf6d aghpf aghmh agh1 aanatsi aesbrd ajbmo61 ///
		alssmoke ahifdip ahifdin ahhpers ahhadult aghmh aghsf *lga /// aherate
		ahhstate ahhsos aanbcob aes alsdrink alssmoke arg* ahhpno *cob* amhrea* *hhhqivw *hglth *hwtsc* ///
		alssupvl alssupac alssupcd alssuplf alssuplt alssupnh alssuppi alssuppv alssupsh alssuptp /// // social support index items
		alosat* /// // Satisfaction variables (life, safety, etc)
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

	gen ehi = hhincome/(1 + 0.5*(hhadult-1) + 0.3*hhchild)
	label var ehi "equivalised household income (thousands)"

	** income quintile based on EHI by wave
	sort ehi
	gen rank = _n/_N
	gen ehiq2 = [rank >= 0.2 & rank < 0.4]
	gen ehiq3 = [rank >= 0.4 & rank < 0.6]
	gen ehiq4 = [rank >= 0.6 & rank < 0.8]
	gen ehiq5 = [rank >= 0.8]

	sort xwaveid
	gen ehiqall = 1 + ehiq2 + 2*ehiq3 + 3*ehiq4 + 4*ehiq5

	** income quartile based on EHI by wave
	sort ehi

	sort xwaveid
	gen     ehi_quart = 1 if [rank < 0.25]
	replace ehi_quart = 2 if [rank >= 0.25 & rank < 0.5]
	replace ehi_quart = 3 if [rank >= 0.5 & rank < 0.75]
	replace ehi_quart = 4 if [rank >= 0.75]

	drop rank
	save "$data\wave_1.dta", replace


	* Deal with waves >2
	** Appends variables that exist only in some waves to relevant waves
	local i = 2
	foreach w in b c d e f g h i j k l m n o p q r s t u v w {

		use using "$data\Combined_`w'230u.dta", clear

		local want ///
			xwaveid `w'anatsi* `w'hglth `w'hhrhid `w'hhssa1 `w'hhssa2 `w'hhssa3 `w'hhssa4 ///
			`w'hhwtrp `w'hgint `w'hgsex `w'hgage `w'hhiage `w'edhigh1 `w'mrcurr ///
			`w'tifditn `w'tifditp `w'ghgh `w'ghbp `w'ghmh `w'ghpf `w'ghre `w'ghrht *hwtsc* ///
			`w'ghrp `w'ghvt `w'ghsf `w'ghsf6d `w'gh3a `w'gh1 `w'esbrd `w'jbmo61 ///
			`w'hifdip `w'hifdin `w'hhpers `w'hhadult *ncdsp *lga `w'hhstate `w'hhsos ///
			`w'anbcob `w'es `w'lsdrkf `w'lssmkf `w'lstbcn `w'rg* `w'hhpno *cob* ///
			`w'losat* `w'mhrea* `w'hhhqivw `w'levio ///
			`w'lssupvl `w'lssupac `w'lssupcd `w'lssuplf `w'lssuplt `w'lssupnh `w'lssuppi `w'lssuppv `w'lssupsh `w'lssuptp /// // social support items
			`w'firisk /// // financial risk taking
			`w'lstrust /// // Trust
			`w'pnenvy /// // Envy
			`w'pnagree `w'pnconsc `w'pnemote `w'pnextrv `w'pnopene /// // Personality traits
			`w'lssecd `w'lsseci `w'lssefd `w'lssefh `w'lsselc `w'lssepa `w'lssesp /// // Locus of control
			`w'pdk10rc /// // Psychological distress
			`w'hech /// // Childhood health rating
			`w'gh10 /// // Social and physical functioning
			`w'fmagelh `w'fmfcob `w'fmmcob `w'fmfemp `w'fmmemp `w'fmfhlq `w'fmmhlq `w'fmpdiv `w'fmhsib /// // Childhood variables
			`w'lertr `w'lefrd `w'jomms `w'jompi `w'leinf `w'ledfr `w'ledsc `w'ledrl `w'lepcm `w'lejlf `w'levio `w'leins `w'lejls /// // Job/Geneneral stress vars
			`w'fiprbeg `w'fiprbfh `w'fiprbmr `w'fiprbps `w'fiprbuh `w'fiprbwm `w'fiprbwo /// // Financial stress vars
			`w'mrcurr /// // Stress divorced/widowed var
			`w'xpphi `w'phpriin /// // Health insurance vars
			`w'lspact `w'bmi `w'hechps `w'fffrt `w'ffveg `w'ffbf /// // Lifestyle (exercise/diet)
			`w'lshrvol /// // volunteering hours
			`w'hehcany `w'hecpany /// // Checkup doctor vars
			`w'slhrwk /// // sleep
			`w'aneab /// // english proficiency
			`w'lssexor /// // sexual orientation
			`w'lsrelrs /// // Stepparent satisfaction
			`w'lsrelsp /// // partner satisfaction
			`w'lsrelrp /// // parent satisfaction
			`w'hehbp `w'hehcd `w'heoc /// // blood hypertension, heart, circulatory
			`w'hecbe `w'heast /// // Bronchitis/emphasyema, and asthma*/ // NOTE: WE DROP RESPIRATORY AS AGE DEPENDENT
			`w'heart /// // arthiritis or osteoporosis
			`w'hecan /// // any type of cancer
			`w'hedi2 // type 2 diabetes

		* Build existing varlist only
		local keepvars
		foreach pat of local want {
			capture unab tmp : `pat'
			if !_rc {
				local keepvars `keepvars' `tmp'
			}
		}

		keep `keepvars'

		rename `w'* *
		gen wave = `i'

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

		gen ehi = hhincome/(1 + 0.5*(hhadult-1) + 0.3*hhchild)
		label var ehi "equivalised household income (thousands)"

		** income quintile based on EHI by wave
		sort ehi
		gen rank = _n/_N
		gen ehiq2 = [rank >= 0.2 & rank < 0.4]
		gen ehiq3 = [rank >= 0.4 & rank < 0.6]
		gen ehiq4 = [rank >= 0.6 & rank < 0.8]
		gen ehiq5 = [rank >= 0.8]

		sort xwaveid
		gen ehiqall = 1 + ehiq2 + 2*ehiq3 + 3*ehiq4 + 4*ehiq5

		** income quartile based on EHI by wave
		sort ehi

		sort xwaveid
		gen     ehi_quart = 1 if [rank < 0.25]
		replace ehi_quart = 2 if [rank >= 0.25 & rank < 0.5]
		replace ehi_quart = 3 if [rank >= 0.5 & rank < 0.75]
		replace ehi_quart = 4 if [rank >= 0.75]

		drop rank

		g pv = 0 if levio == 1
		replace pv = 1 if levio == 2
		la var pv "Victim physical violence"

		save "$data\wave_`i'.dta", replace
		local i = `i' + 1
	}

	use "$data\wave_1.dta", clear
	forvalues i = 2/23 {
		append using "$data\wave_`i'.dta"
	}

	sort xwaveid wave

	/*
	* Merge final interview status (fstatus) and death information for each wave:
	merge m:1 xwaveid using "raw_data\Master_t200u.dta", keepusing (hhsm *fstatus xhhstrat yodeath isdeath aadeath yrenter yrleft) gen(fstatusmerge)

	drop if fstatusmerge ~= 3
	drop fstatusmerge
	*/

	* general data cleaning:

	* weight
	rename hhwtrp weight
	g sc_weight = hhwtsc

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

	xtile hh_inc_q = hhincome, nq(4) // quartiles hh income

	* long term health condition
	g lth = 0 if hglth == 2
	replace lth = 1 if hglth == 1

	g age_g = 1 if hhiage >= 15 & hhiage <= 24
	replace age_g = 2 if hhiage >= 25 & hhiage <= 34
	replace age_g = 3 if hhiage >= 35 & hhiage <= 44
	replace age_g = 4 if hhiage >= 45 & hhiage <= 54
	replace age_g = 5 if hhiage >= 55 & hhiage <= 64
	replace age_g = 6 if hhiage >= 65 & hhiage <= 74
	replace age_g = 7 if hhiage >= 75

	tab age_g, gen(ageg_d)
	gen age2 = age0*age0

	ren hhslga lga_code_2011
	ren lga_code_2011 lgacode_2011

	g smoke = 0 if lssmkf > 0
	replace smoke = 1 if lssmkf == 3

	save "$data\waves1_23.dta", replace
}

* Chronic conditions
egen chronic_cvd = rowmax(hehbp hehcd heoc) // blood hypertension, heart, circulatory
egen chronic_respiratory = rowmax(hecbe heast) // Bronchitis/emphasyema, and asthma*/ // NOTE: WE DROP RESPIRATORY AS AGE DEPENDENT
egen chronic_musculo = rowmax(heart) // arthiritis or osteoporosis
egen chronic_cancer = rowmax(hecan) // any type of cancer
egen chronic_diabetes2 = rowmax(hedi2) // type 2 diabetes
egen chronic_any = rowmax(chronic_cvd chronic_musculo chronic_cancer chronic_diabetes2) // not respiratory included

* english skill
g english_proficiency = aneab

* health vars
rename gh1 sa_health
recode sa_health (1=5) (2=4) (4=2) (5=1)

g childhood_health = hech // childhood health rating
g mental_health = ghmh // mental health
g general_health = ghgh // general health
g overall_health = ghsf6d // overall health
g spfunctioning = gh10   // social/physical functioning

* satisfaction vars
g life_sat = losat // life satisfaction
g health_satisfaction = losatyh
g neighbourhood_satisfaction = losatnl
g home_satisfaction = losathl
g financial_satisfaction = losatfs
g partner_satisfaction = lsrelsp
g safety_satisfaction = losatsf
g parent_satisfaction = lsrelrp
g stepparent_satisfaction = lsrelrs

* childhood vars
g moved_first = fmagelh // age first moved from home
g father_cob = fmfcob // father country born
g mother_cob = fmmcob // mother country born
g father_paid = fmfemp // father paid employment when 14 years old
g mother_paid = fmmemp // mother paid employment when 14 years old
g father_educ = fmfhlq // father highest level qualification
g mother_educ = fmmhlq // mothers highest level qualification
g parents_divorced = fmpdiv // parents ever divorced/seperated
g siblings = fmhsib // ever had siblings

* stress vars
rename lertr stressw_retired  // work-related
rename lefrd stressw_firedredundant
rename jomms stressw_job
rename jompi stressw_job_ill

rename leinf stressf_familyinjill // family related
rename ledfr stressf_deathfriend
rename ledsc stressf_deathspousechild
rename ledrl stressf_deathrelfam
rename lepcm stressf_propertycrime
rename lejlf stressf_jail

rename levio stressp_physicalv // personal stress
rename leins stressp_injill
rename lejls stressp_jail

g stressp_financial = 1 if fiprbeg == 1 | fiprbfh == 1 | fiprbmr == 1 ///
	| fiprbps == 1 | fiprbuh == 1 | fiprbwm == 1 | fiprbwo == 1
replace stressp_financial = 0 if missing(stressp_financial) & ///
	fiprbeg != 1 & fiprbfh != 1 & fiprbmr != 1 & ///
	fiprbps != 1 & fiprbuh != 1 & fiprbwm != 1 & fiprbwo != 1

g stressp_divorced = 1 if mrcurr == 3 | mrcurr == 4
replace stressp_divorced = 0 if mrcurr > 4 | mrcurr < 3

g stressp_widowed = 1 if mrcurr == 5
replace stressp_widowed = 0 if mrcurr != 5

* demographic vars

* private health insurance
g phi = 1 if xpphi == 2  // expenditure variable
replace phi = 0 if xpphi == 1
label var phi "private health insurance"
label define phi 1 "has PHI" 0 "no PHI"
label values phi phi

g phi_2 = 1 if phpriin == 1
replace phi_2 = 0 if phpriin == 2
label var phi_2 "Private Health Insurance Coverage"
label values phi phi

* lifestyle behaviours
g smoke2 = 0 if lssmkf > 0   // never smoked vs has smoked or smokes
replace smoke2 = 1 if lssmkf != 1

g smoke3 = 0 if lssmkf > 0   // (never smoked + has smoked) vs smokes
replace smoke3 = 1 if lssmkf == 3 | lssmkf == 4 | lssmkf == 5

rename lspact exercise  // physical activity
label var exercise "moderate or intensive activity for at least 30 minutes"

rename hechps parents_smoked

rename fffrt fruits
replace fruits = -10 if fruits == 9

rename ffveg vegetables
replace vegetables = -10 if vegetables == 9

rename ffbf eats_breakfast
replace eats_breakfast = -10 if eats_breakfast == 9

* volunteer/community vars
rename lshrvol volunteer

* chronic condition check ups
rename hehcany checkup1_any
rename hecpany checkup2_any

* personality traits
rename pnagree pers_agreeableness
rename pnconsc pers_conscientiousness
rename pnemote pers_emotionalstability
rename pnextrv pers_extroversion
rename pnopene pers_opentoexper

** Psychological distreess
rename pdk10rc psych_distress

** Sexuality
rename lssexor sexuality

* sleep
g sleep_hours = slhrwk  // sleep hours

* parents born overseas
g father_cob_os = 1 if father_cob != 1101 & father_cob > 0
replace father_cob_os = 0 if father_cob == 1101

g mother_cob_os = 1 if mother_cob != 1101 & mother_cob > 0
replace mother_cob_os = 0 if mother_cob == 1101

* age groups
g age_group = .
replace age_group = 1 if age0 >= 15 & age0 < 25
replace age_group = 2 if age0 >= 25 & age0 < 35
replace age_group = 3 if age0 >= 35 & age0 < 45
replace age_group = 4 if age0 >= 45 & age0 < 55
replace age_group = 5 if age0 >= 55 & age0 < 65
replace age_group = 6 if age0 >= 65 & age0 < 75
replace age_group = 7 if age0 >= 75

* Locus of control
g control_doanything = lssecd
g control_changethings = lsseci
g control_future = lssefd
g control_helpless = lssefh
g control_little = lsselc
g control_pushed = lssepa
g control_problems = lssesp

recode control_little       (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_little_r)
recode control_problems     (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_problems_r)
recode control_changethings (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_changethings_r)
recode control_helpless     (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_helpless_r)
recode control_pushed       (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_pushed_r)

gen control = .
replace control = control_future + control_doanything ///
	+ control_little_r + control_problems_r + control_changethings_r ///
	+ control_helpless_r + control_pushed_r ///
	if control_future > 0 & control_doanything > 0 & control_little_r > 0 & control_problems_r > 0 ///
	& control_changethings_r > 0 & control_helpless_r > 0 & control_pushed_r > 0

replace control = control/7

* Social Support
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

recode social_loneliness (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_loneliness_r)
recode social_confide    (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_confide_r)
recode social_leanon     (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_leanon_r)
recode social_helpneed   (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_helpneed_r)
recode social_time       (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_time_r)
recode social_visit      (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_visit_r)

gen social_support = .
replace social_support = social_cheerup + social_lotsfriends + social_helpneed2 + social_talk ///
	+ social_loneliness_r + social_confide_r + social_leanon_r ///
	+ social_helpneed_r + social_visit_r + social_time_r ///
	if social_cheerup > 0 & social_lotsfriends > 0 & social_helpneed2 > 0 & social_talk > 0 ///
	& social_loneliness_r > 0 & social_confide_r > 0 & social_leanon_r > 0 & social_helpneed_r > 0 ///
	& social_visit_r > 0 & social_time_r > 0

replace social_support = social_support/10

* Envy
rename pnenvy envy

* trust
rename lstrust trust

* financial risk
rename firisk financial_risk

* medical checkups
replace checkup1_any = 0 if checkup1_any == 2
replace checkup2_any = 0 if checkup2_any == 2
label define noyes 0 "No" 1 "Yes"
label values checkup1_any noyes
label values checkup2_any noyes

* personality variables
label var pers_extroversion "Extroversion"
label var pers_agreeableness "Agreeableness"
label var pers_conscientiousness "Conscientiousness"
label var pers_emotionalstability "Emotional Stability"
label var pers_opentoexper "Openness"

* health variables
label var sa_health "Self-Assessed Health"
label var mental_health "Mental health"
label var overall_health "Overall Health"
label var spfunctioning "Social and Physical Functioning"
label var checkup1_any "Medical Checkup: Set 1"
label var checkup2_any "Medical Checkup: Set 2"
label var childhood_health "Childhood Health"

* sociodemographic variables
label var age_group "Age Group (years)"
label var male "Male (sex)"
label var married "Married"
label var educ "Education"
label var ehi_quart "Equivalised Household Income"
label var lf "Labour Force"
label var indig "Indigeneous or TSI"
label var rural "Rural"
label var cob_os "Born Overseas"
label var cob_n_en "Born Overseas in Non-English Speaking Country"
label var english_proficiency "English Proficiency"
label var moved_first "Age first moved out of home"
label var siblings "Siblings"

label define age_group 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65-74" 7 "75+"
label define ehi_quart 1 "1st Quartile (Lowest)" 2 "2nd Quartile" 3 "3rd Quartile" 4 "4th Quartile (Highest)"
label values age_group age_group
label values ehi_quart ehi_quart

* lifestyle vars
label var lsdrkf "Drinks Alcohol"
label var exercise "Exercise (Moderate/Intensive)"
label var bmi "Body Mass Index (BMI)"
label var fruits "Fruits"
label var vegetables "Vegetables"
label var smoke2 "Current/Ex Smoker"
label var eats_breakfast "Eats Breakfast"
label var sleep_hours "Hours slept per week"

* Stress classifactions
label var stressw_retired "Retired"   // actually cant include these because all conditional on having employment
label var stressw_firedredundant "Fired/Made Redundant"
label var stressw_job "Job Stress"
label var stressw_job_ill "Job Causes Illness (Belief)"

label var stressf_familyinjill "Family Member Seriously Injured/Ill"
label var stressf_deathfriend "Death of Friend"
label var stressf_deathspousechild "Death of Spouse/Child"
label var stressf_deathrelfam "Death of Relative/Family Member"
label var stressf_propertycrime "Victim of Property Crime"
label var stressf_jail "Family Member in Jail"

label var stressp_physicalv "Victim of Physical Violence"
label var stressp_injill "Serious Injury/Illness"
label var stressp_jail "In Jail"
label var stressp_widowed "Widowed"
label var stressp_divorced "Divorced/Seperated"
label var stressp_financial "Financial"

* satisfaction variables
label var health_satisfaction "Health Satisfaction"
label var neighbourhood_satisfaction "Neighbourhood Satisfaction"
label var home_satisfaction "Home Satisfaction"
label var financial_satisfaction "Financial Satisfaction"
label var partner_satisfaction "Partner Satisfaction"
label var safety_satisfaction "Safety Satisfaction"
label var life_sat "Life Satisfaction"
label var parent_satisfaction "Parent Satisfaction"
label var stepparent_satisfaction "Step-Parent Satisfaction"

* social support variables
label var volunteer "Volunteers"

* family history
label var father_educ "Father Education"
label var father_paid "Father Paid Employment at 14 Years Old"
label var mother_educ "Mother Education"
label var mother_paid "Mother Paid Employment at 14 Years Old"
label var parents_divorced "Parents Ever Divorced"
label var father_cob_os "Father Born Overseas"
label var mother_cob_os "Mother Born Overseas"

* Chronic conditions
label var chronic_cvd "Cardiovascular disease"
label var chronic_respiratory "Respiratory disease"
label var chronic_musculo "Musculoskeletal disease"
label var chronic_cancer "Cancer (any type)"
label var chronic_diabetes2 "Type-2 Diabetes"
label var chronic_any "Chronic condition (any)" // note: non-respiratory

** other value labelling for variables i forgot
label define yesno 1 "Yes" 0 "No"
label define yesno2 1 "Yes" 2 "No" // not needed actually - did manually below
label define yesno3 1 "No" 2 "Yes" // not needed actually - did manually below

* Yes-no (binary) value labelling
label values cob_os yesno
label values cob_n_en yesno
label values phi* yesno
label values smoke2 yesno 
label values father_cob_os yesno 
label values mother_cob_os yesno
label values chronic_* yesno
label values stressp_financial yesno 
label values stressp_divorced yesno 
label values stressp_widowed yesno


**yesno2 option 
foreach v of varlist parents_divorced siblings {
	replace `v' = 0 if `v' ==2
	label values `v' yesno
}

**yesno3 option 
foreach v of varlist  stressw_retired stressw_firedredundant stressf_familyinjill stressf_deathfriend stressf_deathspousechild ///
                      stressf_deathspousechild stressf_deathrelfam stressf_propertycrime stressf_jail stressp_physicalv stressp_injill ///
					  stressp_jail {
					  	replace `v' = 0 if `v' ==1
						replace `v' = 1 if `v '==2
						label values `v' yesno
					  }

* Parental paid employment
** 1 = yes, 0 = no, deceased, or not living with respondent 
replace father_paid = 0 if father_paid >1
replace mother_paid = 0 if mother_paid >1

save "$data/main.dta", replace


	/********************************
	     chronic condition paper 
	********************************/
	
/********************************************************************
CHRONIC CONDITION PAPER — ESTIMATION BLOCK (clean + stable)
- Fixes occupation collinearity by using one categorical occ_group
- Labels *_pre variables for clean esttab output
********************************************************************/

use "$data/main.dta", clear

*-----------------------------*
* 0) Keep only what you need
*-----------------------------*
keep /// 
    childhood_health /// // childhood health rating; only asked once to each person then not asked again
    xwaveid wave age0 chronic_any sexuality ///
    male married indig rural cob_os cob_n_en ///
    educ ehi_quart ///
    lf trade cle_s prd_tr labour whtcollar bluecollar ///
    sa_health mental_health lth ///
    checkup1_any checkup2_any ///
    lsdrkf smoke2 exercise bmi ///
    father_cob_os mother_cob_os father_paid mother_paid ///
    siblings ///
    stressw_retired stressw_firedredundant ///
    stressf_familyinjill stressf_deathfriend stressf_deathrelfam ///
    stressf_propertycrime stressf_jail ///
    stressp_physicalv stressp_injill stressp_financial stressp_divorced ///
    psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///
    social_support ///
    life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction safety_satisfaction

*-----------------------------*
* 1) Setup: risk waves only
*-----------------------------*

* Childhood health rating
bys xwaveid: egen childhood_health_max = max(childhood_health) 
drop if childhood_health_max == 6 // "Health varied"
recode childhood_health_max (5=1) (4=2) (2=4) (1=5)

* LGBT+ ever (NOTE: see comment below if you want strict pre-determination)
gen lgbo = .
replace lgbo = 1 if inlist(sexuality, 2, 3, 4)
replace lgbo = 0 if sexuality == 1
bys xwaveid: egen lgbo_ever = max(lgbo)
drop lgbo sexuality   // sexuality not used further

keep if age0 >= 15
gen year = 2000 + wave

* keep only measurement waves
keep if inlist(wave, 9, 13, 17, 21)
sort xwaveid wave

*-----------------------------*
* 2) Occupation: make ONE categorical variable (fix collinearity)
*-----------------------------*
gen occ_group = .
replace occ_group = 0 if lf==0

* default "other employed / not in listed buckets"
replace occ_group = 1 if lf==1

replace occ_group = 2 if trade==1
replace occ_group = 3 if cle_s==1
replace occ_group = 4 if prd_tr==1
replace occ_group = 5 if labour==1

label define occ_group ///
    0 "Not in labour force" ///
    1 "Other employed" ///
    2 "Trades" ///
    3 "Clerical/sales/service" ///
    4 "Production/transport" ///
    5 "Labourers", replace
label values occ_group occ_group
label var occ_group "Occupation group"

* Drop the overlapping occupation binaries so they can't cause collinearity
drop trade cle_s prd_tr labour whtcollar bluecollar lf

*-----------------------------*
* 3) Define model covariates (EDIT THESE ONLY)
*-----------------------------*
global X_cat  educ ehi_quart  occ_group

global X_cont childhood_health_max sa_health mental_health lsdrkf exercise bmi ///
              psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///
              social_support ///
              life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction safety_satisfaction

global X_bin  male married indig rural cob_os cob_n_en lgbo_ever ///
              lth checkup1_any checkup2_any ///
              smoke2 ///
              father_cob_os mother_cob_os father_paid mother_paid ///
              siblings ///
              stressw_retired stressw_firedredundant ///
              stressf_familyinjill stressf_deathfriend stressf_deathrelfam ///
              stressf_propertycrime stressf_jail ///
              stressp_physicalv stressp_injill stressp_financial stressp_divorced

global X_all $X_cat $X_cont $X_bin

*-----------------------------*
* 4) Drop no-SCQ / negative codes (your approach: row drops)
*-----------------------------*
foreach v of global X_all {
    drop if `v' == -8
    drop if `v' == -10
    drop if `v' < 0
	drop if `v' ==. // basically just for LGBO (3200 rows; 50 chronic people i think)
}

*-----------------------------*
* 5) Build *_pre covariates (previous risk wave)
*-----------------------------*
sort xwaveid year
foreach v of global X_all {
    gen `v'_cf = `v'
    by xwaveid (year): replace `v'_cf = `v'_cf[_n-1] if missing(`v'_cf)
    by xwaveid (year): gen `v'_pre = `v'_cf[_n-1]
    drop `v'_cf
}

*-----------------------------*
* 6) Labels for *_pre (for clean esttab)
*    - copies value labels when they exist
*-----------------------------*
foreach v of global X_all {
    local vl : value label `v'
    if "`vl'" != "" label values `v'_pre `vl'

    local lab : variable label `v'
    if "`lab'" == "" local lab "`v'"
    label var `v'_pre "`lab'"
}

*-----------------------------*
* 7) Chronic outcome + drop prevalent-at-entry
*-----------------------------*
gen chronic_m = chronic_any
replace chronic_m = 0 if chronic_m == -1
replace chronic_m = . if chronic_m == -10
replace chronic_m = . if chronic_m == 99
drop if missing(chronic_m)

bys xwaveid (wave): gen chronic_first = chronic_m[1]
drop if chronic_first==1
drop chronic_first

*-----------------------------*
* 8) Gap rule: require immediate prior risk wave at first onset
*-----------------------------*

* compute lag4_ok ONCE (DON'T recompute later in checks after dropping waves)
sort xwaveid wave
bys xwaveid (wave): gen prev_wave = wave[_n-1]
gen byte lag4_ok = (wave==9) | (wave - prev_wave == 4)
drop prev_wave

* Ensure *_pre is ONLY defined for true 4-year lags
foreach v of global X_all {
    replace `v'_pre = . if lag4_ok==0
}

bys xwaveid: egen onset_wave = min(cond(chronic_m==1, wave, .))
bys xwaveid: egen bad_onset_person = max(wave==onset_wave & onset_wave<. & lag4_ok==0)
unique(xwaveid) if bad_onset_person ==1 // 236 people
drop if bad_onset_person==1 
drop onset_wave bad_onset_person

*-----------------------------*
* 9) First onset + at-risk periods
*-----------------------------*
bys xwaveid: egen first_onset_year = min(cond(chronic_m==1, year, .))
gen ever_onset = first_onset_year < .
drop if ever_onset==1 & year > first_onset_year

*-----------------------------*
* 10) Event tertiles at first onset
*-----------------------------*
quietly centile age0 if ever_onset==1 & year==first_onset_year, centile(33.333 66.666)
scalar c1 = r(c_1)
scalar c2 = r(c_2)

gen event = 0
replace event = 1 if year==first_onset_year & age0 <= c1
replace event = 2 if year==first_onset_year & age0 >  c1 & age0 <= c2
replace event = 3 if year==first_onset_year & age0 >  c2

*-----------------------------*
* 11) Estimation sample
*    - drop wave 9 (baseline-only)
*    - use only rows with true 4-year lag
*-----------------------------*
bys xwaveid (wave): gen prev_wave_full = wave[_n-1]
drop if wave==9
gen byte est_sample = (lag4_ok==1)

tab wave prev_wave_full if est_sample==1, missing

*-----------------------------*
* 12) Build *_pre macros for mlogit
*-----------------------------*
global X_cat_pre  ""
global X_cont_pre ""
global X_bin_pre  ""

foreach v of global X_cat {
    global X_cat_pre "$X_cat_pre `v'_pre"
}

foreach v of global X_cont {
    global X_cont_pre "$X_cont_pre `v'_pre"
}

foreach v of global X_bin {
    global X_bin_pre "$X_bin_pre `v'_pre"
}


* Outcome labels -> become mlogit equation names (use underscores!)
label define event_lbl ///
    0 "No onset" ///
    1 "Early onset" ///
    2 "Mid onset" ///
    3 "Late onset", replace
label values event event_lbl



*-----------------------------*
* 13) Export table
*-----------------------------*
cap which esttab
if _rc ssc install estout, replace

estimates store M_full
esttab M_full using "$output/mlogit_full_clean.rtf", replace ///
    eform b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label compress nogaps ///
    eqlabels("Onset: youngest tertile" "Onset: middle tertile" "Onset: oldest tertile")	

	
	


	/********************************************************************
  FIXED version (no r(198), correct y-gridlines, harmonised x-axis,
  and Drinks will appear even if Stata treated it as factor).

  Key fixes:
  1) Removed the rclass program (your "+ invalid name" came from macros
     not being populated inside that program). We compute y-line limits
     directly with locals.

  2) yline() now stops at the LAST row only:
        total_rows = N + H + (H-1)*GAP
        y_last     = total_rows - 0.5

     (This matches how coefplot's headings(gap()) actually inserts rows:
      the GAP applies *between* headings, not before the first.)

  3) X-axis is harmonised across panels and uses fewer tick labels so it
     won't overlap when the left-side labels are long.

  4) Drinks: we auto-detect whether the coefficient is lsdrkf_pre (continuous)
     OR k.lsdrkf_pre (treated as factor). It will plot whichever exists.
********************************************************************/

*-------------------------*
* 0) Outcome labels (eq names for coefplot) — underscores only
*-------------------------*
label define event_lbl ///
    0 "No_onset" ///
    1 "Early_onset" ///
    2 "Mid_onset" ///
    3 "Late_onset", replace
label values event event_lbl

*-------------------------*
* 1) Estimate model + store
*-------------------------*
mlogit event i.wave ///
    i.($X_cat_pre $X_bin_pre) ///
    c.($X_cont_pre) ///
    if est_sample==1, ///
    baseoutcome(0) vce(cluster xwaveid) rrr
estimates store log2

*-------------------------*
* 2) Plotting style + Drinks coefficient name detection
*-------------------------*
set scheme s1mono
graph set window fontface "Arial"

local GAP 1

* Harmonised x-axis (fewer ticks to avoid overlap in narrow panels)
local XAXIS ///
    xscale(range(0.8 1.53)) ///
    xlabel(0.8(0.2)1.4 1.5, format(%3.1f) labsize(small) nogrid)

* Coef labels (Drinks uses detected name)
local COEFLABS ///
    1.male_pre                     = "Male" ///
    1.married_pre                  = "Married/de facto" ///
    1.indig_pre                    = "Indigenous" ///
    1.rural_pre                    = "Rural" ///
    1.cob_os_pre                   = "Born overseas" ///
    1.cob_n_en_pre                 = "Born overseas (Non-English)" ///
    1.lgbo_ever_pre                = "LGBO" ///
    1.father_cob_os_pre            = "Father born overseas" ///
    1.mother_cob_os_pre            = "Mother born overseas" ///
    1.father_paid_pre              = "Father paid employment" ///
    1.mother_paid_pre              = "Mother paid employment" ///
    1.siblings_pre                 = "Siblings" ///
    2.educ_pre                     = "Yr 12/equivalent" ///
    3.educ_pre                     = "Bachelor or higher" ///
    2.ehi_quart_pre                = "EHI (Quartile 2)" ///
    3.ehi_quart_pre                = "EHI (Quartile 3)" ///
    4.ehi_quart_pre                = "EHI (Quartile 4)" ///
    1.occ_group_pre                = "Other employed" ///
    2.occ_group_pre                = "Trades" ///
    3.occ_group_pre                = "Clerical/sales/service" ///
    4.occ_group_pre                = "Production/transport" ///
    5.occ_group_pre                = "Labourers" ///
    1.stressw_retired_pre          = "Retired" ///
    1.stressw_firedredundant_pre   = "Fired or redundant" ///
    1.stressf_familyinjill_pre     = "Family injured/illness" ///
    1.stressf_deathfriend_pre      = "Death of friend" ///
    1.stressf_deathrelfam_pre      = "Death of relative" ///
    1.stressf_propertycrime_pre    = "Property crime victim" ///
    1.stressf_jail_pre             = "Family member jailed" ///
    1.stressp_physicalv_pre        = "Physical violence victim" ///
    1.stressp_injill_pre           = "Injury or illness" ///
    1.stressp_financial_pre        = "Financial stress" ///
    1.stressp_divorced_pre         = "Divorced/separated" ///
    1.smoke2_pre                   = "Smoker" ///
    lsdrkf_pre                     = "Drinks" ///
    exercise_pre                   = "Exercise" ///
    bmi_pre                        = "Body Mass Index" ///
    1.checkup1_any_pre             = "Medical checkups (Set 1)" ///
    1.checkup2_any_pre             = "Medical checkups (Set 2)" ///
	childhood_health_max_pre           = "Childhood health" ///
    sa_health_pre                  = "Self-assessed health" ///
    mental_health_pre              = "Mental health" ///
    psych_distress_pre             = "K10 distress" ///
    social_support_pre             = "Social support" ///
    life_sat_pre                   = "Life satisfaction" ///
    health_satisfaction_pre        = "Health satisfaction" ///
    neighbourhood_satisfaction_pre = "Neighbourhood satisfaction" ///
    safety_satisfaction_pre        = "Safety satisfaction" ///
    home_satisfaction_pre          = "Home satisfaction" ///
    pers_agreeableness_pre         = "Agreeable" ///
    pers_conscientiousness_pre     = "Conscientious" ///
    pers_emotionalstability_pre    = "Emotional stability" ///
    pers_opentoexper_pre           = "Open" ///
    pers_extroversion_pre          = "Extrovert"

* Base common style
local GBASE ///
    drop(_cons) eform ///
    coeflabels(`COEFLABS') ///
    xline(1, lpattern(dash) lcolor(black) lwidth(medthin)) ///
    ylabel(, labsize(small) angle(0) nogrid) ///
    graphregion(color(white) margin(l=6 r=2 t=2 b=6)) ///
    plotregion(margin(zero)) ///
    xsize(7)

* ============================================================
* PANEL 1: Demographics + Family background + Education & SES + Employment
* ============================================================
local KEEPVARS_p1 ///
    1.male_pre 1.married_pre 1.indig_pre 1.rural_pre ///
    1.cob_os_pre 1.cob_n_en_pre 1.lgbo_ever_pre ///
    1.father_cob_os_pre 1.mother_cob_os_pre 1.father_paid_pre 1.mother_paid_pre 1.siblings_pre ///
    2.educ_pre 3.educ_pre 2.ehi_quart_pre 3.ehi_quart_pre 4.ehi_quart_pre ///
    1.occ_group_pre 2.occ_group_pre 3.occ_group_pre 4.occ_group_pre 5.occ_group_pre

local HEADS_p1 ///
    headings( ///
        1.male_pre          = "{bf:Demographics}" ///
        1.father_cob_os_pre = "{bf:Family background}" ///
        2.educ_pre          = "{bf:Education & SES}" ///
        1.occ_group_pre     = "{bf:Employment}", ///
        gap(`GAP') labsize(small) ///
    )

local N1 : word count `KEEPVARS_p1'
local H1 4
local total1 = `N1' + `H1' + (`H1' - 1)*`GAP'
local ylast1 = `total1' - 0.5
local ysize1 = 0.40*`N1' + 1.6

coefplot ///
    (log2, drop(Mid_onset:* Late_onset:*)  label("Early onset") offset(0.12) ///
        msymbol(O) msize(small) mcolor(black) ///
        ciopts(recast(rcap) lwidth(thin) lcolor(black))) ///
    (log2, drop(Early_onset:* Late_onset:*) label("Mid onset") offset(0) ///
        msymbol(O) msize(small) mcolor(gs6) ///
        ciopts(recast(rcap) lwidth(thin) lcolor(gs6))) ///
    (log2, drop(Early_onset:* Mid_onset:*)  label("Late onset") offset(-0.12) ///
        msymbol(O) msize(small) mcolor(gs10) ///
        ciopts(recast(rcap) lwidth(thin) lcolor(gs10))) ///
    , ///
    `GBASE' ///
    keep(`KEEPVARS_p1') order(`KEEPVARS_p1') ///
    `HEADS_p1' ///
    ysize(`ysize1') ///
    yline(0.5(1)`ylast1', lcolor(gs12) lpattern(solid) lwidth(thin)) ///
	xlabel(0(0.5)5.5, labsize(small) nogrid) ///
    grid(none) ///
    xtitle("Relative risk ratio", size(small)) ///
    legend(order(2 "Early onset" 4 "Mid onset" 6 "Late onset") ///
           cols(1) size(small) pos(2) ring(0) ///
           region(lstyle(solid) lcolor(black) lwidth(thin))) ///
    name(fig_p1, replace)

* ============================================================
* PANEL 2: Stressors + Lifestyle behaviours + Health care use
* ============================================================
local KEEPVARS_p2 ///
    1.stressw_retired_pre 1.stressw_firedredundant_pre ///
    1.stressf_familyinjill_pre 1.stressf_deathfriend_pre 1.stressf_deathrelfam_pre ///
    1.stressf_propertycrime_pre 1.stressf_jail_pre ///
    1.stressp_physicalv_pre 1.stressp_injill_pre 1.stressp_financial_pre 1.stressp_divorced_pre ///
    1.smoke2_pre lsdrkf_pre exercise_pre bmi_pre ///
    1.checkup1_any_pre 1.checkup2_any_pre

local HEADS_p2 ///
    headings( ///
        1.stressw_retired_pre = "{bf:Stressors}" ///
        1.smoke2_pre          = "{bf:Lifestyle behaviours}" ///
        1.checkup1_any_pre    = "{bf:Health care use}", ///
        gap(`GAP') labsize(small) ///
    )

local N2 : word count `KEEPVARS_p2'
local H2 3
local total2 = `N2' + `H2' + (`H2' - 1)*`GAP'
local ylast2 = `total2' - 0.5
local ysize2 = 0.40*`N2' + 1.6

coefplot ///
    (log2, drop(Mid_onset:* Late_onset:*)  label("Early onset") offset(0.12) ///
        msymbol(O) msize(small) mcolor(black) ///
        ciopts(recast(rcap) lwidth(thin) lcolor(black))) ///
    (log2, drop(Early_onset:* Late_onset:*) label("Mid onset") offset(0) ///
        msymbol(O) msize(small) mcolor(gs6) ///
        ciopts(recast(rcap) lwidth(thin) lcolor(gs6))) ///
    (log2, drop(Early_onset:* Mid_onset:*)  label("Late onset") offset(-0.12) ///
        msymbol(O) msize(small) mcolor(gs10) ///
        ciopts(recast(rcap) lwidth(thin) lcolor(gs10))) ///
    , ///
    `GBASE' ///
    keep(`KEEPVARS_p2') order(`KEEPVARS_p2') ///
    `HEADS_p2' ///
    ysize(`ysize2') ///
    yline(0.5(1)`ylast2', lcolor(gs12) lpattern(solid) lwidth(thin)) ///
	xlabel(0(0.5)5.5, labsize(small) nogrid) ///
    grid(none) ///
    xtitle("Relative risk ratio", size(small)) ///
    legend(off) ///
    name(fig_p2, replace)

* ============================================================
* PANEL 3: Health & psychosocial + Satisfaction + Personality traits
* ============================================================
local KEEPVARS_p3 ///
    childhood_health_max_pre sa_health_pre mental_health_pre psych_distress_pre social_support_pre ///
    life_sat_pre health_satisfaction_pre neighbourhood_satisfaction_pre ///
    safety_satisfaction_pre home_satisfaction_pre ///
    pers_agreeableness_pre pers_conscientiousness_pre pers_emotionalstability_pre ///
    pers_opentoexper_pre pers_extroversion_pre

local HEADS_p3 ///
    headings( ///
        childhood_health_max_pre   = "{bf:Health & psychosocial}" ///
        life_sat_pre               = "{bf:Satisfaction}" ///
        pers_agreeableness_pre     = "{bf:Personality traits}", ///
        gap(`GAP') labsize(small) ///
    )

local N3 : word count `KEEPVARS_p3'
local H3 3
local total3 = `N3' + `H3' + (`H3' - 1)*`GAP'
local ylast3 = `total3' - 0.5
local ysize3 = 0.40*`N3' + 1.6

coefplot ///
    (log2, drop(Mid_onset:* Late_onset:*)  label("Early onset") offset(0.12) ///
        msymbol(O) msize(small) mcolor(black) ///
        ciopts(recast(rcap) lwidth(thin) lcolor(black))) ///
    (log2, drop(Early_onset:* Late_onset:*) label("Mid onset") offset(0) ///
        msymbol(O) msize(small) mcolor(gs6) ///
        ciopts(recast(rcap) lwidth(thin) lcolor(gs6))) ///
    (log2, drop(Early_onset:* Mid_onset:*)  label("Late onset") offset(-0.12) ///
        msymbol(O) msize(small) mcolor(gs10) ///
        ciopts(recast(rcap) lwidth(thin) lcolor(gs10))) ///
    , ///
    `GBASE' ///
    keep(`KEEPVARS_p3') order(`KEEPVARS_p3') ///
    `HEADS_p3' ///
    ysize(`ysize3') ///
    yline(0.5(1)`ylast3', lcolor(gs12) lpattern(solid) lwidth(thin)) ///
	xlabel(0.4(0.1)1.5, labsize(small) nogrid) ///
    grid(none) ///
    xtitle("Relative risk ratio", size(small)) ///
    legend(off) ///
    name(fig_p3, replace)

*-------------------------*
* Export + combined (use bigger inner margins so axes don't clash)
*-------------------------*
graph export "$output/Figure_multinomial_panel1.tif", replace name(fig_p1)
graph export "$output/Figure_multinomial_panel2.tif", replace name(fig_p2)
graph export "$output/Figure_multinomial_panel3.tif", replace name(fig_p3)

graph combine fig_p1 fig_p2 fig_p3, cols(1) xcommon ///
    imargin(small) graphregion(color(white) margin(zero)) ///
    xsize(7) ysize(11.0) name(fig_all, replace)

graph export "$output/Figure_multinomial_THEMED_panels.pdf", replace
graph export "$output/Figure_multinomial_THEMED_panels.tif", width(4000) replace

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
*******************************************************
* CHRONIC CONDITION PAPER — mlogit + BEAUTIFUL coefplot
* (one row per covariate; 3 dots per row)
*******************************************************

/********************************************************************
COEFPLOT FOR CHRONIC CONDITION MLOGIT (matches your old style)
- Each coefficient appears ONCE on the y-axis
- 3 markers/CI per coefficient (event=1/2/3), distinguished by legend
- Uses proper labels (copies labels/value labels onto *_pre)
********************************************************************/

*-----------------------------*
* 0) Estimate + store (name must match coefplot call)
*-----------------------------*

* Outcome labels -> become mlogit equation names (use underscores!)
label define event_lbl ///
    0 "No onset" ///
    1 "Early onset" ///
    2 "Mid onset" ///
    3 "Late onset", replace
label values event event_lbl

mlogit event i.wave ///
    i.($X_cat_pre $X_bin_pre) ///
    c.($X_cont_pre) ///
    if est_sample==1, ///
    baseoutcome(0) vce(cluster xwaveid)

estimates store log2   // <-- IMPORTANT: use this exact name


********************
* Multinomial coefplot (replicate previous style)
********************
set scheme s1mono
graph set window fontface "Arial"


* --- choose what appears in the plot (must match coeflegend names) ---
* NOTE: for factor vars, include the coefficient levels that actually exist (i.e., non-base levels)
local KEEPVARS ///
    /* Demographics */ ///
    1.male_pre 1.married_pre 1.indig_pre 1.rural_pre ///
    1.cob_os_pre 1.cob_n_en_pre 1.lgbo_ever_pre ///
    /* Family background */ ///
    1.father_cob_os_pre 1.mother_cob_os_pre 1.father_paid_pre 1.mother_paid_pre 1.siblings_pre ///
    /* Education / SES */ ///
    2.educ_pre 3.educ_pre ///
    2.ehi_quart_pre 3.ehi_quart_pre 4.ehi_quart_pre ///
    /* Employment */ ///
    1.occ_group_pre 2.occ_group_pre 3.occ_group_pre 4.occ_group_pre 5.occ_group_pre ///
    /* Stressors */ ///
    1.stressw_retired_pre 1.stressw_firedredundant_pre ///
    1.stressf_familyinjill_pre 1.stressf_deathfriend_pre 1.stressf_deathrelfam_pre ///
    1.stressf_propertycrime_pre 1.stressf_jail_pre ///
    1.stressp_physicalv_pre 1.stressp_injill_pre 1.stressp_financial_pre 1.stressp_divorced_pre ///
    /* Lifestyle */ ///
    1.smoke2_pre lsdrkf_pre exercise_pre bmi_pre ///
    /* Health care use */ ///
    1.checkup1_any_pre 1.checkup2_any_pre ///
    /* Health / psychosocial */ ///
    sa_health_pre mental_health_pre psych_distress_pre social_support_pre ///
    /* Satisfaction */ ///
    life_sat_pre health_satisfaction_pre neighbourhood_satisfaction_pre ///
    safety_satisfaction_pre home_satisfaction_pre ///
    /* Personality */ ///
    pers_agreeableness_pre pers_conscientiousness_pre pers_emotionalstability_pre ///
    pers_opentoexper_pre pers_extroversion_pre

* --- Order = themed order (this is what makes headings work nicely) ---
local ORDERVARS `KEEPVARS'

* --- coefficient labels ---
local COEFLABS ///
    1.male_pre                     = "Male" ///
    1.married_pre                  = "Married/de facto" ///
    1.indig_pre                    = "Indigenous" ///
    1.rural_pre                    = "Rural" ///
    1.cob_os_pre                   = "Born overseas" ///
    1.cob_n_en_pre                 = "Born overseas (Non-English)" ///
    1.father_cob_os_pre            = "Father born overseas" ///
    1.mother_cob_os_pre            = "Mother born overseas" ///
    1.father_paid_pre              = "Father paid employment" ///
    1.mother_paid_pre              = "Mother paid employment" ///
    1.siblings_pre                 = "Siblings" ///
    1.stressw_retired_pre          = "Retired" ///
    1.stressw_firedredundant_pre   = "Fired or redundant" ///
    1.stressf_familyinjill_pre     = "Family injured/illness" ///
    1.stressf_deathfriend_pre      = "Death of friend" ///
    1.stressf_deathrelfam_pre      = "Death of relative" ///
    1.stressf_propertycrime_pre    = "Property crime victim" ///
    1.stressf_jail_pre             = "Family member jailed" ///
    1.stressp_physicalv_pre        = "Physical violence victim" ///
    1.stressp_injill_pre           = "Injury or illness" ///
    1.stressp_financial_pre        = "Financial stress" ///
    1.stressp_divorced_pre         = "Divorced/separated" ///
    1.lgbo_ever_pre                = "LGBO" ///
    2.educ_pre                     = "Yr 12/equivalent" ///
    3.educ_pre                     = "Bachelor or higher" ///
    2.ehi_quart_pre                = "EHI (Quartile 2)" ///
    3.ehi_quart_pre                = "EHI (Quartile 3)" ///
    4.ehi_quart_pre                = "EHI (Quartile 4)" ///
    1.occ_group_pre                = "Other employed" ///
    2.occ_group_pre                = "Trades" ///
    3.occ_group_pre                = "Clerical/sales/service" ///
    4.occ_group_pre                = "Production/transport" ///
    5.occ_group_pre                = "Labourers" ///
    1.smoke2_pre                   = "Smoker" ///
    1.checkup1_any_pre             = "Medical checkups (Set 1)" ///
    1.checkup2_any_pre             = "Medical checkups (Set 2)" ///
	lsdrkf_pre                     = "Drinks" ///
    sa_health_pre                  = "Self-assessed health" ///
    mental_health_pre              = "Mental health" ///
    exercise_pre                   = "Exercise" ///
    bmi_pre                        = "Body Mass Index" ///
    psych_distress_pre             = "K10 distress" ///
    social_support_pre             = "Social support" ///
    life_sat_pre                   = "Life satisfaction" ///
    health_satisfaction_pre        = "Health satisfaction" ///
    neighbourhood_satisfaction_pre = "Neighbourhood satisfaction" ///
    safety_satisfaction_pre        = "Safety satisfaction" ///
    home_satisfaction_pre          = "Home satisfaction" ///
    pers_agreeableness_pre         = "Agreeable" ///
    pers_conscientiousness_pre     = "Conscientious" ///
    pers_emotionalstability_pre    = "Emotional stability" ///
    pers_opentoexper_pre           = "Open" ///
    pers_extroversion_pre          = "Extrovert"

* dynamic sizing
local N : word count `ORDERVARS'
local yend = `N' + 0.5
local ysize = cond(`N'<=8, 3.8, 0.45*`N')

* Headings (theme separators)
* Key rule: specify ONLY the FIRST coefficient in each theme. :contentReference[oaicite:1]{index=1}
local HEADS ///
    headings( ///
        1.male_pre            = "{bf:Demographics}" ///
        1.father_cob_os_pre   = "{bf:Family background}" ///
        2.educ_pre            = "{bf:Education \& SES}" ///
        1.occ_group_pre       = "{bf:Employment}" ///
        1.stressw_retired_pre = "{bf:Stressors}" ///
        1.smoke2_pre          = "{bf:Lifestyle behaviours}" ///
        1.checkup1_any_pre    = "{bf:Health care use}" ///
        sa_health_pre         = "{bf:Health \& psychosocial}" ///
        life_sat_pre          = "{bf:Satisfaction}" ///
        pers_agreeableness_pre= "{bf:Personality traits}", ///
        gap(1) labsize(small) ///
    )

* Common styling (matches your old figure)
local GCOMMON ///
    drop(_cons) eform ///
    keep(`KEEPVARS') order(`ORDERVARS') ///
    coeflabels(`COEFLABS') ///
    `HEADS' ///
    xline(1, lpattern(dash) lcolor(black) lwidth(medthin)) ///
    xlabel(0.8(0.1)1.53, labsize(small) nogrid) ///
    ylabel(, labsize(small) angle(0) nogrid) ///
    graphregion(color(white) margin(l=6 r=2 t=2 b=2)) ///
    plotregion(margin(zero)) ///
    xsize(7) ysize(`ysize')

coefplot ///
    (log2, drop(Mid_onset:* Late_onset:*) ///
          label("Early onset") offset(0.12) ///
          msymbol(O) msize(small) mcolor(black) ///
          ciopts(recast(rcap) lwidth(thin) lcolor(black))) ///
    (log2, drop(Early_onset:* Late_onset:*) ///
          label("Mid onset") offset(0) ///
          msymbol(O) msize(small) mcolor(gs6) ///
          ciopts(recast(rcap) lwidth(thin) lcolor(gs6))) ///
    (log2, drop(Early_onset:* Mid_onset:*) ///
          label("Late onset") offset(-0.12) ///
          msymbol(O) msize(small) mcolor(gs10) ///
          ciopts(recast(rcap) lwidth(thin) lcolor(gs10))) ///
    , ///
    `GCOMMON' ///
    yline(0.5(1)`yend', lcolor(gs12) lpattern(solid) lwidth(thin)) ///
    grid(none) ///
    xtitle("Relative risk ratio", size(small)) ///
    legend( ///
        order(2 "Early onset" 4 "Mid onset" 6 "Late onset") ///
        cols(1) size(small) pos(2) ring(0) ///
        region(lstyle(solid) lcolor(black) lwidth(thin)) ///
    ) ///
    name(fig_multi, replace)

graph export "$output/Figure_multinomial_chronic.tif", width(4000) replace
graph export "$output/Figure_multinomial_chronic.pdf", replace























	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
/********************************************************************
Discrete-time competing-risks onset model estimated via mlogit

Risk waves: 2009, 2013, 2017, 2021  (waves 9, 13, 17, 21)
Outcome per risk wave:
  0 = no first onset this wave
  1 = first onset this wave, age < 40
  2 = first onset this wave, age 40-54
  3 = first onset this wave, age 55-69
  4 = first onset this wave, age 70+

Covariates: last observed value BEFORE the risk wave (LOCF + lag)
Wave FE: i.wave  (baseline hazard)
SE: clustered by xwaveid
********************************************************************/

/********************************************************************
FULL competing-risks discrete-time onset model (mlogit)

- Outcome measured only in waves 9/13/17/21
- Covariates use "last observed value prior to risk wave" (LOCF + 1-wave lag)
- Drop prevalent-at-entry (chronic==1 at first observed measurement wave)
- Stop contributing risk time after first onset
- Drop wave 9 from estimation (baseline-only => structural zero events)

EDITING:
- To add/remove predictors: edit the locals in Section 1 only.
********************************************************************/







/********************************************************************
CHRONIC CONDITION PAPER — FINAL ESTIMATION BLOCK (clean + consistent)
- Uses your chosen covariates only (post "drop no-SCQ" decisions)
- Builds *_pre from full panel (LOCF + 1-wave lag)
- Restricts outcome to waves 9/13/17/21
- Drops prevalent-at-entry (chronic==1 at first observed risk wave)
- Drops wave 9 from estimation (structural zero events)
********************************************************************/
/********************************************************************
FINAL ESTIMATION BLOCK — SIMPLE + CONSISTENT WITH YOUR LOGIC
********************************************************************/

/********************************************************************
CHRONIC CONDITION PAPER — SIMPLE ESTIMATION BLOCK
(EDIT globals once, then rerun from "SETUP" down whenever you want)
********************************************************************/

use  "$data/main.dta", clear

*========================
* EDIT THESE 3 LISTS ONLY
*========================

keep ///
    xwaveid wave age0 chronic_any ///
    male married indig rural cob_os cob_n_en english_proficiency sexuality ///   /* demographics */
    educ ehi_quart income hhincome hh_inc_q lf ///     /* SES / labour / occupation */
    trade cle_s prd_tr labour whtcollar bluecollar ///
    sa_health mental_health general_health overall_health spfunctioning childhood_health lth ///    /* health + healthcare */
    phi phi_2 checkup1_any checkup2_any /// 
    lsdrkf smoke2 smoke3 exercise bmi fruits vegetables eats_breakfast sleep_hours volunteer ///     /* lifestyle */
    moved_first father_cob_os mother_cob_os father_paid mother_paid father_educ mother_educ ///         /* family background */
    parents_divorced siblings parents_smoked ///                                                     /* stress */
    stressw_retired stressw_firedredundant stressw_job stressw_job_ill ///
    stressf_familyinjill stressf_deathfriend stressf_deathspousechild stressf_deathrelfam ///
    stressf_propertycrime stressf_jail ///
    stressp_physicalv stressp_injill stressp_jail stressp_financial stressp_divorced stressp_widowed ///
    psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///    /* psych / preferences */
    control social_support trust envy financial_risk ///
    life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction ///     /* satisfaction */
    partner_satisfaction safety_satisfaction parent_satisfaction stepparent_satisfaction

	
global X_cat  educ ehi_quart lsdrkf

global X_cont sa_health mental_health exercise bmi ///
               psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///
               social_support ///
               life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction safety_satisfaction

global X_bin  male married indig rural cob_os cob_n_en lgbo_ever ///
               lf trade cle_s prd_tr labour whtcollar bluecollar ///
               lth checkup1_any checkup2_any ///
               smoke2 ///
               father_cob_os mother_cob_os father_paid mother_paid ///
               siblings ///
               stressw_retired stressw_firedredundant ///
               stressf_familyinjill stressf_deathfriend  stressf_deathrelfam ///
               stressf_propertycrime stressf_jail ///
               stressp_physicalv stressp_injill  stressp_financial stressp_divorced 

global X_all  $X_cat $X_cont $X_bin



*-----------------------------*
* SETUP: risk waves only
*-----------------------------*
keep if age0 >= 15
gen year = 2000 + wave
sort xwaveid year

* LGBT+ ever (from sexuality) -> lgbo_ever
gen lgbo = .
replace lgbo = 1 if inlist(sexuality, 2, 3, 4)
replace lgbo = 0 if sexuality == 1
bys xwaveid: egen lgbo_ever = max(lgbo)
drop lgbo

* keep only the measurement waves
keep if inlist(wave, 9, 13, 17, 21)
sort xwaveid wave


* drop vars decided not need based on missingness 
	drop envy trust // personality traits is enough...
	drop sleep_hours financial_risk  // sad but not available in 2009....?
	drop control // measured 2008, 2011, 2015, etc; drop to just be consistent by setting only waves 2009, 13, 17, 21
	drop phi phi_2 english_proficiency // too many missing - not everyone asked i think
	drop childhood_health father_educ mother_educ parents_divorced parents_smoked moved_first // too many missing --> personal/family history vars
	drop stressw_job stressw_job_ill // conditional on being employed --> too many missing 
	drop partner_sat* parent_sat* stepparent_sat* // conditional on being relationshiop etc?? --> too many missing 
	drop fruits eats_breakfast vegetables volunteer // a little too much missing (7-10%) - can perhaps run robustness after.... 
	drop income hhincome hh_inc_q general_health overall_health spfunctioning smoke3 // vars that we measure in other ways so dont need these versions
	                                                                                           // (e.g. ehi_quart vs income vs hhincome)

*-----------------------------*
* 1a) DROP no-SCQ first (-8)
*    (row drops; Stata shows counts)
*-----------------------------*
foreach v of global X_all {
    drop if `v' == -8
}

*-----------------------------*
* 1b) DROP non-responding person (-10)
*    (row drops; Stata shows counts)
*-----------------------------*
foreach v of global X_all {
    drop if `v' == -10
}


*-----------------------------*
* 2) DROP other negative codes (<0)
*    (row drops; Stata shows counts)
*-----------------------------*
foreach v of global X_all {
    drop if `v' < 0
}


*-----------------------------*
* 3) Build PRE covariates (LOCF + 1-wave lag)
*-----------------------------*
sort xwaveid year
foreach v of global X_all {
    gen `v'_cf = `v'
    by xwaveid (year): replace `v'_cf = `v'_cf[_n-1] if missing(`v'_cf)
    by xwaveid (year): gen `v'_pre = `v'_cf[_n-1]
    drop `v'_cf
}


*-----------------------------*
* 4) Chronic outcome
*-----------------------------*
gen chronic_m = chronic_any
replace chronic_m = 0 if chronic_m == -1
replace chronic_m = . if chronic_m == -10
replace chronic_m = . if chronic_m == 99
drop if missing(chronic_m)



*-----------------------------*
* 5) Drop prevalent-at-entry (person-level)
*-----------------------------*
bys xwaveid (year): gen chronic_first = chronic_m[1]
unique(xwaveid) if chronic_first ==1 // 5426 people enter the dataset with a chronic condition
drop if chronic_first == 1
drop chronic_first


*-----------------------------------------------------------*
* GAP RULE YOU WANT:
* Drop PEOPLE if their FIRST onset wave does NOT have the
* immediately previous risk wave observed (exactly 4 years earlier).
*-----------------------------------------------------------*

* compute lag4_ok ONCE (DON'T recompute later in checks after dropping waves)
sort xwaveid wave
bys xwaveid (wave): gen prev_wave = wave[_n-1]
gen byte lag4_ok = (wave==9) | (wave - prev_wave == 4)
drop prev_wave

* first onset wave (if any)
bys xwaveid: egen onset_wave = min(cond(chronic_m==1, wave, .))

* drop people with onset but bad lag at onset
bys xwaveid: egen bad_onset_person = max(wave==onset_wave & onset_wave<. & lag4_ok==0)
unique(xwaveid) if bad_onset_person ==1 // 239 people
drop if bad_onset_person==1 
drop onset_wave bad_onset_person


*-----------------------------*
* 6) First onset + at-risk periods
*-----------------------------*
bys xwaveid: egen first_onset_year = min(cond(chronic_m==1, year, .))
gen ever_onset = first_onset_year < .

drop if ever_onset==1 & year > first_onset_year

*-----------------------------*
* 7) Event tertiles at first onset
*-----------------------------*
quietly centile age0 if ever_onset==1 & year==first_onset_year, centile(33.333 66.666)
scalar c1 = r(c_1)
scalar c2 = r(c_2)

gen event = 0
replace event = 1 if year==first_onset_year & age0 <= c1
replace event = 2 if year==first_onset_year & age0 >  c1 & age0 <= c2
replace event = 3 if year==first_onset_year & age0 >  c2

unique(xwaveid) if event >0 // 2383 people develop a condition and meet the restriction criteria


*-----------------------------*
* 8) Drop wave 9 from estimation (structural zero events)
*-----------------------------*
drop if wave == 9 // we keep covariates_pre in the year 2013 (i.e. 2009 covariates) so its fine

* only rows with valid 4-year lag can be used in estimation
gen byte est_sample = (lag4_ok==1)

tab event if est_sample==1
tab wave event if est_sample==1
count if est_sample==1


*------------------------------------------------------------
* FLAG BINARY PREDICTORS THAT WILL BREAK mlogit
*   - looks at var_pre==1 only
*   - flags if (N1 < 50) OR if any event category has 0 counts
*------------------------------------------------------------
di as txt "---- Potential problem binaries (var_pre==1 rare or empty event cells) ----"

foreach v of global X_bin {

    quietly count if est_sample==1 & `v'_pre==1
    local N1 = r(N)

    local empty = 0
    foreach e in 0 1 2 3 {
        quietly count if est_sample==1 & `v'_pre==1 & event==`e'
        if r(N)==0 local empty = 1
    }

    if (`N1' < 50) | (`empty'==1) {
        di as res "`v'_pre" ///
           "  N1=" %6.0f `N1' ///
           "  emptyEventCell=" %1.0f `empty'
    }
}


*------------------------------------------------------------
* FLAG BINARY PREDICTORS WITH EMPTY CELLS WITHIN WAVE
*------------------------------------------------------------
di as txt "---- Potential problem binaries (empty cells within wave) ----"

foreach v of global X_bin {

    local bad = 0

    foreach w in 13 17 21 {
        foreach e in 0 1 2 3 {
            quietly count if est_sample==1 & wave==`w' & `v'_pre==1 & event==`e'
            if r(N)==0 local bad = 1
        }
    }

    if (`bad'==1) {
        quietly count if est_sample==1 & `v'_pre==1
        di as res "`v'_pre" "  N1=" %6.0f r(N) "  (has empty wave×event cells)"
    }
}

/* NOTE: These were the problem vars. Ive already removed them from original macros above so this code unecessary
drop stressf_deathspousechild stressf_deathspousechild_pre stressp_jail stressp_jail_pre // too sparse overall; creates problem for conversion or whatever
drop stressp_widowed stressp_widowed_pre // too sparse within event ==1; young people arent widowed. 
*/

* build global *_pre lists (so mlogit line stays clean)
global X_cat_pre  ""
global X_cont_pre ""
global X_bin_pre  ""

foreach v of global X_cat {
    global X_cat_pre "$X_cat_pre `v'_pre"
}

foreach v of global X_cont {
    global X_cont_pre "$X_cont_pre `v'_pre"
}

foreach v of global X_bin {
    global X_bin_pre "$X_bin_pre `v'_pre"
}


*-----------------------------*
* 9) Estimate
*-----------------------------*


mlogit event i.wave ///
    i.($X_cat_pre $X_bin_pre) ///
    c.($X_cont_pre) ///
	if est_sample==1, ///
    baseoutcome(0) 


*-----------------------------*
* 10) Export table
*-----------------------------*
cap which esttab
if _rc ssc install estout, replace

estimates store M_full
esttab M_full using "$output\mlogit_full_clean.rtf", replace ///
    eform b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label compress nogaps





	
	
	
	
	
	
	
	
	
	
	
*-------------------------
* CHECK 1: Any events left in 2009? (should be none because you drop wave 9)
*-------------------------
tab wave event

*-------------------------
* CHECK 2: At most 1 event per person in estimation sample
*-------------------------
bys xwaveid: egen n_event = total(est_sample==1 & event>0)
assert n_event <= 1
drop n_event

*-------------------------
* CHECK 3: All estimation rows have the correct previous wave (4-year lag)
*-------------------------
bys xwaveid (wave): gen prev_wave = wave[_n-1]
count if est_sample==1 & (wave - prev_wave != 4)
di as txt "Bad-lag rows in estimation sample (should be 0): " as res r(N)

* show a few offenders if any exist
list xwaveid wave prev_wave event if est_sample==1 & (wave - prev_wave != 4) in 1/20

drop prev_wave

*-------------------------
* CHECK 4: How many rows are being excluded because of gaps?
*-------------------------
count if wave!=9 & lag4_ok==0
di as txt "Rows excluded due to missing previous risk wave: " as res r(N)

count if est_sample==1
di as txt "Rows used in mlogit estimation: " as res r(N)





















































*------------------------------------------------------------*
* 0) Keep the variables you might use (INCLUDING all waves!)
*------------------------------------------------------------*
* IMPORTANT: do NOT restrict to waves 9/13/17/21 yet; we need all waves
keep ///
    xwaveid wave age0 chronic_any ///
    male married indig rural cob_os cob_n_en english_proficiency sexuality ///   /* demographics */
    educ ehi_quart income hhincome hh_inc_q lf ///     /* SES / labour / occupation */
    trade cle_s prd_tr labour whtcollar bluecollar ///
    sa_health mental_health general_health overall_health spfunctioning childhood_health lth ///    /* health + healthcare */
    phi phi_2 checkup1_any checkup2_any /// 
    lsdrkf smoke2 smoke3 exercise bmi fruits vegetables eats_breakfast sleep_hours volunteer ///     /* lifestyle */
    moved_first father_cob_os mother_cob_os father_paid mother_paid father_educ mother_educ ///         /* family background */
    parents_divorced siblings parents_smoked ///                                                     /* stress */
    stressw_retired stressw_firedredundant stressw_job stressw_job_ill ///
    stressf_familyinjill stressf_deathfriend stressf_deathspousechild stressf_deathrelfam ///
    stressf_propertycrime stressf_jail ///
    stressp_physicalv stressp_injill stressp_jail stressp_financial stressp_divorced stressp_widowed ///
    psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///    /* psych / preferences */
    control social_support trust envy financial_risk ///
    life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction ///     /* satisfaction */
    partner_satisfaction safety_satisfaction parent_satisfaction stepparent_satisfaction

* Ensure year exists (you already have it in your output; this is just safe)
keep if age0 >= 15
gen year = 2000 + wave
sort xwaveid year

* Chronic measure (numeric 0/1/.)
gen chronic_m = chronic_any
replace chronic_m = 0 if chronic_m == -1
replace chronic_m = . if chronic_m == -10
replace chronic_m = . if chronic_m == 99

* Keep only measurement waves
**first deal with vars that need to be maxed across 
g lgbo = 1 if inlist(sexuality, 2, 3, 4)
replace lgbo = 0 if sexuality ==1
bys xwaveid: egen lgbo_ever = max(lgbo)

* Now drop
keep if inlist(wave, 9, 13, 17, 21)
drop if missing(chronic_m)

order xwaveid year chronic_m

*------------------------------------------------------------*
* 1) Drop no-SCQ people and do complete-case analysis 
** remove vars that have too many missing --> dont do complete case analysis on these 
*------------------------------------------------------------*

	* drop vars decided not need based on missingness 
	drop envy trust // personality traits is enough...
	drop sleep_hours financial_risk  // sad but not available in 2009....?
	drop control // measured 2008, 2011, 2015, etc; drop to just be consistent by setting only waves 2009, 13, 17, 21
	drop phi phi_2 english_proficiency // too many missing - not everyone asked i think
	drop chronic_any // not needed as created above
	drop childhood_health father_educ mother_educ parents_divorced parents_smoked moved_first // too many missing --> personal/family history vars
	drop stressw_job stressw_job_ill // conditional on being employed --> too many missing 
	drop partner_sat* parent_sat* stepparent_sat* // conditional on being relationshiop etc?? --> too many missing 
	drop fruits eats_breakfast vegetables volunteer // a little too much missing (7-10%) - can perhaps run robustness after.... 
	drop sexuality income hhincome hh_inc_q general_health overall_health spfunctioning smoke3 // vars that we measure in other ways so dont need these versions
	                                                                                           // (e.g. ehi_quart vs income vs hhincome)
	

	* Drop No-SCQ
foreach var of varlist ///
    male married indig rural cob_os cob_n_en lgbo_ever ///   /* demographics */
    educ ehi_quart lf ///     /* SES / labour / occupation */
    trade cle_s prd_tr labour whtcollar bluecollar ///
    sa_health mental_health  lth ///    /* health + healthcare */
    checkup1_any checkup2_any /// 
    lsdrkf smoke2 exercise bmi  ///     /* lifestyle */
    father_cob_os mother_cob_os father_paid mother_paid  ///         /* family background */
    siblings ///                                                     /* stress */
    stressw_retired stressw_firedredundant  ///
    stressf_familyinjill stressf_deathfriend stressf_deathspousechild stressf_deathrelfam ///
    stressf_propertycrime stressf_jail ///
    stressp_physicalv stressp_injill stressp_jail stressp_financial stressp_divorced stressp_widowed ///
    psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///    /* psych / preferences */
    social_support  ///
    life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction safety_satisfaction ///
	{
		drop if `var' ==-8 // no-SCQ 
	}
		

/*
* ---- >20% missing ----
di as text "Vars with >20% missing:"
foreach v of varlist chronic_any lgbo_ever ///
    male married indig rural cob_os cob_n_en english_proficiency sexuality ///
    educ ehi_quart income hhincome hh_inc_q lf ///
    trade cle_s prd_tr labour whtcollar bluecollar ///
    sa_health mental_health general_health overall_health spfunctioning childhood_health lth ///
    phi phi_2 checkup1_any checkup2_any ///
    lsdrkf smoke2 smoke3 exercise bmi fruits vegetables eats_breakfast volunteer ///
    moved_first father_cob_os mother_cob_os father_paid mother_paid father_educ mother_educ ///
    parents_divorced siblings parents_smoked ///
    stressw_retired stressw_firedredundant stressw_job stressw_job_ill ///
    stressf_familyinjill stressf_deathfriend stressf_deathspousechild stressf_deathrelfam ///
    stressf_propertycrime stressf_jail ///
    stressp_physicalv stressp_injill stressp_jail stressp_financial stressp_divorced stressp_widowed ///
    psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///
    social_support  financial_risk ///
    life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction ///
    partner_satisfaction safety_satisfaction parent_satisfaction stepparent_satisfaction {
    
    quietly count if missing(`v')
    local p = r(N)/_N
    if `p' > .20 di as res "`v'"
}

* ---- 10–20% missing ----
di as text "Vars with 10–20% missing:"
foreach v of varlist chronic_any lgbo_ever ///
    male married indig rural cob_os cob_n_en english_proficiency sexuality ///
    educ ehi_quart income hhincome hh_inc_q lf ///
    trade cle_s prd_tr labour whtcollar bluecollar ///
    sa_health mental_health general_health overall_health spfunctioning childhood_health lth ///
    phi phi_2 checkup1_any checkup2_any ///
    lsdrkf smoke2 smoke3 exercise bmi fruits vegetables eats_breakfast volunteer ///
    moved_first father_cob_os mother_cob_os father_paid mother_paid father_educ mother_educ ///
    parents_divorced siblings parents_smoked ///
    stressw_retired stressw_firedredundant stressw_job stressw_job_ill ///
    stressf_familyinjill stressf_deathfriend stressf_deathspousechild stressf_deathrelfam ///
    stressf_propertycrime stressf_jail ///
    stressp_physicalv stressp_injill stressp_jail stressp_financial stressp_divorced stressp_widowed ///
    psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///
    social_support  financial_risk ///
    life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction ///
    partner_satisfaction safety_satisfaction parent_satisfaction stepparent_satisfaction {
    
    quietly count if missing(`v')
    local p = r(N)/_N
    if `p' > .10 & `p' <= .20 di as res "`v'"
}

* ---- 5–10% missing ----
di as text "Vars with 10–20% missing:"
foreach v of varlist chronic_any lgbo_ever ///
    male married indig rural cob_os cob_n_en english_proficiency sexuality ///
    educ ehi_quart income hhincome hh_inc_q lf ///
    trade cle_s prd_tr labour whtcollar bluecollar ///
    sa_health mental_health general_health overall_health spfunctioning childhood_health lth ///
    phi phi_2 checkup1_any checkup2_any ///
    lsdrkf smoke2 smoke3 exercise bmi fruits vegetables eats_breakfast volunteer ///
    moved_first father_cob_os mother_cob_os father_paid mother_paid father_educ mother_educ ///
    parents_divorced siblings parents_smoked ///
    stressw_retired stressw_firedredundant stressw_job stressw_job_ill ///
    stressf_familyinjill stressf_deathfriend stressf_deathspousechild stressf_deathrelfam ///
    stressf_propertycrime stressf_jail ///
    stressp_physicalv stressp_injill stressp_jail stressp_financial stressp_divorced stressp_widowed ///
    psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///
    social_support  ///
    life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction ///
    partner_satisfaction safety_satisfaction parent_satisfaction stepparent_satisfaction {
    
    quietly count if missing(`v')
    local p = r(N)/_N
    if `p' > .5 & `p' <= .10 di as res "`v'"
}

*/


* ---- finalise complete case analysis ----


*
* ---- >20% values <0 (non-respond, refuse/not stated, not asked, whatever) ----
di as text "Vars with >20% missing:"
foreach v of varlist  ///
    male married indig rural cob_os cob_n_en lgbo_ever ///   /* demographics */
    educ ehi_quart lf ///     /* SES / labour / occupation */
    trade cle_s prd_tr labour whtcollar bluecollar ///
    sa_health mental_health  lth ///    /* health + healthcare */
    checkup1_any checkup2_any /// 
    lsdrkf smoke2 exercise bmi  ///     /* lifestyle */
    father_cob_os mother_cob_os father_paid mother_paid  ///         /* family background */
    siblings ///                                                     /* stress */
    stressw_retired stressw_firedredundant  ///
    stressf_familyinjill stressf_deathfriend stressf_deathspousechild stressf_deathrelfam ///
    stressf_propertycrime stressf_jail ///
    stressp_physicalv stressp_injill stressp_jail stressp_financial stressp_divorced stressp_widowed ///
    psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///    /* psych / preferences */
    social_support  ///
    life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction safety_satisfaction {     /* satisfaction */

    quietly count if `v' <0
    local p = r(N)/_N
    if `p' > .07 di as res "`v'"
}

//* NOTE ABOVE: fruits/eats breakfast vars have lots 7% and 10% missing; can run model with them later if we want. 



 foreach v of varlist  ///
   male married indig rural cob_os cob_n_en lgbo_ever ///   /* demographics */
    educ ehi_quart lf ///     /* SES / labour / occupation */
    trade cle_s prd_tr labour whtcollar bluecollar ///
    sa_health mental_health  lth ///    /* health + healthcare */
    checkup1_any checkup2_any /// 
    lsdrkf smoke2 exercise bmi  ///     /* lifestyle */
    father_cob_os mother_cob_os father_paid mother_paid  ///         /* family background */
    siblings ///                                                     /* stress */
    stressw_retired stressw_firedredundant  ///
    stressf_familyinjill stressf_deathfriend stressf_deathspousechild stressf_deathrelfam ///
    stressf_propertycrime stressf_jail ///
    stressp_physicalv stressp_injill stressp_jail stressp_financial stressp_divorced stressp_widowed ///
    psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///    /* psych / preferences */
    social_support  ///
    life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction safety_satisfaction {
    
 drop if `v' <0 // non-responding, refused/notstated, etc
}	
	

	

*------------------------------------------------------------*
* 1) DEFINE predictor groups (EDIT THESE LISTS)
*    - Put variables in EXACTLY ONE group for clean tables
*------------------------------------------------------------*

* Demographics
local G_demo_bin   male married indig rural cob_os cob_n_en
local G_demo_cont  english_proficiency   // if categorical in your data, move to _cat
local G_demo_cat   sexuality             // if many categories, consider dropping/collapsing

* Socioeconomic / labour / occupation
local G_ses_cat    educ ehi_quart hh_inc_q
local G_ses_cont   income hhincome
local G_work_bin   lf trade cle_s prd_tr labour whtcollar bluecollar

* Health + healthcare use
local G_health_cont sa_health mental_health general_health overall_health spfunctioning childhood_health
local G_health_bin  lth phi phi_2 checkup1_any checkup2_any

* Lifestyle
local G_life_cat   lsdrkf
local G_life_bin   smoke2 smoke3
local G_life_cont  exercise bmi fruits vegetables eats_breakfast sleep_hours volunteer

* Family background
local G_fam_bin    father_cob_os mother_cob_os father_paid mother_paid parents_divorced siblings parents_smoked
local G_fam_cont   moved_first
local G_fam_cat    father_educ mother_educ   // WARNING: could be high-cardinality

* Stress / adverse events
local G_stress_bin stressw_retired stressw_firedredundant stressw_job stressw_job_ill ///
                   stressf_familyinjill stressf_deathfriend stressf_deathspousechild stressf_deathrelfam ///
                   stressf_propertycrime stressf_jail ///
                   stressp_physicalv stressp_injill stressp_jail stressp_financial stressp_divorced stressp_widowed

* Psych / preferences
local G_psych_cont psych_distress pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper ///
                   control social_support trust envy financial_risk

* Satisfaction
local G_sat_cont   life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction ///
                   partner_satisfaction safety_satisfaction parent_satisfaction stepparent_satisfaction

* Master list of predictors (raw names, not _pre)
local X_all ///
    `G_demo_bin' `G_demo_cont' `G_demo_cat' ///
    `G_ses_cat' `G_ses_cont' `G_work_bin' ///
    `G_health_cont' `G_health_bin' ///
    `G_life_cat' `G_life_bin' `G_life_cont' ///
    `G_fam_bin' `G_fam_cont' `G_fam_cat' ///
    `G_stress_bin' ///
    `G_psych_cont' ///
    `G_sat_cont'

*------------------------------------------------------------*
* 2) Build PRE-period covariates via LOCF + 1-wave lag
*    (this is the only loop you really need)
*------------------------------------------------------------*
foreach v of local X_all {
    * treat negative special codes as missing before carry-forward
    capture confirm numeric variable `v'
    if !_rc replace `v' = . if `v' < 0

    gen `v'_cf = `v'
    by xwaveid (year): replace `v'_cf = `v'_cf[_n-1] if missing(`v'_cf)
    by xwaveid (year): gen `v'_pre = `v'_cf[_n-1]
    drop `v'_cf
}

*------------------------------------------------------------*
* 3) Create chronic_m ONLY in measurement waves (risk waves)
*------------------------------------------------------------*
gen chronic_meas = inlist(wave, 9, 13, 17, 21)

gen chronic_m = .
replace chronic_m = chronic_any if chronic_meas==1
replace chronic_m = 0 if chronic_m == -1
replace chronic_m = . if chronic_m == -10
replace chronic_m = . if chronic_m == 99

*------------------------------------------------------------*
* 4) Drop prevalent-at-entry based on first MEASUREMENT wave observed
*------------------------------------------------------------*
bys xwaveid: egen first_meas_year = min(cond(chronic_meas==1, year, .))
bys xwaveid: egen prevalent = max(year==first_meas_year & chronic_m==1)
drop if prevalent==1
drop prevalent

*------------------------------------------------------------*
* 5) First onset year (from measurement waves only), and keep risk periods
*------------------------------------------------------------*
bys xwaveid: egen first_onset_year = min(cond(chronic_m==1, year, .))
gen ever_onset = first_onset_year < .

* Keep only measurement waves for the outcome process
keep if chronic_meas==1
drop if missing(chronic_m)

* Stop after first onset
drop if ever_onset==1 & year > first_onset_year

*------------------------------------------------------------*
* 6) Event categories (YOUR current tertile version)
*    -> programmatic cutpoints so you don't hard-code 47/59
*------------------------------------------------------------*
centile age0 if year==first_onset_year, centile(33.333 66.666)
local c1 = r(c_1)
local c2 = r(c_2)

gen event = 0
replace event = 1 if year==first_onset_year & age0 <= `c1'
replace event = 2 if year==first_onset_year & age0 >  `c1' & age0 <= `c2'
replace event = 3 if year==first_onset_year & age0 >  `c2'

*------------------------------------------------------------*
* 7) Drop baseline wave 9 from estimation (structural zero events)
*------------------------------------------------------------*
drop if wave==9

*------------------------------------------------------------*
* 8) Build the mlogit RHS spec (EDIT HERE if you want)
*    Use i. for categorical/binary and c. for continuous.
*------------------------------------------------------------*

local RHS ///
    i.wave ///
    /* Demographics */
    i.male_pre i.married_pre i.indig_pre i.rural_pre i.cob_os_pre i.cob_n_en_pre ///
    c.english_proficiency_pre i.sexuality_pre ///
    /* SES / labour / occupation */
    i.educ_pre i.ehi_quart_pre i.hh_inc_q_pre c.income_pre c.hhincome_pre ///
    i.lf_pre i.trade_pre i.cle_s_pre i.prd_tr_pre i.labour_pre i.whtcollar_pre i.bluecollar_pre ///
    /* Health + healthcare */
    c.sa_health_pre c.mental_health_pre c.general_health_pre c.overall_health_pre c.spfunctioning_pre c.childhood_health_pre ///
    i.lth_pre i.phi_pre i.phi_2_pre i.checkup1_any_pre i.checkup2_any_pre ///
    /* Lifestyle */
    i.lsdrkf_pre i.smoke2_pre i.smoke3_pre ///
    c.exercise_pre c.bmi_pre c.fruits_pre c.vegetables_pre c.eats_breakfast_pre c.sleep_hours_pre c.volunteer_pre ///
    /* Family background */
    c.moved_first_pre i.father_cob_os_pre i.mother_cob_os_pre i.father_paid_pre i.mother_paid_pre ///
    i.parents_divorced_pre i.siblings_pre i.parents_smoked_pre ///
    i.father_educ_pre i.mother_educ_pre ///
    /* Stress */
    i.stressw_retired_pre i.stressw_firedredundant_pre i.stressw_job_pre i.stressw_job_ill_pre ///
    i.stressf_familyinjill_pre i.stressf_deathfriend_pre i.stressf_deathspousechild_pre i.stressf_deathrelfam_pre ///
    i.stressf_propertycrime_pre i.stressf_jail_pre ///
    i.stressp_physicalv_pre i.stressp_injill_pre i.stressp_jail_pre i.stressp_financial_pre i.stressp_divorced_pre i.stressp_widowed_pre ///
    /* Psych / preferences */
    c.psych_distress_pre c.pers_agreeableness_pre c.pers_conscientiousness_pre c.pers_emotionalstability_pre c.pers_extroversion_pre c.pers_opentoexper_pre ///
    c.control_pre c.social_support_pre c.trust_pre c.envy_pre c.financial_risk_pre ///
    /* Satisfaction */
    c.life_sat_pre c.health_satisfaction_pre c.neighbourhood_satisfaction_pre c.home_satisfaction_pre c.financial_satisfaction_pre ///
    c.partner_satisfaction_pre c.safety_satisfaction_pre c.parent_satisfaction_pre c.stepparent_satisfaction_pre

*------------------------------------------------------------*
* 9) Estimate
*------------------------------------------------------------*
mlogit event `RHS', baseoutcome(0) vce(cluster xwaveid)

*------------------------------------------------------------*
* 10) Export regression table (RTF)
*     (Uses esttab; installs if needed)
*------------------------------------------------------------*
cap which esttab
if _rc ssc install estout, replace

estimates store M_full

* Relative risk ratios are often nicer to read for mlogit
esttab M_full using "$output\mlogit_full.rtf", replace ///
    eform b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label compress nogaps ///
    title("Discrete-time competing risks model (RRR)") ///
    addnotes("Covariates are lagged (LOCF + 1-wave lag). SEs clustered by xwaveid. Baseline wave 9 excluded from estimation.")


	
	
	
	
	
	
	
	
	
	
	

*----------------------------------*
* 1) Prep
*----------------------------------*
keep xwaveid wave age0 male educ ehi_quart rural cob_os chronic_any
keep if age0 >= 15
gen year = 2000 + wave
sort xwaveid year

* Chronic measure (numeric 0/1/.)
gen chronic_m = chronic_any
replace chronic_m = 0 if chronic_m == -1
replace chronic_m = . if chronic_m == -10
replace chronic_m = . if chronic_m == 99

* Keep only measurement waves
keep if inlist(wave, 9, 13, 17, 21)
drop if missing(chronic_m)

*-----------------------------*
* 2) Build pre-period covariates from ANNUAL panel
*    (add lots more vars to xvars later)
*-----------------------------*
local xvars male ehi_quart educ rural cob_os

foreach v of local xvars {
    gen `v'_cf = `v'
    replace `v'_cf = . if `v'_cf < 0
    by xwaveid (year): replace `v'_cf = `v'_cf[_n-1] if missing(`v'_cf)
    by xwaveid (year): gen `v'_pre = `v'_cf[_n-1]
    drop `v'_cf
}

*----------------------------------*
* 3) Drop prevalent-at-entry
*    (chronic==1 at first observed measurement wave)
*----------------------------------*
bys xwaveid (year): gen first_meas = (_n==1)
bys xwaveid: egen prevalent = max(first_meas==1 & chronic_m==1)
drop if prevalent==1
drop first_meas prevalent

*----------------------------------*
* 4) First onset wave + at-risk periods
*----------------------------------*
bys xwaveid: egen first_onset_year = min(cond(chronic_m==1, year, .))
gen ever_onset = first_onset_year < .

drop if ever_onset==1 & year > first_onset_year

*----------------------------------*
* 5) Event category at first onset
*----------------------------------*

xtile age_tert = age0 if year==first_onset_year, n(3) // to obtain tertiles of age at onset 

gen event = 0
replace event = 1 if year==first_onset_year & age0 <= 47 // tertile 1 max = 47
replace event = 2 if year==first_onset_year & inrange(age0,48,59)
replace event = 3 if year==first_onset_year & inrange(age0,60,100)

*----------------------------------*
* 6) DROP 2009 FROM ESTIMATION SAMPLE
*    (baseline-only wave => structural zero events)
*----------------------------------*
drop if wave==9

*----------------------------------*
* 7) mlogit with wave FE
*----------------------------------*
mlogit event i.wave ///
    i.male_pre i.ehi_quart_pre i.educ_pre i.rural_pre i.cob_os_pre, ///
    baseoutcome(0) vce(cluster xwaveid)


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

*-----------------------------*
* 1) Prep
*-----------------------------*
keep if age0 >= 15
gen year = 2000 + wave
sort xwaveid year

* Treat special missing codes in chronic_any
gen chronic_m = chronic_any
replace chronic_m = 0 if chronic_m == -1
replace chronic_m = . if chronic_m == -10
replace chronic_m = . if chronic_m == 99    // your "not in 9/13/17/21" marker (or other missing)

*-----------------------------*
* 2) Build pre-period covariates from ANNUAL panel
*    (add lots more vars to xvars later)
*-----------------------------*
local xvars male ehi_quart educ rural cob_os

foreach v of local xvars {
    gen `v'_cf = `v'
    replace `v'_cf = . if `v'_cf < 0
    by xwaveid (year): replace `v'_cf = `v'_cf[_n-1] if missing(`v'_cf)
    by xwaveid (year): gen `v'_pre = `v'_cf[_n-1]
    drop `v'_cf
}

*-----------------------------*
* 3) Keep only the 4 risk waves and require chronic observed
*-----------------------------*
keep if inlist(wave, 9, 13, 17, 21)
drop if missing(chronic_m)

*-----------------------------*
* 4) Drop "prevalent at entry" cases
*    (chronic==1 at their first observed risk wave => onset happened before we can see it)
*-----------------------------*
bys xwaveid (year): gen first_risk = (_n==1)
g dum = 1 if first_risk==1 & chronic_m==1
bys xwaveid: egen max_dum = max(dum)
drop if max_dum ==1
drop first_risk dum max_dum
/*drop if first_risk==1 & chronic_m==1
drop first_risk
*/

*-----------------------------*
* 5) First onset wave + keep only at-risk periods
*-----------------------------*
bys xwaveid: egen first_onset_year = min(cond(chronic_m==1, year, .))
gen ever_onset = (first_onset_year < .)

* after first onset, not at risk anymore
drop if ever_onset==1 & year > first_onset_year

*-----------------------------*
* 6) Outcome category (event type) at the FIRST onset wave
*-----------------------------*
gen event = 0
replace event = 1 if year==first_onset_year & age0 < 40
replace event = 2 if year==first_onset_year & inrange(age0,40,54)
replace event = 3 if year==first_onset_year & inrange(age0,55,69)
replace event = 4 if year==first_onset_year & age0 >= 70


*-----------------------------*
* 7) Multinomial logit with wave FE
*-----------------------------*

drop if year ==2009

mlogit event ///
    i.wave ///
    i.male_pre i.ehi_quart_pre i.educ_pre i.rural_pre i.cob_os_pre, ///
    baseoutcome(0) vce(cluster xwaveid)	
	
	
	
	
	
	
tab event, m
tab wave event, m
tab wave event if event>0, m

foreach v in male_pre ehi_quart_pre educ_pre rural_pre cob_os_pre {
    di "---- `v' ----"
    tab event `v', m
}	
	
	
	
	
	
	
	
	
	


*------------------------------------------------------------
* 0) Keep the 4 chronic-condition waves you need
*------------------------------------------------------------

keep if age0 >= 15

gen year = 2000 + wave
drop wave
sort xwaveid year
order xwaveid year

* Drop people who only have 1 wave 
bys xwaveid: g N = _N
drop if N ==1
drop N
*/

* Keep relevant vars 
keep ///
xwaveid year age0 male educ ehi_quart rural cob_os hhwtsc chronic*



*------------------------------------------------------------
* 1) DEFINE CHRONIC AT THE SAME WAVE/YEAR
*------------------------------------------------------------
order chronic_any* 

replace chronic_any = 0 if chronic_any == -1 // not asked question because no chronic condition 
replace chronic_any = . if chronic_any ==-10 // non-responding or no-SCQ?
replace chronic_any = 99 if chronic_any ==. // missing (not in wave 9, 13, 17, 21)

order chronic_any 
drop chronic_resp* chronic_cvd chronic_m* chronic_c* chronic_di* // dont need these anymore 


/********************************************************************
Competing-risks discrete-time setup estimated via multinomial logit

Risk periods: waves 9,13,17,21 (years 2009,2013,2017,2021)
Outcome per risk period:
  0 = no first onset this period
  1 = first onset, age<40
  2 = first onset, age 40-54
  3 = first onset, age 55-69
  4 = first onset, age 70+

Covariates: last observed value prior to each risk period (usually year-1)
Wave indicators: i.wave (baseline hazard)
SEs: clustered by xwaveid
********************************************************************/

*------------------------------------------------------------*
* 0) Ensure wave exists
*------------------------------------------------------------*
capture confirm variable wave
if _rc {
    gen wave = year - 2000
}

*------------------------------------------------------------*
* 1) Make a clean numeric chronic measure for the 4 waves
*------------------------------------------------------------*
gen chronic_meas = inlist(wave, 9, 13, 17, 21)

capture confirm numeric variable chronic_any
if _rc {
    * if chronic_any is string like "Yes"/"No"/"99"
    gen chronic_m = .
    replace chronic_m = 1 if lower(chronic_any) == "yes"
    replace chronic_m = 0 if lower(chronic_any) == "no"
    replace chronic_m = . if chronic_any == "99" | chronic_any == ""
}
else {
    gen chronic_m = chronic_any
    replace chronic_m = 0 if chronic_m == -1
    replace chronic_m = . if chronic_m == -10
    replace chronic_m = . if chronic_m == 99
}

*------------------------------------------------------------*
* 2) Create "pre-period" covariates = last observed prior value
*    Add more variables to xvars as needed.
*------------------------------------------------------------*
sort xwaveid year

local xvars male ehi_quart educ rural cob_os

* Clean negative special codes in covariates (if present)
foreach v of local xvars {
    capture confirm numeric variable `v'
    if !_rc {
        replace `v' = . if `v' < 0
    }
}

* Carry-forward within person (fills gaps), then take lag (previous observed row)
foreach v of local xvars {
    gen `v'_cf = `v'
    by xwaveid (year): replace `v'_cf = `v'_cf[_n-1] if missing(`v'_cf)
    by xwaveid (year): gen `v'_pre = `v'_cf[_n-1]
}


*------------------------------------------------------------*
* 3) Keep only the risk periods (measurement waves)
*------------------------------------------------------------*
keep if chronic_meas==1
drop if missing(chronic_m)   // must observe chronic status in that wave

*------------------------------------------------------------*
* 4) Identify first onset wave/year
*------------------------------------------------------------*
bys xwaveid: egen first_onset_year = min(cond(chronic_m==1, year, .))

gen ever_onset = (first_onset_year < .)

* Drop periods after first onset (no longer at risk)
drop if ever_onset==1 & year > first_onset_year

*------------------------------------------------------------*
* 5) Build multinomial outcome for each period
*------------------------------------------------------------*
gen event = 0

* Event occurs only in the first onset year
replace event = 1 if year==first_onset_year & age0 < 40
replace event = 2 if year==first_onset_year & inrange(age0,40,54)
replace event = 3 if year==first_onset_year & inrange(age0,55,69)
replace event = 4 if year==first_onset_year & age0 >= 70

* Sanity check: at most one event per person
bys xwaveid: egen n_events = total(event>0)
assert n_events <= 1
drop n_events

*------------------------------------------------------------*
* 6) Run multinomial logit with wave fixed effects
*------------------------------------------------------------*
mlogit event ///
    i.wave ///
    i.male_pre i.ehi_quart_pre i.educ_pre i.rural_pre i.cob_os_pre, ///
    baseoutcome(0) vce(cluster xwaveid)



































































	

	/********************************
	     chronic condition paper 
	********************************/
	
use "$data\waves1_23.dta", clear    

*------------------------------------------------------------
* 0) Keep the 4 chronic-condition waves you need
*------------------------------------------------------------

keep if age0 >= 15
keep if inlist(wave, 9, 13, 17, 21)

gen year = 2000 + wave
drop wave
sort xwaveid year
order xwaveid year

* Drop people who only have 1 wave; cant identify onset. 
bys xwaveid: g N = _N
drop if N ==1
drop N

* Keep relevant vars 
keep ///
xwaveid year age0 male educ ehi_quart rural cob_os hhwtsc chronic*

* interval FE based on START year of interval
gen interval = .
replace interval = 1 if year == 2009
replace interval = 2 if year == 2013
replace interval = 3 if year == 2017
label define interval 1 "2009-13" 2 "2013-17" 3 "2017-21" // note: year 2021 has no interval in dataset as used as endpoint for 2017-2021. 
label values interval interval
order xwaveid year interval

*------------------------------------------------------------
* 1) DEFINE CHRONIC AT THE SAME WAVE/YEAR
*------------------------------------------------------------
order chronic_any* 

foreach s in i m q u {
    replace chronic_any_`s' = 0 if chronic_any_`s' == -1 // not asked question because no chronic condition 
    replace chronic_any_`s' = . if chronic_any_`s' < -1 // non-responding or no-SCQ?
}

gen chronic = .
replace chronic = chronic_any_i if year==2009
replace chronic = chronic_any_m if year==2013
replace chronic = chronic_any_q if year==2017
replace chronic = chronic_any_u if year==2021

order chronic 
drop chronic_* // dont need these anymore 

*------------------------------------------------------------
* 2) FIX "CHRONIC SWITCHING" BEFORE BUILDING INTERVALS (KEY!)
*------------------------------------------------------------

sort xwaveid year

* Make a variable showing onset constant once onset received
by xwaveid (year): gen chronic_mon = chronic
by xwaveid (year): replace chronic_mon = 1 if chronic_mon[_n-1]==1 & chronic_mon==0

* Next-wave status from MONOTONE chronic
by xwaveid (year): gen year_next         = year[_n+1]
by xwaveid (year): gen chronic_mon_next  = chronic_mon[_n+1]

* Keep only valid 4-year intervals (start years)
keep if inlist(year,2009,2013,2017) & year_next==year+4 // year_next part drops gaps people (2009 --> 2017); not 1 wave people

* Start/end status
gen chronic0 = chronic_mon
gen chronic1 = chronic_mon_next

* Event for this interval
gen event = (chronic0==0 & chronic1==1)

* Must be disease-free at start to be at risk; i.e. drop intervals the person already has the condition at start 
keep if chronic0==0 // drops 13,685 rows

*------------------------------------------------------------
* 3) Drop people who in their onset year have an age >55 and started < 55
*------------------------------------------------------------

gen age_next = age0 + 4
drop if age_next >55 & age0 <55 & event ==1 // 284 rows 


*------------------------------------------------------------
* 4) Final Dataset Construction
*------------------------------------------------------------

keep ///
xwaveid year interval event  ///
age0 male educ ehi_quart rural cob_os ///
hhwtsc 

* Have to do this step second because dont want to drop people that have onset in 2013 based off 2013 covariates
drop if missing(age0, male, educ, ehi_quart, rural, cob_os, hhwtsc) // 18 rows? 

* after drop if missing(...)
sort xwaveid year
by xwaveid: gen byte gap = (_n>1 & year - year[_n-1] != 4)
by xwaveid: egen byte anygap = max(gap)
drop if anygap==1
drop gap anygap // 50 ROWS

sort xwaveid year
order xwaveid year interval event

			
* Age band FE (example)
gen ageband = .
replace ageband = 1 if age0 < 40
replace ageband = 2 if age0 >=40 & age0<55
replace ageband = 3 if age0 >=55 & age0<70
replace ageband = 4 if age0 >=70 
label define ageband 1 "<40" 2 "40-54" 3 "55-69" 4 "70+"
label values ageband ageband


*------------------------------------------------------------
* 4) CLOGLOG MODEL FOR HAZARD RATIOS
*------------------------------------------------------------

** CLOGLOG MODEL
cloglog event i.ageband i.interval ///
    i.male i.educ i.ehi_quart i.rural i.cob_os ///
    , vce(cluster xwaveid) eform

estimates store M1

* Appendix HR table (pick ONE option you have installed)

* Option A: esttab (ssc install estout)
* esttab M1 using "appendix_hr.rtf", eform se label replace ///
*     star(* 0.10 ** 0.05 *** 0.01) b(3) se(3)

* Option B: outreg2 (ssc install outreg2)
* outreg2 [M1] using "appendix_hr.doc", eform dec(3) replace





**STUFF
g age_band_onset = string(age0, "%9.0f") + " - " + string(age_next, "%9.0f")








*------------------------------------------------------------
* AFTER cloglog: predicted hazards -> p_first -> F(55)
*------------------------------------------------------------

* 1) Predicted interval hazard (4-year) from cloglog xb
predict double eta, xb
gen double hhat = 1 - exp(-exp(eta))

* 2) Survival at start of each interval and first-onset probability
sort xwaveid year
by xwaveid: gen double S_start = 1
by xwaveid: replace S_start = S_start[_n-1] * (1 - hhat[_n-1]) if _n>1
gen double p_first = S_start * hhat

* 3) Allocate p_first to "by age 55" using fraction of interval below 55
local c = 55
gen double w55 = .
replace w55 = 1 if age0 + 4 <= `c'
replace w55 = 0 if age0 >= `c'
replace w55 = (`c' - age0)/4 if age0 < `c' & age0 + 4 > `c'
replace w55 = min(max(w55,0),1)

gen double p_first_by55 = p_first * w55

order xwaveid year interval event eta hhat S_start p_first

* 4) Person-level cumulative incidence by 55: F_i(55)
by xwaveid: egen double F55 = total(p_first_by55)

* 5) Keep one row per person
by xwaveid: keep if _n==_N

label var F55 "Predicted cumulative incidence of first onset by age 55"



*** TABLE
* Weighted mean F55 by sex (Method A descriptive disparity)
mean F55, over(male)
mean F55, over(cob_os)

* If you want the gap as a single number (male - female)
reg F55 i.male [pw=hhwtsc], vce(robust)
lincom 1.male
























*------------------------------------------------------------
* 5) CALCULATING HAZARDS (h_it); DOUBLE EXPONENTIATING
*------------------------------------------------------------

* Predicted linear index and interval hazard h_it
predict double eta, xb // this is the linear prediction of the cloglog model 
gen double hhat = 1 - exp(-exp(eta))   // this is h_it over the 4-year interval (double exponentiating)

* Define age end of interval (4 years by construction)
gen age_next = age0 + 4

gen byte under55   = (age_next <= 55)
gen byte over55    = (age0 >= 55)
gen byte strad55   = (age0 < 55 & age_next > 55) 

* Survival at start of each interval (within-person)
sort xwaveid year
by xwaveid: gen double S_start = 1
by xwaveid: replace S_start = S_start[_n-1] * (1 - hhat[_n-1]) if _n>1

* Probability first onset happens in THIS interval
gen double p_first = S_start * hhat

order xwaveid year interval event eta hhat S_start p_first

* Allocate probability mass into early / late / ambiguous bins
gen double p_first_early = p_first if under55
gen double p_first_late  = p_first if over55
gen double p_first_amb   = p_first if strad55

by xwaveid: egen double p_early = total(p_first_early)
by xwaveid: egen double p_late  = total(p_first_late)
by xwaveid: egen double p_amb   = total(p_first_amb)

* Keep one row per person (use last interval row)
by xwaveid: keep if _n==_N

* Conditional "early vs late" share, excluding ambiguous probability mass
gen double p_class = p_early + p_late
gen double p_early_cond = p_early / p_class   // Pr(early | classifiable)





























cloglog event i.ageband i.interval  ///
    male i.educ i.ehi_quart i.rural i.cob_os ///
    , vce(cluster xwaveid) eform
	
estimates store m1
		
**Define dt and sanity-check it's always 4
gen dt = year_next - year

**Predict cloglog index and convert to interval probability + annual hazard rate
predict eta, xb

* Predicted probability of onset over the FULL interval (4 years)
gen p_full = 1 - exp(-exp(eta))

* Implied annual hazard rate (λ per year)
gen lambda = exp(eta) / dt

gen p_check = 1 - exp(-lambda*dt)
summ p_full p_check




*------------------------------------------------------------
* 1) Build psychosocial variables at interval START waves
*------------------------------------------------------------

/* Envy 
gen envy = .
replace envy = envy_i if interval ==1 
replace envy = envy_m if interval ==2
replace envy = envy_q if interval ==3

* Trust
gen trust = .
replace trust = trust_h if interval==1
replace trust = trust_k if interval==2
replace trust = trust_n if interval==3
*/

/* Social support index components (reverse coding)
foreach v in i m q {
    recode social_loneliness_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_loneliness_`v'_r)
    recode social_confide_`v'    (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_confide_`v'_r)
    recode social_leanon_`v'     (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_leanon_`v'_r)
    recode social_helpneed_`v'   (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_helpneed_`v'_r)
    recode social_time_`v'       (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_time_`v'_r)
    recode social_visit_`v'      (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_visit_`v'_r)
}

foreach v in i m q {
    gen social_support_`v' = .
    replace social_support_`v' = social_cheerup_`v' + social_lotsfriends_`v' + social_helpneed2_`v' + social_talk_`v' ///
        + social_loneliness_`v'_r + social_confide_`v'_r + social_leanon_`v'_r ///
        + social_helpneed_`v'_r + social_visit_`v'_r + social_time_`v'_r ///
        if social_cheerup_`v' > 0 & social_lotsfriends_`v' > 0 & social_helpneed2_`v' > 0 & social_talk_`v' > 0 ///
        & social_loneliness_`v'_r > 0 & social_confide_`v'_r > 0 & social_leanon_`v'_r > 0 & social_helpneed_`v'_r > 0 ///
        & social_visit_`v'_r > 0 & social_time_`v'_r > 0

    replace social_support_`v' = social_support_`v'/10
}

gen social_support = .
replace social_support = social_support_i if interval==1
replace social_support = social_support_m if interval==2
replace social_support = social_support_q if interval==3

* Psychological distress
gen psych_distress = .
replace psych_distress = psych_distress_i if interval==1
replace psych_distress = psych_distress_m if interval==2
replace psych_distress = psych_distress_q if interval==3

* Financial risk preferences
gen risk_pref = .
replace risk_pref = risk_financial_h if interval==1
replace risk_pref = risk_financial_n if interval==2
replace risk_pref = risk_financial_q if interval==3

* Personality traits
gen pers_agreeableness = .
replace pers_agreeableness = pers_agreeableness_i if interval==1
replace pers_agreeableness = pers_agreeableness_m if interval==2
replace pers_agreeableness = pers_agreeableness_q if interval==3

gen pers_conscientiousness = .
replace pers_conscientiousness = pers_conscientiousness_i if interval==1
replace pers_conscientiousness = pers_conscientiousness_m if interval==2
replace pers_conscientiousness = pers_conscientiousness_q if interval==3

gen pers_emotionalstability = .
replace pers_emotionalstability = pers_emotionalstability_i if interval==1
replace pers_emotionalstability = pers_emotionalstability_m if interval==2
replace pers_emotionalstability = pers_emotionalstability_q if interval==3

gen pers_opentoexper = .
replace pers_opentoexper = pers_opentoexper_i if interval==1
replace pers_opentoexper = pers_opentoexper_m if interval==2
replace pers_opentoexper = pers_opentoexper_q if interval==3

gen pers_extroversion = .
replace pers_extroversion = pers_extroversion_i if interval==1
replace pers_extroversion = pers_extroversion_m if interval==2
replace pers_extroversion = pers_extroversion_q if interval==3

* Locus of control
foreach v in g k o {
    recode control_little_`v'       (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_little_`v'_r)
    recode control_problems_`v'     (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_problems_`v'_r)
    recode control_changethings_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_changethings_`v'_r)
    recode control_helpless_`v'     (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_helpless_`v'_r)
    recode control_pushed_`v'       (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_pushed_`v'_r)
}

foreach v in g k o {
    gen control_`v' = .
    replace control_`v' = control_future_`v' + control_doanything_`v' ///
        + control_little_`v'_r + control_problems_`v'_r + control_changethings_`v'_r ///
        + control_helpless_`v'_r + control_pushed_`v'_r ///
        if control_future_`v' > 0 & control_doanything_`v' > 0 & control_little_`v'_r > 0 & control_problems_`v'_r > 0 ///
        & control_changethings_`v'_r > 0 & control_helpless_`v'_r > 0 & control_pushed_`v'_r > 0

    replace control_`v' = control_`v'/7
}

gen locus_control = .
replace locus_control = control_g if interval==1
replace locus_control = control_k if interval==2
replace locus_control = control_o if interval==3

*/


/*------------------------------------------------------------
* 3) Clean missing codes on predictors (no SCQ / nonresponse)
*------------------------------------------------------------
foreach v of varlist social_support psych_distress trust risk_pref ///
                 pers_agreeableness pers_conscientiousness pers_emotionalstability pers_opentoexper pers_extroversion ///
                 locus_control {
    replace `v' = . if `v' < 0
}

*/

*------------------------------------------------------------
* 4) FIX "CHRONIC SWITCHING" BEFORE BUILDING INTERVALS (KEY!)
*------------------------------------------------------------

sort xwaveid year

* Make a variable showing onset constant once onset received
by xwaveid (year): gen chronic_mon = chronic
by xwaveid (year): replace chronic_mon = max(chronic_mon, chronic_mon[_n-1]) if _n>1

* Next-wave status from MONOTONE chronic
by xwaveid (year): gen year_next         = year[_n+1]
by xwaveid (year): gen chronic_mon_next  = chronic_mon[_n+1]

* Keep only valid 4-year intervals (start years)
keep if inlist(year,2009,2013,2017) & year_next==year+4 // year_next part drops (1) one wave people and (2) gaps people (2009 --> 2017)

* Start/end status
gen chronic0 = chronic_mon
gen chronic1 = chronic_mon_next

* Event for this interval
gen event = (chronic0==0 & chronic1==1)

* Must be disease-free at start to be at risk
keep if chronic0==0 // drops 18,548 people 


*------------------------------------------------------------
* 5) Keep analysis vars (interval-start covariates + weight)
*------------------------------------------------------------

* Have to do this step second because dont want to drop people that have onset in 2013 based off 2013 covariates
keep ///
xwaveid year interval year_next event  ///
age0 male educ ehi_quart rural cob_os ///
hhwtsc 

drop if missing(age0, male, educ, ehi_quart, rural, cob_os, hhwtsc)

sort xwaveid year
order xwaveid year year_next interval event

* Sanity checks
tab interval
tab year year_next
by xwaveid: egen e = total(event)
tab e

				
* Age band FE (example)
gen ageband = .
replace ageband = 1 if age0 < 40
replace ageband = 2 if age0 >=40 & age0<55
replace ageband = 3 if age0 >=55 & age0<70
replace ageband = 4 if age0 >=70 
label define ageband 1 "<40" 2 "40-54" 3 "55-69" 4 "70+"
label values ageband ageband


** CLOGLOG MODEL
cloglog event i.ageband i.interval  ///
    male i.educ i.ehi_quart i.rural i.cob_os ///
    , vce(cluster xwaveid) eform
	
estimates store m1
		
**Define dt and sanity-check it's always 4
gen dt = year_next - year

**Predict cloglog index and convert to interval probability + annual hazard rate
predict eta, xb

* Predicted probability of onset over the FULL interval (4 years)
gen p_full = 1 - exp(-exp(eta))

* Implied annual hazard rate (λ per year)
gen lambda = exp(eta) / dt

gen p_check = 1 - exp(-lambda*dt)
summ p_full p_check


**Main contribution: Pr(onset before age 55), i.e. early onset risk F55

* Amount of time in the interval that occurs before age 55
gen dt_pre55 = max(0, min(dt, 55 - age0))

* Hazard contribution before 55
gen haz_pre55 = lambda * dt_pre55

* Accumulate hazard up to 55 within each person
sort xwaveid year
by xwaveid: gen H55 = sum(haz_pre55)

* Person-level cumulative hazard up to 55 (last value)
by xwaveid: egen H55_last = max(H55)

* Collapse to one row per person for person-level F55
by xwaveid: keep if _n==_N

* Model-based cumulative incidence (prob onset before 55)
gen F55 = 1 - exp(-H55_last)

* Example summaries
summ F55
mean F55, over(male)


** CUM INCIDENCE CURVE BY AGE (stepwise)
preserve

* Recreate (if needed) the pieces on the interval-level dataset
gen dt = year_next - year
predict eta, xb
gen lambda = exp(eta)/dt
gen haz_full = lambda*dt

sort xwaveid year
by xwaveid: gen H = sum(haz_full)
gen F_end = 1 - exp(-H)          // cumulative incidence by end of each interval
gen age_end = age0 + dt

* Average cumulative incidence by age band and sex (example)
collapse (mean) F_end, by(age_end male)

list, sepby(age_end)

restore

	
	
	
	
	
	
	
	
*====================================
* TABLE 1: baseline/entry descriptives
*====================================

* ever onset during follow-up (in your interval dataset)
bys xwaveid: egen ever_onset = max(event)

* define entry row = first observed interval for each person
bys xwaveid (year): gen entry = (_n==1)

preserve
keep if entry==1

label define ever 0 "No onset during follow-up" 1 "Onset during follow-up"
label values ever_onset ever

* Option A (recommended if your Stata supports it): dtable
dtable ///
    age0 i.male i.educ i.ehi_quart i.rural i.cob_os ///
    trust envy ///
    [pweight=hhwtsc], ///
    by(ever_onset) ///
    continuous(age0 trust envy, stat(mean sd)) ///
    factor(male educ ehi_quart rural cob_os, stat(fvpercent)) 

restore
	
	
*========================
* MODELS: single-psychosocial + full model
*========================

* Put all psychosocial vars here
local psycho "trust envy"

* Put baseline controls here (keep ageband + interval FEs in every model)
local controls "i.ageband i.interval male i.educ i.ehi_quart i.rural i.cob_os"

* Install if needed (for nice tables)
* ssc install estout, replace

eststo clear

* Single-psychosocial models
foreach v of local psycho {
    cloglog event `controls' `v' [pweight=hhwtsc], vce(cluster xwaveid)
    eststo m_`v'
}

* Full model
cloglog event `controls' `psycho' [pweight=hhwtsc], vce(cluster xwaveid)
eststo m_full

* Export as hazard ratios (exp(coef)) with CI
esttab m_trust m_envy m_full using "$output/regs.csv", ///
    eform b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0g) labels("Observations")) ///
    label nogaps compress	

* Predicted 4-year onset probability by age band (averaged over sample covariates)
margins ageband, predict(pr)

* If you want by ageband x interval (often useful)
margins ageband#interval, predict(pr)
		
*========================
* Predicted cumulative incidence through the observed intervals
*========================

* 1) Predicted hazard for each interval-row
predict phat, pr   // phat = predicted P(event=1) in that interval

* 2) Chain survival within person over intervals (your dataset already stops at onset)
sort xwaveid year
by xwaveid (year): gen S = .
by xwaveid (year): replace S = 1 - phat if _n==1
by xwaveid (year): replace S = S[_n-1]*(1 - phat) if _n>1

gen F = 1 - S   // cumulative incidence through end of each interval

* 3) Label the end-of-interval year (where the cumulative incidence applies)
gen endyear = year_next   // 2013, 2017, 2021

* 4) Weighted mean cumulative incidence at each endpoint
mean F if endyear==2013 [pweight=hhwtsc]
mean F if endyear==2017 [pweight=hhwtsc]
mean F if endyear==2021 [pweight=hhwtsc]

* 5) If you want cumulative incidence curves stratified by ageband-at-start
mean F if endyear==2013, over(ageband) [pweight=hhwtsc]
mean F if endyear==2017, over(ageband) [pweight=hhwtsc]
mean F if endyear==2021, over(ageband) [pweight=hhwtsc]
	
	
	
	
	
	
/*****************************************************************
Table 3: Predicted cumulative incidence by age thresholds
Scenarios: low vs high trust; low vs high envy; plus joint extremes
Assumes person–interval data (start years 2009/2013/2017):
  xwaveid year interval age0 ageband event trust envy weights hhwtsc
*****************************************************************/


*-----------------------------
* 0) Fit main model
*-----------------------------
cloglog event i.ageband i.interval ///
    c.trust c.envy ///
    male i.educ i.ehi_quart i.rural i.cob_os ///
    [pweight=hhwtsc], vce(cluster xwaveid)

estimates store PH

*-----------------------------
* 1) Weighted means for trust/envy
*-----------------------------
quietly mean trust [pweight=hhwtsc]
local trust_mean = r(table)[1,1]

quietly mean envy [pweight=hhwtsc]
local envy_mean  = r(table)[1,1]

local trust_low  = 2
local trust_high = 6
local envy_low   = 2
local envy_high  = 6

local ages "45 55 70"

tempfile base
save `base', replace

*-----------------------------
* 2) Build Table 3
*-----------------------------
tempname posth
postfile `posth' str35 scenario int age_th double cuminc using table3, replace

foreach sc in ///
    "Trust low vs envy mean" ///
    "Trust high vs envy mean" ///
    "Envy low vs trust mean" ///
    "Envy high vs trust mean" ///
    "Low trust + High envy" ///
    "High trust + Low envy" {

    use `base', clear
    estimates restore PH

    * Set scenario values
    replace trust = `trust_mean'
    replace envy  = `envy_mean'

    if "`sc'"=="Trust low vs envy mean"     replace trust = `trust_low'
    if "`sc'"=="Trust high vs envy mean"    replace trust = `trust_high'
    if "`sc'"=="Envy low vs trust mean"     replace envy  = `envy_low'
    if "`sc'"=="Envy high vs trust mean"    replace envy  = `envy_high'
    if "`sc'"=="Low trust + High envy" {
        replace trust = `trust_low'
        replace envy  = `envy_high'
    }
    if "`sc'"=="High trust + Low envy" {
        replace trust = `trust_high'
        replace envy  = `envy_low'
    }

    * Predicted hazard per interval-row
    predict xb, xb
    gen h = 1 - exp(-exp(xb))

    * Chain survival within person across observed intervals
    bysort xwaveid (year): gen S = .
    bysort xwaveid (year): replace S = (1 - h) if _n==1
    bysort xwaveid (year): replace S = S[_n-1] * (1 - h) if _n>1
    gen F = 1 - S

    * Age at end of interval (4-year step)
    gen age_end = age0 + 4

    * For each threshold: each person's latest F where age_end <= threshold
   foreach A of local ages {
    bysort xwaveid (age_end): gen Ftmp = F if age_end <= `A'
    bysort xwaveid: egen F_byA = max(Ftmp)
    drop Ftmp

    * ---- DIAGNOSTIC: check scenario is actually changing predictions
    * (optional, but useful once)
    * quietly summarize xb
    * di as txt "`sc'  xb mean = " %9.4f r(mean)

    * ---- IMPORTANT FIX: collapse to ONE ROW PER PERSON for the mean
    preserve
        bysort xwaveid (year): keep if _n==1   // one record per person
        quietly summarize F_byA [aw=hhwtsc]
        local m = r(mean)
    restore

    post `posth' ("`sc'") (`A') (`m')

    drop F_byA
}
}

postclose `posth'

*-----------------------------
* 3) Display Table 3
*-----------------------------
use table3, clear
reshape wide cuminc, i(scenario) j(age_th)
format cuminc* %6.3f
list scenario cuminc*, noobs abbreviate(28)

*-----------------------------
* 4) Optional Figure (trust)
*-----------------------------
use table3, clear
keep if inlist(scenario, "Trust low vs envy mean", "Trust high vs envy mean")
twoway ///
    (line cuminc age_th if scenario=="Trust low vs envy mean", sort) ///
    (line cuminc age_th if scenario=="Trust high vs envy mean", sort), ///
    ytitle("Predicted cumulative incidence") ///
    xtitle("Age threshold") ///
    legend(order(1 "Low trust" 2 "High trust"))



	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
use "$data\waves1_23.dta", clear	

keep if inlist(wave, 9, 13, 17, 21) // these are the only waves needed for the discrete-time modelling strategy 
keep if age0 >=15

g year = 2000 + wave
drop wave
sort xwaveid year 
order xwaveid year 

* interval variable 
g interval = . 
replace interval = 1 if year ==2009
replace interval = 2 if year ==2013
replace interval = 3 if year ==2017

label define interval 1 "2009-13" 2 "2013-17" 3 "2017-21"
label values interval interval

order xwaveid year interval

* Social support index 
foreach v in i m q {
recode social_loneliness_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_loneliness_`v'_r)
recode social_confide_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_confide_`v'_r)
recode social_leanon_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_leanon_`v'_r)
recode social_helpneed_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_helpneed_`v'_r)
recode social_time_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_time_`v'_r)
recode social_visit_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(social_visit_`v'_r)
}


foreach v in i m q {
g social_support_`v' = .	
replace social_support_`v' = social_cheerup_`v' + social_lotsfriends_`v' + social_helpneed2_`v' + social_talk_`v' ///
                      + social_loneliness_`v'_r + social_confide_`v'_r + social_leanon_`v'_r  ///
					  + social_helpneed_`v'_r + social_visit_`v'_r + social_time_`v'_r ///
       if social_cheerup_`v' > 0 & social_lotsfriends_`v' > 0 & social_helpneed_`v' > 0 & social_talk_`v' > 0 ///
       & social_loneliness_`v'_r > 0 & social_confide_`v'_r > 0 & social_leanon_`v'_r > 0 & social_helpneed_`v'_r > 0 ///
	   & social_visit_`v'_r > 0 & social_time_`v'_r >0

replace social_support_`v' = social_support_`v'/10
}

g social_support =.
replace social_support = social_support_i if interval ==1 
replace social_support = social_support_m if interval ==2
replace social_support = social_support_q if interval ==3 

* Psych distress score 
g psych_distress =. 
replace psych_distress = psych_distress_i if interval ==1
replace psych_distress = psych_distress_m if interval ==2
replace psych_distress = psych_distress_q if interval ==3

* Trust
g trust = .
replace trust = trust_h if interval ==1 
replace trust = trust_k if interval ==2
replace trust = trust_n if interval ==3

* Financial risk 
g risk_pref =. 
replace risk_pref = risk_financial_h if interval ==1 
replace risk_pref = risk_financial_n if interval ==2
replace risk_pref = risk_financial_q if interval ==3 

* Personality traits
g pers_agreeableness=. 
replace pers_agreeableness = pers_agreeableness_i if interval ==1 
replace pers_agreeableness = pers_agreeableness_m if interval ==2
replace pers_agreeableness = pers_agreeableness_q if interval ==3

g pers_conscientiousness=. 
replace pers_conscientiousness = pers_conscientiousness_i if interval ==1 
replace pers_conscientiousness = pers_conscientiousness_m if interval ==2
replace pers_conscientiousness = pers_conscientiousness_q if interval ==3

g pers_emotionalstability=. 
replace pers_emotionalstability = pers_emotionalstability_i if interval ==1 
replace pers_emotionalstability = pers_emotionalstability_m if interval ==2
replace pers_emotionalstability = pers_emotionalstability_q if interval ==3

g pers_opentoexper=.
replace pers_opentoexper = pers_opentoexper_i if interval ==1 
replace pers_opentoexper = pers_opentoexper_m if interval ==2
replace pers_opentoexper = pers_opentoexper_q if interval ==3

g pers_extroversion=.
replace pers_extroversion = pers_extroversion_i if interval ==1 
replace pers_extroversion = pers_extroversion_m if interval ==2
replace pers_extroversion = pers_extroversion_q if interval ==3

* Locus of control 
foreach v in g k o {
recode control_little_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_little_`v'_r)
recode control_problems_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_problems_`v'_r)
recode control_changethings_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_changethings_`v'_r)
recode control_helpless_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_helpless_`v'_r)
recode control_pushed_`v' (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1), gen(control_pushed_`v'_r)
}

foreach v in g k o {
g control_`v' = .	
replace control_`v' =  control_future_`v' + control_doanything_`v' ///
                      + control_little_`v'_r + control_problems_`v'_r + control_changethings_`v'_r  ///
					  + control_helpless_`v'_r + control_pushed_`v'_r  ///
       if control_future_`v'  > 0 & control_doanything_`v'  > 0 & control_little_`v'_r > 0 & control_problems_`v'_r > 0 ///
	   & control_changethings_`v'_r > 0 & control_helpless_`v'_r > 0 & control_pushed_`v'_r > 0

replace control_`v' = control_`v'/7
}

g locus_control =.
replace locus_control = control_g if interval ==1 
replace locus_control = control_k if interval ==2
replace locus_control = control_o if interval ==3 

* Chronic 
drop if chronic_any_i ==1 // (16,175) people have a condition so we cant model their onset; have to drop. 
                          // note: the people ==- here have a condition thats not one of ours 
						  
foreach v in m q u {
	replace chronic_any_`v' = 0 if chronic_any_`v' ==-1 
}		
				  
g chronic =. 
replace chronic = chronic_any_m if interval ==1 
replace chronic = chronic_any_q if interval ==2 
replace chronic = chronic_any_u if interval ==3

drop if year ==2021 // we dont need it anymore; only needed it to define onset for 2021 in the 2017-2021 interval

drop chronic_*

* Keep relevant variables only 
keep ///
age0 male educ ehi_quart rural cob_os /// // covariates  /// // chronic conditions
hhwtsc /// // population weight 
locus_control social_support trust risk_pref psych_distress /// // psychosocial chars 
pers_agreeableness pers_conscientiousness pers_emotionalstability pers_opentoexper pers_extroversion /// // psychosocial cars (pers traits)
chronic ///
year xwaveid interval

** Deal no scq and non-responding 
drop if chronic == -10 // non-responding 
drop if psych_distress <0 | psych_distress ==. // no scq + non responding + refused/not stated
drop if social ==. // probably refused/not stated 
drop if risk_pref <0 | risk_pref ==. // no SCQ, non-responding, multiple sc, refused/not stated 
drop if pers_agreeableness <0 | pers_agreeableness ==.
drop if pers_conscientiousness <0 | pers_conscientiousness ==.
drop if pers_emotionalstability <0
drop if pers_opentoexper <0

//  too many missings... ~5k???
drop if locus_control ==. 
drop if trust ==. 

drop if chronic ==.

foreach v of varlist age0 male ehi_quart educ rural cob_os {
	drop if `v' ==.
}

* Compute within-person gaps
bysort xwaveid (year): gen year_gap = year - year[_n-1] if _n>1

* See what gaps exist
tab year_gap, missing

* Flag any non-4 gaps (e.g., 2009 -> 2017 gives gap = 8)
gen bad_gap = year_gap != 4 & !missing(year_gap)

* Drop them 
bys xwaveid: egen max_gap = max(bad_gap)
drop if max_gap ==1

sort xwaveid year 
order xwaveid year interval chronic





*age groups
g age_group =.
replace age_group = 1 if age0 >=15 & age0<40
replace age_group = 2 if age0 >=40 & age0<55
replace age_group = 3 if age0 >=55 & age0<70
replace age_group = 4 if age0 >=70 

*personality variables
label var pers_extroversion "Extroversion"
label var pers_agreeableness "Agreeableness"
label var pers_conscientiousness "Conscientiousness"
label var pers_emotionalstability "Emotional Stability"
label var pers_opentoexper "Openness"

*sociodemographic variables
label var age_group "Age Group (years)"
label var male "Male (sex)"
label var educ "Education"
label var ehi_quart "Equivalised Household Income"
label var rural "Rural"
label var cob_os "Born Overseas"

label define age_group 1 "15-39" 2 "40-54" 3 "55-69" 4 "70+" 
label define ehi_quart 1 "1st Quartile (Lowest)" 2 "2nd Quartile" 3 "3rd Quartile" 4 "4th Quartile (Highest)"
label values age_group age_group
label values ehi_quart ehi_quart

* Psychosocial labels

save "$data\main.dta", replace



















	
	
	
	
	
	
	
	
	
	




































*cleaning waves 9, 13, 17 ,21

foreach v in i m q u {
    use "$data\Combined_`v'230u.dta", clear

    if "`v'" == "i" {
        gen wave = 9
    }
    if "`v'" == "m" {
        gen wave = 13
    }
    if "`v'" == "q" {
        gen wave = 17
    }
    if "`v'" == "u" {
        gen wave = 21
    }

	
	*general data cleaning:
	
	* sex
	rename `v'hgsex male
	recode male 2=0
	label define male 0 "female" 1 "male"
	label values male male
	label var male "=1 if male"

	* in labour force
	gen lf = 1 if `v'esbrd == 1 | `v'esbrd == 2
	replace lf = 0 if lf == .
	label var lf "=1 if in labour force"
	label define lf 1 "in labour force" 0 "not in labour force"
	label values lf lf

	* age
	rename `v'hgage age0

	* married
	gen married = 1 if `v'mrcurr == 1 | `v'mrcurr == 2
	replace married = 0 if married == . & `v'mrcurr > 0
	label var married "=1 if married or de facto"
	label define married 1 "married or de facto" 0 "not married"
	label values married married
	
	* indigenous
	gen indig = 1 if `v'anatsi == 2 | `v'anatsi == 3 | `v'anatsi == 4
	replace indig = 0 if indig == . & `v'anbcob > 0
	label var indig "=1 if indigenous or Torres Strait Islander"
	label define indig 1 "indigenous or TSI" 0 "not indigenous"
	label values indig indig

	* education
	gen degree = 1 if `v'edhigh1 <= 3
	replace degree = 0 if degree == . & `v'edhigh1 ~= 10
	label var degree "=1 if has a bachelor or higher degree"

	gen oth_psq = 1 if `v'edhigh1 == 4 | `v'edhigh1 == 5
	replace oth_psq = 0 if oth_psq == . & `v'edhigh1 ~= 10
	label var oth_psq "=1 if has other non-degree post-school qualifications"

	gen yr12 = 1 if `v'edhigh1 == 8
	replace yr12 = 0 if yr12 == . & `v'edhigh1 ~= 10
	label var yr12 "=1 if completed year 12"
	
	// or something like the following
	gen educ = 1 if `v'edhigh1 == 9
	replace educ = 2 if `v'edhigh1 == 8 | `v'edhigh1 == 5
	replace educ = 3 if `v'edhigh1 == 4 | `v'edhigh1 == 3 | `v'edhigh1 == 2 | `v'edhigh1 == 1
	tab `v'edhigh1 educ, m
	label var educ "highest education"
	label define educ 1 "less than Yr 12" 2 "Yr 12 or equivalent" 3 "Bachelor or above"
	label values educ educ
	
	* state of residence
	rename `v'hhstate state

	* rural/urban
	gen rural = 0 if `v'hhsos == 0 | `v'hhsos == 1
	replace rural = 1 if `v'hhsos == 2 | `v'hhsos == 3 | `v'hhsos == 4
	label var rural "=1 if rural"
	label define rural 1 "rural" 0 "urban"
	label values rural rural

	* cob
	gen cob_os = 1 if `v'anbcob == 2 | `v'anbcob == 3
	replace cob_os = 0 if `v'anbcob == 1
	label var cob_os "=1 if born overseas"

	gen cob_n_en = 1 if `v'anbcob == 3
	replace cob_n_en = 0 if `v'anbcob == 1 | `v'anbcob == 2
	label var cob_n_en "=1 if born in non-English speaking foeign country"

	* personal disposable income
	gen income = `v'tifditp - `v'tifditn
	replace income = income/1000
	label var income "personal disposable income (thousands)"
	
	* household disposable income
	gen hhincome = `v'hifdip - `v'hifdin
	replace hhincome = hhincome/1000
	label var hhincome "household disposable income (thousands)"

	gen hhchild = `v'hhpers - `v'hhadult
	label var hhchild "number of children in household"
	gen ehi = hhincome/(1+0.5*(`v'hhadult-1)+0.3*hhchild)
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
	
   *disablity
	* pwd
    g pwd=0 if `v'hglth==2 
    replace pwd=1 if `v'hglth==1 
	
  
	/********************************
	     chronic condition paper 
	********************************/
	
   *english skill
	g english_proficiency = `v'aneab
	
	*health vars
	g gh1 = `v'gh1   // self assessed health
	rename gh1 sa_health
	recode sa_health (1=5) (2=4) (4=2) (5=1)
	
	g childhood_health = `v'hech // childhood health rating
	
	g mental_health = `v'ghmh // mental health
	
	g general_health = `v'ghgh // general health
	
	g overall_health = `v'ghsf6d // overall health
	
	g spfunctioning = `v'gh10   // social/physical functioning
	
	*satisfaction vars
	g life_sat = `v'losat // life satisfaction
	g health_satisfaction = losatyh 
	g neighbourhood_satisfaction = losatnl 
	g home_satisfaction = `v'losathl 
	g financial_satisfaction = `v'losatfs
	g partner_satisfaction = `v'lsrelsp 
	g safety_satisfaction = `v'losatsf 
	g parent_satisfaction = `v'lsrelrp
	g stepparent_satisfaction = `v'lsrelrs
	
	*childhood vars
	g moved_first = `v'fmagelh // age first moved from home
	g father_cob = `v'fmfcob // father country born
	g mother_cob =`v'fmmcob // mother country born
	g father_paid = `v'fmfemp // father paid employment when 14 years old
	g mother_paid = `v'fmmemp // mother paid employment when 14 years old 
	g father_educ = `v'fmfhlq // father highest level qualification 
	g mother_educ = `v'fmmhlq // mothers highest level qualification
	g parents_divorced = `v'fmpdiv // parents ever divorced/seperated
	g siblings = `v'fmhsib // ever had siblings
	
	*stress vars
	rename `v'lertr stressw_retired  //work-related
	rename `v'lefrd stressw_firedredundant
	rename `v'jomms stressw_job 
	rename `v'jompi stressw_job_ill
	
	rename `v'leinf stressf_familyinjill //family related
	rename `v'ledfr stressf_deathfriend
	rename `v'ledsc stressf_deathspousechild
	rename `v'ledrl stressf_deathrelfam
	rename `v'lepcm stressf_propertycrime 
	rename `v'lejlf stressf_jail
	
	rename `v'levio stressp_physicalv //personal stress
	rename `v'leins stressp_injill
	rename `v'lejls stressp_jail 
	
	g stressp_financial = 1 if `v'fiprbeg ==1 | `v'fiprbfh ==1 | `v'fiprbmr ==1 ///
	| `v'fiprbps==1 | `v'fiprbuh==1 | `v'fiprbwm==1 | `v'fiprbwo==1 
	replace stressp_financial = 0 if missing(stressp_financial) & ///
    `v'fiprbeg !=1 & `v'fiprbfh !=1 & `v'fiprbmr !=1 & ///
    `v'fiprbps !=1 & `v'fiprbuh !=1 & `v'fiprbwm !=1 & `v'fiprbwo !=1
	
	g stressp_divorced = 1 if `v'mrcurr ==3 | `v'mrcurr==4
	replace stressp_divorced = 0 if `v'mrcurr >4 | `v'mrcurr <3 
	
	g stressp_widowed = 1 if `v'mrcurr ==5
	replace stressp_widowed =0 if `v'mrcurr !=5 
	
	*demographic vars 
	
	*private health insurance
	g phi = 1 if `v'xpphi ==2  // expenditure variable
	replace phi =0 if `v'xpphi ==1
	label var phi "private health insurance"
	label define phi 1 "has PHI" 0 "no PHI"
	label values phi phi
	
	g phi_2 = 1 if `v'phpriin ==1
	replace phi_2 = 0 if `v'phpriin == 2
	label var phi_2 "Private Health Insurance Coverage"
	label values phi phi
	
	*lifestyle behaviours
	
	g smoke=0 if `v'lssmkf>0  //smoke
	replace smoke=1 if `v'lssmkf==3
	
    g smoke2 =0 if `v'lssmkf >0   // never smoked vs has smoked or smokes
    replace smoke2 =1 if `v'lssmkf !=1
	
	g smoke3 = 0 if `v'lssmkf >0       // (never smoked + has smoked) vs smokes
	replace smoke3 = 1 if `v'lssmkf == 3 | `v'lssmkf ==4 | `v'lssmkf ==5
	
	recode `v'lsdrkf 3=8 4=7 5=6 6=5 7=4 8=3 //drinking
	label define `v'lsdrkf 1 "has never drunk alcohol" 2 "no longer drinks" 3 "drinks rarely" 4 "drinks less than once a week" 5 "drinks 1-2 days/week" 6 "drinks 3-4 days/week" 7 "drinks 4-5 days/week" 8 "drinks daily"
	label values `v'lsdrkf lsdrkf
	rename `v'lsdrkf drinks
	
	rename `v'lspact exercise  //physical activity
	label var exercise "moderate or intensive activity for at least 30 minutes"
	
	rename `v'bmi bmi
	
	rename `v'hechps parents_smoked
	
	rename `v'fffrt fruits
	replace fruits = -10 if fruits==9
	
	rename `v'ffveg vegetables
	replace vegetables = -10 if vegetables ==9
	
	rename `v'ffbf eats_breakfast
	replace eats_breakfast = -10 if eats_breakfast ==9
	
	*social support vars 
	rename `v'lssupvl loneliness // loneliness
	rename `v'lssuplf friends //friends
	
	*volunteer/community vars
	rename `v'lshrvol volunteer
	
	*chronic condition check ups 
	rename `v'hehcany checkup1_any
	rename `v'hecpany checkup2_any
	
	*weight
	rename `v'hhwtrp weight
	rename `v'hhwtsc weight_onset
	
	*personality traits
    rename `v'pnagree pers_agreeableness
    rename `v'pnconsc pers_conscientiousness
    rename `v'pnemote pers_emotionalstability
    rename `v'pnextrv pers_extroversion
    rename `v'pnopene pers_opentoexper		
	
	*chronic conditions
	rename `v'heany chronic_any   // ever told if have any of these illnesses (yes vs no; if yes, questions on specific illnesses are asked)
	
	rename `v'hehbp chronic_bloodhyper // CVD (blood hypertension, heart, circulatory)
	rename `v'hehcd chronic_heart
	rename `v'heoc  chronic_circulatory
	egen chronic_cvd = rowmax(chronic_bloodhyper chronic_heart chronic_circulatory)
	
	rename `v'hecbe chronic_bronchemphys // respiratory (bronchitis or emphasyema, and asthma)
    rename `v'heast chronic_asthma
	egen chronic_respiratory = rowmax(chronic_bronchemphys chronic_asthma)
	
	rename `v'heart  chronic_arthosteo  // musculoskeletal (arhirits or osteoporosis)
	
	rename `v'hedep chronic_mental // depression or anxiety
	rename `v'heomi chronic_mental_other
	
	rename `v'hecan chronic_cancer //cancer
	label var chronic_cancer "Diagnosed with any type of cancer"
	label define cancer 0 "No" 1 "Yes"
	label values chronic_cancer cancer
	
	rename `v'hedi1 diabetes_t1 // diabetes
	rename `v'hedi2 chronic_diabetes2
	
	* Psychosocial variables 
	**Locus of control 
	rename `v'ssecd locus_doanything
	rename `v'sseci locus_changethings
	rename `v'ssefd locus_future
	rename `v'ssefh locus_helpless 
	rename `v'sselc locus_littlecontrol
	rename `v'ssepa locus_pushedaround 
	rename `v'ssesp locus_solveproblems
	**Psychological distreess 
	rename `v'dk10rc psych_distress
	**Sexuality 
	rename `v'lssexor sexuality
	
    save "$data\vars_wave_`v'.dta", replace
}

*append all waves 9, 13, 17, 21
use "$data\vars_wave_i.dta", clear
foreach v in m q u  {
    append using "$data\vars_wave_`v'.dta"
}

	keep age0 male married educ ehi_quart lf indig rural cob_os cob_n_en english_proficiency phi_2 siblings moved_first  /// // sociodemo vars
	     drinks exercise smoke2 bmi vegetables fruits eats_breakfast  /// // lifestyle behaviors
		 stressf_deathfriend stressf_deathrelfam stressf_deathspousechild stressf_familyinjill stressf_jail stressf_propertycrime /// // stress(family)
		 stressp_divorced stressp_financial stressp_injill stressp_jail stressp_physicalv stressp_widowed /// // stress(personal)
		 stressw_firedredundant stressw_job stressw_job_ill stressw_retired /// // stress(work)
		 pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper /// // personality traits
		 mental_health overall_health sa_health pwd spfunctioning checkup1_any checkup2_any childhood_health /// // health predictors 
		 loneliness friends volunteer /// // social support/volunteers
		 life_sat neighbourhood_satisfaction home_satisfaction financial_satisfaction partner_satisfaction /// satisfaction vars
		 safety_satisfaction health_satisfaction parent_satisfaction stepparent_satisfaction /// 
		 father_cob father_educ father_paid mother_cob mother_educ mother_paid parents_divorced /// // family history
		 chronic_cvd chronic_arthosteo chronic_cancer chronic_any chronic_diabetes2 chronic_mental chronic_respiratory /// // chronic conditions
		 xwaveid wave /// // identifiers
		 mslhrwk qslhrwk uslhrwk // hours of sleep per week waves 13, 17, 21 (no wave 9)
		 
	
*sleep 
g sleep_hours = . // sleep hours
replace sleep_hours = mslhrwk if mslhrwk !=.
replace sleep_hours = qslhrwk if qslhrwk !=.
replace sleep_hours = uslhrwk if uslhrwk !=.
drop mslhrwk qslhrwk uslhrwk

*parents born overseas
g father_cob_os = 1 if father_cob !=1101 & father_cob >0
replace father_cob_os = 0 if father_cob ==1101 

g mother_cob_os = 1 if mother_cob !=1101 & mother_cob >0
replace mother_cob_os = 0 if mother_cob ==1101 

*age groups
g age_group =.
replace age_group = 1 if age0 >=15 & age0<25
replace age_group = 2 if age0 >=25 & age0<35
replace age_group = 3 if age0 >=35 & age0<45
replace age_group = 4 if age0 >=45 & age0<55
replace age_group = 5 if age0 >=55 & age0<65
replace age_group = 6 if age0 >=65 & age0<75
replace age_group = 7 if age0 >=75

*medical checkups
replace checkup1_any = 0 if checkup1_any==2
replace checkup2_any = 0 if checkup2_any ==2
label define noyes 0 "No" 1 "Yes"
label values checkup1_any noyes
label values checkup2_any noyes

*personality variables
label var pers_extroversion "Extroversion"
label var pers_agreeableness "Agreeableness"
label var pers_conscientiousness "Conscientiousness"
label var pers_emotionalstability "Emotional Stability"
label var pers_opentoexper "Openness"

*health variables 
label var sa_health "Self-Assessed Health"
label var pwd "Disability"
label var mental_health "Mental health"
label var overall_health "Overall Health"
label var spfunctioning "Social and Physical Functioning"
label var checkup1_any "Medical Checkup: Set 1"
label var checkup2_any "Medical Checkup: Set 2"
label var childhood_health "Childhood Health"

*chronic condition variables
label var chronic_cvd "Cardiovascular Disease"
label var chronic_arthosteo "Musculoskeletal Ilness"
label var chronic_cancer "Cancer: Any type"
label var chronic_diabetes2 "Diebetes: Type 2"

*sociodemographic variables
label var age_group "Age Group (years)"
label var male "Male (sex)"
label var married "Married"
label var educ "Education"
label var ehi_quart "Equivalised Household Income"
label var lf "Labour Force"
label var indig "Indigeneous or TSI"
label var rural "Rural"
label var cob_os "Born Overseas"
label var cob_n_en "Born Overseas in Non-English Speaking Country"
label var english_proficiency "English Proficiency"
label var moved_first "Age first moved out of home"
label var siblings "Siblings"

label define age_group 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65-74" 7 "75+"
label define ehi_quart 1 "1st Quartile (Lowest)" 2 "2nd Quartile" 3 "3rd Quartile" 4 "4th Quartile (Highest)"
label values age_group age_group
label values ehi_quart ehi_quart

*lifestyle vars
label var drinks "Drinks Alcohol"
label var exercise "Exercise (Moderate/Intensive)"
label var bmi "Body Mass Index (BMI)"
label var fruits "Fruits"
label var vegetables "Vegetables"
label var smoke2 "Current/Ex Smoker"
label var eats_breakfast "Eats Breakfast"
label var sleep_hours "Hours slept per week"

*Stress classifactions
label var stressw_retired "Retired"   // actually cant include these because all conditional on having employment
label var stressw_firedredundant "Fired/Made Redundant"
label var stressw_job "Job Stress"
label var stressw_job_ill "Job Causes Illness (Belief)"
	
label var stressf_familyinjill "Family Member Seriously Injured/Ill"
label var stressf_deathfriend "Death of Friend"
label var stressf_deathspousechild "Death of Spouse/Child"
label var stressf_deathrelfam "Death of Relative/Family Member"
label var stressf_propertycrime "Victim of Property Crime"
label var stressf_jail "Family Member in Jail"
	
label var stressp_physicalv "Victim of Physical Violence"
label var stressp_injill "Serious Injury/Illness"
label var stressp_jail "In Jail"
label var stressp_widowed "Widowed"
label var stressp_divorced "Divorced/Seperated"
label var stressp_financial "Financial"
	
*satisfaction variables
label var health_satisfaction "Health Satisfaction"
label var neighbourhood_satisfaction "Neighbourhood Satisfaction"
label var home_satisfaction "Home Satisfaction"
label var financial_satisfaction "Financial Satisfaction"
label var partner_satisfaction "Partner Satisfaction"
label var safety_satisfaction "Safety Satisfaction"
label var life_sat "Life Satisfaction"
label var parent_satisfaction "Parent Satisfaction"
label var stepparent_satisfaction "Step-Parent Satisfaction"

*social support variables
label var loneliness "Loneliness"
label var friends "Lots of friends"
label var volunteer "Volunteers"

*family history
label var father_educ "Father Education"
label var father_paid "Father Paid Employment at 14 Years Old"
label var mother_educ "Mother Education"
label var mother_paid "Mother Paid Employment at 14 Years Old"
label var parents_divorced "Parents Ever Divorced"
label var father_cob_os "Father Born Overseas"
label var mother_cob_os "Mother Born Overseas"

save "$data\main.dta", replace


/*********************************************
chronic condition dummy generation
*********************************************/

*chronic condition dummy variable
sort xwaveid wave
egen chronic_dummy = rowmax(chronic_cvd chronic_cancer ///
                      chronic_arthosteo chronic_diabetes2) // for subset of chronic_any==1; 
					                                       // have to add people who werent asked (no chronic); exclude respiratory + mental illness
g flag_other =.
replace flag_other = 1 if chronic_dummy ==0 // these are people in control group that have a condition not in our 5

replace chronic_dummy = 0 if chronic_any==2 // add primary control group (those who ticked no to have any chronic condition)

drop if chronic_dummy <0 // 21938 dropped: <15 years old 

order xwaveid wave chronic_dummy chronic_any chronic_cvd chronic_cancer chronic_arthosteo chronic_diabetes2	


/*********************************************
LASSO pre-processing
*********************************************/

*dealing with missing values and/or non-respondents

*numerical variables 
*deal with special cases
replace moved_first =. if moved_first ==99 // check hilda data dictionary why these are 99; prob invalid/missing

*value labels - move above later
replace siblings =0 if siblings==2
label values siblings noyes

foreach var of varlist stressp_injill stressp_physicalv stressp_jail  {
    replace `var' = 0 if `var' == 1
    replace `var' = 1 if `var' == 2
}

foreach var of varlist stressp* {
	label values `var' noyes
}

foreach var of varlist stressf*  {
    replace `var' = 0 if `var' == 1
    replace `var' = 1 if `var' == 2
	label values `var' noyes
}

foreach var of varlist stressw_retired stressw_firedredundant  {
    replace `var' = 0 if `var' == 1
    replace `var' = 1 if `var' == 2
	label values `var' noyes
}

replace parents_divorced = 0 if parents_divorced ==1
replace parents_divorced = 1 if parents_divorced ==2 

*remaining unlabeled
label values cob_os noyes
label values cob_n_en noyes
label values pwd noyes
label values phi_2 noyes 
label values parents_divorced noyes

*replace all values <0 in each variable as missing
destring xwaveid, replace

*define numerical variables
global numerical age0 english_proficiency moved_first /// sociodemo vars
                  drinks exercise bmi vegetables fruits sleep_hours eats_breakfast /// lifestyle behaviors
                  pers_extroversion pers_agreeableness pers_conscientiousness pers_emotionalstability pers_opentoexper /// personality traits
                  mental_health overall_health sa_health spfunctioning childhood_health /// health vars
                  loneliness friends volunteer /// social support / volunteers
                  life_sat health_satisfaction neighbourhood_satisfaction home_satisfaction financial_satisfaction /// satisfaction vars
                  partner_satisfaction safety_satisfaction parent_satisfaction stepparent_satisfaction

*replace values less than 0 with missing for each numeric variable
foreach var of global numerical {
    replace `var' = . if `var' < 0
}

*mean imputation method for numeric vars
foreach var of global numerical { 
    qui su `var', meanonly
    replace `var' = r(mean) if missing(`var')
}

*categorical variables
global categorical ///
         male married educ ehi_quart lf indig rural cob_os cob_n_en phi_2 siblings /// // sociodemo vars
		 stressf_deathfriend stressf_deathrelfam stressf_deathspousechild stressf_familyinjill stressf_jail stressf_propertycrime /// // stress(family)
		 stressp_divorced stressp_financial stressp_injill stressp_jail stressp_physicalv stressp_widowed /// // stress(personal)
		 stressw_firedredundant stressw_job stressw_job_ill stressw_retired /// // stress(work)
		 pwd  checkup1_any checkup2_any  /// // health predictors 
		 father_cob father_educ father_paid mother_cob mother_educ mother_paid parents_divorced  // family history


foreach var of global categorical  {
    replace `var' = . if `var' < 0
}

*missing category imputation for categoric vars
foreach var of global categorical {
    replace `var' = 9999 if missing(`var')
    capture label define `var'_lbl 9999 "Missing", add
    capture label values `var' `var'_lbl
}

/*
*identify variables with >20% missing data
foreach var of varlist _all {
    qui count if missing(`var')
    local nmiss = r(N)
    qui count
    local ntotal = r(N)
    local pctmiss = 100 * `nmiss' / `ntotal'
    di "`var': " %6.2f `pctmiss'
}

drop parents_smoked stressw_job stressw_job_ill partner_satisfaction income phi // note: these are vars conditional on (a) having employment and (b) having partner, so makes sense 
*/

drop english_proficiency // this was only asked for immigrants i think

/*drop the variables very highly correlated with age (reverse causality)
these are:
1) labour force
2) widowed
3) retired
4) childhood health (only asked to people who arent old maybe?)
5) social and physical functioning
6) father_educ and mother_educ
7) sleep hours
8) the stress vairables related to death of family member/friend/personal illness/injury etc
9) overall health, self-assessed health, health satisfaction, parent sat, stepparent sat
4) overall health
5) self assessed health
6) childhood health (only asked to people who arent old maybe?)
7) income
8) job stress vars (same reason as labour force and income)
9) home satisfaction
10) life satisfaction
11) financial satisfaction 
12) health satisfaction 
14) sp functioning 
16) stress death friend 
17) stress death rel/family 
18) stress death spouse child
19) family injury illness 
*/

*/
drop stressp_widowed stressw_retired stressf_deathfriend stressf_deathrelfam ///
stressf_deathspousechild stressp_injill stressf_familyinjill ///
lf childhood_health spfunctioning father_educ mother_educ sleep_hours overall_health


*Create lagged variables of time-variant predictors

sort xwaveid wave

foreach  var in age0 married educ ehi_quart rural phi_2 siblings  /// // sociodemo vars
	     drinks exercise smoke2 bmi vegetables fruits eats_breakfast  /// // lifestyle behaviors
		 stressf_jail stressf_propertycrime /// // stress(family)
		 stressp_divorced stressp_financial stressp_jail stressp_physicalv /// // stress(personal)
		 stressw_firedredundant stressw_job stressw_job_ill /// // stress(work)
		 pers_agreeableness pers_conscientiousness pers_emotionalstability pers_extroversion pers_opentoexper /// // personality traits
		 mental_health pwd checkup1_any checkup2_any /// // health predictors 
		 loneliness friends volunteer /// // social support/volunteers
		 life_sat neighbourhood_satisfaction home_satisfaction financial_satisfaction partner_satisfaction /// satisfaction vars
		 safety_satisfaction  parents_divorced   {
    gen lag_`var' = `var'[_n-1] if xwaveid == xwaveid[_n-1]
}


/*********************************************
Age at onset dependent variable
*********************************************/

*single chronic conditions 

 //  5000 unique individuals (so a couple are 1 1 1 1 for all 4 years and some also maybe only in dataset for 1 year for e.g.)

 foreach condition in chronic_cvd chronic_arthosteo chronic_diabetes2 chronic_cancer {
    *replace -1 with 0 in the chronic condition variable - these are people without ANY condition. Not important anyway due to onset only
    replace `condition' = 0 if `condition' ==-1

    *identify the first occurrence of each chronic condition
    bysort xwaveid (wave): gen first_`condition' = _n if `condition' == 1 & `condition'[_n-1] == 0

    *generate age at onset variable
    gen age_at_onset_`condition' = .
    replace age_at_onset_`condition' = age0 if first_`condition' != .
	
	order xwaveid wave `condition' first_`condition' age_at_onset_`condition'
}

label var age_at_onset_chronic_cancer "Cancer"
label var age_at_onset_chronic_cvd "CVD"
label var age_at_onset_chronic_diabetes2 "Diabetes (Type 2)"
label var age_at_onset_chronic_arthosteo "Arthirits or Osteoporisis"

* pooled chronic conditions
bysort xwaveid (wave): gen first_chronic = _n if chronic_dummy==1 & chronic_dummy[_n-1]==0

gen age_at_onset = .
replace age_at_onset = age0 if first_chronic!=.

label var age_at_onset "Age at onset (pooled chronic conditions)"

order xwaveid wave age_at_onset first_chronic chronic_dummy


/*********************************************
Age at onset histograms
*********************************************/

* Step 1: Create histograms with smaller text and variable labels
foreach var in age_at_onset_chronic_cancer ///
               age_at_onset_chronic_diabetes2 ///
               age_at_onset_chronic_arthosteo ///
               age_at_onset_chronic_cvd {

    * Get sample size
    quietly count if !missing(`var')
    local n = r(N)

    * Get variable label
    local label : variable label `var'

    * Create histogram with smaller text
    histogram `var', frequency ///
        name(h_`var', replace) ///
        title("`label'", size(vsmall)) ///
        subtitle("N = `n'", size(tiny) position(11) ring(0)) ///
        ytitle("Frequency", size(tiny)) ///
        xtitle("Age at Onset", size(tiny)) ///
        xlabel(, labsize(tiny)) ///
        ylabel(, labsize(tiny))
}

* Step 2: Combine into a 2x3 layout and scale up graph area
graph combine h_age_at_onset_chronic_cancer ///
              h_age_at_onset_chronic_diabetes2 ///
              h_age_at_onset_chronic_arthosteo ///
              h_age_at_onset_chronic_cvd, ///
              cols(2) iscale(1.3)  



 * Generate a single summary table for all age_at_onset variables including quartiles and IQR
 
preserve
svyset xwaveid [pweight=weight_onset], strata(xwaveid)
asdoc svy: sum age_at_onset age_at_onset_chronic_respiratory age_at_onset_chronic_cvd age_at_onset_chronic_arthosteo ///
      age_at_onset_chronic_mental age_at_onset_chronic_diabetes2 age_at_onset_chronic_cancer [aw=weight],  ///
     stat(N mean median sd iqr p25 p50 p75 p99 min max) label dec(1) save($output\test1_onset.doc) replace 
restore

preserve
drop if weight<0
	 svy: mean age_at_onset_chronic_respiratory  // Check weighted mean
restore 
	 
	 
svyset xwaveid [pweight=weight]  // Set survey weights 
	 	 	 
 
* Loop over chronic conditions
foreach condition in chronic_respiratory chronic_cvd chronic_arthosteo chronic_mental chronic_diabetes2 chronic_cancer {
    * Identify the first occurrence of each chronic condition
    bysort xwaveid (wave): gen first_`condition' = _n if `condition' == 1 & `condition'[_n-1] == 

    * Generate age at onset variable
    gen age_at_onset_`condition' = .
    replace age_at_onset_`condition' = age0 - 4 if first_`condition' != .
}


* Generate a single summary table for all age_at_onset variables including quartiles and IQR
asdoc sum age_at_onset_pooled age_at_onset_chronic_respiratory age_at_onset_chronic_cvd age_at_onset_chronic_arthosteo ///
      age_at_onset_chronic_mental age_at_onset_chronic_diabetes2 age_at_onset_chronic_cancer, ///
     stat(N mean median sd iqr p25 p50 p75 p99) label dec(1) save($output\summary_stats.doc) replace 




/*********************************************
LASSO Regressions
*********************************************/

*drop in vars only small amount of missing (note: proceeding row is residual of preceding)
drop if married ==9999 // 3 rows 
drop if indig ==9999 // 16 rows
drop if educ ==9999 // 32 rows
drop if rural ==9999 // 15 rows
drop if life_sat == // have to do this before 
drop if siblings ==9999 // 130 rows



/*drop the variables that have too many missing observations
1) mother education
2) father educ
*/

*age at onset OLS LASSO 

glo lags lag_married i.lag_educ i.lag_ehi_quart lag_rural lag_phi_2 lag_siblings lag_drinks lag_exercise lag_smoke2 lag_bmi lag_vegetables lag_fruits lag_eats_breakfast lag_stressf_jail lag_stressf_propertycrime lag_stressp_divorced lag_stressp_financial lag_stressp_jail lag_stressp_physicalv lag_stressw_firedredundant lag_stressw_job lag_stressw_job_ill lag_pers_agreeableness lag_pers_conscientiousness lag_pers_emotionalstability lag_pers_extroversion lag_pers_opentoexper lag_mental_health lag_pwd lag_checkup1_any lag_checkup2_any lag_loneliness lag_friends lag_volunteer lag_life_sat lag_neighbourhood_satisfaction lag_home_satisfaction lag_financial_satisfaction lag_partner_satisfaction lag_safety_satisfaction lag_parents_divorced


glo nonlags male indig cob_os cob_n_en moved_first father_paid mother_paid father_cob_os mother_cob_os

*CVD
lasso linear age_at_onset_chronic_cvd $lags $nonlags, selection (cv)

elasticnet linear age_at_onset_chronic_cvd $lags $nonlags, alpha(0.5) selection(cv)


lassocoef
lassoselect id = 14
	

	
Note1. we probably have an issue of multicolineariy
note2. we need to do the multiple imputation method
note3. we need to split the data into training and testing sets
note4. what do we do about weights?
note5. have to consider u-shaped relationship for some variables 

What to do:
(1) keep it with the mean and missing imputation method for now - also drop all vars that have only a little bit missing this is fine. 
(2) we need to decide what variables to include - this is tricky. We need things that are not determined by age - as age at onset is still an age variable. Thus, everyone that has age at onset a bit later for example will have certain characteristics that are associated with later age also. 
^ long story short, drop all vars with a strong theoretical link to age
(3) Once we have those age-independent covariates, do the lasso elastic net so that we disentangle effects and have all coefficients
(4) we need to potentially drop cancer (we dont know what cancer it is) and also arth/osteo as very weird. 
    Maybe we can link type-2 diabetes to cardiovascular disease and have "cardiovascular-related illness"
(5) 
	
	
	
****************
*cox proportional hazards model
****************
	
gen first_obs = wave if chronic_dummy == 1
bysort xwaveid (wave): replace first_obs = first_obs[_n-1] if missing(first_obs)
bysort xwaveid (wave): gen event = chronic_dummy == 1 & chronic_dummy[_n-1] == 0
bysort xwaveid (wave): replace event = 0 if wave > first_obs  // ignore repeats
	
	
gen age0 = age   // age at start of wave
gen age1 = age + 4  // approximate, assuming 4 years between waves

bysort xwaveid (wave): gen onset = chronic_dummy == 1 & chronic_dummy[_n-1] == 0
bysort xwaveid (wave): replace onset = 0 if onset[_n-1] == 1  // remove later ones
	
	
* Step 1: Sort data by person and time
sort xwaveid wave  // Replace 'wave' with your time variable if different

* Step 2: Create a flag if person's first obs is onset == 1
gen first_obs = (_n == 1)
bysort xwaveid (wave): replace first_obs = chronic_dummy if _n == 1
bys xwaveid: drop if first_obs ==1

*step 3
gen drop_id = .
bysort xwaveid (wave): replace drop_id = 1 if first_obs == 1 & _n == 1
bysort xwaveid (wave): egen tag_to_drop = max(drop_id)
drop if tag_to_drop == 1

* Step 4: For the rest, flag when the first onset happens
bysort xwaveid (wave): gen onset_seen = onset
bysort xwaveid (wave): replace onset_seen = sum(onset)

* Step 5: Set onset = 1 if onset_seen > 0
gen onset_adj = onset
replace onset_adj = 1 if onset_seen > 0

* Optional: Replace the original variable
replace onset = onset_adj
drop onset_adj onset_seen first_onset first_obs
	
	
*variable generation 
	
gen event = onset == 1

g year = wave +2000
gen t = year - 2009   // assuming your panel starts in 2009

stset t, id(xwaveid) failure(event)

stcox male age0 married 
vegetables fruits eats_breakfast exercise drinks friends loneliness volunteer pers_extroversion pers_agreeableness pers_conscientiousness pers_emotionalstability pers_opentoexper
	
	
gen onset = 0
bysort xwaveid (year): gen byte ever1 = 0
bysort xwaveid (year): replace onset = 1 if chronic_dummy == 1 & sum(chronic_dummy == 1 & !missing(chronic_dummy)) == 1
drop ever1

gen first_treat_year = .
bysort xwaveid (year): replace first_treat_year = year if onset == 1
bysort xwaveid (year): replace first_treat_year = first_treat_year[_n-1] if missing(first_treat_year)
gen event = year >= first_treat_year & !missing(first_treat_year)
	
	
sts graph, cumhaz by(age0) title("Cumulative Hazard by A")

*age version
stset age0, id(xwaveid) failure(event)
stcox male married vegetables fruits eats_breakfast exercise drinks friends loneliness volunteer pers_extroversion pers_agreeableness pers_conscientiousness pers_emotionalstability pers_opentoexper
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

*lasso logit have chronic

xtset xwaveid wave
bys xwaveid (year) egen mn_chronic = mean(chronic)

lasso logit chronic_dummy lag_male lag_exercise lag_smoke2 lag_drinks lag_loneliness lag_pers_extroversion lag_pers_agreeableness lag_pers_conscientiousness lag_pers_emotionalstability lag_pers_opentoexper lag_lf lag_married lag_sa_health ib1.lag_educ ib1.lag_ehi_quart lag_phi lag_cob_os lag_cob_n_en lag_mental_health lag_general_health lag_overall_health lag_life_sat lag_overweight lag_rural, selection(cv)


* Loop over all your variables to demean them
foreach var in state male age0 vegetables fruits eats_breakfast siblings exercise drinks friends stressp_injill ///
    stressf_familyinjill stressf_deathspousechild stressf_deathrelfam stressf_deathfriend stressf_propertycrime ///
    stressp_jail stressw_retired stressw_firedredundant volunteer pers_extroversion pers_conscientiousness ///
    pers_emotionalstability pers_opentoexper bmi lf married indig rural cob_os cob_n_en sa_health mental_health ///
    general_health overall_health spfunctioning life_sat health_satisfaction neighbourhood_satisfaction ///
    home_satisfaction financial_satisfaction safety_satisfaction english_proficiency stressp_financial ///
    stressp_divorced stressp_widowed educ hhchild ehi_quart pwd smoke2 {
    * Demean the variable by wave (xwaveid)
    bysort xwaveid: egen mn_`var' = mean(`var')
	gen dm_`var' = `var' - mn_`var'
}

* Run lasso logit with clustering of standard errors by individual (e.g., `xwaveid`)
* Run lasso logit (binary dependent variable) with clustering standard errors
// removed time invariant vars manually ( male siblings indig cob_os cob_n_en )

    lasso logit chronic_dummy dm_state dm_age0 dm_vegetables dm_fruits ///
    dm_eats_breakfast dm_exercise dm_drinks dm_friends dm_stressp_injill ///
    dm_stressf_familyinjill dm_stressf_deathspousechild dm_stressf_deathrelfam dm_stressf_deathfriend ///
    dm_stressf_propertycrime dm_stressp_jail dm_stressw_retired dm_stressw_firedredundant ///
    dm_volunteer dm_pers_extroversion dm_pers_conscientiousness dm_pers_emotionalstability ///
    dm_pers_opentoexper dm_bmi dm_lf dm_married  dm_rural  ///
     dm_sa_health dm_mental_health dm_general_health dm_overall_health ///
    dm_spfunctioning dm_life_sat dm_health_satisfaction dm_neighbourhood_satisfaction ///
    dm_home_satisfaction dm_financial_satisfaction dm_safety_satisfaction dm_english_proficiency ///
    dm_stressp_financial dm_stressp_divorced dm_stressp_widowed dm_educ dm_hhchild dm_ehi_quart ///
    dm_pwd dm_smoke2, cluster(xwaveid) selection(cv)

lasso logit chronic_dummy state age_group vegetables fruits ///
eats_breakfast exercise drinks friends stressp_injill ///
stressf_familyinjill stressf_deathspousechild stressf_deathrelfam stressf_deathfriend ///
stressf_propertycrime stressp_jail stressw_retired stressw_firedredundant ///
volunteer pers_extroversion pers_conscientiousness pers_emotionalstability ///
pers_opentoexper bmi lf married rural ///
sa_health mental_health general_health overall_health ///
spfunctioning life_sat health_satisfaction neighbourhood_satisfaction ///
home_satisfaction financial_satisfaction safety_satisfaction english_proficiency ///
stressp_financial stressp_divorced stressp_widowed educ hhchild ehi_quart ///
pwd smoke2, cluster(xwaveid) selection(cv) 























































/*********************************************
descriptives
*********************************************/

* pooled descriptives all waves

/*preserve
drop if chronic_dummy <0
replace male = male*100
replace married = married*100


 dtable i.age_group male married i.educ i.ehi_quart, ///
     continuous(male married, statistics(mean count)) /// 
     factor(age_group educ ehi_quart, statistics(fvpercent fvfrequency)) /// 
     by(chronic_dummy, nototals) ///
     title("Demographic characteristics of LGBT and Non-LGBT Respondents in 2001") ///
     nformat(%9.1f mean fvpercent) ///
     nformat(%9.2g count fvfrequency) ///
     sformat("(%s)" count fvfrequency) ///
     sformat("%s" fvpercent) ///  // Ensures percentages are NOT in parentheses
     export("$output\dstats.docx", as(docx) replace)

restore
*/

preserve
drop if weight<0
svyset [pweight=weight]
replace chronic_cvd =0 if chronic_cvd==-1
replace chronic_respiratory =0 if chronic_respiratory==-1
replace chronic_cancer =0 if chronic_cancer==-1
replace chronic_arthosteo =0 if chronic_arthosteo==-1
replace chronic_mental =0 if chronic_mental==-1
replace chronic_diabetes2 =0 if chronic_diabetes2==-1

drop if chronic_dummy <0
drop if chronic_cvd < 0 | chronic_respiratory < 0 | chronic_cancer < 0 | ///
        chronic_arthosteo < 0 | chronic_mental < 0 | chronic_diabetes2 < 0 
drop if exercise <0 | drinks <0 
drop if pers_extroversion <0 | pers_agreeableness <0 | pers_conscientiousness <0 | pers_emotionalstability <0 | pers_opentoexper <0
drop if loneliness <0 | friends <0

replace male = male*100
replace married = married*100

replace chronic_cvd = chronic_cvd*100
replace chronic_respiratory = chronic_respiratory*100
replace chronic_cancer = chronic_cancer*100
replace chronic_arthosteo = chronic_arthosteo*100
replace chronic_mental =  chronic_mental*100
replace chronic_diabetes2 = chronic_diabetes2*100

replace smoke = smoke*100
replace smoke2 = smoke2*100
replace smoke3 = smoke3*100 


gen wave_chronic = wave * 10 + chronic_dummy  // Unique values like 91 (wave 9, chronic 1)

dtable i.age_group male married i.educ i.ehi_quart ///
	 chronic_cvd chronic_respiratory chronic_cancer chronic_arthosteo chronic_mental chronic_diabetes2 ///
	 smoke smoke2 smoke3 drinks exercise ///
	 pers_extroversion pers_agreeableness pers_conscientiousness pers_emotionalstability pers_opentoexper /// 
	 loneliness friends, svy  ///
     continuous(male married  ///
	            chronic_cvd chronic_respiratory chronic_cancer chronic_arthosteo chronic_mental chronic_diabetes2 ///
				smoke smoke2 smoke3 drinks exercise ///
				pers_extroversion pers_agreeableness pers_conscientiousness pers_emotionalstability pers_opentoexper ///
				loneliness friends, ///
				statistics(mean sd)) /// 
     factor(age_group educ ehi_quart, statistics(fvpercent fvfrequency)) /// 
     by(wave_chronic, nototals) ///   // Use the combined variable
     title("Demographic characteristics of LGBT and Non-LGBT Respondents by Wave") ///
     nformat(%9.2f mean fvpercent) ///
     nformat(%9.2g count fvfrequency) ///
     sformat("(%s)" count fvfrequency) ///
     sformat("%s" fvpercent) ///  
     export("$output\dstats4.docx", as(docx) replace)

restore












































**********************************************************
* Age at onset of chronic condition descriptive statistics 
**********************************************************

*single chronic conditions 

 //  5000 unique individuals (so a couple are 1 1 1 1 for all 4 years and some also maybe only in dataset for 1 year for e.g.)

 foreach condition in chronic_cvd chronic_arthosteo chronic_diabetes2 chronic_cancer {
    * Replace -1 with 0 in the chronic condition variable
    replace `condition' = 0 if `condition' >0 & `condition' <1

    * Identify the first occurrence of each chronic condition
    bysort xwaveid (wave): gen first_`condition' = _n if `condition' == 1 & `condition'[_n-1] == 0

    * Generate age at onset variable
    gen age_at_onset_`condition' = .
    replace age_at_onset_`condition' = age0 if first_`condition' != .
	
	order xwaveid wave `condition' first_`condition' age_at_onset_`condition'
}

label var age_at_onset_chronic_cancer "Cancer"
label var age_at_onset_chronic_cvd "CVD"
label var age_at_onset_chronic_diabetes2 "Diabetes (Type 2)"
label var age_at_onset_chronic_arthosteo "Musculoskeletal"

* Step 1: Create histograms with smaller text and variable labels
foreach var in age_at_onset_chronic_cancer ///
               age_at_onset_chronic_diabetes2 ///
               age_at_onset_chronic_arthosteo ///
               age_at_onset_chronic_cvd {

    * Get sample size
    quietly count if !missing(`var')
    local n = r(N)

    * Get variable label
    local label : variable label `var'

    * Create histogram with smaller text
    histogram `var', frequency ///
        name(h_`var', replace) ///
        title("`label'", size(vsmall)) ///
        subtitle("N = `n'", size(tiny) position(11) ring(0)) ///
        ytitle("Frequency", size(tiny)) ///
        xtitle("Age at Onset", size(tiny)) ///
        xlabel(, labsize(tiny)) ///
        ylabel(, labsize(tiny))
}

* Step 2: Combine into a 2x3 layout and scale up graph area
graph combine h_age_at_onset_chronic_cancer ///
              h_age_at_onset_chronic_diabetes2 ///
              h_age_at_onset_chronic_arthosteo ///
              h_age_at_onset_chronic_cvd, ///
              cols(2) iscale(1.3)  


* pooled chronic conditions
bysort xwaveid (wave): gen first_chronic = _n if chronic_dummy==1 & chronic_dummy[_n-1]==0

gen age_at_onset = .
replace age_at_onset = age0 if first_chronic!=.

label var age_at_onset "Age at onset (pooled chronic conditions)"

-+order xwaveid wave age_at_onset first_chronic chronic_dummy











 * Generate a single summary table for all age_at_onset variables including quartiles and IQR
 
preserve
svyset xwaveid [pweight=weight_onset], strata(xwaveid)
asdoc svy: sum age_at_onset age_at_onset_chronic_respiratory age_at_onset_chronic_cvd age_at_onset_chronic_arthosteo ///
      age_at_onset_chronic_mental age_at_onset_chronic_diabetes2 age_at_onset_chronic_cancer [aw=weight],  ///
     stat(N mean median sd iqr p25 p50 p75 p99 min max) label dec(1) save($output\test1_onset.doc) replace 
restore

preserve
drop if weight<0
	 svy: mean age_at_onset_chronic_respiratory  // Check weighted mean
restore 
	 
	 
svyset xwaveid [pweight=weight]  // Set survey weights 
	 	 	 
			 
			 
			 
			 
			 
			 
			 
			 
			 
			 
			 
 
* Loop over chronic conditions
foreach condition in chronic_respiratory chronic_cvd chronic_arthosteo chronic_mental chronic_diabetes2 chronic_cancer {
    * Identify the first occurrence of each chronic condition
    bysort xwaveid (wave): gen first_`condition' = _n if `condition' == 1 & `condition'[_n-1] == 

    * Generate age at onset variable
    gen age_at_onset_`condition' = .
    replace age_at_onset_`condition' = age0 - 4 if first_`condition' != .
}



