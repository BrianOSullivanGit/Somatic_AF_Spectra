#!/bin/bash

# This script automatically sets up all the run scripts for each simulation listed under ../SomaticAlleleSpectra/output
# These are then run by submitting them as jobs as listed in run.slurm
printFn () {
  # $1 = depth
  # $2 = distribution name

  depth=$1
  abrv=`echo $2|sed 's/uniform_/u/1'`

  printf "#!/bin/bash\n"
  printf "\n"
  printf "# This script effectively runs this simulation.\n"
  printf "# Its tasks are,\n"
  printf "# Spike in the distribution to the (phased) pre-tumour BAMs.\n"
  printf "# Realign and merge the modified tumour BAMs.\n"
  printf "# Calls runSomaticVariantCaller.bash which in turn performs somatic variant calling\n"
  printf "# with the required caller and maps the output to the ground truth.\n"
  printf "date;\n"
  printf "\${SPIKEIN_BASH} %c\n" '\'
  printf "                      ../../../BaseBamTnPairs/%sx/T_X1_HG00110.ucsc_coding_exons_hg38_%sx_76bp.bam %c\n" $depth $((depth / 2)) '\'

  printf "                      ../../../BaseBamTnPairs/%sx/T_X2_HG00110.ucsc_coding_exons_hg38_%sx_76bp.bam %c\n" $depth $((depth / 2)) '\'
  printf "                      ../../../Reference/X1_HG00110.ucsc_coding_exons_hg38.fa %c\n" '\'
  printf "                      ../../../Reference/X2_HG00110.ucsc_coding_exons_hg38.fa %c\n" '\'
  printf "                      ../../../SomaticAlleleSpectra/output/h1_%s.spike %c\n" $2 '\'
  printf "                      ../../../SomaticAlleleSpectra/output/h2_%s.spike %c\n"  $2 '\'
  printf '                      || { echo -e "\\n\\033[7mSpike-in failed. Resolve issues before proceeding.\\033[0m";exit 1; }\n'  
  printf "\n"
  printf "\${REALIGNANDMERGE_BASH} %c\n" '\'
  printf "                                   T_X1_HG00110.ucsc_coding_exons_hg38_%sx_76bp.spike.bam %c\n" $((depth / 2)) '\'
  printf "                                   T_X2_HG00110.ucsc_coding_exons_hg38_%sx_76bp.spike.bam %c\n" $((depth / 2)) '\'
  printf "                                   ../../../Reference/GRCh38.d1.vd1.fa %c\n" '\'
  printf "                                   T_HG00110.ucsc_coding_exons_hg38_%sx_76bp_spiked %c\n" $depth '\'
  printf '                                   || { echo -e "\\n\\033[7mRealign and merge failed. Resolve issues before proceeding.\\033[0m";exit 1; }\n'
  printf "\n"
  printf "mkdir SomaticVariantCallerOutput\n"
  printf "cd SomaticVariantCallerOutput\n"
  printf "\n"
  printf "# Now run the caller (MUTECT  etc..) & map its output to the ground truth.\n"
  printf "../../../runSomaticVariantCaller.bash ../T_HG00110.ucsc_coding_exons_hg38_%sx_76bp_spiked.realn.phased.bam %c\n" $depth '\'
  printf "                                 ../../../../BaseBamTnPairs/%sx/N_HG00110.ucsc_coding_exons_hg38_%sx_76bp.realn.phased.bam %c\n" $depth $depth '\'
  printf "                                 ../T_X1_HG00110.ucsc_coding_exons_hg38_%sx_76bp.truth.vcf  %c\n" $((depth / 2)) '\'
  printf "                                 ../T_X2_HG00110.ucsc_coding_exons_hg38_%sx_76bp.truth.vcf\n" $((depth / 2))
  printf "date;\n"

  # Now append slurm run script with commands to run this simulation.
  printf "cd %s/%sx\n" $2 $depth >> run.slurm
  printf "sbatch -c8 --job-name=%s --mem-per-cpu=7750 run.bash\n" $abrv >> run.slurm
  printf "cd ../../\n" >> run.slurm

}

echo > run.slurm
# Set up the uniform simulations first.
# These are run at 100x only.
ls -d ../SomaticAlleleSpectra/output/* | sed -e 's/.*output\/h[12]_//1' -e 's/.spike$//1' | sort | uniq | grep uniform | \
while read line
 do
  # 100x
  mkdir -p ${line}/100x
  printFn 100 ${line} > ${line}/100x/run.bash
  chmod u+x ${line}/*/run.bash
done

# Now set up all other simulations to run at depths
# 100x, 200x, 350x, 600x
ls -d ../SomaticAlleleSpectra/output/* | sed -e 's/.*output\/h[12]_//1' -e 's/.spike$//1' | sort | uniq | grep -v uniform | \
while read line
 do
  # 100x
  mkdir -p ${line}/100x
  printFn 100 ${line} > ${line}/100x/run.bash
  # 200x
  mkdir -p ${line}/200x
  printFn 200 ${line} > ${line}/200x/run.bash
  # 350x
  mkdir -p ${line}/350x
  printFn 350 ${line} > ${line}/350x/run.bash
  # 600x
  mkdir -p ${line}/600x
  printFn 600 ${line} > ${line}/600x/run.bash

  chmod u+x ${line}/*/run.bash
done

