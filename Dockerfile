FROM google/dart:2.7 AS build
RUN apt-get -q update && \
    apt-get -y install make && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /code
VOLUME /code
WORKDIR /code
CMD ["make", "setup", "binary"]
