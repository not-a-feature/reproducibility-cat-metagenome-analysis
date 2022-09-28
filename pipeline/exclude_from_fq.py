"""
@author: Jules Kreuer
@contact: jules.kreuer@uni-tuebingen.de
"""

import argparse
import fastq as fq

def main(LIST_PATH, FQ_PATH, OUT_PATH):
    print("Checking", FQ_PATH, "against", LIST_PATH)

    headers = set()

    # Read header file to include
    with open(LIST_PATH) as f:
        for l in f:
            headers.add(l.strip().lstrip("@"))

    if OUT_PATH is None:
        OUT_PATH = FQ_PATH.rsplit(".", 1)[0] + ".filtered.fq"
    print("Writing to", OUT_PATH)

    # Read fastq file
    fos = fq.read(FQ_PATH)

    # Filter reads
    fos = filter(lambda fo: fo.getHead().split()[0].lstrip("@") in headers, fos)
    fos = list(fos)

    fq.write(fos, OUT_PATH, "w")

    print("done")


if __name__ == "__main__":
    # Parse arguments
    parser = argparse.ArgumentParser(description='Remove reads that are not in header list')
    parser.add_argument('-l', "--list", action='store', dest='list', help='Specify path to list of headers to include', required=True)
    parser.add_argument('-fq', "--fastq", action='store', dest='fastq', help='Specify path to fastq file', required=True)
    parser.add_argument('-o', "--out", action='store', dest='out', help='Specify path to output file', required=False)
    
    args = parser.parse_args()
    LIST_PATH = args.list
    FQ_PATH = args.fastq
    OUT_PATH = args.out

    main(LIST_PATH, FQ_PATH, OUT_PATH)