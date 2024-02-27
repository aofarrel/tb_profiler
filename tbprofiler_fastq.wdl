version 1.0
import "./tbprofiler_tasks.wdl" as tbprof

workflow TBProfile_By_Fastq {
    input { Array[File] fastqs }
    
    call tbprof.tb_profiler_fastq as profile { input: fastqs = fastqs }

    output {
        File tbprofiler_json = profile.tbprofiler_json
        File tbprofiler_txt = profile.tbprofiler_txt
        String sample_tab_strain = profile.strain
        String sample_tab_resistance = profile.resistance
        Int sample_tab_median_depth = profile.median_depth_as_int
    }
}