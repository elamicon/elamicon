#!/usr/bin/env python3
"""
Print each char from stdin in hex
"""
import sys

input_string = sys.stdin.read()

for pos, char in enumerate(input_string):
    codepoint = ord(char)
    print(f"{pos:3d} {codepoint:>4x} {char}")