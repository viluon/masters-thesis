apt-get update
apt-get install -y python3 zip bzip2
zip -9 -Z bzip2 -r -x '.git/*' @ .github/workflows/payload .
latexmk -pdf ctufit-thesis.tex
makeglossaries ctufit-thesis
latexmk -pdf ctufit-thesis.tex
git clone --recursive --depth 1 --branch lua-script-hack https://github.com/viluon/truepolyglot.git
truepolyglot/truepolyglot pdfzip \
    --pdffile ctufit-thesis.pdf \
    --luafile .github/workflows/payload.lua \
    --zipfile .github/workflows/payload.zip \
    ./poly.pdf
chmod +x poly.pdf
