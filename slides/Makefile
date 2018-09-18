slides.html: slides.md
	pandoc -s -t slidy slides.md -o slides.html
	sed 's#http://www.w3.org/Talks/Tools/Slidy2/styles#.#' -i slides.html
	sed 's#http://www.w3.org/Talks/Tools/Slidy2/scripts#.#' -i slides.html

install: slides.html
	mkdir -p ${out}/share/domcode-slides
	cp slides.html ${out}/share/domcode-slides/


