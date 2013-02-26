all:
	erb -r ./helpers.rb report.md > temp-report.md
	~/.cabal/bin/pandoc -f markdown -t latex --bibliography bibliography.bib --csl ieee.csl -o temp-report.latex temp-report.md
	erb -r ./helpers.rb template.latex > report.latex
	rm temp-report.*