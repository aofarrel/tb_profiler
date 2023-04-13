version 1.0

task tb_profiler_bam {
    input {
        File bam
        
        Boolean ssd = false
        Int cpu = 2
        Int memory = 4
        Int preempt = 1
    }
    String sample_name = basename(bam, "_to_Ref.H37Rv.bam")
    String diskType = if((ssd)) then " SSD" else " HDD"
    
    command <<<
    tb-profiler profile -a ~{bam} -p ~{sample_name} --txt
    sed -n '11p' results_from_fastq/tbprofiler.results.txt >> ~{sample_name}_strain.txt
    sed -n '12p' results_from_fastq/tbprofiler.results.txt >> ~{sample_name}_resistance.txt
    >>>
    
    runtime {
        cpu: cpu
		disks: "local-disk " + ceil(2*size(bam, "GB")) + diskType
		docker: "ashedpotatoes/tbprofiler:4.4.2"
		memory: "${memory} GB"
		preemptible: "${preempt}"
    }
    output {
    File tbprofiler_results = "results/~{sample_name}.results.json"
    String tbprofiler_strain = "~{sample_name}: " + read_string("~{sample_name}_strain.txt")
    String tbprofiler_resistance = "~{sample_name}: " + read_string("~{sample_name}_resistance.txt")
    }
}

workflow profile {
    input { File bam }
    
    call tb_profiler_bam { input: bam = bam }
}
