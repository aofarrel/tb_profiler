version 1.0
import "https://raw.githubusercontent.com/theiagen/public_health_bioinformatics/v2.3.0/tasks/species_typing/mycobacterium/task_tbprofiler.wdl" as tbprof
import "https://raw.githubusercontent.com/theiagen/public_health_bioinformatics/v2.3.0/tasks/species_typing/mycobacterium/task_tbp_parser.wdl" as tbprof_parser

workflow ThiagenTBProfiler {
    input {
        File fastq1
        File fastq2
        String sample
        String? operator
        
        # qc cutoffs; ie discarding the *entire* sample
        # note that myco's guardrail mode sets these to
        # 10% and 3x respectively as of v5.5.0
        Int minimum_pct_mapped = 98
        Int minimum_coverage = 5
        
        # other options
        Boolean soft_all_qc = false
        Boolean soft_coverage = false
        Boolean soft_pct_mapped = false
        Int warn_if_below_this_depth = 10
        
    }
    
    parameter_meta {
        fastq1: "This sample's forward read"
        fastq2: "This sample's reverse read"
        minimum_pct_mapped: "Sample fails QC if less than this percent of a sample maps to the TB ref genome."
        minimum_coverage: "Sample fails QC if median coverage is less than this."
        soft_all_qc: "Turns all QC metrics into warnings, not errors."
        soft_coverage: "Failing minimum_coverage will be a warning, not an error."
        soft_pct_mapped: "Failing minimum_pct_mapped will be a warning, not an error."
        warn_if_below_this_depth: "Mutations below this depth will be flagged as low-depth in the Laboratorian report. Does not affect TBProfiler JSON nor any cleaning of FASTQs."
    }
    
    call tbprof.tbprofiler as profiler {
        input:
            read1 = fastq1,
            read2 = fastq2,
            samplename = sample
    }
    
    call tbprof_parser.tbp_parser as csv_maker {
        input:
            tbprofiler_bam = profiler.tbprofiler_output_bam,
            tbprofiler_bai = profiler.tbprofiler_output_bai,
            tbprofiler_json = profiler.tbprofiler_output_json,
            samplename = sample,
            sequencing_method = "WGS",
            operator = select_first([operator, "operator_not_filled_in"]),
            min_depth = warn_if_below_this_depth
    }
    
    if(soft_all_qc) {
        String override = "PASS"
    }
    
    if(!(profiler.tbprofiler_pct_reads_mapped > minimum_pct_mapped)) {
        String warning_mapping = "TBPROF_" + profiler.tbprofiler_pct_reads_mapped + "_PCT_MAPPED_(MIN_" + minimum_pct_mapped + ")" #!StringCoercion
        if(!(soft_pct_mapped)) {
            String failed_mapping = "TBPROF_" + profiler.tbprofiler_pct_reads_mapped + "_PCT_MAPPED_(MIN_" + minimum_pct_mapped + ")" #!StringCoercion
        }
    }
    
    if(!(profiler.tbprofiler_median_coverage > minimum_coverage)) {
        String warning_coverage = "TBPROF_" + profiler.tbprofiler_median_coverage + "_COVERAGE_(MIN_" + minimum_coverage + ")" #!StringCoercion
        if(!(soft_coverage)) {
            String failed_coverage = "TBPROF_" + profiler.tbprofiler_median_coverage + "_COVERAGE_(MIN_" + minimum_coverage + ")" #!StringCoercion
        }
    }
    
    
    String error_or_pass = select_first([override, failed_mapping, failed_coverage, "PASS"])
    Array[String] warnings = select_all([warning_mapping, warning_coverage])
    if(length(warnings) < 0) {
        Array[String] no_warnings = ["PASS"]
    }
    
    output {
        # pass/fail
        String status_code = error_or_pass
        Array[String] warning_codes = select_first([no_warnings, warnings])
        
        # metrics
        Int    median_coverage = profiler.tbprofiler_median_coverage
        Float  pct_reads_mapped = profiler.tbprofiler_pct_reads_mapped
        Float  pct_genome_covered = csv_maker.tbp_parser_genome_percent_coverage
        String resistance = profiler.tbprofiler_dr_type
        String strain = profiler.tbprofiler_sub_lineage
        File   tbprofiler_json = profiler.tbprofiler_output_json
        Int    n_dr_variants = profiler.tbprofiler_num_dr_variants
        Int    n_other_variants = profiler.tbprofiler_num_other_variants
        Int    median_depth = profiler.tbprofiler_median_depth

        # metrics in TSV format for UShER annotation
        String sample_and_resistance = "${sample}\t${profiler.tbprofiler_dr_type}"
        String sample_and_strain = "${sample}\t${profiler.tbprofiler_sub_lineage}"
        String sample_and_coverage = "${sample}\t${profiler.tbprofiler_median_coverage}"
        
        # CSVs for other tools
        File tbprofiler_looker_csv = csv_maker.tbp_parser_looker_report_csv
        File tbprofiler_laboratorian_report_csv = csv_maker.tbp_parser_laboratorian_report_csv
        File tbprofiler_lims_report_csv = csv_maker.tbp_parser_lims_report_csv
        File tbprofiler_coverage_report_csv = csv_maker.tbp_parser_coverage_report

        # others
        File tbprofiler_tsv = tbprofiler.tbprofiler_output_tsv
        File tbprofiler_json = tbprofiler.tbprofiler_output_json
        
    }
}
