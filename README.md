# Elamicon

We are cataloging [Linear Elam](http://www.iranicaonline.org/articles/elam-iv)
glyphs and try to group them into letters. Our hope is to improve the knowledge
about this obscure writing system. Given the small corpus, it
is unlikely that we will ever develop a comprehensive understanding of the
inscriptions unless a substantially bigger body of inscriptions is discovered.

You can visit the
[Elamicon catalog page](https://elamicon.github.io/) to see the corpus
we've developed so far.


## Our goals

- Catalog all glyphs found in Linear Elamite fragments (complete)
- Create a digital font from the glyphs (complete)
- Transcribe all known fragments of Linear Elamite into a text corpus (in progress)
- Offer basic tools that help in analyzing the corpus (in progress)

We are hopeful that new fragments will be discovered. In this case we will
extend the corpus to include the new material. Visit the
[Elamicon catalog](https://elamicon.github.io/) to explore what we've developed so far.



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

The compiled `ElamiconLiberation` fonts are derivatives of the
[Liberation Fonts](https://fedorahosted.org/liberation-fonts/). They are
licensed under the SIL Open Font License, Version 1.1.

