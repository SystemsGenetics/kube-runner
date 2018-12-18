#!/usr/bin/env nextflow



/**
 * The split process splits the input subset list into chunks.
 */
process split {
	input:
		val(infile) from params.subset_list

	output:
		file("*") into SUBSET_CHUNKS mode flatten

	when:
		params.subset == true

	script:
		"""
		split -d -n r/${params.chunks} $infile ""
		"""
}



/**
 * The subsets process performs experiments from a single chunk of a subset list.
 */
process subset {
	tag { chunk.name }

	input:
		file(chunk) from SUBSET_CHUNKS

	output:
		set val("subset"), file("*.log") into SUBSET_LOGS

	script:
		"""
		source activate gene-oracle

		cd ${HOME}/workspace/gene-oracle

		python scripts/classify.py \
			--dataset      ${params.dataset} \
			--gene_list    ${params.gene_list} \
			--sample_json  ${params.sample_json} \
			--config       ${params.config} \
			--out_file     \$OLDPWD/subset.${chunk.name}.log \
			--subset_list  \$OLDPWD/${chunk.name} \
			--verbose
		"""
}



/**
 * The random process performs a single chunk of random experiments.
 */
process random {
	tag { index }

	input:
		val(index) from Channel.from( 0 .. params.chunks-1 )

	output:
		set val("random"), file("*.log") into RANDOM_LOGS

	when:
		params.random == true

	script:
		"""
		IDX=\$(printf %02d $index)
		let "MIN = $params.random_min + ($params.random_max - $params.random_min + 1) * $index / $params.chunks"
		let "MAX = $params.random_min + ($params.random_max - $params.random_min + 1) * ($index + 1) / $params.chunks - 1"

		source activate gene-oracle

		cd ${HOME}/workspace/gene-oracle

		python scripts/classify.py \
			--dataset      ${params.dataset} \
			--gene_list    ${params.gene_list} \
			--sample_json  ${params.sample_json} \
			--config       ${params.config} \
			--out_file     \$OLDPWD/random.\$IDX.log \
			--random_test \
			--range_random_genes \$MIN \$MAX \
			--rand_iters ${params.random_iters} \
			--verbose
		"""
}



/**
 * Group output chunks by prefix so that they can be merged.
 */
MERGE_CHUNKS = Channel.empty()
	.concat(SUBSET_LOGS, RANDOM_LOGS)
	.groupTuple()



/**
 * The merge process takes the output chunks from previous processes
 * and merges their outputs into a single file.
 */
process merge {
	publishDir params.output_dir
	tag { prefix }

	input:
		set val(prefix), file(chunks) from MERGE_CHUNKS

	output:
		file("${prefix}.log")

	script:
		"""
		cat ${chunks} > ${prefix}.log
		"""
}
