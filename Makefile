OFONTS = $(wildcard fonts/original/Liberation*.ttf)
EFONTS = $(subst fonts/original/,fonts/Elamicon,$(OFONTS))
CFONTS = $(subst fonts/original/,fonts/CMinoan,$(OFONTS))
TIMESPATH = /usr/share/fonts/truetype/msttcorefonts/

all: elamicon.js $(EFONTS) $(CFONTS) fonts/Elamicon-Fonts.zip fonts/CMinoan-Fonts.zip build/elamicon.zip

elms := $(wildcard *.elm src/*.elm)
elamicon.js: $(elms)
	elm-make elamicon.elm --output elamicon.js

fonts/ElamiconLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/Elamicon-Fonts.zip: $(MFONTS)
	cd fonts && zip -r Elamicon-Fonts.zip ElamiconLiberation*.ttf


fonts/CMinoanLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf
	bin/addfont "Cypricon" $^ "$@"

fonts/CMinoanLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf 
	bin/addfont "Cypricon" $^ "$@"

fonts/CMinoanLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf
	bin/addfont "Cypricon" $^ "$@"

fonts/CMinoan-Fonts.zip: $(CFONTS)
	cd fonts && zip -r CMinoan-Fonts.zip CMinoanLiberation*.ttf

clean:
	rm -f elamicon.js
	rm -f fonts/*.ttf
	rm -f fonts/*.zip
	rm -rf build

live: $(MFONTS)
	elm-live elamicon.elm --output elamicon.js --open

build/elamicon.zip: elamicon.js index.html css/main.css 
	mkdir -p build
	rm -f "$@"
	zip -r "$@" $^ fonts/*.ttf

Times: fonts/Elamicon_Times_New_Roman.zip

fonts/Elamicon_Times_New_Roman.zip: fonts/Elamicon_Times_New_Roman_Bold_Italic.ttf fonts/Elamicon_Times_New_Roman_Italic.ttf fonts/Elamicon_Times_New_Roman_Bold.ttf fonts/Elamicon_Times_New_Roman.ttf
	zip -r fonts/Elamicon_Times_New_Roman.zip $^

fonts/Elamicon_Times_New_Roman_Bold_Italic.ttf: elamicon.sfdir
	bin/addfont "Elamicon-" $(TIMESPATH)Times_New_Roman_Bold_Italic.ttf $^ $@

fonts/Elamicon_Times_New_Roman_Italic.ttf: elamicon.sfdir
	bin/addfont "Elamicon-" $(TIMESPATH)Times_New_Roman_Italic.ttf $^ $@

fonts/Elamicon_Times_New_Roman_Bold.ttf: elamicon.sfdir
	bin/addfont "Elamicon-" $(TIMESPATH)Times_New_Roman_Bold.ttf $^ $@

fonts/Elamicon_Times_New_Roman.ttf: elamicon.sfdir
	bin/addfont "Elamicon-" $(TIMESPATH)Times_New_Roman.ttf $^ $@
