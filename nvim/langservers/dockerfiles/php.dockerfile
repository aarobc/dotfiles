FROM php:8.5-cli

# phpactor ships as a self-contained phar; curl only exists to fetch it and is dropped once it does.
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -Lo /usr/local/bin/phpactor https://github.com/phpactor/phpactor/releases/latest/download/phpactor.phar && \
    chmod +x /usr/local/bin/phpactor && \
    apt-get purge -y curl && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Containers run as the host uid/gid (see dockerized() in vim/lua/lsp.lua), so php's default HOME is not
# writable. Point it somewhere harmless; this is also where phpactor caches its indexed project data.
ENV HOME=/tmp

# No ENTRYPOINT: compose.yml names the command, so nvim can invoke the service bare.
