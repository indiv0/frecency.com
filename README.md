# frecency.com
## Quickstart

Install the prerequisites: `yarn` and `docker`.

Install TailwindCSS.
```sh
yarn install
```

Compile the styles.
```sh
NODE_ENV=production yarn run tailwindcss build style.css -o static/style.css
```

Build the docker container containing `zola`:
```sh
docker build -t zola .
```

Run a `zola` server to serve the website during development:
```sh
docker run --rm --name frecency.com\
    -v $(pwd)/config.toml:/app/config.toml\
    -v $(pwd)/content:/app/content\
    -v $(pwd)/static:/app/static\
    -v $(pwd)/templates:/app/templates\
    --publish 1111:1111 zola serve --interface 0.0.0.0
```

Build the website for publishing:
```sh
docker run --rm\
    -v $(pwd)/config.toml:/app/config.toml\
    -v $(pwd)/content:/app/content\
    -v $(pwd)/dist:/app/dist\
    -v $(pwd)/static:/app/static\
    -v $(pwd)/templates:/app/templates\
    zola build --output-dir dist/public
```

Deploy the website to S3:
```
aws s3 cp --recursive dist/public/ s3://frecency.com/
```
