# Somatic_AF_Spectra
*Simulation details and output associated with the manuscript "Comprehensive and realistic simulation of tumour genomic sequencing data".*

To run, please follow the instructions below. Contact BrianOSullivan@yahoo.com with questions.

## Table of contents<!-- omit in toc -->
- [If you are in a hurry..](#if-you-are-in-a-hurry)
- [Set up framework and reference files.](#set-up-framework-and-reference-files)
- [Create base BAM pairs.](#create-base-bam-pairs)
- [Create Somatic Distribution config files.](create-somatic-distribution-config-files)
- [Run the simulations.](#run-the-simulations)
- [Run analyses.](#run-analyses)


## If you are in a hurry..
There is a link below to a tarball of VCFs and other output files created by a previous run of these simulations. If you wish to skip setting up and running these simulations, download and untar that file (below). It will populate all the required output directories allowing you to skip ahead to the final step 'Run analyses'. If not then ignore this step and proceed through the process.

```
git clone  https://github.com/BrianOSullivanGit/Somatic_AF_Spectra
cd <path to your install>/Somatic_AF_Spectra/
wget https://www.dropbox.com/s/4ewotu5j88mktgb/Somatic_AF_Spectra.output.tgz?dl=0
tar xvf Somatic_AF_Spectra.output.tgz
```

## Set up framework and reference files.

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

The first step in setting up the Reference directory is to download the version of the Mutect2 panel-of-normals (PON) used in these simulations. This is a controlled file located on the GDC repository. You will need a GDC token and access to the gdc-client tool to download it. See [this link](https://gdc.cancer.gov/access-data/obtaining-access-controlled-data) to find out how to get token based access to GDC controlled data and [this link](https://gdc.cancer.gov/node/159) to download a copy of the gdc-client for your platform. In the example below we use a Ubuntu x64 client.
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

Now run setup.bash script located in the Reference directory. This will download the GRCh38 reference genome and associated index files. It will also unpack the target BED and germline donor VCF. Finally it uses the stochasticSim framework to create a phased donor genome for use in the simulations. This personalised reference genome will contain all germline SNVs and indels annotated for 1000 genomes donor HG00110 (female of English and Scottish ancestry). We will use it to simulate phased, perfectly aligned, normal and pre-tumour (i.e., before the somatic variants have been spiked in) genomic sequencing data. The pre-tumour BAM will in turn be used as a base to spike-in the somatic distribution of interest, after which each set will be realigned against the standard reference, merged and used as input to somatic variant calling.

```
./setup.bash
```
Please note that if you have already downloaded / indexed any of these reference files previously you may copy / create a link to them here to save time/bandwidth (directory contents shown at the end of this section). You may in that case edit setup.bash to skip any redundant steps in setting up the Reference directory.

## Create base BAM pairs

In this step we use the read simulator (in this instance, ART) to create pre-tumour and normal phased BAMs at each of the required depths of coverage. The pre-tumour BAMs will be used as a base to spike-in the required somatic distributions when we run the simulations (below). The normal phased BAM pair for each depth of coverage is realigned against the standard reference and merged creating a normal (control) BAM which will be used during somatic variant calling (the last stage in running the simulation). Slurm scheduler commands are used to submit the required jobs in the example below. Modify as required to fit your scheduler / node & resource availability.

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
The list of somatic mutations used in each simulation is located under the Somatic_AF_Spectra/SomaticAlleleSpectra directory.
These lists are stored in a set of spike-in configuration files in the output directory and used by the simulations. The R script createSomaticDistributionCfgs.R creates the frequency distribution for each simulation and the bash script createSomaticDistributionCfgs.bash matches each SNVs frequency with a random genomic location creating the required set of spike-in config files in the output directory. Refer to the file createSomaticDistributionCfgs.R and the manuscript associated with these simulations for more details on these distributions. The R script createSomaticDistributionCfgs.R is called at the start of the bash script createSomaticDistributionCfgs.bash. You will need to have R installed to run this script. Run it as shown below. If R is not installed on the node, go to one where it is installed and run the R script separately first before running the bash script.

```
cd <path to your install>/Somatic_AF_Spectra/SomaticAlleleSpectra
./createSomaticDistributionCfgs.bash
```

## Run the simulations
Once the base BAM pairs and required somatic distribution config files have been created you may now run the simulations. Before running the simulations you will need to run a script to set up the Sims directory. This creates a set of directories that will contain simulation output together with a series of run scripts that will be submitted to the scheduler to run each individual simulation. Setup the Sims directory with,

```
cd <path to your install>/Somatic_AF_Spectra/Sims
./setup.bash
```

Once setup has completed you may run the simulations by sourcing run.slurm which contains the necessary commands to submit the simulation jobs, as shown below. These simulations were run on a linux based cluster running the Slurm Workload Manager. You may need to modify run.slurm for your cluster depending on your scheduler / the nodes & resources available on your cluster e.t.c.. Also, depending on the resources available to you you may wish to stagger the jobs to limit the load on the cluster. Either way it is probably best to more the run.slurm file and run one 100x job first to make sure your setup is working ok.
```
cd <path to your install>/Somatic_AF_Spectra/Sims

# Advisable, more run.slurm and run one 100x job to completion first.
# ie.,
#
# cd ../../
# cd neutral_8.51/100x
# sbatch -c8 --job-name=neutral_8.51 --mem-per-cpu=7750 run.bash

# Alternatively, if you want to set all jobs going,
source ./run.slurm
```

## Run analyses.
When the simulations have completed you may run the analyses located in the plots directory. Again you must have R installed with the Rscript binary located under /usr/bin/Rscript to run these analyses. You can run them individually or alternatively call run.bash which runs them all sequentially. The resulting plots are located in the output directory. After the plots have been created, the neutral_summary.bash creates a summary table of the neutral subclonal simulations. Please refer to the corresponding section in the manuscript for further information about each of these plots. 
```
cd <path to your install>/Somatic_AF_Spectra/Plots
./run.bash
```


