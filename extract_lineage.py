import os
from tqdm import tqdm
import subprocess

jsons = os.listdir(".")
with open("lineages.txt", "a") as lineage_file:
    for json in tqdm(jsons):
        sample = os.path.basename(json).strip("to_Ref.H37Rv.bam.results.json")
        with subprocess.Popen(f"ack ./{json} -o --match '(?<=sublin\": \")(.*?)(?=\")' ", 
                shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) as ack:
            for output in ack.stdout:
                if '"' in output.decode('UTF-8'):
                    lineage_file.write(f"{sample}: ??? \n")
                elif output.decode('UTF-8').startswith("\n"):
                    pass
                else:
                    lineage_file.write(f"{sample}: {output.decode('UTF-8')}")