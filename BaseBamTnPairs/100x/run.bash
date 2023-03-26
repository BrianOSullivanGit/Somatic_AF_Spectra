#!/bin/bash
date

# Generate phased normal and pre-tumour BAMs
../../../stochasticSimFramework/stochasticSim-1.0/bin/generatePhasedBams.bash \
                ../../Reference/X1_HG00110.ucsc_coding_exons_hg38.fa \
                ../../Reference/X2_HG00110.ucsc_coding_exons_hg38.fa \
                76 \
                71500000 \
                180 \
                "50x_76bp"

# Re-align the normal BAMs agains the standard reference and then merge them.
../../../stochasticSimFramework/stochasticSim-1.0/bin/realignAndMerge.bash \
                N_X1_HG00110.ucsc_coding_exons_hg38_50x_76bp.bam \
                N_X2_HG00110.ucsc_coding_exons_hg38_50x_76bp.bam \
                ../../Reference/GRCh38.d1.vd1.fa \
                N_HG00110.ucsc_coding_exons_hg38_100x_76bp

date