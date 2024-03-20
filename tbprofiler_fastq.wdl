version 1.0
import "./tbprofiler_tasks.wdl" as tbprof

workflow TBProfile_By_Fastq {
    input { Array[File] fastqs }
    
    call tbprof.tb_profiler_fastq as profile { input: fastqs = fastqs }

    output {
        File tbprofiler_json = profile.tbprofiler_json
        File tbprofiler_txt = profile.tbprofiler_txt

        # for annotation
        String sample_and_strain = profile.sample_and_strain
        String sample_and_resistance = profile.sample_and_resistance
        String sample_and_median_depth = profile.sample_and_median_depth

        # raw results
        String strain = profile.sample_and_strain
        String resistance = profile.resistance
        Int median_depth = profile.median_depth
    }
}