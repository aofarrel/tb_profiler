version 1.0

task tb_profiler_bam {
    input {
        File bam
        
        Boolean ssd = false
        Int cpu = 2
        Int memory = 4
        Int preempt = 1
    }
    String bam_basename = basename(bam)
    String diskType = if((ssd)) then " SSD" else " HDD"
    
    command <<< tb-profiler profile -a ~{bam} -p ~{bam_basename} >>>
    
    runtime {
        cpu: cpu
		disks: "local-disk " + ceil(2*size(bam, "GB")) + diskType
		docker: "ashedpotatoes/tbprofiler:4.4.2"
		memory: "${memory} GB"
		preemptible: "${preempt}"
    }
    output { File tbprofiler_results = "results/~{bam_basename}.results.json" }
}

workflow profile {
    input { File bam }
    
    call tb_profiler_bam { input: bam = bam }
}
