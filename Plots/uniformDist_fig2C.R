#!/usr/bin/Rscript
library(ggplot2)

# Set up the 100x caller detection matrix from these 100x uniform simulations.
aa=read.table("output/100xDetectionMatrix.txt", header = FALSE, sep = '\t')
dm=matrix(as.double(unlist(aa)), ncol = 200, byrow = TRUE)
# 10000 was the number of somatic variants used in setting up each semi-centile in the caller matrix.
# so normalise by this amount to express in terms of burden fraction.
dm=dm/10000

# Just print a simple call probability plot for now.. To do this we sum to columns to get the total probability
# of a true somatic variant in the semi-centile being called (regardless of how the caller
# annotates its allele frequency after it is called)
p=ggplot(NULL, aes(x=1:200/200, y = colSums(dm))) + geom_point() + theme(panel.background = element_blank()) +
    xlab("ground truth allele frequency") + ylab("call probability")  + ylim(c(0,1)) + xlim(c(0,0.5))

pdf(file = "./output/uniformDist_fig2C.pdf",
    width = 7,
    height = 8)
    
p + theme(legend.position = "none") + theme(axis.text = element_text(size = 15)) 
dev.off()
