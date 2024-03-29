# This is goofy and not very efficient, but it gets the job done
# It's not implemented in the WDL

import os
from tqdm import tqdm
import subprocess

with open("paths_to_all_jsons.txt", 'r') as paths:
    jsons = [line.rstrip() for line in paths]
with open("lineages.txt", "a") as lineage_file:
    for json in tqdm(jsons):
        sample = os.path.basename(json).strip("to_Ref.H37Rv.bam").strip(".results.json").strip(".TBProfiler.json")
        with subprocess.Popen(f"ack ./{json} -o --match '(?<=sublin\": \")(.*?)(?=\")' ", 
                shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) as ack:
            for output in ack.stdout:
                if '"' in output.decode('UTF-8'):
                    lineage_file.write(f"{sample}\tUnknown\n")
                elif output.decode('UTF-8').startswith("\n"):
                    pass
                else:
                    lineage_file.write(f"{sample}\t{output.decode('UTF-8')}")
