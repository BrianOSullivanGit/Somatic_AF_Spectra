#!/bin/bash

mkdir output 2>/dev/null
./neutral_fig2B.bash
./neutral_fig3.R
# ./neutral_summary.bash
./pm_fig4A.R
./pm_fig4B.R
./uniformDist_fig2C.bash
./uniformDist_fig2C.R
./uniformDist_fig2D.bash
