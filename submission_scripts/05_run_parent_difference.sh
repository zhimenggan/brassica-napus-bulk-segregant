#!/bin/bash

DARMOR='ETNV208_DSW57010_HFL2JCCXY_L7'
CABRIOLET='ETNV203_DSW57009_HFL2JCCXY_L6'

PILEUPDIR='./mpileup_unique_2018_04_20_15_02'

MPILEUP_REF=$(find $PILEUPDIR -name "mpileup_reference")

DARMOR_NUM=$(expr $(grep -n $DARMOR $MPILEUP_REF | cut -c1) - 1)
CABRIOLET_NUM=$(expr $(grep -n $CABRIOLET $MPILEUP_REF | cut -c1) - 1)

OUTPUT_DIR=$(date +parents_unique_%Y_%m_%d_%H_%M) ### Changed
mkdir -p ./$OUTPUT_DIR/run_logs
mkdir -p ./$OUTPUT_DIR/slurm_scripts
mkdir -p ./$OUTPUT_DIR/output_data

echo \
"#!/bin/bash -e
#SBATCH -p nbi-long
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem 32000
#SBATCH -o ./$OUTPUT_DIR/run_logs/parent_diff.%N.%j.out
#SBATCH -e ./$OUTPUT_DIR/run_logs/parent_diff.%N.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=marc.jones@jic.ac.uk

python pileup_ref_differences.py \
    ./$OUTPUT_DIR/output_data/published_darmor_darmor.csv \
    ./$OUTPUT_DIR/output_data/darmor_cabriolet.csv \
    $DARMOR_NUM \
    $CABRIOLET_NUM

" > ./$OUTPUT_DIR/slurm_scripts/parent_diff.sh
JOBID=$(sbatch ./$OUTPUT_DIR/slurm_scripts/parent_diff.sh | \
    awk '{print($4)}')
echo "Submitted job $JOBID"
