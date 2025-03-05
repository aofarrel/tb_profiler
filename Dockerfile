# This Dockerfile adjusts tb-profiler's ref genome so we can feed it BAMs directly from myco
FROM staphb/tbprofiler:6.6.2
RUN wget https://raw.githubusercontent.com/aofarrel/tb_profiler/main/ref/tb_ref.fa
RUN samtools faidx tb_ref.fa
RUN bwa index tb_ref.fa

# Because our reference starts with >NC_000962.3 we need to run this
RUN tb-profiler update_tbdb --match_ref tb_ref.fa || true
