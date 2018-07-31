talk.pdf: talk.md
	pandoc -t beamer talk.md -o talk.pdf

talk.epub: talk.md
	pandoc talk.md -o talk.epub

install: talk.pdf
	install talk.pdf ${out}
	install talk.epub ${out}

