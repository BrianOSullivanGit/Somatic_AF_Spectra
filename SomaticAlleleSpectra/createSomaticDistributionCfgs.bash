#!/bin/bash

# First create the set of frequencies for the required distribution.
# This step required that R is installed & the interpreter (Rscript) located under /usr/bin/Rscript.
# See https://cran.r-project.org/doc/manuals/r-release/R-admin.html
#
# In some cases R may only be installed on the head node.
# In that case you will need to run createSomaticDistributionCfgs.R there to create the
# frequency distributions first before running this script.
#  
# Call the set of R scripts for this simulation set.
printf "Creating required somatic allele frequency spectra...."

./createSomaticDistributionCfgs.R
printf "done.\n"

# Now generate the list of random target loci

# Haplotype 1
ls output/h1_*_freqs.txt | while read line
 do
  prefix=`echo $line| sed 's/_freqs.txt//1'`
  burden=`wc -l ${line}|sed 's/ .*//1'`
  printf "Generating %d random target SNVs in %s...." ${burden} ${prefix}
  zcat ../Reference/X1_HG00110_ucsc_coding_exons_hg38.merged.bed.gz | awk '{ i=$2; while(i!=$3) {print $1"\t"i+1"\t.";i++} }' | shuf -n ${burden}  > ${prefix}_loci.txt
  printf "done.\n"
done

# Combine these two files together into the required spike in configuration files.
ls output/h1_*_freqs.txt |  while read line
 do
  prefix=`echo $line| sed 's/_freqs.txt//1'`
  printf "Creating spike-in config for %s...." ${prefix}
  paste ${prefix}"_loci.txt" ${prefix}"_freqs.txt" > ${prefix}".unsorted.spike"
  # Sort it
  cat ${prefix}".unsorted.spike"| egrep '^chr[0-9]'| sort -k1.4,1.5n -k2,2n > ${prefix}".spike"
  cat ${prefix}".unsorted.spike"| egrep -v '^chr[0-9]'| sort -k1.4,1.5 -k2,2n >> ${prefix}".spike"
  # Clean up redundant files.
  rm ${prefix}"_loci.txt" ${prefix}"_freqs.txt" ${prefix}".unsorted.spike"
  printf "done.\n"
done

# Now Haplotype 2
ls output/h2_*_freqs.txt | while read line
 do
  prefix=`echo $line| sed 's/_freqs.txt//1'`
  burden=`wc -l ${line}|sed 's/ .*//1'`
  printf "Generating %d random target SNVs in %s...." ${burden} ${prefix}
  zcat ../Reference/X2_HG00110_ucsc_coding_exons_hg38.merged.bed.gz | awk '{ i=$2; while(i!=$3) {print $1"\t"i+1"\t.";i++} }' | shuf -n ${burden}  > ${prefix}_loci.txt
  printf "done.\n"
done

# Combine these two files together into the required spike in configuration files.
ls output/h2_*_freqs.txt |  while read line
 do
  prefix=`echo $line| sed 's/_freqs.txt//1'`
  printf "Creating spike-in config for %s...." ${prefix}
  paste ${prefix}"_loci.txt" ${prefix}"_freqs.txt" > ${prefix}".unsorted.spike"
  # Sort it
  cat ${prefix}".unsorted.spike"| egrep '^chr[0-9]'| sort -k1.4,1.5n -k2,2n > ${prefix}".spike"
  cat ${prefix}".unsorted.spike"| egrep -v '^chr[0-9]'| sort -k1.4,1.5 -k2,2n >> ${prefix}".spike"
  # Clean up redundant files.
  rm ${prefix}"_loci.txt" ${prefix}"_freqs.txt" ${prefix}".unsorted.spike"
  printf "done.\n"
done




