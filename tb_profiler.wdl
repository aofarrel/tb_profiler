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
    # to do: check if this works on ones that return no lineage like SAMN0657912
    sed -n '11p' results/~{sample_name}.results.txt >> ~{sample_name}_strain.txt
    sed -n '12p' results/~{sample_name}.results.txt >> ~{sample_name}_resistance.txt
    >>>
    
    runtime {
        cpu: cpu
		disks: "local-disk " + ceil(2*size(bam, "GB")) + diskType
		docker: "ashedpotatoes/tbprofiler:4.4.2"
		memory: "${memory} GB"
		preemptible: "${preempt}"
    }
    output {
    File tbprofiler_json = "results/~{sample_name}.results.json"
    File tbprofiler_txt = "results/~{sample_name}.results.txt" # will probably get rid of this eventually
    String tbprofiler_strain = "~{sample_name}: " + read_string("~{sample_name}_strain.txt")
    String tbprofiler_resistance = "~{sample_name}: " + read_string("~{sample_name}_resistance.txt")
    }
}

workflow profile {
    input { File bam }
    
    call tb_profiler_bam { input: bam = bam }
}
