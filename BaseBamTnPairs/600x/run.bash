#!/bin/bash
date

# Generate phased normal and pre-tumour BAMs
${GENERATEPHASEDBAMS_BASH} \
                ../../Reference/X1_HG00110.ucsc_coding_exons_hg38.fa \
                ../../Reference/X2_HG00110.ucsc_coding_exons_hg38.fa \
                76 \
                429000000 \
                180 \
                "300x_76bp"

# Re-align the normal BAMs agains the standard reference and then merge them.
${REALIGNANDMERGE_BASH} \
                N_X1_HG00110.ucsc_coding_exons_hg38_300x_76bp.bam \
                N_X2_HG00110.ucsc_coding_exons_hg38_300x_76bp.bam \
                ../../Reference/GRCh38.d1.vd1.fa \
                N_HG00110.ucsc_coding_exons_hg38_600x_76bp

date
