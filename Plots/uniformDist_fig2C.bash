#!/bin/bash

mkdir tmpDmEntries.$$
cd tmpDmEntries.$$

ls -d ../../Sims/uniform_* | sed -e 's/.*uniform_//1' -e 's/_/ /1'| \
while read line
do inpt=($line)
#echo ${inpt[0]}
cat ../../Sims/uniform_${inpt[0]}_${inpt[1]}/100x/SomaticVariantCallerOutput/gtMapper.hap.ref | awk -v a=${inpt[0]} -v b=0.01 -f ../detectionMatrixBin.awk
a=`bc -l <<< "scale=2; ${inpt[0]} + 0.01"`
cat ../../Sims/uniform_${inpt[0]}_${inpt[1]}/100x/SomaticVariantCallerOutput/gtMapper.hap.ref | awk -v a=${a} -v b=0.01 -f ../detectionMatrixBin.awk
a=`bc -l <<< "scale=2; ${inpt[0]} + 0.02"`
cat ../../Sims/uniform_${inpt[0]}_${inpt[1]}/100x/SomaticVariantCallerOutput/gtMapper.hap.ref | awk -v a=${a} -v b=0.01 -f ../detectionMatrixBin.awk
a=`bc -l <<< "scale=2; ${inpt[0]} + 0.03"`
cat ../../Sims/uniform_${inpt[0]}_${inpt[1]}/100x/SomaticVariantCallerOutput/gtMapper.hap.ref | awk -v a=${a} -v b=0.01 -f ../detectionMatrixBin.awk
done

# Compile the detection matrix.
ls *_DM_entry.txt | sort -n| while read line; do cat ${line}; done > ../output/100xDetectionMatrix.txt

cd ../
rm -fr tmpDmEntries.$$

# Pad the rest of the detection matrix with zeros as we only covered the first half of the spectrum here.
for ((i=1;i<=100;i++)); 
do 
   printf '0\t%.0s' {1..200}| sed 's/\t$/\n/1' >> output/100xDetectionMatrix.txt
done

# Now we have the detection matrix we can call the R script to use it to plot
# call probability as a function of ground truth allele frequency.
./uniformDist_fig2C.R
