# elvik-corrected-meta-analysis-reproduce.R
# Created 30 Dec 2012, updated 7 March 2013. Copyright Tim Churches, Sydney, Australia.
# Licensed under the terms of the 
# Creative Commons Attribution-ShareAlike 3.0 Australia license 
# (see http://http://creativecommons.org/licenses/by-sa/3.0/au/ ).

# This code attempts to reproduce the fixed-effects and random-effects pooled estimates as they
# are given in Table 4 of:
# Rune Elvik, Corrigendum to: “Publication bias and time-trend bias in meta-analysis of bicycle 
# helmet efficacy: A re-analysis of Attewell, Glase and McFadden, 2001” [Accid. Anal. Prev. 43 (2011) 1245–1251],
# Accident Analysis & Prevention, Available online 23 December 2012, ISSN 0001-4575, 10.1016/j.aap.2012.12.003.
# ( http://www.sciencedirect.com/science/article/pii/S0001457512004253 )

# The original meta-anlaysis by Attewell et al. which Elvik attempts to update is as follows:
# R.G. Attewell, K. Glase, M. McFadden, Bicycle helmet efficacy: a meta-analysis, 
# Accident Analysis & Prevention, Volume 33, Issue 3, May 2001, Pages 345-352, ISSN 0001-4575,
# 10.1016/S0001-4575(00)00048-8. ( http://www.sciencedirect.com/science/article/pii/S0001457500000488 )

# Most of the data used in this analysis reproduction were abstracted from the monograph for the Attewell et al. 
# meta-analysis:
# Attewell, R.; Glase, K., McFadden, M. (2000). Bicycle Helmets and Injury Prevention: A formal review.
# Canberra, Australia: Australian Transport Safety Bureau. ISBN 0 642 25514 8. 
# ( http://www.infrastructure.gov.au/roads/safety/publications/2000/pdf/Bic_Crash_5.pdf )
# (Continuity corrections as used by Elvik have been added to the data, as noted below.)

# Results for the "new" studies usd in the Elvik meta-analysis were abstracted directly from the relevant papers,
# with the exception of Hausotter 2000, which is a secondary reference to an (apparently) unpublished study by 
# Hannover Medical School. Only an electronic copy of the Hausotter article could be obtained, and that did not include 
# the numerical results of the Hannover study. Therefore for this study, the contingency table counts which appeared 
# in a spreadsheet provided to me by Professor Elvik were used.

# We need a function from the metafor package to conveniently convert from contingency table counts to ORs and SEs.
require(metafor)
# But the actual meta-analysis we'll do with the meta package.
require(meta)

# The data are on GitHub, so we'll need to fetch it from there via curl
require(RCurl)

# Read in data from the Attewell et al. 2001 meta-analysis, the counts taken from the appendix
# in the Attewell report, with the addition of counts from two of the four "new" studies
# included in the Elvik meta-analysis. Note that continuity corrections as used by Elvik
# have been added to the counts in several of these studies. These continuity corrections
# were extracted from a spreadsheet which ws supplied by Professor Elvik and which contained the
# data used in the Elvik meta-analysis.
studies <- read.csv(textConnection(getURL("https://raw.github.com/timchurches/meta-analyses/master/Attewell_et_al_and_Elvik.csv")),header=T)

# Contingency table counts are not available (from the published papers) for two of the "new"
# studies used in the Elvik meta-analysis. Therefore we read in the summary results (OR estimate
# and published 95% confidence intervals) for these studies and estimate variance from those.
HA <- read.csv(textConnection(getURL("https://raw.github.com/timchurches/meta-analyses/master/Elvik_Hansen_Amoros_ORs.csv")),header=T)
HA$vi <- (((log(HA$UL95)-log(HA$LL95))/3.92))^2
HA$yi <- log(HA$OR)

# Calculate contingency table marginal totals
studies$obs.helmet <- studies$cases.helmet + studies$controls.helmet
studies$obs.no.helmet <- studies$cases.no.helmet + studies$controls.no.helmet

# Calculate ORs and variance using the escalc() function from the metafor package, and add these columns to main studies
# table
studies <- cbind(studies,escalc(measure='OR',ai=cases.helmet,bi=cases.no.helmet,ci=controls.helmet,di=controls.no.helmet,data=studies))

# Add the rows for the Hansen and Amoros new studies to the main data table
studies <- merge(studies,HA,all=T)

# Calculate SE
studies$sei <- studies$vi^0.5

# Display source data as a check
studies

# Read the results for fixed-effects and random-effects summary estimates as they appear in table 4 of the published
# 2012 corrigendum to the Elvik meta-analysis, for comparison with the results obtained from this reproduction of the 
# Elvik meta-analysis.
elvik.results <- read.csv(textConnection(getURL("https://raw.github.com/timchurches/meta-analyses/master/Elvik-meta-analysis-corrigendum-table4-results.csv")),header=T)

# Create subsets for each of the groups of studies in the Elvik meta-analysis
studies.head.old <- studies[which(studies$injury.type=="head" & studies$meta.analysis == 'A'),]
studies.head.new <- studies[which(studies$injury.type=="head" & studies$meta.analysis == 'E'),]
studies.head.all <- studies[which(studies$injury.type=="head" & studies$meta.analysis %in% c('A','E')),]
studies.brain.old <- studies[which(studies$injury.type=="brain" & studies$meta.analysis == 'A'),]
studies.face.old <- studies[which(studies$injury.type=="face" & studies$meta.analysis == 'A'),]
studies.face.new <- studies[which(studies$injury.type=="face" & studies$meta.analysis == 'E'),]
studies.face.all <- studies[which(studies$injury.type=="face" & studies$meta.analysis %in% c('A','E')),]
studies.neck.old <- studies[which(studies$injury.type=="neck" & studies$meta.analysis == 'A'),]
studies.neck.new <- studies[which(studies$injury.type=="neck" & studies$meta.analysis == 'E'),]
studies.neck.all <- studies[which(studies$injury.type=="neck" & studies$meta.analysis %in% c('A','E')),]
studies.fatal.old <- studies[which(studies$injury.type=="fatal" & studies$meta.analysis == 'A'),]
studies.hfn.old <- studies[which(studies$injury.type %in% c("head","face","neck") & studies$meta.analysis == 'A'),]
studies.hfn.new <- studies[which(studies$injury.type %in% c("head","face","neck") & studies$meta.analysis == 'E'),]
studies.hfn.all <- studies[which(studies$injury.type %in% c("head","face","neck") & studies$meta.analysis %in% c('A','E')),]

# Now calculate and display summary estimates for each group of studies as per Elvik 2012 corrigendum table 4
# Note that metagen() uses DerSimonian-Laird pooling as default, and we specify rank method (as Elvik used) as the bias 
# detection algorithm

subset.meta <- function(dfsubset,injury.type,studies.included) {
  ma <- metagen(TE=yi,seTE=sei,studlab=study.label,data=dfsubset,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")
  subset.ma.results <- data.frame(source="reprod", injury.type=injury.type, studies.included=studies.included, num.studies=ma$k, FE.OR=exp(ma$TE.fixed), 
                        FE.LL95=exp(ma$lower.fixed), FE.UL95=exp(ma$upper.fixed), RE.OR=exp(ma$TE.random), RE.LL95=exp(ma$lower.random), 
                        RE.UL95=exp(ma$upper.random))
  elvik.results <- rbind(elvik.results,subset.ma.results)
  summary(ma)
}

subset.meta(head.old.meta,"head","Attewell")

head.old.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.head.old,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")
head.new.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.head.new,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")
head.all.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.head.all,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")

summary(head.old.meta)
summary(head.new.meta)
summary(head.all.meta)

brain.old.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.brain.old,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")

summary(brain.old.meta)

face.old.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.face.old,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")
face.new.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.face.new,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")
face.all.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.face.all,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")

summary(face.old.meta)
summary(face.new.meta)
summary(face.all.meta)

neck.old.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.neck.old,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")
neck.new.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.neck.new,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")
neck.all.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.neck.all,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")

summary(neck.old.meta)
summary(neck.new.meta)
summary(neck.all.meta)

fatal.old.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.fatal.old,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")

summary(fatal.old.meta)

hfn.old.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.hfn.old,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")
hfn.new.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.hfn.new,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")
hfn.all.meta <- metagen(TE=yi,seTE=sei,studlab=study.label,data=studies.hfn.all,method.bias="rank",label.e="Injured",label.c="Not injured",sm="OR")

summary(hfn.old.meta)
summary(hfn.new.meta)
summary(hfn.all.meta)

# Finally calculate trimmed-and-filled results for head, face and neck just as an illustration of 
# the magnitude of the calculation errors in the Elvik corrigendum.
# Note that from a statistical point-of-view, application of the Duval-and-Tweedie trim-and-fill method
# to pooled results for different outcomes, when each of those outcomes has its own quite different mean
# effect (helmets are very protective for heads, somewhat protective for faces, not protective for necks)
# is just plain wrong. The Duval-and-Tweedie method is based on the assumption that all published studies
# come from just one underlying distribution of estimates, not multiple distributions each with its own mean and variance!

hfn.all.tf <- trimfill(hfn.all.meta)
summary(hfn.all.tf)
