# This awk script parses each entry in the ground truth map file (gtMapper.hap.ref).
# For each true positive (true somatic variant annotated as PASS in the variant caller VCF)
# with a true variant allele frequency within the range specified (by command line arguments)
# it bins the value of the allele frequency as estimated by the caller for that variant.
# The true allele frequency range of interest is usually the first half of the
# allele frequency spectrum (0-0.5) of a ground-truth uniform distribution, split
# into semi-centile bins. This awk script is called for each semi-centile to track
# down how much of the true burden in that semi-centile is detected by the caller
# and where in the allele frequency spectrum the caller estimates it comes from.

# The output of each invocation of this script (ie., at each semi-centile) is recorded
# and compiled into a "detection matrix".

# The "detection matrix" allows us to develop an empirical model that decomposes
# the observed spectrum (annotated by the caller) into a set of ground truth
# semi-centile uniform distributions (using multiple linear regression) indicating
# where the ground truth of this burden is located in the allele frequency spectrum.

# Each row in the detection matrix may also be summed to tell us what fraction of
# the burden in each semi-sentils is detected by the caller.
# This allows us to predict the probability that a true somatic mutation is passed
# by Mutect2, as a function of its true allele frequency.

BEGIN {
    b=b/2
    bin_width = b
    a=a/2
    b=a+b
    num_bins = (1 / bin_width)
    for (i = 1; i <= num_bins; ++i) {
        hist[i] = 0
    }
} {
    if ($3 != "PASS") next;
    if ($6 == "PASS" || $6 ~ /MASKED/) {
        $7=$7/2
        if ($7 < a || $7 > b) next;
    } else if ($10 == "PASS" || $10 ~ /MASKED/) {
        $11=$11/2
        if ($11 < a || $11 > b) next;
    } else next;
    bin = 1 + int(($2 - 1e-09) / bin_width)
    hist[bin]++
}
END {
    for (i = 1; i <= num_bins; ++i) {
        printf("%i", hist[i]) > a"_"b"_DM_entry.txt"
        if(i!=num_bins)
            printf("\t") > a"_"b"_DM_entry.txt"        
    }
    printf("\n") > a"_"b"_DM_entry.txt"
} 
