# Language servers for nvim, run on demand as containers. Build with `make langservers`; see vim/lua/lsp.lua.
# Only node and the servers live here. eslint, its plugins and configs resolve from the project's own bind-mounted
# node_modules instead, so a repo is linted by exactly the eslint version its lockfile pins.
# Debian, not alpine: projects build native modules against host glibc, and musl cannot load those .node binaries.
FROM node:22-slim

# typescript is a peer dependency of @vue/language-server v3, which reads ts.server.protocol off it and crashes on
# startup without it. This copy is only for vue_ls' protocol plumbing; actual type info comes from vtsls, which is
# pointed at the project's own typescript by autoUseWorkspaceTsdk.
RUN npm install -g --no-fund --no-audit vscode-langservers-extracted@4 @vtsls/language-server@0.2 \
    @vue/language-server@3 typescript@5 \
    && npm cache clean --force

# vtsls loads @vue/typescript-plugin from here, by container path: see VUE_PLUGIN in vim/lua/lsp.lua
ENV VUE_LANGUAGE_SERVER=/usr/local/lib/node_modules/@vue/language-server

# Containers run as the host uid/gid (see dockerized() in vim/lua/lsp.lua), so
# node's default HOME is not writable. Point it somewhere harmless.
ENV HOME=/tmp

# No ENTRYPOINT: nvim passes the server to run as the command.
CMD ["vscode-eslint-language-server", "--stdio"]
