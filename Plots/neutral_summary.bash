#!/bin/bash

printf "Depth\tnumCalled\tnumFPs\tnumMutsInSample\tDetectionRate\tZeroAltCoverRate\tDetectedBurden>0.05\tTMB(75.8MBtarget)\n"

ls -d ../Sims/neutral_8.51/*x | sed 's/.*\///1' | while read line
do

numFPs=`awk 'BEGIN{numFps=0}{ if($3 != "PASS") next; if ($6 == "PASS" || $6 ~ /MASK/) next; if ($10 == "PASS" || $10 ~ /MASK/) next; numFps++; }END{print numFps}' ../Sims/neutral_8.51/${line}/SomaticVariantCallerOutput/gtMapper.hap.ref`

numCalled=`zcat ../Sims/neutral_8.51/${line}/SomaticVariantCallerOutput/HG00110.ucsc_coding_exons_hg38*.filtered.vcf.gz | awk 'BEGIN{numCall=0}{ if($7 == "PASS") numCall++; }END{print numCall}'`

# True number of somatic mutations in sample.
numPsInSample=`cat ../SomaticAlleleSpectra/output/*neut*.spike|wc -l`


numNoAltCover=`awk 'BEGIN{noAltCov=0}{ if($7 != "NO_COVERAGE" && $7 != "UNDETECTED") next; noAltCov++; }END{print noAltCov}' ../Sims/neutral_8.51/${line}/T_*_HG00110.ucsc_coding_exons_hg38_*.truth.vcf`

burden=`zcat ../Sims/neutral_8.51/${line}/SomaticVariantCallerOutput/HG00110.ucsc_coding_exons_hg38*.filtered.vcf.gz | egrep -v '^#' | awk 'BEGIN{burdenCount=0}{if($7=="PASS" && $4 ~ /^[GCAT]$/ && $5 ~ /^[GCAT]$/) {split($9,format,":");split($11,formatContentsTumour,":"); for(i in format){formatAttributesTumour[format[i]]=formatContentsTumour[i]}; if(formatAttributesTumour["AF"] >= 0.05) burdenCount++} }END{print burdenCount}'`

# Print out summary.
# Detection rate is number of true positives called divided by the total number of true positives in the sample.
# printf "%s\t%s\t%s\t%s\n" ${line} ${numCalled} ${numFPs} ${numPsInSample} ${numNoAltCover} | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"($2-$3)/$4; if($4 != 0) { print "\t"$5/$4 } else { print "\t"0 } }'

printf "%s\t%s\t%s\t%s\t%s\t%s\n" ${line} ${numCalled} ${numFPs} ${numPsInSample} ${numNoAltCover} ${burden}| awk '{print $1"\t"$2"\t"$3"\t"$4"\t"(($2-$3)/$4)"\t"($5/$4)"\t"$6"\t"($6/75.8)}'


done
