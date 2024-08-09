-- command :Lazy
-- U for Update
local overrides = require "custom.configs.overrides"

local plugins = {
  -- Override plugin definition options
  -- Add additional plugins
  { -- Mason is used to help install LSP servers, formatters, linters, and debug adapters.
    "williamboman/mason.nvim",
    opts = {
      -- call :MasonInstallAll
      ensure_installed = {
        "lua-language-server", -- incl with NvChad defaults
        "rust-analyzer",
        "html-lsp",
        "prettier",
        "stylua",
        "svelte-language-server",
        "codelldb",
        "tailwindcss-language-server",
        "dot-language-server",
        "yaml-language-server",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- formatting & linting
      "mskelton/null-ls.nvim",
      config = function()
        require "custom.configs.null-ls"
      end,
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  -- { -- rust tools
  --   "simrat39/rust-tools.nvim",
  --   ft = "rust", -- so Lazyvim knows when to load it
  --   after = "nvim-lspconfig",
  --   config = function()
  --     require "custom.configs.rust_tools"
  --   end,
  -- },
  {
    "mrcjkb/rustaceanvim",
    -- after = "nvim-lspconfig",
    version = "^4", -- Recommended
    -- lazy = false, -- This plugin is already lazy
    ft = { "rust" },
    config = function()
      require "custom.configs.rustaceanvim"
    end,
  },
  { -- text syntax highlighting per language
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- defaults
        "vim",
        "lua",

        -- web dev
        "html",
        "css",
        "javascript",
        "typescript",
        "json",
        "svelte",
        "toml",
        "ron", -- rust object notation

        -- low level
        "rust",
        "markdown",

        -- custom parser
        "wit",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
    -- from https://github.com/NvChad/NvChad/discussions/2426
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "syntax")
      require("nvim-treesitter.parsers").get_parser_configs().just = {
        install_info = {
          url = "https://github.com/IndianBoy42/tree-sitter-just", -- local path or git repo
          files = { "src/parser.c", "src/scanner.c" },
          branch = "main",
          -- use_makefile = true -- this may be necessary on MacOS (try if you see compiler errors)
        },
        maintainers = { "@IndianBoy42" },
      }
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  { -- Aggregated Trouble list
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      dofile(vim.g.base46_cache .. "trouble") -- theme using chadrd.ui.extended_integrations in custom/chadrc.lua
      require("trouble").setup {
        modes = {
          diagnostics = { auto_open = true },
        },
        auto_close = true,
        open_no_results = true,
      }
    end,
  },
  { -- AI tooling
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    -- opts = overrides.copilot,
    config = function()
      require "custom.configs.copilot"
      -- Mapping tab is already used by NvChad
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""
      -- The mapping is set to other key, see custom/lua/mappings
      -- or run <leader>ch to see copilot mapping section
    end,
  },
  { -- cinnamon is a smooth scrolling plugin
    "declancm/cinnamon.nvim",
    event = { "BufReadPre", "BufNewFile", "BufEnter" },
    config = function()
      require("cinnamon").setup()
    end,
  },
  { -- debugger
    "mfussenegger/nvim-dap",
  },
  { -- terminal
    "akinsho/toggleterm.nvim",
    lazy = false, -- TODO: To get things rolling, load it right away
    version = "*",
    config = function()
      require "custom.configs.toggleterm"
    end,
  },
  { -- integrate crate.io into completion
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        config = true,
      },
    },
    opts = overrides.cmp,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local conf = require "plugins.configs.telescope"
      conf.defaults.mappings.i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<Esc>"] = require("telescope.actions").close,
      }
      conf.defaults.file_ignore_patterns = { "node_modules/", ".git", "docs/", "target/", "package-lock.json" }

      return conf
    end,
  },
  -- pest syntax highlighting
  -- {
  --   "pest-parser/pest.vim",
  --   ft = "pest",
  -- },
  {
    "NoahTheDuke/vim-just",
    ft = { "just" },
  },
}

return plugins
