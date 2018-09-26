#!/bin/bash
# Example command script for gene-oracle

# define input/output directories
INPUT_DIR="$HOME/input"
OUTPUT_DIR="$HOME/output"

# define arguments
DATASET="$INPUT_DIR/gtex_gct_data_float_v7.npy"
GENE_LIST="$INPUT_DIR/gtex_gene_list_v7.npy"
SAMPLE_JSON="$INPUT_DIR/gtex_tissue_count_v7.json"
SUBSET_LIST="$INPUT_DIR/oncogenetic_sets.txt"
CONFIG="models/net_config.json"
OUT_FILE="$OUTPUT_DIR/oncogenetic_classify_kfold10.log"

# run gene-oracle
cd $HOME/gene-oracle

python scripts/classify.py \
   --dataset     $DATASET \
   --gene_list   $GENE_LIST \
   --sample_json $SAMPLE_JSON \
   --subset_list $SUBSET_LIST \
   --config      $CONFIG \
   --out_file    $OUT_FILE
