# Language servers for nvim, run on demand as containers. See vim/lua/lsp.lua.
# Build with `make langservers`.
#
# Only node and the servers themselves live in here. eslint, its plugins and its
# shareable configs deliberately do NOT: they resolve from the project's own
# node_modules, which is bind-mounted at its real host path. That way a repo is
# linted by exactly the eslint version its lockfile pins.
#
# Debian-based rather than alpine on purpose. Projects install native modules
# against glibc on the host, and musl cannot load those .node binaries.
FROM node:22-slim

RUN npm install -g --no-fund --no-audit vscode-langservers-extracted@4 \
    && npm cache clean --force

# Containers run as the host uid/gid (see dockerized() in vim/lua/lsp.lua), so
# node's default HOME is not writable. Point it somewhere harmless.
ENV HOME=/tmp

# No ENTRYPOINT: nvim passes the server to run as the command.
CMD ["vscode-eslint-language-server", "--stdio"]
