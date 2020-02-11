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
    """
    List of token groups that are considered one type.
    """
    @classmethod
    def from_tokens(cls, tokens):
        types = cls()
        for t in tokens:
            types.add(t)
        return types

    def __init__(self):
        self.types = {}

        # Keep a lookup table with key "name-dir", example key names:
        # "H1-dex", "H1-sin", "H4-ambi"
        self.names = {}

    def add(self, token):
        if token.group in self.types:
            self.types[token.group].append(token.token)
        else:
            self.types[token.group] = [token.token]

        # token name, but also the group name if that name has not

        group_dir_name = f"{token.group}-{token.dir}"
        if group_dir_name not in self.names:
            self.names[group_dir_name] = token.token

    def syllabary(self):
        """ Generate a syllabary string, one type per line.

        The type name is written in angle brackets, followed by all tokens
        for the type. Example:

            〈Latin A〉Aa
            〈Latin B〉Bb
            〈Latin C〉Cc
        """
        lines = []
        for name, tokens in sorted(self.types.items()):
            lines.append("〈{}〉{}".format(name, "".join(tokens)))
        return "\n".join(lines)

    def closest(self, names, dir):
        """
        Search for the closest matching token for the given names.

        A token for the first matching name will be returned. If the name
        matches a group name, the first token from the group is returned.
        """
        for n in names:
            dir_name = f"{n}-{dir}"
            if dir_name in self.names:
                return self.names[dir_name]
        for n in names:
            dir_name = f"{n}-ambi"
            if dir_name in self.names:
                return self.names[dir_name]
        raise KeyError(f"None of `{names}` found.")


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
        name_words = name_str.split()
        try:
            name_with_variant = name_words[1]
            group = re.sub("[0-9]+$", "", name_with_variant)

            # The writing direction is determined by either "sin" or
            # "dex" in the name. If the sign doesn't have either designation
            # we assume it can be used in both directions.
            dir = (
                "RTL" if "sin" in name_words else
                "LTR" if "dex" in name_words else
                "ambi")
        except IndexError:
            raise ValueError("Need at least two words (script and name) but got '{}'"
                             .format(name_str))
        return cls(token, name_str, group, dir)


    def __init__(self, token, name, group, dir):
        self.token = token
        self.name = name
        self.group = group
        self.dir = dir

    def elm_record(self):
        return ("""{{ token = '{}', name = "{}" }}"""
                .format(escape(self.token), escape(self.name)))


if __name__ == "__main__":
    module_name = sys.argv[1]

    tokens = list(Token.from_lines(sys.stdin))
    token_str = "\n ,".join([t.elm_record() for t in tokens])

    types = Types.from_tokens(tokens)
    type_str = types.syllabary()
    print('module {} exposing (tokens, syllabary)\ntokens =\n [{}\n ]\nsyllabary = """{}"""'
        .format(module_name, token_str, escape(type_str)))
