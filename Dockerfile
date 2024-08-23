# This Dockerfile adjusts tb-profiler's ref genome so we can feed it BAMs directly from myco
FROM staphb/tbprofiler:6.2.1
RUN wget https://raw.githubusercontent.com/aofarrel/tb_profiler/main/ref/tb_ref.fa
RUN samtools faidx tb_ref.fa
RUN bwa index tb_ref.fa