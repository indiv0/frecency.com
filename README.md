# blog.frecency.dev
## Quickstart

Build the docker container containing `zola`:
```sh
docker build -t zola .
```

Run a `zola` server to serve the website during development:
```sh
docker run --rm\
    -v $(pwd)/config.toml:/config.toml\
    -v $(pwd)/content:/content\
    -v $(pwd)/static:/static\
    -v $(pwd)/templates:/templates\
    --publish 1111:1111 zola serve --interface 0.0.0.0
```
