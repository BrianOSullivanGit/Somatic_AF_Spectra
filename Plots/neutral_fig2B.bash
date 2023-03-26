#!/bin/bash

( printf '#!/usr/bin/Rscript\nlibrary(ggplot2)\n
value = c()
group = c()
band = c()
data <- data.frame(band,group,value)\n\n'; \
ls  ../Sims/neutral_*/*0x/SomaticVariantCallerOutput/plotGtPieChart.R | while read line
do

 depth=`echo ${line} | sed -e 's/.*neutral_.*[0-9]\///1' -e 's/\/.*//1'`
 echo
 echo "# ${depth}"
 egrep 'group = c\(|value = c\(' ${line} | sed -e 's/^[ ][ ]*//1' -e 's/),/)/1'
 echo 'band = rep("'${depth}'",length(value))'
 echo 'data <- rbind(data,data.frame(band,group,value))'
 echo
done; \

printf '
library(RColorBrewer)
myPal=brewer.pal(n = 9, name = "GnBu")[c(-3,-8)]
myPal[1]="#449977"

pdf(file = "./output/neutral_fig2B.pdf",
    width = 5,
    height = 5)

ggplot(data, aes(fill=group, y=value, x=band)) + 
    geom_bar(position="stack", stat="identity") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    scale_fill_manual(values = myPal) +
    theme(panel.background = element_blank()) +
    xlab("Depth of coverage") +
    ylab("Number filtered")

dev.off()\n' ) > neutral_fig2B.R

chmod u+x neutral_fig2B.R
./neutral_fig2B.R
