version 1.0

task tb_profiler_fastq {
    input {
        Array[File] fastqs
        
        Int addldisk = 15
        Int cpu = 2
        Int memory = 4
        Int preempt = 1
        Boolean ssd = false
    }
    Int diskSize = addldisk + ceil(2*size(fastqs, "GB"))
    String diskType = if((ssd)) then " SSD" else " HDD"
    
    # This needs to be to handle inputs like sample+run+num (ERS457530_ERR551697_1.fastq)
    # or inputs like sample+num (ERS457530_1.fastq). In both cases, we want to convert to just
	# sample name (ERS457530).
	String read_file_basename = basename(fastqs[0]) # used to calculate sample name + outfile_sam
	String sample_name = sub(read_file_basename, "_.*", "")
    
    command <<<
    tb-profiler profile -1 ~{fastqs[0]} -2 ~{fastqs[1]} -p ~{sample_name} --txt
    sed -n '11p' results/~{sample_name}.results.txt | sed -r 's/^Strain: //' >> ~{sample_name}_strain.txt
    sed -n '12p' results/~{sample_name}.results.txt | sed -r 's/^Drug-resistance: //' >> ~{sample_name}_resistance.txt
    sed -n '13p' results/~{sample_name}.results.txt | sed -r 's/^Median Depth: //' >> ~{sample_name}_depth.txt
    sed -r 's/~{sample_name}: //' ~{sample_name}_depth.txt >> ~{sample_name}_rawdepth.txt
    >>>
    
    runtime {
        cpu: cpu
		disks: "local-disk " + diskSize + diskType
		docker: "ashedpotatoes/tbprofiler:4.4.2"
		memory: "${memory} GB"
		preemptible: "${preempt}"
    }
    output {
        File tbprofiler_json = "results/~{sample_name}.results.json"
        File tbprofiler_txt = "results/~{sample_name}.results.txt"
        String strain = "~{sample_name}: " + read_string("~{sample_name}_strain.txt")
        String resistance = "~{sample_name}: " + read_string("~{sample_name}_resistance.txt")
        String median_depth = "~{sample_name}: " + read_string("~{sample_name}_depth.txt")
        Int median_depth_as_int = "~{sample_name}: " + read_int("~{sample_name}_rawdepth.txt")
    }
}

task tb_profiler_bam {
    input {
        File bam
        String? bam_suffix
        
        Int cpu = 2
        Int memory = 4
        Int preempt = 1
        Boolean ssd = false
    }
    String diskType = if((ssd)) then " SSD" else " HDD"
    String sample_name = basename(bam, select_first([bam_suffix, "_to_Ref.H37Rv.bam"]))
    
    command <<<
    tb-profiler profile -a ~{bam} -p ~{sample_name} --txt
    sed -n '11p' results/~{sample_name}.results.txt | sed -r 's/^Strain: //' >> ~{sample_name}_strain.txt
    sed -n '12p' results/~{sample_name}.results.txt | sed -r 's/^Drug-resistance: //' >> ~{sample_name}_resistance.txt
    sed -n '13p' results/~{sample_name}.results.txt | sed -r 's/^Median Depth: //' >> ~{sample_name}_depth.txt
    sed -r 's/~{sample_name}: //' ~{sample_name}_depth.txt >> ~{sample_name}_rawdepth.txt
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
        String strain = "~{sample_name}: " + read_string("~{sample_name}_strain.txt")
        String resistance = "~{sample_name}: " + read_string("~{sample_name}_resistance.txt")
        String median_depth = "~{sample_name}: " + read_string("~{sample_name}_depth.txt")
        Int median_depth_as_int = "~{sample_name}: " + read_int("~{sample_name}_rawdepth.txt")
    }
}