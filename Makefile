OFONTS = $(wildcard fonts/original/Liberation*.ttf)
EFONTS = $(subst fonts/original/,fonts/Elamicon,$(OFONTS))
BFONTS = $(subst fonts/original/,fonts/Byblicon,$(OFONTS))
IFONTS = $(subst fonts/original/,fonts/NorthItalic,$(OFONTS))
TIMESPATH = /usr/share/fonts/truetype/msttcorefonts/


all: elamicon.js fonts/Elamicon-Fonts.zip fonts/Byblicon-Fonts.zip fonts/NorthItalic-Fonts.zip

build: build/elamicon.js fonts/Elamicon-Fonts.zip fonts/Byblicon-Fonts.zip fonts/NorthItalic-Fonts.zip fonts/copyright
	cp -r plates build
	cp -r css build
	cp index.html logo.png build
	mkdir -p build/fonts
	cp -r fonts/*Liberation* build/fonts
	cp -r fonts/*.zip build/fonts
	cp fonts/copyright build/fonts

fonts/original/north-italic.txt: fonts/original/north-italic.docx
	bin/docx_to_lines $^ > "$@"

src/Generated: fonts/original/north-italic.txt
	mkdir -p "$@"
	bin/select_script "Raet|All" < $^ | bin/extract_script_chars Generated.Raetic > src/Generated/Raetic.elm
	bin/select_script "Lep|All" < $^ | bin/extract_script_chars Generated.Lepontic > src/Generated/Lepontic.elm
	bin/select_script "Etr|All" < $^ | bin/extract_script_chars Generated.Etruscan > src/Generated/Etruscan.elm
	bin/select_script "Run|All" < $^ | bin/extract_script_chars Generated.Runic > src/Generated/Runic.elm

elms := $(wildcard *.elm src/*.elm src/Generated/*.elm) src/Generated

elamicon.js: $(elms)
	echo "module Generated.Build exposing (build)\nbuild = \"$$(date -u +%Y-%m-%dT%H:%M:%SZ) (commit $$(git rev-parse --short HEAD))\"" > src/Generated/Build.elm
	elm make --output="$@" elamicon.elm

build/elamicon.js: $(elms)
	mkdir -p build
	elm make --optimize --output=elamicon.opt.js elamicon.elm
	uglifyjs elamicon.opt.js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output="$@"


# The imports from Universität Wien are time consuming and are done manually.
# The import-results are committed to source-control.
dump/raetica:
	bin/download_wiki_xml https://www.univie.ac.at/raetica/api.php "$@"
	
dump/lexlep:
	bin/download_wiki_xml https://www.univie.ac.at/lexlep/api.php "$@"

src/Imported/RaeticInscriptions.elm: dump/raetica fonts/original/north-italic.txt
	bin/select_script "Raet" < fonts/original/north-italic.txt > dump/raetic-script.txt
	python3 bin/import_thesaurus Raetic dump/raetica/*-current.xml dump/raetic-script.txt > "$@"

src/Imported/LeponticInscriptions.elm: dump/lexlep fonts/original/north-italic.txt
	bin/select_script "Lep" < fonts/original/north-italic.txt > dump/lepontic-script.txt
	python3 bin/import_thesaurus \
		Lepontic \
		dump/lexlep/*-current.xml \
		dump/lepontic-script.txt > "$@"



fonts/elamicon-base.ttf: fonts/original/elamicon.sfdir fonts/original/special.sfdir
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSans-Regular.ttf: fonts/original/LiberationSans-Regular.ttf  fonts/elamicon-base.ttf
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSans-Bold.ttf: fonts/original/LiberationSans-Bold.ttf  fonts/elamicon-base.ttf
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSans-Italic.ttf: fonts/original/LiberationSans-Italic.ttf  fonts/elamicon-base.ttf
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSans-BoldItalic.ttf: fonts/original/LiberationSans-BoldItalic.ttf  fonts/elamicon-base.ttf
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf  fonts/elamicon-base.ttf
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf  fonts/elamicon-base.ttf
	bin/addfont "Elamicon" $^ "$@"

fonts/ElamiconLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf  fonts/elamicon-base.ttf
	bin/addfont "Elamicon" $^ "$@"

fonts/Elamicon-Fonts.zip: $(EFONTS) $(MFONTS) fonts/copyright
	cd fonts && zip -rq Elamicon-Fonts.zip ElamiconLiberation*.ttf copyright



fonts/byblos-fixed.svg: fonts/original/byblos.svg
	cp $^ "$@"
	bin/fix_glyph_names "$@"

fonts/byblos-scaled.ttf: fonts/byblos-fixed.svg
	bin/scale_font $^ 2 0 "$@"
	bin/set_bearing "$@" 200

fonts/byblos-base.ttf: fonts/byblos-scaled.ttf fonts/original/special.sfdir
	bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSans-Regular.ttf: fonts/original/LiberationSans-Regular.ttf fonts/byblos-base.ttf
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSans-Bold.ttf: fonts/original/LiberationSans-Bold.ttf fonts/byblos-base.ttf
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSans-Italic.ttf: fonts/original/LiberationSans-Italic.ttf fonts/byblos-base.ttf
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSans-BoldItalic.ttf: fonts/original/LiberationSans-BoldItalic.ttf fonts/byblos-base.ttf
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf fonts/byblos-base.ttf
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf fonts/byblos-base.ttf
		bin/addfont "Byblicon" $^ "$@"

fonts/BybliconLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf fonts/byblos-base.ttf
		bin/addfont "Byblicon" $^ "$@"

fonts/Byblicon-Fonts.zip: $(BFONTS) fonts/copyright
		cd fonts && zip -rq Byblicon-Fonts.zip BybliconLiberation*.ttf copyright



fonts/north-italic-fixed.svg: fonts/original/north-italic.svg
	cp $^ "$@"
	bin/fix_glyph_names "$@"

fonts/north-italic-scaled.ttf: fonts/north-italic-fixed.svg
	bin/scale_font $^ 2.15 -560 "$@"
	bin/set_bearing "$@" 200

fonts/north-italic-scaled-garamond.ttf: fonts/north-italic-fixed.svg
	bin/scale_font $^ 1.02 -280 "$@"
	bin/set_bearing "$@" 200

fonts/north-italic-base.ttf: fonts/north-italic-scaled.ttf fonts/original/special.sfdir
	bin/addfont "NorthItalic" $^ "$@"

fonts/north-italic-base-garamond.ttf: fonts/north-italic-scaled-garamond.ttf fonts/original/special.sfdir
	bin/addfont "NorthItalic" $^ "$@"

fonts/NorthItalicLiberationSans-Regular.ttf: fonts/original/LiberationSans-Regular.ttf fonts/north-italic-base.ttf
		bin/addfont "NorthItalic" $^ "$@"

fonts/NorthItalicLiberationSans-Bold.ttf: fonts/original/LiberationSans-Bold.ttf fonts/north-italic-base.ttf
		bin/addfont "NorthItalic" $^ "$@"

fonts/NorthItalicLiberationSans-Italic.ttf: fonts/original/LiberationSans-Italic.ttf fonts/north-italic-base.ttf
		bin/addfont "NorthItalic" $^ "$@"

fonts/NorthItalicLiberationSans-BoldItalic.ttf: fonts/original/LiberationSans-BoldItalic.ttf fonts/north-italic-base.ttf
		bin/addfont "NorthItalic" $^ "$@"

fonts/NorthItalicLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf fonts/north-italic-base.ttf
		bin/addfont "NorthItalic" $^ "$@"

fonts/NorthItalicLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf fonts/north-italic-base.ttf
		bin/addfont "NorthItalic" $^ "$@"

fonts/NorthItalicLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf fonts/north-italic-base.ttf
		bin/addfont "NorthItalic" $^ "$@"

fonts/NorthItalic-Fonts.zip: $(IFONTS) fonts/copyright
		cd fonts && zip -rq NorthItalic-Fonts.zip NorthItalicLiberation*.ttf copyright



clean:
	rm -f elamicon*.js
	rm -f fonts/*.ttf
	rm -f fonts/*.zip
	rm -rf build
	rm -rf src/Generated

live: $(MFONTS)
	elm-live elamicon.elm --output elamicon.js --open


ElamiconTimes: fonts/Elamicon_Times_New_Roman.zip

fonts/Elamicon_Times_New_Roman.zip: fonts/Elamicon_Times_New_Roman_Bold_Italic.ttf fonts/Elamicon_Times_New_Roman_Italic.ttf fonts/Elamicon_Times_New_Roman_Bold.ttf fonts/Elamicon_Times_New_Roman.ttf
	zip -rq fonts/Elamicon_Times_New_Roman.zip $^

fonts/Elamicon_Times_New_Roman_Bold_Italic.ttf: fonts/original/elamicon.sfdir
	bin/addfont "Elamicon-" $(TIMESPATH)Times_New_Roman_Bold_Italic.ttf $^ $@

fonts/Elamicon_Times_New_Roman_Italic.ttf: fonts/original/elamicon.sfdir
	bin/addfont "Elamicon-" $(TIMESPATH)Times_New_Roman_Italic.ttf $^ $@

fonts/Elamicon_Times_New_Roman_Bold.ttf: fonts/original/elamicon.sfdir
	bin/addfont "Elamicon-" $(TIMESPATH)Times_New_Roman_Bold.ttf $^ $@

fonts/Elamicon_Times_New_Roman.ttf: fonts/original/elamicon.sfdir
	bin/addfont "Elamicon-" $(TIMESPATH)Times_New_Roman.ttf $^ $@

BybliconTimes: fonts/Byblicon_Times_New_Roman.zip

fonts/Byblicon_Times_New_Roman.zip: fonts/Byblicon_Times_New_Roman_Bold_Italic.ttf fonts/Byblicon_Times_New_Roman_Italic.ttf fonts/Byblicon_Times_New_Roman_Bold.ttf fonts/Byblicon_Times_New_Roman.ttf
	zip -rq fonts/Byblicon_Times_New_Roman.zip $^

fonts/Byblicon_Times_New_Roman_Bold_Italic.ttf: fonts/byblos-scaled.ttf
	bin/addfont "Byblicon-" $(TIMESPATH)Times_New_Roman_Bold_Italic.ttf $^ $@

fonts/Byblicon_Times_New_Roman_Italic.ttf: fonts/byblos-scaled.ttf
	bin/addfont "Byblicon-" $(TIMESPATH)Times_New_Roman_Italic.ttf $^ $@

fonts/Byblicon_Times_New_Roman_Bold.ttf: fonts/byblos-scaled.ttf
	bin/addfont "Byblicon-" $(TIMESPATH)Times_New_Roman_Bold.ttf $^ $@

fonts/Byblicon_Times_New_Roman.ttf: fonts/byblos-scaled.ttf
	bin/addfont "Byblicon-" $(TIMESPATH)Times_New_Roman.ttf $^ $@


NorthItalicTimes: fonts/NorthItalic_Times_New_Roman.zip

fonts/NorthItalic_Times_New_Roman.zip: fonts/NorthItalic_Times_New_Roman_Bold_Italic.ttf fonts/NorthItalic_Times_New_Roman_Italic.ttf fonts/NorthItalic_Times_New_Roman_Bold.ttf fonts/NorthItalic_Times_New_Roman.ttf
	zip -rq $@ $^


fonts/NorthItalic_Times_New_Roman_Bold_Italic.ttf: fonts/north-italic-base.ttf
	bin/addfont "NorthItalic-" $(TIMESPATH)Times_New_Roman_Bold_Italic.ttf $^ $@

fonts/NorthItalic_Times_New_Roman_Italic.ttf: fonts/north-italic-base.ttf
	bin/addfont "NorthItalic-" $(TIMESPATH)Times_New_Roman_Italic.ttf $^ $@

fonts/NorthItalic_Times_New_Roman_Bold.ttf: fonts/north-italic-base.ttf
	bin/addfont "NorthItalic-" $(TIMESPATH)Times_New_Roman_Bold.ttf $^ $@

fonts/NorthItalic_Times_New_Roman.ttf: fonts/north-italic-base.ttf
	bin/addfont "NorthItalic-" $(TIMESPATH)Times_New_Roman.ttf $^ $@


fonts/NorthItalic_Garamond.zip: fonts/NorthItalic_Garamond_Bold_Italic.ttf fonts/NorthItalic_Garamond_Italic.ttf fonts/NorthItalic_Garamond_Bold.ttf fonts/NorthItalic_Garamond.ttf fonts/NorthItalic_Garamond_Semibold.ttf fonts/NorthItalic_Garamond_Semibold_Italic.ttf
	zip -rq $@ $^


fonts/NorthItalic_Garamond_Bold_Italic.ttf: fonts/north-italic-base-garamond.ttf
	bin/addfont "NorthItalic-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro-Bold-Italic_2007.ttf $^ $@

fonts/NorthItalic_Garamond_Bold.ttf: fonts/north-italic-base-garamond.ttf
	bin/addfont "NorthItalic-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro-Bold_2008.ttf $^ $@

fonts/NorthItalic_Garamond_Italic.ttf: fonts/north-italic-base-garamond.ttf
	bin/addfont "NorthItalic-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro-Italic_2009.ttf $^ $@

fonts/NorthItalic_Garamond_Semibold.ttf: fonts/north-italic-base-garamond.ttf
	bin/addfont "NorthItalic-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro-Semibold_2011.ttf $^ $@

fonts/NorthItalic_Garamond_Semibold_Italic.ttf: fonts/north-italic-base-garamond.ttf
	bin/addfont "NorthItalic-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro-Semibold-Italic_2010.ttf $^ $@

fonts/NorthItalic_Garamond.ttf: fonts/north-italic-base-garamond.ttf
	bin/addfont "NorthItalic-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro_2012.ttf $^ $@

.DELETE_ON_ERROR:
