CV=HyunRyongLee_CV
CV_INDUSTRY=HyunRyongLee_CV_Industry
RESUME=resume
# Halt on errors instead of going to the shell
FLAGS = -halt-on-error -interaction=batchmode
TEX = $(CV).tex
PLOTS = $(shell grep -o "plots/.*\.pdf" floats.tex)
FIGS = $(wildcard figures/*.pdf figures/*.png) $(PLOTS)
REVNUM = $(shell git log --pretty=oneline | wc -l | sed 's/ //g')

# dsm: On macOS, use GNU sed instead of BSD sed (why can't systems converge on such a stupid thing...)
# hrlee: I do not understand, but sed to remove \OK{...} does not work with the -r command on Linux??
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	SED := gsed
	READFILE_OPT := -r
else
	SED := sed
	READFILE_OPT :=
endif

default: paper 

paper: $(CV).pdf $(CV_INDUSTRY).pdf $(RESUME).pdf

# explicit rule for the paper alone
$(CV).pdf: $(TEX) 
	pdflatex $(FLAGS) $(CV) || pdflatex $(CV)
	echo $(TEX)
	ps2pdf -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.4 -dEmbedAllFonts=true -dSubsetFonts=true -r600 $(CV).pdf $(CV)_opt.pdf
	# Preserve metadata
	pdftk $(CV).pdf dump_data output metadata.txt
	pdftk $(CV)_opt.pdf update_info metadata.txt output $(CV).pdf
	cp $(CV).pdf $(CV)_opt.pdf
	qpdf --linearize $(CV)_opt.pdf $(CV).pdf

$(CV_INDUSTRY).pdf: $(CV_INDUSTRY).tex
	pdflatex $(FLAGS) $(CV_INDUSTRY) || pdflatex $(CV_INDUSTRY)
	ps2pdf -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.4 -dEmbedAllFonts=true -dSubsetFonts=true -r600 $(CV_INDUSTRY).pdf $(CV_INDUSTRY)_opt.pdf
	# Preserve metadata
	pdftk $(CV_INDUSTRY).pdf dump_data output metadata.txt
	pdftk $(CV_INDUSTRY)_opt.pdf update_info metadata.txt output $(CV_INDUSTRY).pdf
	cp $(CV_INDUSTRY).pdf $(CV_INDUSTRY)_opt.pdf
	qpdf --linearize $(CV_INDUSTRY)_opt.pdf $(CV_INDUSTRY).pdf

$(RESUME).pdf: $(RESUME).tex
	pdflatex $(FLAGS) $(RESUME) || pdflatex $(RESUME)
	ps2pdf -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.4 -dEmbedAllFonts=true -dSubsetFonts=true -r600 $(RESUME).pdf $(RESUME)_opt.pdf
	# Preserve metadata
	pdftk $(RESUME).pdf dump_data output metadata.txt
	pdftk $(RESUME)_opt.pdf update_info metadata.txt output $(RESUME).pdf
	cp $(RESUME).pdf $(RESUME)_opt.pdf
	qpdf --linearize $(RESUME)_opt.pdf $(RESUME).pdf

clean:
	rm *.pdf *.log *.aux

.PHONY: paper
