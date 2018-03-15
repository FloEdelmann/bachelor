docdir := edel17/Dokumentation
pandoc := ~/.cabal/bin/pandoc
pandoc-crossref := $(wildcard ~/.cabal/bin/pandoc-crossref)
bilder-jpg := $(wildcard Bilder/*.jpg)
bilder-jpg-copied := $(bilder-jpg:%=$(docdir)/Latex/%)
bilder-png := $(wildcard Bilder/*.png)
bilder-png-copied := $(bilder-png:%=$(docdir)/Latex/%)
bilder-svg := $(wildcard Bilder/*.svg)
bilder-pdf := $(bilder-svg:%.svg=$(docdir)/Latex/%.pdf)

all: $(docdir)/PDF/edel17.pdf $(docdir)/Abstract.txt
	cd $(docdir)/Latex && pdflatex -halt-on-error edel17.tex && bibtex edel17 && makeindex -s edel17.ist -o edel17.gls edel17.glo && cp edel17.pdf ../../../ && gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=reduced.pdf edel17.pdf && cp reduced.pdf ~/cloud-backup/edel17.pdf && mkdir -p ../PDF && mv edel17.pdf ../PDF/edel17-uncompressed.pdf && mv reduced.pdf ../PDF/edel17.pdf

$(docdir)/PDF/edel17.pdf: $(docdir)/Latex/edel17.tex $(docdir)/Latex/abstract.tex $(docdir)/Latex/body.tex

$(docdir)/Abstract.txt: abstract.md pandoc-filter.js
	NODE_PATH=~/.npm-packages/lib/node_modules $(pandoc) --smart --from=markdown --to=plain --filter=pandoc-filter.js --output=$(docdir)/Abstract.txt abstract.md

$(docdir)/Latex/abstract.tex: abstract.md
	$(pandoc) --smart --from=markdown --to=latex --data-dir=. --template=abstract.latex --output=$(docdir)/Latex/abstract.tex abstract.md
	./pandoc-postprocessing.js $(docdir)/Latex/abstract.tex

$(docdir)/Latex/Bilder/%.pdf: Bilder/%.svg
	mkdir -p $(docdir)/Latex/Bilder
	inkscape --export-pdf $@ $<

$(docdir)/Latex/Bilder/%.jpg: Bilder/%.jpg
	mkdir -p $(docdir)/Latex/Bilder
	cp $< $@

$(docdir)/Latex/Bilder/%.png: Bilder/%.png
	mkdir -p $(docdir)/Latex/Bilder
	cp $< $@

$(docdir)/Latex/body.tex: edel17.md $(bilder-jpg-copied) $(bilder-png-copied) $(bilder-pdf) $(docdir)/Latex/Bib/edel17.bib pandoc-*.js
	NODE_PATH=~/.npm-packages/lib/node_modules $(pandoc) --smart --from=markdown --to=latex --top-level-division=chapter --listings --filter=$(pandoc-crossref) --filter=pandoc-filter.js --natbib --bibliography=$(docdir)/Latex/Bib/edel17.bib --output=$(docdir)/Latex/body.tex edel17.md
	./pandoc-postprocessing.js $(docdir)/Latex/body.tex

clean:
	rm -f $(docdir)/Latex/edel17.aux
	rm -f $(docdir)/Latex/edel17.brf
	rm -f $(docdir)/Latex/edel17.glo
	rm -f $(docdir)/Latex/edel17.gls
	rm -f $(docdir)/Latex/edel17.ilg
	rm -f $(docdir)/Latex/edel17.ist
	rm -f $(docdir)/Latex/edel17.lof
	rm -f $(docdir)/Latex/edel17.log
	rm -f $(docdir)/Latex/edel17.lol
	rm -f $(docdir)/Latex/edel17.out
	rm -f $(docdir)/Latex/edel17.toc
	rm -f $(docdir)/Latex/edel17.bbl
	rm -f $(docdir)/Latex/edel17.blg
	rm -f $(docdir)/Latex/edel17.fdb_latexmk
	rm -f $(docdir)/Latex/edel17.fls
	rm -f $(docdir)/Latex/edel17.lot
	rm -f $(docdir)/Latex/Titel/erklaerung-lmu.aux
	rm -f $(docdir)/Latex/Titel/erklaerung-tum.aux
	rm -f $(docdir)/Latex/Titel/titel-lmu.aux
	rm -f $(docdir)/Latex/Titel/titel-tum.aux

reallyclean: clean
	rm -rf edel17.pdf
	rm -f $(docdir)/Abstract.txt
	rm -f $(docdir)/Latex/abstract.tex
	rm -f $(docdir)/Latex/body.tex
	rm -rf $(docdir)/Latex/Bilder
	rm -rf $(docdir)/PDF

open:
	xdg-open $(docdir)/PDF/edel17.pdf

zip: all clean
	zip -r edel17.zip edel17
