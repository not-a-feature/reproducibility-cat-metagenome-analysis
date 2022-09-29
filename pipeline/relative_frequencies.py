#!/usr/bin/python3
import sys
from collections import defaultdict
from group_assignment_data import *

phylum_counter = {}
tax_lookup = defaultdict(lambda: None)


with open(sys.argv[1]) as f:
    for line in f:
        dongle = line.split()
        tax_lookup[dongle[0].strip()] = dongle[1].strip()

# for v in set(tax_lookup.values()):
#     phylum_counter[v] = 0


for v in ["Actinobacteria", "Bacteriodetes", "Firmicutes", "Fusobacteria", "Proteobacteria", "Other"]:
    phylum_counter[v] = 0

total = 0
with open(sys.argv[2]) as f:
    for line in f:
        tax = tax_lookup[line.strip()]
        if tax:
            if tax in actinobacteria:
                phylum = "Actinobacteria"
            elif tax in bacteriodetes:
                phylum = "Bacteriodetes"
            elif tax in firmicutes:
                phylum = "Firmicutes"
            elif tax in fusobacteria:
                phylum = "Fusobacteria"
            elif tax in proteobacteria:
                phylum = "Proteobacteria"
            else:
                phylum = "Other"
            total = total + 1
            phylum_counter[phylum] = phylum_counter[phylum] + 1


for k, v in sorted(phylum_counter.items(), key=lambda x: x[1], reverse=True):
    print(f"{k} {v} {v / total}")
