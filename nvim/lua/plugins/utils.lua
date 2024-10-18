return {
  "christoomey/vim-tmux-navigator", -- tmux & split window navigation
  "szw/vim-maximizer",
  "tpope/vim-sleuth",
  "mbbill/undotree",
  { "Bilal2453/luvit-meta", lazy = true },
  -- "mattn/emmet-vim",
  -- utility functions
  "nvim-lua/plenary.nvim",

  "tpope/vim-surround",
  "tpope/vim-repeat",

  -- devicons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",
      }
    end,
  },

  -- convert quotes to template string quotes automatically
  {
    "axelvc/template-string.nvim",
    config = true,
    ft = {
      "typescript",
      "vue",
      "javascript",
      "python",
      "html",
    },
  },
  -- align text
  { "godlygeek/tabular", cmd = "Tabularize" },
  -- json schema provider
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },

  {
    "NvChad/nvim-colorizer.lua",
    lazy = true,
    ft = {
      "lua",
      "html",
      "vue",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
      "css",
    },
    opts = function(self, opts)
      return vim.tbl_deep_extend("force", opts, {
        filetypes = self.ft,
        user_default_options = {
          RRGGBBAA = true,
          tailwind = true,
        },
      })
    end,
  },

  -- Useful plugin to show you pending keybinds.
  "folke/which-key.nvim",
  event = "VimEnter", -- Sets the loading event to 'VimEnter'
  opts = {
    icons = {
      -- set icon mappings to true if you have a Nerd Font
      mappings = vim.g.have_nerd_font,
    },
  },
}
