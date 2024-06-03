local get_theme_tb = function(type)
  local default_path = "base46.themes." .. vim.g.nvchad_theme
  local user_path = "custom.themes." .. vim.g.nvchad_theme

  local present1, default_theme = pcall(require, default_path)
  local present2, user_theme = pcall(require, user_path)

  if present1 then
    return default_theme[type]
  elseif present2 then
    return user_theme[type]
  else
    error "No such theme!"
  end
end

-- Check to see if a Wasm Interface Type (WIT) project is being built
-- This is done by seeing if there are any files ending in .wit
local is_wit_project = function()
  local wit_files = vim.fn.globpath(vim.fn.getcwd(), "**/*.wit")
  return #wit_files > 0
end

local checkOnSave = function()
  local ret = {
    allFeatures = true,
    command = "clippy",
    extraArgs = { "--no-deps" },
    target = "wasm32-unknown-unknown",
  }
  -- if is_wit_project also add overrideCommand
  if is_wit_project() then
    ret.overrideCommand = { "cargo", "component", "check", "--message-format=json" }
  end
  return ret
end

vim.g.rustaceanvim = {
  tools = {
    float_win_config = {
      border = "rounded",
    },
    -- https://www.lazyvim.org/extras/lang/rust
    on_initialized = function()
      vim.cmd [[
                augroup RustLSP
                  autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
                  autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
                  autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
                augroup END
              ]]
      -- format on save. https://www.jvt.me/posts/2022/03/01/neovim-format-on-save/
      vim.cmd [[autocmd BufWritePre *.rs lua vim.lsp.buf.format()]]
    end,
  },
  server = {
    on_attach = function(_, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      -- Hover actions
      vim.keymap.set("n", "<C-space>", function()
        vim.cmd.RustLsp { "hover", "actions" }
      end, opts)
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", function()
        vim.cmd.RustLsp "codeAction"
        -- or vim.lsp.buf.codeAction() if you don't want grouping.
      end, opts)
      -- more keymaps:
      vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
      vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- already in core/mappings.lua
      vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
      vim.keymap.set("n", "<leader>ra", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
      vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
      vim.keymap.set("n", "<leader>cd", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)

      -- Toggle inlay hints
      vim.keymap.set("n", "<leader>ih", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
      end, { desc = "Inlay hints Toggle" })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
      })

      vim.lsp.handlers["textDocument/codeAction"] = vim.lsp.with(vim.lsp.buf.code_action, {
        border = "rounded",
      })

      -- https://rust-analyzer.github.io/manual.html#semantic-syntax-highlighting
      -- whether to higlight semantics or not, see https://neovim.io/doc/user/lsp.html#vim.lsp.semantic_tokens.start%28%29
      -- client.server_capabilities.semanticTokensProvider = nil -- <== use telescope exclusively

      local colors = get_theme_tb "base_30"
      -- typeAlias
      -- Emitted for type aliases and Self in `impl`s.
      --
      -- union
      -- Emitted for unions.
      vim.api.nvim_set_hl(0, "@lsp.type.attribute", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "@lsp.type.enumMember", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "@lsp.type.function", { fg = colors.green })
      vim.api.nvim_set_hl(0, "@lsp.type.derive", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "@lsp.type.macro", { fg = colors.pink })
      vim.api.nvim_set_hl(0, "@lsp.type.method", { fg = colors.vibrant_green })
      vim.api.nvim_set_hl(0, "@lsp.type.namespace", { fg = colors.orange })
      vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = colors.red })
      vim.api.nvim_set_hl(0, "@lsp.type.property", { fg = colors.purple })
      -- vim.api.nvim_set_hl(0, "@lsp.type.struct", { fg = colors.cyan })
      -- vim.api.nvim_set_hl(0, "@lsp.modifiers.trait", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "@lsp.type.typeParameter", { fg = colors.orange })
      -- vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = colors.cyan })
      vim.api.nvim_set_hl(0, "@lsp.type.union", { fg = colors.purple })
      vim.api.nvim_set_hl(0, "@lsp.type.typeAlias", { fg = colors.pink })
      vim.api.nvim_set_hl(0, "@lsp.type.self", { fg = colors.orange })

      -- custom highlight groups:
      vim.api.nvim_set_hl(0, "Docs", { fg = "#868e86" })
      -- vim.api.nvim_set_hl(0, "Libraries", { fg = colors.blue })
      vim.api.nvim_set_hl(0, "GreenDocsHighlightGroup", { fg = "#82634e" })
      vim.api.nvim_set_hl(0, "ReadOnlyGrp", { fg = "#be899f" })

      -- vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = "purple" }) -- works
      vim.api.nvim_create_autocmd("LspTokenUpdate", {
        callback = function(args)
          local token = args.data.token
          -- if token.modifiers.documentation then
          --   vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, "Docs")
          -- end

          if token.type == "struct" and token.modifiers.documentation then
            vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, "GreenDocsHighlightGroup")
          end
          -- or token.modifiers.library token.modifiers.trait  or
          if token.modifiers.intraDocLink then
            vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, "GreenDocsHighlightGroup")
          end
          if token.modifiers.library then
            vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, "Libraries")
          end
        end,
      })
    end,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          runBuildScripts = true,
          extraEnv = {
            ["RUSTFLAGS"] = "--cfg rust_analyzer",
          },
          cfgs = {
            "web_sys_unstable_apis",
            "doctest",
            "wasm32",
            'target_arch = "wasm32"',
          },
          target = {
            "wasm32-unknown-unknown",
            "wasi-wasm32",
          },
        },
        -- if `is_wit_project` true, then also add
        -- "rust-analyzer.check.overrideCommand": ["cargo", "component", "check", "--message-format=json"]
        -- check = {
        -- overrideCommand = {
        --   allFeatures = true,
        --   command = "cargo component check ",
        --   extraArgs = { "--message-format=json" },
        -- },
        -- },
        -- Add clippy lints for Rust.
        checkOnSave = checkOnSave(),
        procMacro = {
          enable = true,
          ignored = {
            ["async-trait"] = { "async_trait" },
            ["napi-derive"] = { "napi" },
            ["async-recursion"] = { "async_recursion" },
          },
        },
      },
    },
  },
  dap = {
    -- debug adapter protocol
    adapter = function()
      local ok, mason_registry = pcall(require, "mason-registry")
      local adapter ---@type any
      if ok then
        -- rust tools configuration for debugging support
        local codelldb = mason_registry.get_package "codelldb" -- ensure you installed it with mason, :MasonInstallAll & ensure_installed = { "codelldb" }
        local extension_path = codelldb:get_install_path() .. "/extension/"
        local codelldb_path = extension_path .. "adapter/codelldb"

        local liblldb_path = extension_path .. "lldb/lib/liblldb"
        local this_os = vim.uv.os_uname().sysname

        -- The path is different on Windows
        if this_os:find "Windows" then
          codelldb_path = extension_path .. "adapter\\codelldb.exe"
          liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
        else
          -- The liblldb extension is .so for Linux and .dylib for MacOS
          liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
        end

        local cfg = require "rustaceanvim.config"
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
      end
      return adapter
    end,
  },
}
