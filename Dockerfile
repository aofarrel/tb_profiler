# This Dockerfile adjusts tb-profiler's ref genome so we can feed it BAMs directly from myco
FROM staphb/tbprofiler:4.4.2
RUN wget https://raw.githubusercontent.com/aofarrel/tb_profiler/main/ref/tb_ref.fa
RUN samtools faidx tb_ref.fa
RUN bwa index tb_ref.fa

# This gets around a known bug in tbprofiler:4.4.2
# https://github.com/jodyphelan/TBProfiler/issues/278
RUN ls -lha && tb-profiler update_tbdb --match_ref tb_ref.fa || true
RUN cd tbdb && tb-profiler create_db --prefix tbdb --match_ref ../tb_ref.fa --load