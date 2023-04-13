FROM texlive/texlive

COPY . /app
WORKDIR /app

RUN apt-get update && apt-get install -y python3 zip wget;

ENTRYPOINT bash
