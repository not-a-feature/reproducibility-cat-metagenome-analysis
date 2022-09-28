"""
@author: Jules Kreuer
@contact: contact@juleskreuer.eu
"""


import argparse
import miniFasta as mf


def main(MIN_LEN, FA_PATH, OUT_PATH):
    print("Checking", FA_PATH, ", min length", MIN_LEN)

    if OUT_PATH is None:
        OUT_PATH = FA_PATH.rsplit(".", 1)[0] + ".filtered.fq"
    print("Writing to", OUT_PATH)

    fas = mf.read(FA_PATH)

    # Filter reads
    fas = filter(lambda fa: MIN_LEN < len(fa), fas)
    fas = list(fas)

    mf.write(out, OUT_PATH, "a")
    print("done")


if __name__ == "__main__":
    # Parse arguments
    parser = argparse.ArgumentParser(description="Splits fastq files at pos 150")
    parser.add_argument(
        "-fa", "--fasta", action="store", dest="fasta", help="Specify path to fasta file", required=True
    )
    parser.add_argument("-o", "--out", action="store", dest="out", help="Specify path to output file", required=False)
    parser.add_argument("-l", "--len", action="store", dest="len", help="Minimal length", required=True)

    args = parser.parse_args()
    MIN_LEN = int(args.len)
    FA_PATH = args.fasta
    OUT_PATH = args.out

    main(MIN_LEN, FA_PATH, OUT_PATH)
