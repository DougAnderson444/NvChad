-- local autocmd = vim.api.nvim_create_autocmd
vim.diagnostic.config {
  float = {
    border = "rounded",
    source = "always",
  },
}

-- vim command for reload buffer if written from elsewhere:
vim.cmd [[
  augroup autoread
    autocmd!
    autocmd FocusGained,BufEnter,CursorHold * if mode() != 'c' | checktime | endif
  augroup END
]]

-- notification after file change
vim.cmd [[
  augroup filechanged
    autocmd!
    autocmd FileChangedShellPost * echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None
  augroup END
]]

-- use vim.filetype.add to add the .wit extension as a filetype
vim.filetype.add {
  extension = {
    wit = "wit",
  },
}

-- cannot get the WIT parser to work, use TS as a close approximation for any files ending in .wit
vim.treesitter.language.register("typescript", "wit")
