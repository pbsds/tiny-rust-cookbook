PANDOC_ARGS += --defaults defaults.yaml
MAIN_FILE = cookbook_rust

live-view: ${MAIN_FILE}.pdf has-entr
	-xdg-open ${MAIN_FILE}.pdf &
	printf "%s\n" ${MAIN_FILE}.md defaults.yaml Makefile \
		| entr -p make ${MAIN_FILE}.pdf

has-%:
	@command -v $* >/dev/null || ( \
		echo "ERROR: Command '$*' not found! Make sure it is installed and available in PATH"; \
		false; \
	) >&2

%.pdf: %.md Makefile defaults.yaml has-pandoc has-pandoc-crossref
	pandoc -i $< ${PANDOC_ARGS} -o $@ #--pdf-engine=pdflatex

%.tex: %.md Makefile defaults.yaml has-pandoc has-pandoc-crossref
	pandoc -i $< ${PANDOC_ARGS} -o $@ --standalone

%.html: %.md Makefile defaults.yaml has-pandoc has-pandoc-crossref
	pandoc -i $< ${PANDOC_ARGS} -o $@ --katex --standalone --self-contained
