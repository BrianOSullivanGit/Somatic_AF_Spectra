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


# Shell commands to parse out the ground truth read fractions from point mass simulation (VCFs) results.
# Note: We assume >= Mutect2, GATK 4 in ordering of tumour and normal format fields in the VCF.
# This means we expect the tumour sample in fiels 11 (after the normal in field 10).
# If you are using VCFs from earlier GATK versions or other callers you may have to adjust this
# depending on which field they put the tumour in.

OneHundredXvcfAlleleFrequenciesParseCommand="zcat ../Sims/pm_0.035/100x/SomaticVariantCallerOutput/HG00110.ucsc_coding_exons_hg38_*x_76bp_spiked.realn.phased.rg.filtered.vcf.gz | egrep -v '^#' | awk '{if($7==\"PASS\" && $4 ~ /^[GCAT]$/ && $5 ~ /^[GCAT]$/) {split($9,format,\":\");split($11,formatContentsTumour,\":\"); for(i in format){formatAttributesTumour[format[i]]=formatContentsTumour[i]}; print formatAttributesTumour[\"AF\"]} }'"

TwoHundredXvcfAlleleFrequenciesParseCommand="zcat ../Sims/pm_0.035/200x/SomaticVariantCallerOutput/HG00110.ucsc_coding_exons_hg38_*x_76bp_spiked.realn.phased.rg.filtered.vcf.gz | egrep -v '^#' | awk '{if($7==\"PASS\" && $4 ~ /^[GCAT]$/ && $5 ~ /^[GCAT]$/) {split($9,format,\":\");split($11,formatContentsTumour,\":\"); for(i in format){formatAttributesTumour[format[i]]=formatContentsTumour[i]}; print formatAttributesTumour[\"AF\"]} }'"

ThreeHundredAndFiftyXvcfAlleleFrequenciesParseCommand="zcat ../Sims/pm_0.035/350x/SomaticVariantCallerOutput/HG00110.ucsc_coding_exons_hg38_*x_76bp_spiked.realn.phased.rg.filtered.vcf.gz | egrep -v '^#' | awk '{if($7==\"PASS\" && $4 ~ /^[GCAT]$/ && $5 ~ /^[GCAT]$/) {split($9,format,\":\");split($11,formatContentsTumour,\":\"); for(i in format){formatAttributesTumour[format[i]]=formatContentsTumour[i]}; print formatAttributesTumour[\"AF\"]} }'"

SixHundredXvcfAlleleFrequenciesParseCommand="zcat ../Sims/pm_0.035/600x/SomaticVariantCallerOutput/HG00110.ucsc_coding_exons_hg38_*x_76bp_spiked.realn.phased.rg.filtered.vcf.gz | egrep -v '^#' | awk '{if($7==\"PASS\" && $4 ~ /^[GCAT]$/ && $5 ~ /^[GCAT]$/) {split($9,format,\":\");split($11,formatContentsTumour,\":\"); for(i in format){formatAttributesTumour[format[i]]=formatContentsTumour[i]}; print formatAttributesTumour[\"AF\"]} }'"

pdata=c()
tdata=c()


# 600x first
x = unlist(read.table(pipe(SixHundredXvcfAlleleFrequenciesParseCommand)))
tdata=data.frame(freq=getbinnedVaf(x,breaks),depth="600x",
xmin=seq(0,1-breakInterval,breakInterval),
xmax=seq(breakInterval,1,breakInterval),
ymin=0)

pdata=tdata

x = unlist(read.table(pipe(ThreeHundredAndFiftyXvcfAlleleFrequenciesParseCommand)))
tdata=data.frame(freq=getbinnedVaf(x,breaks),depth="350x",
xmin=seq(0,1-breakInterval,breakInterval),
xmax=seq(breakInterval,1,breakInterval),
ymin=0)

pdata=rbind(pdata,tdata)

x = unlist(read.table(pipe(TwoHundredXvcfAlleleFrequenciesParseCommand)))
tdata=data.frame(freq=getbinnedVaf(x,breaks),depth="200x",
xmin=seq(0,1-breakInterval,breakInterval),
xmax=seq(breakInterval,1,breakInterval),
ymin=0)

pdata=rbind(pdata,tdata)

x = unlist(read.table(pipe(OneHundredXvcfAlleleFrequenciesParseCommand)))
tdata=data.frame(freq=getbinnedVaf(x,breaks),depth="100x",
xmin=seq(0,1-breakInterval,breakInterval),
xmax=seq(breakInterval,1,breakInterval),
ymin=0)

pdata=rbind(pdata,tdata)

unsmoothedPlotSto=ggplot(pdata, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=freq,fill=depth)) +
    geom_rect(size=0.5, alpha=0.8) + theme(panel.background = element_blank()) +
    xlim(c(0,.15))

# Print unsmoothed version.   
pdf(file = "output/pm_fig4A_not_smoothedSuppFig1.pdf",
    width = 5,
    height = 5)
    
unsmoothedPlotSto + theme_classic()
dev.off()
    
# Smooth it
for(i in levels(pdata$depth))
{
# Also neat with df=90
smoothspline = smooth.spline(x=pdata[pdata$depth==i,"xmax"],y=pdata[pdata$depth==i,"freq"],df = 70) #fitting 
fit = predict(smoothspline, pdata[pdata$depth==i,"xmax"])$y #prediction on test data set

# Iron out any smoothing artefacts.
fit[c(1:min(which(fit<0)))]=0
fit[fit<0]=0

# Replace with fitted values.
pdata[pdata$depth==i,"freq"]=fit
}

smoothedPlotSto=ggplot(pdata, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=freq,fill=depth)) +
    geom_rect(size=0.5, alpha=0.8) + theme(panel.background = element_blank()) +
    xlim(c(0,.15))  + ylim(c(0,300))
    
# Smoothed plus intercept.
s2=smoothedPlotSto + geom_vline(xintercept = 0.035, color = "blue", size=.5) + theme(axis.text = element_text(size = 13))
#s2 + theme(legend.position = "none")
  

pdf(file = "output/pm_fig4A_smoothed.pdf",
    width = 5,
    height = 5)
    
s2 + theme_classic()
dev.off()
