# tb_profiler WDL

Basic WDLization of [TBProfiler](https://github.com/jodyphelan/TBProfiler)'s bam version.

The Docker image is based upon staphb/tbprofiler:4.4.2 but uses a reference genome with a different chromosome name. If you want to use this WDL your bam MUST be aligned to the same reference genome as the one in this repo!