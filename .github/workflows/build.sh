#!/bin/bash

# do not install dependencies here
# APT & other setup commands belong in the Dockerfile

tar --version;
gzip --version;

zip -9 -r -x '.git/*' @ .github/workflows/payload .;

latexmk -pdf ctufit-thesis.tex;
makeglossaries ctufit-thesis;
latexmk -pdf ctufit-thesis.tex;

/truepolyglot/truepolyglot pdfzip \
    --pdffile ctufit-thesis.pdf \
    --luafile .github/workflows/payload.lua \
    --zipfile .github/workflows/payload.zip \
    ./poly.pdf;
chmod +x poly.pdf;

python3 /forcecrc32.py poly.pdf 241 cafebabe;

rm -fr /tmp/* /tmp/.* truepolyglot/
