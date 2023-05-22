import "https://github.com/aofarrel/tb_profiler/blob/main/tb_profiler_tasks.wdl"

workflow TBProfile_By_Bam {
    input { File bam }
    
    call tb_profiler_bam { input: bam = bam }
}