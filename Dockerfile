#FROM rust:1.47.0-slim-buster
FROM debian:stretch-20201012-slim
ENV ZOLA_VERSION v0.12.2
RUN export DEBIAN_FRONTEND=noninteractive &&\
    apt-get update -qq &&\
    apt-get install -y --no-install-recommends curl ca-certificates &&\
    rm -r /var/lib/apt/lists /var/cache/apt/archives
RUN curl --location https://github.com/getzola/zola/releases/download/$ZOLA_VERSION/zola-$ZOLA_VERSION-x86_64-unknown-linux-gnu.tar.gz | tar xz

FROM gcr.io/distroless/cc-debian10:5f673b955c6e2cb289cc8e57651ad1463ea755fb 
WORKDIR /app
COPY --from=0 /zola /usr/bin/zola
EXPOSE 1111
ENTRYPOINT ["/usr/bin/zola"]
