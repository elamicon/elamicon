all: ProtoElamite.ttf

extracted_images: signlist.pdf
	mkdir -p extracted_images
	pdfimages -all $< $@/sign
	# rotate 90 clockwise
	for f in $@/*.jpg; do convert -threshold 99% -rotate 90 -- "$$f" "$${f%.*}.bmp"; done
	for f in $@/*.bmp; do potrace --svg --alphamax 0.9 --flat "$$f"; done

sign_names.txt: signlist.pdf
	pdftotext -layout -nopgbrk $< - | python3 signlistclean.py > $@

named_images: sign_names.txt extracted_images
	mkdir -p $@
	python3 name_images.py extracted_images $@ < $<

ProtoElamite.ttf: named_images
	python3 bitmaps2font $< 100000 ProtoElamite $@

clean:
	rm -rf extracted_images named_images signlist ProtoElamite.ttf signlist.txt signlist_simple.txt sign_names.txt

.DELETE_ON_ERROR:

.PHONY: clean

