# Somatic_AF_Spectra
*Simulation details and output associated with the manuscript "Comprehensive and realistic simulation of tumour genomic sequencing data".*

Contact BrianOSullivan@yahoo.com with questions.

## Table of contents<!-- omit in toc -->
- [Simulation set-up.](#simulation-set-up)
- [Create base BAM pairs.](#create-base-bam-pairs)
- [Run the simulations.](#run-the-simulations)



## Simulation set-up.

### Clone the Somatic_AF_Spectra repository

```
git clone  https://github.com/BrianOSullivanGit/Somatic_AF_Spectra
```

### Clone and build stochasticSim framework.

Enter the Somatic_AF_Spectra/FRAMEWORK directory. Clone and build the stochasticSim repository that will drive these simulations.

```
cd Somatic_AF_Spectra/FRAMEWORK
git clone https://github.com/BrianOSullivanGit/stochasticSim
cd stochasticSim
# Run the install script.
./install.bash
```

You may also want to test out stochasticSim by running the toy example included.  This is not necessary but is recommended. If there are any issues it is better to resolve them now. To run it follow the instructions at the end of the install, ie.,


```
source <path to your install>/FRAMEWORK/stochasticSim/bin/tool.path

# Now, enter the toy example directory and run the simulation,

cd <path to your install>/FRAMEWORK/stochasticSim/toyExample
./run.bash 50 chr19_500KB.bed
```

### Set-up Reference directory.
Before running the simulations you will need to set up the Somatic_AF_Spectra/Reference directory. This consists of downloading/creating a set of reference files that are required by the simulations. 

The first step in setting up the Reference directory is to download the version of the Mutect2 panel-of-normals (PON) used in these simulations. This is a controlled file located on the GDC repository. You will need a GDC token and access to the gdc-client tool to download it. See the following link about how to get token based access to GDC controlled data (https://gdc.cancer.gov/access-data/obtaining-access-controlled-data) and https://gdc.cancer.gov/node/159 to download a copy of the gdc-client for your platform. In the example below we use a Ubuntu x64 client.
Once it's downloaded, unpack the PON VCF and the corresponding index file to the Somatic_AF_Spectra/Reference directory (as shown below).

```
cd <path to your install>/Somatic_AF_Spectra/Reference

# The procedure to download gdc-client and the VCF plus index file is,
wget https://gdc.cancer.gov/files/public/file/gdc-client_v1.6.1_Ubuntu_x64.zip
unzip gdc-client_v1.6.1_Ubuntu_x64.zip
./gdc-client download 726e24c0-d2f2-41a8-9435-f85f22e1c832 -t <insert path to your GDC token file here>
cd 726e24c0-d2f2-41a8-9435-f85f22e1c832
tar xvf MuTect2.PON.5210.vcf.tar -C ../
cd ../
rm -fr 726e24c0-d2f2-41a8-9435-f85f22e1c832
```

Now run setup.bash script located in the Reference directory. This will download the GRCh38 reference genome and associated index files. It will also unpack the target BED and germline donor VCF. Finally it uses the stochasticSim framework to create a phased donor genome for use in the simulations. This personalised reference genome will contain all germline SNVs and indels annotated for 1000 genomes donor HG00110 (female of English and Scottish ancestry). We will use it in our simulations as a base 
to simulate phased, perfectly aligned, normal and pre-tumour (i.e., before the somatic variants have been spiked in) genomic sequencing data.

```
./setup.bash
```
Please note that if you have already downloaded / indexed any of these reference files previously you may copy / create a link to them here to save time/bandwidth (directory contents shown at the end of this section). You may in that case edit setup.bash to skip any redundant steps in setting up the Reference directory.

## Create base BAM pairs

In this step we use the read simulator (in this case, ART) to create pre-tumour and normal phased BAMs at each of the required depths of coverage. The pre-tumour BAMs will be used as a base to spike-in the required somatic distributions when we run the simulations (in the next step). The normal phased BAM pair for each depth of coverage is realigned against the standard reference and merged creating a normal (control) BAM which will be used during somatic variant calling (the last stage in running the simulation). Slurm scheduler commands are used to submit the required jobs in the example below. Modify as required to fit your scheduler / node & resource availability.

### 100x
```
cd <path to your install>/Somatic_AF_Spectra/BaseBamTnPairs/100x
sbatch -c8 --job-name=100xPhasedBase --mem-per-cpu=7750 ./run.bash
```
### 200x
```
cd <path to your install>/Somatic_AF_Spectra/BaseBamTnPairs/200x
sbatch -c8 --job-name=200xPhasedBase --mem-per-cpu=7750 ./run.bash
```
### 350x
```
cd <path to your install>/Somatic_AF_Spectra/BaseBamTnPairs/350x
sbatch -c8 --job-name=350xPhasedBase --mem-per-cpu=7750 ./run.bash
```
### 600x
```
cd <path to your install>/Somatic_AF_Spectra/BaseBamTnPairs/600x
sbatch -c8 --job-name=600xPhasedBase --mem-per-cpu=7750 ./run.bash
```

## Create Somatic Distribution config files
```
cd <path to your install>/Somatic_AF_Spectra/SomaticAlleleSpectra
./createSomaticDistributionCfgs.sh
```

## Run the simulations
Once the base BAM pairs and required somatic distribution config files have been created you may now run the simulations. These simulations were run on a linux based cluster running the Slurm Workload Manager. A script to submit the jobs to the slurm scheduler is located under Somatic_AF_Spectra/Sims/run.slurm . You may need to modify it to run on your cluster depending on your scheduler / the nodes & resources available to you cluster e.t.c..

