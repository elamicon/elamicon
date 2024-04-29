#!/usr/bin/env python3

# Reorder sign list from two column pdf
#
# Example:
#
#     python3 signlistclean.py < signlist.txt > signlistclean.txt

import sys

# HACK some signs have two images or no image at all

no_image = {
    "M136~w",
    "M154~b",
    "M193~b",
    "M207~ca",
    "M248~b",
    "M262~b",
    "M262~ba",
    "M262~bb",
    "M266~f",
    "M297~c",
    "M305+M332",
    "M316~q",
    "M317+M260",
    "M317+M365~d",
    "M323~b",
    "M329~a",
    "M329~b",
    "M329~c",
    "M332",
    "M339",
    "M340~b",
    "M341",
    "M341~a",
    "M341~b",
    "M341~q",
    "M342~i",
    "M370~m",
    "M370+MXXX+M370",
    "M370+MXXX+MXXX",
    "M375~e",
    "M375~ia",
    "M377+MXXX+M377",
    "M393~a",
    "M393~e",
    "M417",
    "M419~m",
    "M419~q",
    "M429",
    "M447~e",
    "M461~q",
    "M461~qa",
    "MXXX+M383+MXXX",
    "M507",
    "M508",
    "M509",
    "M064~d",
    "M454~b",
    "M401",
    "M332~g",
    "M128~dd",
    "M332~a",
    "M402",
    "M343~h+M353",
    "M157~a+M131~a",
}

extra_version = {
    "M006~a",
    "M010",
    "M024",
    "M024~a",
    "M036+1(N30D)",
    "M046",
    "M050~k",
    "M057~a",
    "M057~b",
    "M059~f",
    "M081",
    "M096",
    "M106",
    "M106+M288",
    "M111~o",
    "M112",
    "M122",
    "M146",
    "M206~d",
    "M209~d",
    "M218",
    "M218+M288",
    "M219",
    "M249~n",
    "M259",
    "M260",
    "M260+1(N24)",
    "M261~a",
    "M261~b",
    "M261~d",
    "M262",
    "M263",
    "M263~a",
    "M263~b",
    "M264~a",
    "M264~d",
    "M265",
    "M310",
    "M316",
    "M317",
    "M318~a",
    "M323",
    "M346",
    "M346~a",
    "M367~a",
    "M384~d",
}

columns = [[], []]
last_line = ""

def print_columns():
    global columns
    for column in columns:
        for name in column:
            if name in no_image:
                continue
            print(name)
            if name in extra_version:
                print(f"{name}.1")
    columns = [[], []]

for line in sys.stdin.buffer.readlines():
    try:
        line = line.decode("utf-8")
    except UnicodeDecodeError:
        continue
    if "©" in line:
        # page break
        print_columns()
        last_line = ""
        continue
    words = line.split()
    for i in range(2):
        if len(words) > i:
            word = words[i]
            if word.startswith("M"):
                columns[i].append(word)
            else:
                if last_line.startswith("M"):
                    # HACK some words are split to the next line, luckily
                    # only in the first column.
                    columns[i][-1] += word
                    last_line = ""
    last_line = line

print_columns()