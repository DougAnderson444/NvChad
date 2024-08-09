local configs = require "plugins.configs.lspconfig"
local on_attach = configs.on_attach
local capabilities = configs.capabilities

local lspconfig = require "lspconfig"

-- rust-tools takes car of rust_analyzer for us, so we don't install it here (or it causes conflicts)
local servers = { "html", "dotls", "yamlls" } -- add any server installed with Mason or system-wide

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- add servers[rust_analyzer] = {}
-- lspconfig.rust_analyzer = {}
lspconfig.taplo = {
  keys = {
    {
      "K",
      function()
        if vim.fn.expand "%:t" == "Cargo.toml" and require("crates").popup_available() then
          require("crates").show_popup()
        else
          vim.lsp.buf.hover()
        end
      end,
      desc = "Show Crate Documentation",
    },
  },
}

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
})

-- vim.lsp.inlay_hint.enable(true)
-- vim.api.nvim_create_autocmd("LspAttach", {
--   group = vim.api.nvim_create_augroup("UserLspConfig", {}),
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client and client.server_capabilities.inlayHintProvider then
--       vim.lsp.inlay_hint.enable(true)
--     end
--     -- whatever other lsp config you want
--   end,
-- })

-- Without the loop, you would have to manually set up each LSP
lspconfig.tailwindcss.setup {
  cmd = { "tailwindcss-language-server", "--stdio", "BufEnter" },
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "css",
    "scss",
    "sass",
    "postcss",
    "html",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "svelte",
    "vue",
    "rust",
    "markdown",
  },
  init_options = {
    userLanguages = {
      rust = "html",
    },
  },
  -- Here If any of files from list will exist tailwind lsp will activate.
  root_dir = lspconfig.util.root_pattern(
    "tailwind.config.js",
    "tailwind.config.ts",
    "postcss.config.js",
    "postcss.config.ts",
    "windi.config.ts"
  ),
}
