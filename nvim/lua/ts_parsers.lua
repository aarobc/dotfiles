-- Treesitter parsers this config uses; `make parsers` reads this list. Consumed by lua/matchtag.lua and the php/blade highlighting in init.lua.
-- Compiled on the host and loaded in-process, so unlike the language servers these cannot live in a container.

return {
  'html',
  'vue', -- .vue is filetype=vue now, so html no longer covers it
  'xml', -- and xhtml; pulls in dtd
  'php', -- pulls in php_only
  'blade', -- *.blade.php is filetype=blade (builtin); injects html, php_only, javascript
  'javascript', -- filetype javascriptreact
  'tsx', -- filetype typescriptreact
  -- svelte is in matchtag's filetype list, left out on purpose: unused here, and a missing parser is a no-op
}
