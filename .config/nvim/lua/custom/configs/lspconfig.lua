local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "rust" },
  root_dir = lspconfig.util.root_pattern("Cargo.toml")
})

lspconfig.tsserver.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

lspconfig.html.setup({
  on_attach = on_attach,
  capabilities = capabilities
})

local angular_cmd = {vim.fn.stdpath("data") .. "/mason/bin/ngserver", "--stdio", "--tsProbeLocations", "" , "--ngProbeLocations", ""}
-- print(angular_cmd)
-- /mason/bin/ngserver

lspconfig.angularls.setup({
  cmd = angular_cmd,
  on_attach = on_attach,
  capabilities = capabilities
})

--lspconfig.angularls.setup({
--  on_attach = on_attach,
--  capabilities = capabilities,
--})

--lspconfig.java_language_server.setup({
--  on_attach = on_attach,
--  capabilities = capabilities,
--})

--lspconfig.lua_ls.setup({
--  on_attach = on_attach,
--  capabilities = capabilities,
--}
