#!/usr/bin/python3
# Read characters from a table and generate Elm module
#
# Args:
#    module: Name of the module to output
#
# Example:
#
#   echo "
#   0061 [A] Latin Capital Letter A
#   ...
#   0410 [А] Cyrillic Capital Letter A
#   0411 [Б] Cyrillic Capital Letter Be
#   ...
#   " | extract_script_chars Cyrillic CyrillicTokens

import sys
import re

def escape(str):
    """ I believe string literals in Elm have only the
    backslash and double quote as special chars.
    Prove me wrong. """
    return str.replace("\\", "\\\\").replace("\"", "\\\"")


class Types:
    def __init__(self, tokens):
        self.tokens = list(tokens)

    def add(self, token):
        self.tokens.append(token)

    def syllabary(self):
        """ Generate a syllabary string, one type per line.

        The type name is written in angle brackets, followed by all tokens
        for the type. Example:

            〈Latin A〉Aa
            〈Latin B〉Bb
            〈Latin C〉Cc
        """
        types = {}
        for token in self.tokens:
            if token.group in types:
                types[token.group].append(token.token)
            else:
                types[token.group] = [token.token]

        lines = []
        for name, tokens in sorted(types.items()):
            cleaned_name = name.replace("<", "").replace(">", "")
            lines.append("〈{}〉{}".format(cleaned_name, "".join(tokens)))
        return "\n".join(lines)

    def lookup(self, prefix_map):
        # Keep a lookup table with key "name-dir", example key names:
        # "H1-dex", "H1-sin", "H4-ambi"
        names = {}
        for token in self.tokens:
            names[f"{token.name}-{token.dir}"] = token.token

        return Lookup(names, prefix_map)


class Lookup:
    def __init__(self, names, prefix_map):
        self.names = names
        self.prefix_map = prefix_map

    def closest(self, name, dir):
        """
        Search for the closest matching token for the given names.

        A token for the first matching name will be returned.
        """
        dir_name = f"{name}-{dir}"
        if dir_name in self.names:
            return self.names[dir_name]

        dir_name = f"{name}-ambi"
        if dir_name in self.names:
            return self.names[dir_name]

        for prefix, replacement in self.prefix_map.items():
            if name.startswith(prefix):
                return replacement

        raise KeyError(f"`{name}` not found.")


class Token:
    @classmethod
    def from_lines(cls, lines):
        """ Read lines with type definitions and yield Types. """
        selector = re.compile(r"\[(.)\]\s+(\S.*)$")
        for nr, line in enumerate(lines):
            match = selector.search(line)
            if match:
                yield cls.from_line(match.group(1), match.group(2))

    @classmethod
    def from_line(cls, token, name_str):
        # The format is
        #   <script> <name> <direction> <correspondences>
        # Example:
        #   Raet T3 sin [= Raet L1 dex = Raet P2 dex = Lep L]
        # Limit to three splits so the correspondeces are not split.
        name_words = name_str.split(None, 3)
        try:
            name_with_variant = name_words[1]
            group = re.sub("[0-9]+$", "", name_with_variant)

            # The writing direction is determined by either "sin" or
            # "dex" in the name. If the sign doesn't have either designation
            # we assume it can be used in both directions.
            third_word = dict(enumerate(name_words)).get(2, "")
            dir = third_word if third_word in ["sin", "dex"] else "ambi"
        except IndexError:
            raise ValueError("Need at least two words (script and name) but got '{}'"
                             .format(name_str))
        return cls(token, name_with_variant, group, name_str, dir)


    def __init__(self, token, name, group, desc, dir):
        self.token = token
        self.name = name
        self.group = group
        self.desc = desc
        self.dir = dir

    def elm_record(self):
        return ("""{{ token = '{}', name = "{}" }}"""
                .format(escape(self.token), escape(self.desc)))
