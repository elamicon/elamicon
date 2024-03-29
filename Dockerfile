FROM debian:stable

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-fontforge \
        nodejs \
        npm \
        zip \
        git \
        make
RUN npm install -g elm@0.19.1 uglify-js
