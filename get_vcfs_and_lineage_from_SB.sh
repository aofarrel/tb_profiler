# get all vcfs
awk '{print ".\/rand_runs\/"$2"\/"$1".vcf"}' tba3_all_samples_no_dupes.tsv > tba3_all_no_dupe.invalid_first_line.vcf.tsv
tail -n +2 tba3_all_no_dupe.invalid_first_line.vcf.tsv > tba3_all_no_dupe.vcf.tsv
rm tba3_all_no_dupe.invalid_first_line.vcf.tsv

# get all lineage information
awk '{print $1"\t"$8}' tba3_all_samples_no_dupes.tsv > tba3_all_samples_lineage.tsv
sed 's/lineage//;s/;lineage/;/' tba3_all_samples_lineage.tsv > tba3_all_samples_lineage_concise.tsv
