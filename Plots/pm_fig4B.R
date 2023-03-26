#!/usr/bin/Rscript
library(ggplot2)


# Function to bin data.
breaks=1000
breakInterval=1/breaks
getbinnedVaf <- function(observedAfs,breaks=100)
{
  # Bin them.
  
  breakInterval=1/breaks
  xminBreaks=seq(0,1,breakInterval)
  
  res = hist(observedAfs, plot=FALSE, breaks=xminBreaks)
  
  return(res$counts)
}


# Shell commands to parse out the ground truth read fractions from the 100x point mass simulation results.
gtReadFractionParseCommand="cat ../Sims/pm_0.035/100x/T_X[12]_HG00110.ucsc_coding_exons_hg38_*x_76bp.truth.vcf|awk '{ if($7==\"PASS\" || $7 ~/MASKED/) {dp=$8;sub(\"^DP=\",\"\",dp);sub(\";.*\",\"\",dp);split($10,ad,\",\");print (ad[2]/dp)/2} }'"

# Shell commands to parse out the ground truth read fractions from the 100x point mass simulation VCF output.
vcfAlleleFrequenciesParseCommand="zcat ../Sims/pm_0.035/100x/SomaticVariantCallerOutput/HG00110.ucsc_coding_exons_hg38_100x_76bp_spiked.realn.phased.rg.filtered.vcf.gz | egrep -v '^#' | awk '{if($7==\"PASS\" && $4 ~ /^[GCAT]$/ && $5 ~ /^[GCAT]$/) {split($9,format,\":\");split($11,formatContentsTumour,\":\"); for(i in format){formatAttributesTumour[format[i]]=formatContentsTumour[i]}; print formatAttributesTumour[\"AF\"]} }'"


pdata=c()
tdata=c()


# Read fractions first
x = unlist(read.table(pipe(gtReadFractionParseCommand)))

tdata=data.frame(freq=getbinnedVaf(x,breaks),type="GT Read Fractions",
                 xmin=seq(0,1-breakInterval,breakInterval),
                 xmax=seq(breakInterval,1,breakInterval),
                 ymin=0)



pdata=tdata

x = unlist(read.table(pipe(vcfAlleleFrequenciesParseCommand)))
tdata=data.frame(freq=getbinnedVaf(x,breaks),type="Called by Mutect",
                 xmin=seq(0,1-breakInterval,breakInterval),
                 xmax=seq(breakInterval,1,breakInterval),
                 ymin=0)

pdata=rbind(pdata,tdata)


# Smooth it
for(i in levels(pdata$type))
{
  smoothspline = smooth.spline(x=pdata[pdata$type==i,"xmax"],y=pdata[pdata$type==i,"freq"],df = 70) #fitting 
  fit = predict(smoothspline, pdata[pdata$type==i,"xmax"])$y #prediction on test data set
  fit[fit<0]=0
  pdata[pdata$type==i,"freq"]=fit
}

smoothedGtPlot=ggplot(pdata, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=freq,fill=type)) +
  geom_rect(size=0.5, alpha=1) + theme(panel.background = element_blank()) + 
  xlab("Variant Allele Frequency") +
  ylab("Number of variants") +
  xlim(c(0,.15)) + ylim(c(0,300)) +
  scale_fill_manual(values = c('#96C88A','#8F8FDA')) +
  geom_vline(xintercept = 0.035, color = "blue", size=.5)

pdf(file = "./output/pm_fig4B.pdf",
    width = 10,
    height = 5)

smoothedGtPlot
dev.off()
