import "https://raw.githubusercontent.com/aofarrel/tb_profiler/main/tbprofiler_tasks.wdl" as tbprof
#import "https://raw.githubusercontent.com/aofarrel/SRANWRP/v1.1.10/tasks/processing_tasks.wdl" as sranwrp_processing

workflow TBProfile_By_Fastq {
    input { Array[File] fastqs }
    
    call tbprof.tb_profiler_fastq as profile { input: fastqs = fastqs }

    output {
        File tbprofiler_json = profile.tbprofiler_json
        File tbprofiler_txt = profile.tbprofiler_txt
        String strain = profile.strain
        String resistance = profile.resistance
        String median_depth = profile.median_depth
    }
}