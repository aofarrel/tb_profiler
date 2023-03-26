version 1.0

task tb_profiler_bam {
    input {
        File bam
    }
    String bam_basename = basename(bam)
    command <<<
    #tb-profiler update_tbdb --match_ref /path/to/your/reference.fasta
    tb-profiler profile -a ~{bam} -p ~{bam_basename}
    tar -zcvf ~{bam_basename}.tar.gz ~{bam_basename}
    >>>
    runtime {
        docker: "staphb/tbprofiler:4.4.2"
    }
    output {
        File tbprofiler_results = "~{bam_basename}.gzip"
    }
}