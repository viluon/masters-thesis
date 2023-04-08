apt-get update
apt-get install -y python3 zip bzip2 wget
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
wget https://www.nayuki.io/res/forcing-a-files-crc-to-any-value/forcecrc32.py
python3 forcecrc32.py poly.pdf 241 cafebabe
