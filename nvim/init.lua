


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
        "luisiacc/gruvbox-baby",
        "benlubas/molten-nvim", -- pynb
        "numToStr/Comment.nvim", -- comment
        "nvim-treesitter/nvim-treesitter", -- tree-sitter
        "pocco81/high-str.nvim", -- color highlighter 
        "nvim-lualine/lualine.nvim", -- statusline
        {
            "folke/flash.nvim",
            event = "VeryLazy",
            opts = {},
            keys = {
                { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
                { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
                { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
                { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
                { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
            },
        }
})

require('Comment').setup({padding=true, toggler={line='c'}, opleader={line='<C-c>'} }) -- https://github.com/numToStr/Comment.nvim?tab=readme-ov-file

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "lua", "vim", "python", "javascript", "typescript", "markdown" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, buf)
        local max_filesize = 500 * 1024 -- 500 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
    additional_vim_regex_highlighting = true,
  },
}
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

require("high-str").setup({
  verbosity = 0,
  saving_path = "/tmp/highstr/",
  highlight_colors = {
    color_0 = {"#000000", "smart"},
    color_1 = {"#FF0000", "smart"},
    color_2 = {"#00FF00", "smart"},
    color_3 = {"#0000FF", "smart"},
    color_4 = {"#FFFF00", "smart"},
    color_5 = {"#00FFFF", "smart"},
  }
})



-- require("autoclose").setup()


local o = vim.opt

o.clipboard = "unnamedplus"
o.clipboard = "unnamed"
o.relativenumber = true
o.number = true 
o.smartindent = true
o.shiftwidth = 4
o.tabstop = 2 -- spaces for tabs
o.expandtab = true -- expand tabs into spaces
o.autoindent = true -- when entering new line copy the indent from prev line
o.scrolloff = 20


-- colors
o.termguicolors = true
o.background = "dark"
o.cursorline = true
vim.g.gruvbox_baby_transparent_mode = 1
vim.cmd[[colorscheme gruvbox-baby]]
vim.cmd[[set guicursor=i:block]]
vim.cmd[[hi! Visual cterm=reverse gui=reverse]]
vim.api.nvim_set_hl(0, "Comment", { bg="#333333", fg="#FFFFFF"})
-- vim.api.nvim_set_hl(0, "Visual", { bg="green", fg="#FFFFFF"})
vim.cmd [[hi MatchParen guibg=#f3faa7 guifg=Black gui=bold]]

vim.opt.termguicolors = true
vim.cmd [[highlight Normal guibg=NONE]]
vim.cmd [[highlight NormalNC guibg=NONE]]


-- KEYMAPS
vim.g.mapleader = " "

local k = vim.keymap
-- vim.opt.timeoutlen = 1000

-- Inline 
k.set("n", "+", "<C-a>", {desc = "Increament"})
k.set("n", "-", "<C-x>", {desc = "Decreament"})
k.set("n", "<leader>c", "gcc", {desc = "Comment"})

-- Windows
k.set("n", "<leader>v", "<C-w>v", {desc = "Split Window Vertically"})
k.set("n", "<leader>h", "<C-w>s", {desc = "Split Window Horizontally"})
k.set("n", "<leader>x", "<cmd>close<CR>", {desc = "Close Window"})
k.set("n", "<leader>w", "<C-w>w", {desc = "Next Window"})

-- Tabs
k.set("n", "<leader>t", "<cmd>tabnew %<CR>", {desc = "New Tab"})
k.set("n", "<leader>w", "<cmd>tabclose<CR>", {desc = "Close Tab"})
k.set("n", "<leader>n", "<cmd>tabn<CR>", {desc = "Next Tab"})
k.set("n", "<leader>p", "<cmd>tabp<CR>", {desc = "Prev Tab"})

-- highlight text
k.set("v", "1", ":<c-u>HSHighlight 1<CR>")
k.set("v", "2", ":<c-u>HSHighlight 2<CR>")
k.set("v", "3", ":<c-u>HSHighlight 3<CR>")
k.set("v", "4", ":<c-u>HSHighlight 3<CR>")
k.set("v", "5", ":<c-u>HSHighlight 4<CR>")
k.set("v", "x", ":<c-u>HSRmHighlight<CR>")

vim.keymap.set("v", "[", "c[<C-r>\"]<Esc>")
vim.keymap.set("v", "(", "c(<C-r>\")<Esc>")
vim.keymap.set("v", '"', 'c"<C-r>\""<Esc>')
vim.keymap.set("v", "{", "c{<C-r>\"}<Esc>")


vim.api.nvim_set_keymap('v', 'f', 'zf', { noremap = true, silent = true }) -- Create fold
vim.api.nvim_set_keymap('n', 'f', 'za', { noremap = true, silent = true }) -- Toggle fold


vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true }) -- terminal esc


vim.opt.clipboard = "unnamedplus"

vim.o.termguicolors = true
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- active window: bright background
    vim.api.nvim_set_hl(0, "Normal",   { fg = "#d0d0d0", bg = "#000000" })

    -- inactive windows: dim background
    vim.api.nvim_set_hl(0, "NormalNC", { fg = "#808080", bg = "#000000" })
  end,
})
vim.cmd("doautocmd ColorScheme")

vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true })


-- vim.cmd([[
--   hi FlashLabel guibg=#ff0000 guifg=#FFFFFF gui=bold
--   hi FlashMatch guibg=#111111 guifg=#aaaaaa
--   hi FlashBackdrop guibg=#000000 guifg=#555555
--   hi FlashCurrent guibg=#000000 guifg=aaaaaa
-- ]])
--
vim.cmd([[
  hi FlashLabel guibg=#ff0000 guifg=#FFFFFF gui=bold
  hi FlashMatch guibg=#111111 guifg=#aaaaaa
  hi FlashBackdrop guifg=#555555
  hi FlashCurrent guifg=aaaaaa
]])


-- transparent bg
vim.cmd [[
  hi Normal guibg=NONE ctermbg=NONE
  hi NormalNC guibg=NONE ctermbg=NONE
  hi EndOfBuffer guibg=NONE ctermbg=NONE
  hi LineNr guibg=NONE ctermbg=NONE
  hi SignColumn guibg=NONE ctermbg=NONE
]]

-- Terminal mode window navigation
vim.api.nvim_set_keymap('t', '<C-h>', [[<C-\><C-n><C-w>h]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-j>', [[<C-\><C-n><C-w>j]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-k>', [[<C-\><C-n><C-w>k]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-l>', [[<C-\><C-n><C-w>l]], { noremap = true, silent = true })

