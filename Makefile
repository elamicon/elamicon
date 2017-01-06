OFONTS = $(wildcard fonts/original/*.ttf)
MFONTS = $(subst fonts/original/,fonts/Elamicon,$(OFONTS))
TIMESPATH = /usr/share/fonts/truetype/msttcorefonts/

all: elamicon.js $(MFONTS) fonts/Elamicon-Fonts.zip

elamicon.js: elamicon.elm Elam.elm Grams.elm
	elm-make elamicon.elm --output elamicon.js

fonts/ElamiconLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/Elamicon-Fonts.zip: $(MFONTS)
	cd fonts && zip -r Elamicon-Fonts.zip ElamiconLiberation*.ttf 

clean:
	rm -f elamicon.js
	rm -f fonts/*.ttf
	rm -f fonts/*.zip

live: $(MFONTS)
	elm-live elamicon.elm --output elamicon.js --open

Times: fonts/Elamicon_Times_New_Roman.zip

fonts/Elamicon_Times_New_Roman.zip: fonts/Elamicon_Times_New_Roman_Bold_Italic.ttf fonts/Elamicon_Times_New_Roman_Italic.ttf fonts/Elamicon_Times_New_Roman_Bold.ttf fonts/Elamicon_Times_New_Roman.ttf
	zip -r fonts/Elamicon_Times_New_Roman.zip $^

fonts/Elamicon_Times_New_Roman_Bold_Italic.ttf: elamicon.sfdir
	bin/addfont "Elamicon " $(TIMESPATH)Times_New_Roman_Bold_Italic.ttf $^ $@

fonts/Elamicon_Times_New_Roman_Italic.ttf: elamicon.sfdir
	bin/addfont "Elamicon " $(TIMESPATH)Times_New_Roman_Bold.ttf $^ $@

fonts/Elamicon_Times_New_Roman_Bold.ttf: elamicon.sfdir
	bin/addfont "Elamicon " $(TIMESPATH)Times_New_Roman_Bold.ttf $^ $@

fonts/Elamicon_Times_New_Roman.ttf: elamicon.sfdir
	bin/addfont "Elamicon " $(TIMESPATH)Times_New_Roman.ttf $^ $@
