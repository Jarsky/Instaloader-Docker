# Dockerfile for Instaloader
# Made by Jarsky

FROM python:3.12.1-alpine
RUN apk add --no-cache curl jq

ARG INSTALOADER_VERSION
RUN INSTALOADER_VERSION=$(curl -s "https://api.github.com/repos/instaloader/instaloader/releases/latest" | jq -r .tag_name) \
    && pip3 install instaloader==$INSTALOADER_VERSION \
    && apk del curl jq

RUN mkdir /download
WORKDIR /download

RUN echo "#!/bin/sh" > /run_instaloader.sh \
    && echo "" >> /run_instaloader.sh \
    && echo 'args="$(cat "$1" | xargs)"' >> /run_instaloader.sh \
    && echo 'targets="$(cat "$2" | xargs)"' >> /run_instaloader.sh \
    && echo '' >> /run_instaloader.sh \
    && echo 'instaloader $args $targets' >> /run_instaloader.sh

RUN chmod +x /run_instaloader.sh

CMD /run_instaloader.sh /settings.txt /profiles.txt