version 1.0

task tb_profiler_bam {
    input {
        File bam
    }
    String bam_basename = basename(bam)
    command <<<
    tb-profiler profile -a ~{bam} -p ~{bam_basename}
    tar -zcvf ~{bam_basename}.tar.gz results/
    >>>
    runtime {
        docker: "aofarrel/tbprofiler_nc_000962.3:4.4.2"
    }
    output {
        File tbprofiler_results = "~{bam_basename}.tar.gz"
    }
}

workflow profile {
    input {
        File bam
        File ref
    }
    
    call tb_profiler_bam {
        input:
            bam = bam
    }
}