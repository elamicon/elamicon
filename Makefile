OFONTS = $(wildcard fonts/original/Liberation*.ttf)
FONTS = $(subst fonts/original/,fonts/GEAS,$(OFONTS))
TIMESPATH = /usr/share/fonts/truetype/msttcorefonts/


all: elamicon.js fonts/GEAS-Fonts.zip

build: build/elamicon.js fonts/GEAS-Fonts.zip webfonts
	cp -r plates build
	cp -r css build
	cp index.html logo.png build
	mkdir -p build/fonts
	cp -r fonts/*Liberation* build/fonts
	cp -r fonts/*Reddit* build/fonts
	cp -r fonts/*.zip build/fonts
	cp fonts/copyright build/fonts

fonts/original/deir-alla.txt: fonts/original/deir-alla.docx
	bin/docx_to_lines $^ > "$@"

fonts/original/north-italic.txt: fonts/original/north-italic.docx
	bin/docx_to_lines $^ > "$@"

src/Generated: fonts/original/north-italic.txt fonts/original/deir-alla.txt
	mkdir -p "$@"
	bin/select_script "Raet|All" < fonts/original/north-italic.txt | bin/extract_script_chars Generated.Raetic > src/Generated/Raetic.elm
	bin/select_script "Lep|All" < fonts/original/north-italic.txt | bin/extract_script_chars Generated.Lepontic > src/Generated/Lepontic.elm
	bin/select_script "Etr|All" < fonts/original/north-italic.txt | bin/extract_script_chars Generated.Etruscan > src/Generated/Etruscan.elm
	bin/select_script "Run|All" < fonts/original/north-italic.txt | bin/extract_script_chars Generated.Runic > src/Generated/Runic.elm
	bin/extract_script_chars Generated.DeirAlla < fonts/original/deir-alla.txt > src/Generated/DeirAlla.elm

elms := $(wildcard *.elm src/*.elm src/Generated/*.elm) src/Generated

elamicon.js: $(elms)
	elm make --output="$@" src/Main.elm

build/elamicon.js: $(elms)
	echo "module Generated.Build exposing (build)\nbuild = \"$$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" > src/Generated/Build.elm
	mkdir -p build
	elm make --optimize --output=elamicon.opt.js src/Main.elm
	uglifyjs elamicon.opt.js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output "$@"


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



fonts/geas-base.ttf: \
	fonts/original/elamicon.sfdir \
	fonts/byblos-scaled.ttf \
	fonts/deir-alla-scaled.ttf \
	fonts/north-italic-scaled.ttf \
	fonts/original/special.sfdir
	bin/addfont "GEAS" $^ "$@"

fonts/GEASLiberationSans-Regular.ttf: fonts/original/LiberationSans-Regular.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASLiberationSans-Bold.ttf: fonts/original/LiberationSans-Bold.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASLiberationSans-Italic.ttf: fonts/original/LiberationSans-Italic.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASLiberationSans-BoldItalic.ttf: fonts/original/LiberationSans-BoldItalic.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASLiberationSerif-Regular.ttf: fonts/original/LiberationSerif-Regular.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASLiberationSerif-Bold.ttf: fonts/original/LiberationSerif-Bold.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASLiberationMono-Regular.ttf: fonts/original/LiberationMono-Regular.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"



fonts/GEAS-Fonts.zip: $(FONTS) fonts/copyright
	cd fonts && zip -rq GEAS-Fonts.zip GEASLiberation*.ttf copyright


fonts/GEASRedditSans-Regular.ttf: fonts/original/RedditSans/RedditSans-Regular.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASRedditSans-Bold.ttf: fonts/original/RedditSans/RedditSans-Bold.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASRedditSans-Italic.ttf: fonts/original/RedditSans/RedditSans-Italic.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASRedditSansCondensed-Regular.ttf: fonts/original/RedditSansCondensed/RedditSansCondensed-Regular.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

fonts/GEASRedditSansCondensed-Bold.ttf: fonts/original/RedditSansCondensed/RedditSansCondensed-Bold.ttf fonts/geas-base.ttf
		bin/addfont "GEAS" $^ "$@"

webfonts: \
	fonts/GEASRedditSans-Regular.ttf \
	fonts/GEASRedditSans-Bold.ttf \
	fonts/GEASRedditSans-Italic.ttf \
	fonts/GEASRedditSansCondensed-Regular.ttf \
	fonts/GEASRedditSansCondensed-Bold.ttf

fonts/byblos-fixed.svg: fonts/original/byblos.svg
	cp $^ "$@"
	bin/fix_glyph_names "$@"

fonts/byblos-scaled.ttf: fonts/byblos-fixed.svg
	bin/scale_font $^ 2 0 "$@"
	bin/set_bearing "$@" 200



fonts/north-italic-fixed.svg: fonts/original/north-italic.svg
	cp $^ "$@"
	bin/fix_glyph_names "$@"

fonts/north-italic-scaled.ttf: fonts/north-italic-fixed.svg
	bin/scale_font $^ 2.15 -560 "$@"
	bin/set_bearing "$@" 200

fonts/geas-base-garamond.ttf: fonts/geas-base.ttf
	bin/scale_font $^ 0.55 -30 "$@"



fonts/deir-alla-fixed.svg: fonts/original/deir-alla.svg
	cp $^ "$@"
	bin/fix_glyph_names "$@"

fonts/deir-alla-scaled.ttf: fonts/deir-alla-fixed.svg
	bin/scale_font $^ 2.5 -800 "$@"
	bin/set_bearing "$@" 200



clean:
	rm -f elamicon*.js
	rm -f fonts/*.ttf
	rm -f fonts/*.zip
	rm -rf build
	rm -rf src/Generated

live: $(FONTS)
	elm-live elamicon.elm --start-page=index.html -- --output=elamicon.js



fonts/Times_New_Roman_Bold-cleared.ttf: $(TIMESPATH)Times_New_Roman_Bold.ttf
	bin/clear_font $^ $@

fonts/Times_New_Roman_Bold_Italic-cleared.ttf: $(TIMESPATH)Times_New_Roman_Bold_Italic.ttf
	bin/clear_font $^ $@

fonts/Times_New_Roman_Italic-cleared.ttf: $(TIMESPATH)Times_New_Roman_Italic.ttf
	bin/clear_font $^ $@

fonts/Times_New_Roman-cleared.ttf: $(TIMESPATH)Times_New_Roman.ttf
	bin/clear_font $^ $@

fonts/GEAS_Times_New_Roman_Bold_Italic.ttf: fonts/Times_New_Roman_Bold_Italic-cleared.ttf fonts/geas-base.ttf
	bin/addfont "GEAS-"   $^ $@

fonts/GEAS_Times_New_Roman_Italic.ttf: fonts/Times_New_Roman_Italic-cleared.ttf fonts/geas-base.ttf
	bin/addfont "GEAS-"   $^ $@

fonts/GEAS_Times_New_Roman_Bold.ttf: fonts/Times_New_Roman_Bold-cleared.ttf fonts/geas-base.ttf
	bin/addfont "GEAS-"   $^ $@

fonts/GEAS_Times_New_Roman.ttf: fonts/Times_New_Roman-cleared.ttf fonts/geas-base.ttf
	bin/addfont "GEAS-"   $^ $@

fonts/GEAS_Times_New_Roman.zip: fonts/GEAS_Times_New_Roman_Bold_Italic.ttf fonts/GEAS_Times_New_Roman_Italic.ttf fonts/GEAS_Times_New_Roman_Bold.ttf fonts/GEAS_Times_New_Roman.ttf
	zip -rq fonts/GEAS_Times_New_Roman.zip $^




fonts/GEAS_Garamond_Semibold.ttf: fonts/geas-base-garamond.ttf
	bin/addfont "GEAS-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro-Semibold_2011.ttf $^ $@

fonts/GEAS_Garamond_Semibold-Italic.ttf: fonts/geas-base-garamond.ttf
	bin/addfont "GEAS-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro-Semibold-Italic_2010.ttf $^ $@

fonts/GEAS_Garamond_Italic.ttf: fonts/geas-base-garamond.ttf
	bin/addfont "GEAS-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro-Italic_2009.ttf $^ $@

fonts/GEAS_Garamond.ttf: fonts/geas-base-garamond.ttf
	bin/addfont "GEAS-" fonts/original/adobe-garamond-pro/Adobe-Garamond-Pro_2012.ttf $^ $@

fonts/GEAS_Garamond.zip: fonts/GEAS_Garamond_Italic.ttf fonts/GEAS_Garamond.ttf fonts/GEAS_Garamond_Semibold.ttf fonts/GEAS_Garamond_Semibold-Italic.ttf
	zip -rq $@ $^


.DELETE_ON_ERROR:
