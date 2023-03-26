#!/usr/bin/Rscript

# Somatic allele frequency spectra relevant to simulations referenced in paper,
# "Comprehensive and realistic simulation of tumour genomic sequencing data."

#
# Neutral evolution, with clonal point mass simulated somatic allele frequency spectrum.
# (see https://www.nature.com/articles/ng.3489 )
#
# Note if you change the target size ('tsize') in your simulations then you must update this script with the new value.

# Rem., max freq a subclonal mutation can have is 0.25.
# that is, a mutational event that occurred directly post division of the first transformed cell.
fmin = 0.01
fmax = 0.25

# Target size. (we are using all exons plus 100 flanking bp)
tsize=75828204

# Mutation rate (mutations per base per effective division)
# Lung cancer aproximation (williams et al)
mr=10**-6.47

# Effective mutation rate for this target
mu_c = mr*tsize

# Get the number of subclonal mutations
muts = as.integer(mu_c * (1/fmin - 1/fmax))

# Sample mutation frequencies randomly from the neutral distribution.

# Inverse Transform Sampling
# Use the inverse CDF to determine the value of the variable associated with a specific probability.

# To generate a random observation X,
# 1. Derive the inverse CDF function Fx^−1
# 2. generate a random u from U (0, 1).
# 3. deliver x = Fx^−1(u)

subCfs = runif(muts)

x = fmax*fmin/(fmax-(fmax-fmin)*subCfs)

# Aprox. clonal burden as half the number of subclonal > 5% AF
numClonal=sum(x>0.05)/2

# Double these frequencies (to get their equvalent frequency in the haplotype).
x=2*x

# Add a set of clonal frequencies.
x=c(x,rep(1,numClonal))

# Shuffle
x=sample(x)

# Split randomly between haplotypes.
split=rbinom(1,length(x),.5)


# Tag filename with overall ground truth TMB, mut/MB
tmb=round(10**6 * (sum(x/2 > 0.05)/tsize),2)

# Write out.
write.table(x[-(1:split)], paste0("output/h1_neutral_",tmb,"_freqs.txt"), row.names=F, col.names=F)
write.table(x[1:split], paste0("output/h2_neutral_",tmb,"_freqs.txt"), row.names=F, col.names=F)


#
# A set of uniform somatic allele frequency spectra covering the first half (0 to 0.5) of the frequency spectrum.
# Frequency bands referenced below are relative to the haplotype (ie., they are 0.5 of what they will be when sequenced).
#

# In total there are 40K somatic variants (5K per semi-centile per haplotype) in each distribution.

# H1: Set for haplotype 1
t=runif(20000,0.00,0.04);write.table(t,"output/h1_uniform_0.00_0.04_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.04,0.08);write.table(t,"output/h1_uniform_0.04_0.08_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.08,0.12);write.table(t,"output/h1_uniform_0.08_0.12_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.12,0.16);write.table(t,"output/h1_uniform_0.12_0.16_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.16,0.20);write.table(t,"output/h1_uniform_0.16_0.20_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.20,0.24);write.table(t,"output/h1_uniform_0.20_0.24_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.24,0.28);write.table(t,"output/h1_uniform_0.24_0.28_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.28,0.32);write.table(t,"output/h1_uniform_0.28_0.32_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.32,0.36);write.table(t,"output/h1_uniform_0.32_0.36_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.36,0.40);write.table(t,"output/h1_uniform_0.36_0.40_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.40,0.44);write.table(t,"output/h1_uniform_0.40_0.44_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.44,0.48);write.table(t,"output/h1_uniform_0.44_0.48_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.48,0.52);write.table(t,"output/h1_uniform_0.48_0.52_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.52,0.56);write.table(t,"output/h1_uniform_0.52_0.56_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.56,0.60);write.table(t,"output/h1_uniform_0.56_0.60_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.60,0.64);write.table(t,"output/h1_uniform_0.60_0.64_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.64,0.68);write.table(t,"output/h1_uniform_0.64_0.68_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.68,0.72);write.table(t,"output/h1_uniform_0.68_0.72_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.72,0.76);write.table(t,"output/h1_uniform_0.72_0.76_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.76,0.80);write.table(t,"output/h1_uniform_0.76_0.80_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.80,0.84);write.table(t,"output/h1_uniform_0.80_0.84_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.84,0.88);write.table(t,"output/h1_uniform_0.84_0.88_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.88,0.92);write.table(t,"output/h1_uniform_0.88_0.92_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.92,0.96);write.table(t,"output/h1_uniform_0.92_0.96_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.96,1.00);write.table(t,"output/h1_uniform_0.96_1.00_freqs.txt",row.names = F,col.names = F)



# H2: Set for haplotype 2
t=runif(20000,0.00,0.04);write.table(t,"output/h2_uniform_0.00_0.04_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.04,0.08);write.table(t,"output/h2_uniform_0.04_0.08_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.08,0.12);write.table(t,"output/h2_uniform_0.08_0.12_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.12,0.16);write.table(t,"output/h2_uniform_0.12_0.16_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.16,0.20);write.table(t,"output/h2_uniform_0.16_0.20_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.20,0.24);write.table(t,"output/h2_uniform_0.20_0.24_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.24,0.28);write.table(t,"output/h2_uniform_0.24_0.28_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.28,0.32);write.table(t,"output/h2_uniform_0.28_0.32_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.32,0.36);write.table(t,"output/h2_uniform_0.32_0.36_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.36,0.40);write.table(t,"output/h2_uniform_0.36_0.40_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.40,0.44);write.table(t,"output/h2_uniform_0.40_0.44_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.44,0.48);write.table(t,"output/h2_uniform_0.44_0.48_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.48,0.52);write.table(t,"output/h2_uniform_0.48_0.52_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.52,0.56);write.table(t,"output/h2_uniform_0.52_0.56_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.56,0.60);write.table(t,"output/h2_uniform_0.56_0.60_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.60,0.64);write.table(t,"output/h2_uniform_0.60_0.64_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.64,0.68);write.table(t,"output/h2_uniform_0.64_0.68_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.68,0.72);write.table(t,"output/h2_uniform_0.68_0.72_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.72,0.76);write.table(t,"output/h2_uniform_0.72_0.76_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.76,0.80);write.table(t,"output/h2_uniform_0.76_0.80_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.80,0.84);write.table(t,"output/h2_uniform_0.80_0.84_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.84,0.88);write.table(t,"output/h2_uniform_0.84_0.88_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.88,0.92);write.table(t,"output/h2_uniform_0.88_0.92_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.92,0.96);write.table(t,"output/h2_uniform_0.92_0.96_freqs.txt",row.names = F,col.names = F)
t=runif(20000,0.96,1.00);write.table(t,"output/h2_uniform_0.96_1.00_freqs.txt",row.names = F,col.names = F)

#
# A 10k point mass somatic allele frequency spectrum centered at 0.035 (equivalent to 5k, 0.07 allele frequency  in each haplotype).
#
write.table(rep(0.07, 5000),"output/h1_pm_0.035_freqs.txt",row.names = F,col.names = F)
write.table(rep(0.07, 5000),"output/h2_pm_0.035_freqs.txt",row.names = F,col.names = F)
