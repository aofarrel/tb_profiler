# This Dockerfile adjusts tb-profiler's ref genome so we can feed it BAMs directly from myco
FROM staphb/tbprofiler:4.4.2
RUN wget https://raw.githubusercontent.com/aofarrel/myco/3.1.0/inputs/ref/tb_seq.fasta 
RUN samtools faidx tb_seq.fasta
RUN bwa index tb_seq.fasta

# This gets around a known bug in tbprofiler:4.4.2
# https://github.com/jodyphelan/TBProfiler/issues/278
RUN ls -lha && tb-profiler update_tbdb --match_ref tb_seq.fasta || true
RUN cd tbdb && tb-profiler create_db --prefix tbdb --match_ref ../tb_seq.fasta --load