PANDOC_ARGS += --defaults defaults.yaml

live-view: cookbook_rust.pdf has-entr
	-xdg-open cookbook_rust.pdf &
	printf "%s\n" cookbook_rust.md defaults.yaml Makefile \
		| entr -p make cookbook_rust.pdf

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
