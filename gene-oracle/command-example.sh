#!/bin/bash
# Example command script for gene-oracle

INDEX=$(printf %02d $JOB_RANK)

# define arguments
DATASET="$INPUT_DIR/gtex_gct_data_float_v7.npy"
GENE_LIST="$INPUT_DIR/gtex_gene_list_v7.npy"
SAMPLE_JSON="$INPUT_DIR/gtex_tissue_count_v7.json"
SUBSET_LIST="$INPUT_DIR/hallmark_experiments.$INDEX.txt"
CONFIG="models/net_config.json"
OUT_FILE1="$OUTPUT_DIR/results.$INDEX.hallmark.log"
OUT_FILE2="$OUTPUT_DIR/results.$INDEX.random.log"

# run gene-oracle
cd $HOME/gene-oracle

echo "$INDEX: processing non-random sets..."

python scripts/classify.py \
	--dataset     $DATASET \
	--gene_list   $GENE_LIST \
	--sample_json $SAMPLE_JSON \
	--subset_list $SUBSET_LIST \
	--config      $CONFIG \
	--out_file    $OUT_FILE1

echo "$INDEX: processing random sets..."

python scripts/classify.py \
	--dataset     $DATASET \
	--gene_list   $GENE_LIST \
	--sample_json $SAMPLE_JSON \
	--subset_list $SUBSET_LIST \
	--random_test \
	--rand_iters 50 \
	--config      $CONFIG \
	--out_file    $OUT_FILE2
