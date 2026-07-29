-- Set space as the leader key (must be set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Disable netrw (recommended by nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- --- Editor Options ---
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.mouse = "a"
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:2"
vim.opt.showbreak = "↳"
vim.opt.linebreak = true

-- Search Behavior
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.clipboard = "unnamedplus"   -- Sync Neovim resiter with system clipboard

-- --- Keymaps ---
-- Quick exit from insert mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit Insert Mode" })

-- Clear search highlight on pressing <Esc> in Normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window splitting & navigation
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Stay in visual mode when indenting text blocks
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Reload config
vim.keymap.set("n", "<leader>rc", "<cmd>source $MYVIMRC<CR>", { desc = "Reload Config" })

-- Keep cursor in the center while page jumping with Ctrl-d/Ctrl-u
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- --- Setup Plugins ---
require("lazy").setup({
  -- Colorscheme (Rose Pine Moon)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000, -- Load this colorscheme first
    config = function()
      require("rose-pine").setup({
        variant = "moon",
        dark_variant = "moon",
        styles = {
          bold = true,
          italic = true,
          transparency = true,
        },
      })
      vim.cmd("colorscheme rose-pine")
    end,
  },

  -- Telescope (Fuzzy Finder)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git Status (Changed Files)" })
      vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Find Marks" })
    end
  },

  -- Treesitter (Advanced Syntax Highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.10.0",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "javascript", "typescript", "tsx", "html", "css",
          "json", "yaml", "markdown", "markdown_inline",
          "go", "gomod", "gowork", "gosum",
        },
        highlight = { enable = true },
      })
    end
  },

  -- Gitsigns (Git status markers)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      local gs = require("gitsigns")
      vim.keymap.set("n", "]c", gs.next_hunk, { desc = "Next Git Hunk" })
      vim.keymap.set("n", "[c", gs.prev_hunk, { desc = "Prev Git Hunk" })
      vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk Diff" })
      vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
      vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
      vim.keymap.set("n", "<leader>hb", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
      vim.keymap.set("n", "<leader>hd", gs.diffthis, { desc = "Diff This File" })
    end
  },

  -- Nvim-tree (File/Folder Explorer)
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
    end
  },

  -- Render-markdown (In-buffer Markdown rendering)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    config = function()
      require("render-markdown").setup({})
      vim.keymap.set("n", "<leader>rm", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle Markdown Render" })
    end
  },

  -- Fugitive (Git commands: commit, push, blame, etc.)
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Git Status (Fugitive)" })
      vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git Commit" })
      vim.keymap.set("n", "<leader>gP", "<cmd>Git push<CR>", { desc = "Git Push" })
      vim.keymap.set("n", "<leader>gp", "<cmd>Git pull<CR>", { desc = "Git Pull" })
      vim.keymap.set("n", "<leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Git Diff Split" })
      vim.keymap.set("n", "<leader>gB", "<cmd>Git blame<CR>", { desc = "Git Blame" })
    end
  },

  -- Marks in the signcolumn
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    config = function()
      require("marks").setup({
        default_mappings = true,
        builtin_marks = { ".", "<", ">", "^" },
        cyclic = true,
        refresh_interval = 250,
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
      })
    end
  },

  -- Bufferline (Tab bar for open files/buffers)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "NvimTree", text = "File Explorer", separator = true },
          },
        },
      })
      vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer Tab" })
      vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer Tab" })
      vim.keymap.set("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Pick Buffer Tab" })
      vim.keymap.set("n", "<leader>bc", "<cmd>bdelete<CR>", { desc = "Close Current Buffer" })
    end
  },

  -- Mason (LSP/formatter/linter installer)
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()

      -- Non-LSP tools mason-lspconfig won't install on its own
      local mr = require("mason-registry")
      local ensure_tools_installed = function()
        for _, tool in ipairs({ "biome" }) do
          local ok, pkg = pcall(mr.get_package, tool)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_tools_installed)
      else
        ensure_tools_installed()
      end
    end
  },

  -- Mason + LSP client setup (native vim.lsp.config, nvim 0.11+)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "gopls", "lua_ls" },
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("gopls", {
        settings = { gopls = { gofumpt = true, staticcheck = true } },
      })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      vim.lsp.enable({ "ts_ls", "gopls", "lua_ls" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
          vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to References" }))
          vim.keymap.set("n", "gI", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Docs" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show Diagnostic" }))
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Prev Diagnostic" }))
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next Diagnostic" }))
        end,
      })
    end
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }),
      })
    end
  },

  -- Formatting (format-on-save)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "biome" },
          typescript = { "biome" },
          typescriptreact = { "biome" },
          json = { "biome" },
          go = { "goimports", "gofmt" },
        },
        format_on_save = { timeout_ms = 1000, lsp_fallback = true },
      })
      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        require("conform").format({ lsp_fallback = true })
      end, { desc = "Format Buffer" })
    end
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "biomejs" },
        typescript = { "biomejs" },
        typescriptreact = { "biomejs" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        callback = function() lint.try_lint() end,
      })
    end
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end
  },

  -- Commenting (gc / gcc)
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "auto" } })
    end
  },

  -- Go-specific helpers (struct tags, :GoTest, etc.)
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "go", "gomod" },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    build = ':lua require("go.install").update_all_sync()',
  },
})
