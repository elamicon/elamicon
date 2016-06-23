OFONTS = $(wildcard fonts.original/*.ttf)
MFONTS = $(subst fonts.original/,fonts/Elamicon,$(OFONTS))


all: index.html fonts $(MFONTS)

index.html: elamicon.elm
	elm-make elamicon.elm --output index.html

fonts:
	mkdir fonts


fonts/ElamiconLiberationSerif-Regular.ttf: fonts.original/LiberationSerif-Regular.ttf elamicon.sfdir
	bin/addfont $^ "$@"

fonts/ElamiconLiberationSerif-Bold.ttf: fonts.original/LiberationSerif-Bold.ttf elamicon.sfdir
	bin/addfont $^ "$@"

fonts/ElamiconLiberationMono-Regular.ttf: fonts.original/LiberationMono-Regular.ttf elamicon.sfdir
	bin/addfont $^ "$@"

clean:
	rm -f index.html
	rm -f fonts/*.ttf
	rmdir fonts