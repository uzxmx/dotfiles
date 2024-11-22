#!/usr/bin/env python

import sys
import argparse

if __name__ == '__main__':
    epilog = '''
Find lines from a file which are not present in another file.

Examples:
  # Output lines only in foo.txt
  $> diff common foo.txt bar.txt

  # Output lines in both files
  $> diff common -c foo.txt bar.txt
'''
    parser = argparse.ArgumentParser(usage='diff common', epilog=epilog, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-c', '--common', action='store_true', help='Output lines in both files')
    args, unknown_args = parser.parse_known_args()
    if len(unknown_args) != 2:
        print("You should specify two text files to compare.")
        sys.exit(1)
    with open(unknown_args[0]) as f:
        lines_1 = f.read().splitlines()
    with open(unknown_args[1]) as f:
        lines_2 = f.read().splitlines()
    result = []
    if args.common:
        for l in lines_1:
            if l in lines_2:
                result.append(l)
    else:
        for l in lines_1:
            if l not in lines_2:
                result.append(l)

    for l in result:
        print(l)
