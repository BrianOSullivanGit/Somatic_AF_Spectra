#!/usr/bin/Rscript

library(ggplot2)
# Function to bin data.
breaks=100
breakInterval=1/breaks
getbinnedVaf <- function(x,breaks=100)
{
  # Bin them.
  
  breakInterval=1/breaks
  xminBreaks=seq(0,1,breakInterval)
  
  res = hist(x, plot=FALSE, breaks=xminBreaks)
  
  return(res$counts)
}

# Ground truth NE plot truncated at 200 on x-axis.

# Adjust from frequency in the haplotype (divide by 2).
x = unlist(read.table(pipe("awk '{print $4/2}' ../SomaticAlleleSpectra/output/*neutral_8.51.spike")))
gtFreqs=getbinnedVaf(x,breaks)

# Truncate when printing the GT plot as we want to keep it on the same scale as the sims.
gtFreqs[gtFreqs>200]=200

pdf(file = "output/neutral_fig3.pdf",
    width = 7,
    height = 5)
    
print(ggplot(NULL, aes(xmin=seq(0,1-breakInterval,breakInterval), xmax=seq(breakInterval,1,breakInterval), ymin=0, ymax=gtFreqs)) +
     geom_rect(size=0.5, alpha=1, colour="black", fill='#DDDEDC') +
     theme(panel.background = element_blank()) + 
     labs(title = "Ground truth, clonal point mass with neutral evolutionary model,\n truncated at 200 on x-axis.") +
     xlab("Variant Allele Frequency") +
     ylab("Number of variants") +
     xlim(c(0,1)) + ylim(c(0,200)))

# Now sim plots.
unixCmd="zcat ../Sims/neutral_8.51/100x/SomaticVariantCallerOutput/HG00110.ucsc_coding_exons_hg38_100x_76bp_spiked.realn.phased.rg.filtered.vcf.gz | egrep -v '^#' | awk '{if($4 ~ /^[GCAT]$/ && $5 ~ /^[GCAT]$/ && $7==\"PASS\") {split($9,format,\":\");split($11,formatContentsTumour,\":\"); for(i in format) {formatAttributesTumour[format[i]]=formatContentsTumour[i]}; print formatAttributesTumour[\"AF\"]} }'"
     
sims=c("100x", "200x", "350x", "600x")
     
for(depth in sims) {
x = unlist(read.table(pipe(gsub("100x", depth, unixCmd))))
    
print(ggplot(NULL, aes(xmin=seq(0,1-breakInterval,breakInterval), xmax=seq(breakInterval,1,breakInterval), ymin=0, ymax=getbinnedVaf(x,breaks))) +
     geom_rect(size=0.5, alpha=1, colour="black", fill='#96C88A') +
     theme(panel.background = element_blank()) + 
     labs(title = paste(depth,"clonal point mass with neutral evolutionary model\nTumour purity=100%")) +
     xlab("Variant Allele Frequency") +
     ylab("Number of variants") +
     xlim(c(0,1)) + ylim(c(0,200)))     
}

dev.off()
