#!/bin/bash
# Creates an R script that plots the stacked bar plot of filtered false negatives from the uniform distribution.
# (Fig. 2D in publication)

#
# The data for this plot is striped from the auto-generated R code that plots the filtered
# false negatives for each of the individual uniform dist. simulations across the
# first half of the allele frequency spectrum.
rscriptName=`echo $0 | sed 's/.bash//1'`

(printf '#!/usr/bin/Rscript\nlibrary(ggplot2)\n'
ls -d ../Sims/uniform_0.*| sort -n | while read line
do
b=`echo ${line} | sed -e 's/.*uniform_//1' -e 's/_/-/1'`

# Parse out frequency ranges in this band.
lowSampleAF=`echo ${b}| sed -e 's/-.*//1'`
highSampleAF=`echo ${b}| sed -e 's/.*-//1'`

# Convert from allele frequency in the haplotype to allele frequency in the sample
# ie., when both haplotypes are combined together.
lowSampleAF=`bc -l <<< "scale=2; ${lowSampleAF}/2"`
highSampleAF=`bc -l <<< "scale=2; ${highSampleAF}/2"`

# Pad if required
if [ "$lowSampleAF" == "0" ]; then
   lowSampleAF=".00"
fi

# Overwrite the band with the new value
band="0${lowSampleAF}-0${highSampleAF}"

# Print out the R source
echo "# somatic allele frequency band ${b}"
egrep '^value = |^  group =' ${line}/100x/SomaticVariantCallerOutput/plotGtPieChart.R | sed -e 's/.*://1' -e 's/^  group =/group =/1' -e 's/),$/)/1'
echo 'band = rep("'${band}'",length(value))'
if [[ "$b" =~ ^0.00-0 ]]; then
  echo "data = data.frame(band,group,value)"
else
  echo "data = rbind(data,data.frame(band,group,value))"  
fi
echo
done

printf 'library(RColorBrewer)\n'
printf '\n'
printf '# Stacked\n'
printf 'pdf(file = "output/%s.pdf", width = 15, height = 5)\n' ${rscriptName}

printf 'ggplot(data, aes(fill=group, y=value, x=band)) + \n'
printf '    geom_bar(position="stack", stat="identity") +\n'
printf '    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +\n'
printf '    scale_fill_manual(values = brewer.pal(n = 11, name = "Spectral")) +\n'
printf '    theme(panel.background = element_blank()) +\n'
printf '    xlab("Allele frequency band") +\n'
printf '    ylab("Number incorrectly filtered")\n'
printf 'dev.off()\n') > ${rscriptName}.R 

chmod u+x ${rscriptName}.R
mkdir output 2>/dev/null
./${rscriptName}.R
