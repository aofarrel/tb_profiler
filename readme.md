# tb_profiler WDL

Basic WDLization of [TBProfiler](https://github.com/jodyphelan/TBProfiler). Features both bam-as-input mode and fastq-as-input mode. Extracts strain, drug resistance status, and median coverage into separate report files.

The Docker image is based upon [staphb/tbprofiler](https://hub.docker.com/r/staphb/tbprofiler/tags) but uses a reference genome with a different chromosome name. If you want to use this WDL your bam MUST be aligned to the same reference genome as the one in this repo!

## Notes
* For the bam version of the pipeline, "_to_Ref.H37Rv.bam" will be removed from the bam's filename to generate the sample name unless `bam_suffix` is set
* For the fastq version of the pipeline, everything after the first underscore of the first fastq's filename will be removed to generate the sample name
* Samples that return no lineage, like SAMN0657912, will return an empty string for strain