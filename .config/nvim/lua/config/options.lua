-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  -- vim.o.guifont = "monospace:h10"
  vim.o.guifont = "Hasklug Nerd Font Mono:h11"
end

-- set noexpandtab
-- set tabstop=2


vim.g.autoformat = false
vim.opt.clipboard = ""
vim.o.tabstop = 2 -- Un carácter TAB se ve como 4 espacios
vim.o.expandtab = true -- Presionar la tecla TAB insertará espacios en lugar de un carácter TAB
vim.o.softtabstop = 2 -- Número de espacios insertados en lugar de un carácter TAB
vim.o.shiftwidth = 2 -- Número de espacios insertados al sangrar
