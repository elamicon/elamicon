OFONTS = $(wildcard fonts/original/Liberation*.ttf)
EFONTS = $(subst fonts/original/,fonts/Elamicon,$(OFONTS))
CFONTS = $(subst fonts/original/,fonts/Cypricon,$(OFONTS))
BFONTS = $(subst fonts/original/,fonts/Byblicon,$(OFONTS))
TIMESPATH = /usr/share/fonts/truetype/msttcorefonts/

all: build/elamicon.zip

elms := $(wildcard *.elm src/*.elm)

dev: $(elms)
	elm make --output=elamicon.js elamicon.elm

elamicon.min.js: $(elms)
	elm make --optimize --output=elamicon.opt.js elamicon.elm
	uglifyjs elamicon.opt.js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output="$@"

fonts/ElamiconLiberationSans-Regular.ttf: fonts/original/LiberationSans-Regular.ttf  fonts/original/elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSans-Bold.ttf: fonts/original/LiberationSans-Bold.ttf  fonts/original/elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSans-Italic.ttf: fonts/original/LiberationSans-Italic.ttf  fonts/original/elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSans-BoldItalic.ttf: fonts/original/LiberationSans-BoldItalic.ttf  fonts/original/elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf  fonts/original/elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf  fonts/original/elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf  fonts/original/elamicon.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/Elamicon-Fonts.zip: $(EFONTS) $(MFONTS)
	cd fonts && zip -r Elamicon-Fonts.zip ElamiconLiberation*.ttf

fonts/CypriconLiberationSans-Regular.ttf: fonts/original/LiberationSans-Regular.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf
		bin/addfont "Cypricon" $^ "$@"

fonts/CypriconLiberationSans-Bold.ttf: fonts/original/LiberationSans-Bold.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf 
		bin/addfont "Cypricon" $^ "$@"

fonts/CypriconLiberationSans-Italic.ttf: fonts/original/LiberationSans-Italic.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf 
		bin/addfont "Cypricon" $^ "$@"

fonts/CypriconLiberationSans-BoldItalic.ttf: fonts/original/LiberationSans-BoldItalic.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf 
		bin/addfont "Cypricon" $^ "$@"

fonts/CypriconLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf
		bin/addfont "Cypricon" $^ "$@"

fonts/CypriconLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf 
		bin/addfont "Cypricon" $^ "$@"

fonts/CypriconLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf fonts/original/Cypro-Minoan.sfdir fonts/original/CMinoanHinted.ttf
		bin/addfont "Cypricon" $^ "$@"

fonts/Cypricon-Fonts.zip: $(CFONTS)
		cd fonts && zip -r Cypricon-Fonts.zip CypriconLiberation*.ttf

fonts/byblos-fixed.svg: fonts/original/byblos.svg
	cp $^ "$@"
	bin/fix_glyph_names "$@"

fonts/byblos-scaled.ttf: fonts/byblos-fixed.svg
	bin/scale_font $^ 2 "$@"
	bin/set_bearing "$@" 200 

fonts/BybliconLiberationSans-Regular.ttf: fonts/original/LiberationSans-Regular.ttf fonts/byblos-scaled.ttf fonts/original/byblos-special.sfdir
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSans-Bold.ttf: fonts/original/LiberationSans-Bold.ttf fonts/byblos-scaled.ttf fonts/original/byblos-special.sfdir
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSans-Italic.ttf: fonts/original/LiberationSans-Italic.ttf fonts/byblos-scaled.ttf fonts/original/byblos-special.sfdir 
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSans-BoldItalic.ttf: fonts/original/LiberationSans-BoldItalic.ttf fonts/byblos-scaled.ttf fonts/original/byblos-special.sfdir 
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf fonts/byblos-scaled.ttf fonts/original/byblos-special.sfdir
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf fonts/byblos-scaled.ttf fonts/original/byblos-special.sfdir 
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf fonts/byblos-scaled.ttf fonts/original/byblos-special.sfdir
		bin/addfont "Byblicon" $^ "$@"

fonts/Byblicon-Fonts.zip: $(BFONTS)
		cd fonts && zip -r Byblicon-Fonts.zip BybliconLiberation*.ttf

clean:
	rm -f elamicon*.js
	rm -f fonts/*.ttf
	rm -f fonts/*.zip
	rm -rf build

live: $(MFONTS)
	elm-live elamicon.elm --output elamicon.js --open

build/elamicon.zip: elamicon.min.js index.html css/main.css $(EFONTS) $(BFONTS)
	mkdir -p build
	rm -f "$@"
	zip -rq "$@" $^ fonts/*Liberation*.ttf

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
