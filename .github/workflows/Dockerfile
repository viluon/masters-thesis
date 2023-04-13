FROM texlive/texlive

COPY . /app
WORKDIR /app

RUN apt-get update && apt-get install -y python3 zip wget;
RUN git clone \
    --recursive \
    --depth 1 \
    --branch lua-script-hack \
    https://github.com/viluon/truepolyglot.git \
    /truepolyglot;
RUN wget -O /forcecrc32.py https://www.nayuki.io/res/forcing-a-files-crc-to-any-value/forcecrc32.py;

ENTRYPOINT bash
