#!/usr/bin/env nextflow



/**
 * The import_emx process converts a plain-text expression matrix into
 * a KINC data object.
 */
process import_emx {
	publishDir params.output_dir

	output:
		file("*.emx") into EMX_FILE

	script:
		"""
		EMX_FILE="\$(basename ${params.dataset} .txt).emx"

		kinc settings set logging off || echo

		kinc run import-emx \
			--input ${params.dataset} \
			--output \$EMX_FILE
		"""
}



/**
 * The similarity process performs a single chunk of KINC similarity.
 */
process similarity {
	tag { index }

	input:
		file(emx_file) from EMX_FILE
		val(index) from Channel.from( 0 .. params.chunks-1 )

	output:
		set val(emx_file.name), file("*.abd") into SIMILARITY_CHUNKS

	script:
		"""
		kinc settings set opencl 0:0  || echo
		kinc settings set threads 4   || echo
		kinc settings set logging off || echo

		kinc chunkrun ${index} ${params.chunks} similarity \
			--input ${emx_file} \
			--clusmethod ${params.clus_method} \
			--corrmethod ${params.corr_method}
		"""
}



/**
 * Merge output chunks from similarity into a list.
 */
GROUPED_CHUNKS = SIMILARITY_CHUNKS.groupTuple()



/**
 * The merge process takes the output chunks from similarity
 * and merges them into the final output files.
 */
process merge {
	publishDir params.output_dir

	input:
		file(emx_file) from EMX_FILE
		set val(emx_name), file(chunks) from GROUPED_CHUNKS

	output:
		file("*.ccm") into CCM_FILE
		file("*.cmx") into CMX_FILE

	script:
		"""
		CCM_FILE="\$(basename ${params.dataset} .txt).ccm"
		CMX_FILE="\$(basename ${params.dataset} .txt).cmx"

		kinc settings set logging off || echo

		kinc merge ${params.chunks} similarity \
			--input ${emx_file} \
			--ccm \$CCM_FILE \
			--cmx \$CMX_FILE
		"""
}



/**
 * Copy CMX file into all processes that use it.
 */
CMX_FILE.into { CMX_FILE_THRESHOLD; CMX_FILE_EXTRACT }



/**
 * The threshold process takes the correlation matrix from similarity
 * and attempts to find a suitable correlation threshold.
 */
process threshold {
	publishDir params.output_dir

	input:
		file(cmx_file) from CMX_FILE_THRESHOLD

	output:
		file("*-threshold.log") into THRESHOLD_LOG

	script:
		"""
		LOG_FILE="\$(basename ${params.dataset} .txt)-threshold.log"

		kinc settings set logging off || echo

		kinc run rmt \
			--input ${cmx_file} \
			--log \$LOG_FILE
		"""
}



/**
 * The extract process takes the correlation matrix from similarity
 * and attempts to find a suitable correlation threshold.
 */
process extract {
	publishDir params.output_dir

	input:
		file(emx_file) from EMX_FILE
		file(ccm_file) from CCM_FILE
		file(cmx_file) from CMX_FILE_EXTRACT
		file(log_file) from THRESHOLD_LOG

	output:
		file("*-net.txt")

	script:
		"""
		NET_FILE="\$(basename ${params.dataset} .txt)-net.txt"
		THRESHOLD=\$(tail -n 1 ${log_file})

		kinc settings set logging off || echo

		kinc run extract \
		   --emx ${emx_file} \
		   --ccm ${ccm_file} \
		   --cmx ${cmx_file} \
		   --output \$NET_FILE \
		   --mincorr \$THRESHOLD
		"""
}
