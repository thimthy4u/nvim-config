-- Force cindent and wipe out runtime indentexpr
vim.bo.indentexpr = "" -- Disables the broken runtime /usr/share/nvim/runtime/indent/java.vim
vim.bo.cindent = true -- Force C/Java style indentation
vim.bo.smartindent = false
vim.bo.autoindent = true

-- Tab / Spacing setup (1 tab = 4 spaces)
vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4

-- Tell cindent how to handle braces and statements
-- (j1 indents Java anonymous classes/lambdas properly, +4 indents after {)
vim.bo.cinoptions = "j1,(0,ws,m1"
