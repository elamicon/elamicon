# Elamicon

Elamicon is a tool that helps us decipher and publish ancient scripts.

The tool grew from an effort to catalogue
[Linear Elam](http://www.iranicaonline.org/articles/elam-iv)
glyphs. Our hope was to improve the knowledge about this obscure writing
system. Given the small corpus, it is unlikely that we will ever develop a
comprehensive understanding of the inscriptions unless a substantially bigger
body of inscriptions is discovered. We remain hopeful that new fragments will be
discovered. In this case we will extend the corpus to include the new material.

This tool has grown to incorporate other writing systems. You can browse
them on [our website center-for-decipherment.ch](https://center-for-decipherment.ch/tool/).


## Our goals

We want to make ancient writing systems accessible for digital processing. This includes:

- Catalogue all glyphs in their variants and create a digital font
- Transcribe all fragments into a text corpus
- Group glyph variants together so searching one variant finds the other too
- Offer search and counting functions that help in analyzing the corpus

We avoid permaturely narrowing the meaning of glyphs to predetermined sound values.
This means that many variants of glyphs are represented in our fonts. Only in a second
step these variants are grouped together. This allows
quickly changing the grouping to test out hypotheses. The tool allows switching quickly between adjusting the grouping and searching or frequency analysis. It all works without
installing anything.

Another focus of this project is effortless inclusion of the glyphs in publications. Once installed, the digital fonts we've created allow writing prose mixed with glyphs from the scripts. Sequences of glyphs in published papers can be copied into the search field to continue research immediately.


## Status

Multiple writing systems have been entered to varying extents:

Script|Font|Grouping|Corpus
------|----|--------|------
[Byblos](https://center-for-decipherment.ch/tool/#byblos)|✓|(✓)|✓
[Linear-Elam](https://center-for-decipherment.ch/tool/#elam)|✓|✓|✓
[Raetic](https://center-for-decipherment.ch/tool/#raetic)|✓|✓|-
[Lepontic](https://center-for-decipherment.ch/tool/#lepontic)|✓|-|-
[Etruscan](https://center-for-decipherment.ch/tool/#etruscan)|✓|✓|-
[Runes (Elder Futhark)](https://center-for-decipherment.ch/tool/#runic)|✓|-|-


## Contribute

You can help us transcribing text fragments from published sources.
Send us a mail with the new texts. Similarily, if you'ce created a new
Glyph grouping you think would be helpful to others, send it in so we
can include it.

If you'd like to create a font for a new script please contact us first
so we can talk about the codepoint range to use. We've used both
[Fontforge](http://fontforge.github.io) and [Inkscape](https://inkscape.org)
to create fonts. Other tools should work too.


## Building

To build your own version of the site you need `npm` and the node package
`elm`. To build the fonts, you need the `python-fontforge` bindings. On a
Debian-system, the following commands install these dependencies:

    apt install npm python-fontforge
    npm install -g elm elm-live
    make

You may find the `make live` target useful: It will open a browser window
that autoreloads whenever you save.


## Legalese

The corpus, font source, and all program code will be available under a
permissive license (sorry we haven't settled on the exact text yet). If you
claim copyright to text or glyph shapes on any of the fragments, please point
this out to us and we will gladly remove all traces of the forgery.

The compiled fonts are derivatives of the
[Liberation Fonts](https://fedorahosted.org/liberation-fonts/). They are
licensed under the SIL Open Font License, Version 1.1.

