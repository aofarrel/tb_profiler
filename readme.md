# tb_profiler WDL

Basic WDLization of [TBProfiler](https://github.com/jodyphelan/TBProfiler). Explictly extracts strain (lineage), drug resistance status, and coverage.

	* Standard TBProfiler, FQ file input: [tbprofiler_fastq.wdl](./tbprofiler_fastq.wdl)
	* Standard TBProfiler, BAM file input: [tbprofiler_bam.wdl](./tbprofiler_bam.wdl)
	* TheiaProk's version of TBProfiler, FQ file input: [theiagen_tbprofiler.wdl](./theiagen_tbprofiler.wdl)

The Docker image used by tbprofiler_fastq and tbprofiler_bam is essentially [staphb/tbprofiler](https://hub.docker.com/r/staphb/tbprofiler/tags) but uses a reference genome with a different chromosome name. It's the same NC_000962.3 you know and love. theiagen_tbprofiler have their own Docker image.

## Notes
* Use `--copy-input-files` if using miniwdl
* For the bam version of the pipeline, `_to_Ref.H37Rv.bam` will be removed from the bam's filename to generate the sample name unless `bam_suffix` is set
* For the fastq version of the pipeline, everything after the first underscore of the first fastq's filename will be removed to generate the sample name
* When using the bam version of the pipeline, your bam MUST be aligned to the same reference genome as the one in this repo!
* Samples that return no lineage, like SAMN0657912, will return an empty string for strain
* A comparison of the same sample at different points in [myco_sra](https://dockstore.org/workflows/github.com/aofarrel/myco/myco_sra) TBProfiler can be found in `examples/results_from_bam` and `examples/results_from_fastq`