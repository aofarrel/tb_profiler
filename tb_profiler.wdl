version 1.0

task tb_profiler_fastq {
    input {
    Array[File] fastqs
    
    Boolean ssd = false
    Int cpu = 2
    Int memory = 4
    Int preempt = 1
    }
    String diskType = if((ssd)) then " SSD" else " HDD"
    
    # We need to derive the sample name from our inputs because sample name is a
	# required input for clockwork map_reads. This needs to be to handle inputs
	# like sample+run+num (ERS457530_ERR551697_1.fastq) or inputs like
	# sample+num (ERS457530_1.fastq). In both cases, we want to convert to just
	# sample name (ERS457530).
	String read_file_basename = basename(fastqs[0]) # used to calculate sample name + outfile_sam
	String sample_name = sub(read_file_basename, "_.*", "")
    
    command <<<
    tb-profiler profile -1 ~{fastqs[0]} -2 ~{fastqs[1]} -prefix ~{sample_name}
    sed -n '11p' results/~{sample_name}.results.txt | sed -r 's/^Strain: //' >> ~{sample_name}_strain.txt
    sed -n '12p' results/~{sample_name}.results.txt | sed -r 's/^Drug-resistance: //' >> ~{sample_name}_resistance.txt
    >>>
    
    runtime {
        cpu: cpu
		disks: "local-disk " + ceil(2*size(fastqs, "GB")) + diskType
		docker: "ashedpotatoes/tbprofiler:4.4.2"
		memory: "${memory} GB"
		preemptible: "${preempt}"
    }
    output {
        File tbprofiler_json = "results/~{sample_name}.results.json"
        File tbprofiler_txt = "results/~{sample_name}.results.txt"
        String tbprofiler_strain = "~{sample_name}: " + read_string("~{sample_name}_strain.txt")
        String tbprofiler_resistance = "~{sample_name}: " + read_string("~{sample_name}_resistance.txt")
    }
}

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
    # samples that return no lineage, like SAMN0657912, will return an empty string for strain
    sed -n '11p' results/~{sample_name}.results.txt | sed -r 's/^Strain: //' >> ~{sample_name}_strain.txt
    sed -n '12p' results/~{sample_name}.results.txt | sed -r 's/^Drug-resistance: //' >> ~{sample_name}_resistance.txt
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
        File tbprofiler_txt = "results/~{sample_name}.results.txt"
        String tbprofiler_strain = "~{sample_name}: " + read_string("~{sample_name}_strain.txt")
        String tbprofiler_resistance = "~{sample_name}: " + read_string("~{sample_name}_resistance.txt")
    }
}

workflow profile_by_bam {
    input { File bam }
    
    call tb_profiler_bam { input: bam = bam }
}
