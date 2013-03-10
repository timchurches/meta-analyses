/* elvik_meta_analysis_corrigendum_check.do
   Prepared by Tim Churches, January 2013
   Replicates corrigendum for Elvik meta-analysis of bicycle helmets, Accident Analysis &
   Prevention 2012. */ 
insheet using "Elvik_meta-analysis_data.csv", comma clear

metan yi sei if injury_type == "head" & (meta_analysis == "A"), eform fixedi nograph
metan yi sei if injury_type == "head" & (meta_analysis == "A"), eform randomi nograph
metan yi sei if injury_type == "head" & (meta_analysis == "E"), eform fixedi nograph
metan yi sei if injury_type == "head" & (meta_analysis == "E"), eform randomi nograph
metan yi sei if injury_type == "head" & (meta_analysis == "A" | meta_analysis == "E"), eform fixedi nograph
metan yi sei if injury_type == "head" & (meta_analysis == "A" | meta_analysis == "E"), eform randomi nograph

metan yi sei if injury_type == "face" & (meta_analysis == "A"), eform fixedi nograph
metan yi sei if injury_type == "face" & (meta_analysis == "A"), eform randomi nograph
metan yi sei if injury_type == "face" & (meta_analysis == "E"), eform fixedi nograph
metan yi sei if injury_type == "face" & (meta_analysis == "E"), eform randomi nograph
metan yi sei if injury_type == "face" & (meta_analysis == "A" | meta_analysis == "E"), eform fixedi nograph
metan yi sei if injury_type == "face" & (meta_analysis == "A" | meta_analysis == "E"), eform randomi nograph

metan yi sei if injury_type == "neck" & (meta_analysis == "A"), eform fixedi nograph
metan yi sei if injury_type == "neck" & (meta_analysis == "A"), eform randomi nograph
metan yi sei if injury_type == "neck" & (meta_analysis == "E"), eform fixedi nograph
metan yi sei if injury_type == "neck" & (meta_analysis == "E"), eform randomi nograph
metan yi sei if injury_type == "neck" & (meta_analysis == "A" | meta_analysis == "E"), eform fixedi nograph
metan yi sei if injury_type == "neck" & (meta_analysis == "A" | meta_analysis == "E"), eform randomi nograph

metan yi sei if (injury_type == "head" | injury_type == "face" | injury_type == "neck") & (meta_analysis == "A"), eform fixedi nograph
metan yi sei if (injury_type == "head" | injury_type == "face" | injury_type == "neck") & (meta_analysis == "A"), eform randomi nograph
metan yi sei if (injury_type == "head" | injury_type == "face" | injury_type == "neck") & (meta_analysis == "E"), eform fixedi nograph
metan yi sei if (injury_type == "head" | injury_type == "face" | injury_type == "neck") & (meta_analysis == "E"), eform randomi nograph
metan yi sei if (injury_type == "head" | injury_type == "face" | injury_type == "neck") & (meta_analysis == "A" | meta_analysis == "E"), eform fixedi nograph
metan yi sei if (injury_type == "head" | injury_type == "face" | injury_type == "neck") & (meta_analysis == "A" | meta_analysis == "E"), eform randomi nograph
