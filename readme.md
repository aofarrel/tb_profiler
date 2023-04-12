# tb_profiler WDL

Basic WDLization of the bam-as-input functionality of [TBProfiler](https://github.com/jodyphelan/TBProfiler)'s.

The Docker image is based upon [staphb/tbprofiler](https://hub.docker.com/r/staphb/tbprofiler/tags) but uses a reference genome with a different chromosome name. If you want to use this WDL your bam MUST be aligned to the same reference genome as the one in this repo!