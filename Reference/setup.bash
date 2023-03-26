#!/bin/bash

# Setup the required reference files for this simulation.

# Download and index the required reference genome.
# In these simulations we use GRCh38.
# Consider first if you need to do this step. Have you downloaded and indexed this before?
# If so just add a link to it here, ie.,
# ln -s /<the path to...and its index files>/GRCh38.d1.vd1.fa* ./
# If not, then

# Download the GRCh38 reference genome.
wget https://api.gdc.cancer.gov/data/254f697d-310d-4d7d-a27b-27fbf767a834

# Extract it.
tar xvf 254f697d-310d-4d7d-a27b-27fbf767a834

# Download the corresponding bwa index files.
# This is probably quicker than building them from scratch with
# bwa index -a bwtsw GRCh38.d1.vd1.fa
# but its your choice, depending on your preference / internet speed.
wget https://api.gdc.cancer.gov/data/25217ec9-af07-4a17-8db9-101271ee7225
# Extract it.
tar xvf 25217ec9-af07-4a17-8db9-101271ee7225

# Include the BED file describing the target region of interest.
# We used a simple BED for these simulations of all known hg38 exons downloaded from UCSC.
# Go to https://genome-euro.ucsc.edu/cgi-bin/hgTables , select output in BED format,
# and after clicking output, select 'Coding Exons'.
# A snapshot of that output (from 2021) has already been included with this gitHub for the purposes
# of this simulation. You can replace as required a BED reflecting the target you are interested in.
# 
gunzip ucsc_coding_exons_hg38.bed.gz

# Next include the germline VCF of the target donor on which these simulations will be
# based. We compiled a VCF based on publically available information on all germline SNV and indel
# annotation for 1000 genomes donor HG00110 (female of English and Scottish ancestry) and
# include it here for the purposes of these simulations. The original source of this information is
# from The International Genome Sample Resource,
# https://www.internationalgenome.org/data-portal/sample/HG00110 .
# You may replace this VCF with one from another donor of interest as required.
#
gunzip HG00110.vcf.gz

# Download Mutect2 panel-of-normals.
# If you are using Mutect2 as your somatic variant caller (as is the case in these simulations)
# then you will need to put the panel-of-normals (PON) file in this directory also.
# If you have run Mutect2 before you probably have a copy of this stored away somewhere.
# If so just copy or add a link to it here in the 'Reference' directory.
# Otherwise you will need a GDC token and access to the gdc-client tool to download it.
# See the following link about how to get token based access to GDC controlled data.
# https://gdc.cancer.gov/access-data/obtaining-access-controlled-data .
# To download the gdc-client for your platform go to https://gdc.cancer.gov/node/159/ .
# In the example below we use a Ubuntu x64 client.
# Once it's downloaded unpack the PON VCF and the corresponding index file to this (Reference) directory.
# The procedure to download gdc-client and the VCF plus index file is,

# wget https://gdc.cancer.gov/files/public/file/gdc-client_v1.6.1_Ubuntu_x64.zip
# unzip gdc-client_v1.6.1_Ubuntu_x64.zip
# ./gdc-client download 726e24c0-d2f2-41a8-9435-f85f22e1c832 -t <insert path to your GDC token file here>
# cd 726e24c0-d2f2-41a8-9435-f85f22e1c832
# tar xvf MuTect2.PON.5210.vcf.tar -C ../
# cd ../
# rm -fr 726e24c0-d2f2-41a8-9435-f85f22e1c832

# Create personalised reference assemble files.
# You are now ready to create a personalised reference genome for donor 1000 genomes donor HG00110.
# This is achieved with the 'createPersonalisedMaskedTarget.bash' script from the simulation framework
# bin directory. Along with a set of diploid personalised reference assemblies this will also create
# a pair of liftover files that are used to map genomic coordinates between the standard and personalised reference.
# The files are then compressed and redundant files removed.
# For more information view ('more') the 'createPersonalisedMaskedTarget.bash' script and read the comments
# to see the steps involved and files created.

${CREATEPERSONALISEDMASKEDTARGET_BASH} HG00110 F GRCh38.d1.vd1.fa HG00110.vcf ucsc_coding_exons_hg38.bed 100
# Compress and remove redundant large intermediate files.
${CONDENSE_LIFT} liftover_X1_HG00110.txt > liftover_X1_HG00110.condense.txt
${CONDENSE_LIFT} liftover_X2_HG00110.txt > liftover_X2_HG00110.condense.txt
rm liftover_X1_HG00110.txt liftover_X2_HG00110.txt
