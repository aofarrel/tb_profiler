import "https://github.com/aofarrel/tb_profiler/blob/main/tb_profiler_tasks.wdl"

workflow TBProfile_By_Fastq {
    input { Array[File] fastqs }
    
    call tb_profiler_fastq { input: fastqs = fastqs }
}