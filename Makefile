OFONTS = $(wildcard fonts/original/*.ttf)
MFONTS = $(subst fonts/original/,fonts/Elamicon,$(OFONTS))


all: elamicon.js $(MFONTS) fonts/Elamicon-Fonts.zip

elamicon.js: elamicon.elm
	elm-make elamicon.elm --output elamicon.js

fonts/ElamiconLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf elamicon.sfdir
	bin/addfont $^ "$@"

fonts/ElamiconLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf elamicon.sfdir
	bin/addfont $^ "$@"

fonts/ElamiconLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf elamicon.sfdir
	bin/addfont $^ "$@"

fonts/Elamicon-Fonts.zip: $(MFONTS)
	cd fonts && zip -r Elamicon-Fonts.zip *.ttf 

clean:
	rm -f elamicon.js
	rm -f fonts/*.ttf
	rm -f fonts/*.zip

live: $(MFONTS)
	elm-live elamicon.elm --output elamicon.js --open
