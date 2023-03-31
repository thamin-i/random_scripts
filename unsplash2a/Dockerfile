FROM ubuntu:latest

LABEL org.opencontainers.image.authors="Thamin-i"

COPY unsplash2a.sh /bin/unsplash2a

RUN apt update -y && apt install -y curl jp2a \
    && chmod +x "/bin/unsplash2a"

ENV COLORTERM="truecolor"

ENTRYPOINT [ "/bin/unsplash2a" ]
