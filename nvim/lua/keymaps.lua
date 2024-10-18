---@diagnostic disable: assign-type-mismatch

local function lsp_keymaps(keymaps)
  local keys = require("lazyvim.plugins.lsp.keymaps").get()
  vim.list_extend(keys, keymaps)
end
-- CSS classes usually have dashes in them, so the whole class name should be
-- considered as a word
-- vim.opt_local.iskeyword:append("-")

local M = {}
local opts = { noremap = true, silent = true }

local builtin = require("telescope.builtin")

-- [[ Basic Keymaps ]]
--  See `:help keymap.set()`
---@type LazyKeysSpec[]
M.generals = {
  -- TIP: Disable arrow keys in normal mode
  { "<left>", "<cmd>echo 'Use h to move'<CR>" },
  { "<right>", "<cmd>echo 'Use l to move'<CR>" },
  { "<up>", "<cmd>echo 'Use k to move'<CR>" },
  { "<down>", "<cmd>echo 'Use j to move'<CR>" },

  -- Reset
  { "q", "<nop>" },
  { "gt", "<nop>" },
  { "gT", "<nop>" },

  -- Reset window navigation
  { "<c-h>", nil, mode = { "n", "t" } },
  { "<c-j>", nil, mode = { "n", "t" } },
  { "<c-k>", nil, mode = { "n", "t" } },
  { "<c-l>", nil, mode = { "n", "t" } },

  -- Reset terminal navigation
  { "<c-w>", "<c-w>", mode = { "t" } },

  -- Selection
  { "<cmd-a>", "gg<S-v>G", mode = { "n" } },

  -- Default keymaps
  { "<Esc>", "<cmd>nohlsearch<CR>", mode = { "n" } },
  { "jj", "<Esc>", mode = { "i" } },

  -- Quit
  { "<leader>qq", "<cmd>qa<cr>", mode = { "n" }, desc = "Quit All" },

  -- Increment/decrement
  { "+", "<C-a>", mode = { "n" } },
  { "-", "<C-x>", mode = { "n" } },

  -- Tabs
  { "te", "tabedit", unpack(opts), mode = { "n" } },
  { "<tab>", ":tabnext<Return>", unpack(opts), mode = { "n" } },
  { "<S-tab>", ":tabprev<Return>", unpack(opts), mode = { "n" } },
  { "<leader>to", "<cmd>tabnew<CR>", mode = { "n" }, desc = "Open new tab" }, -- open new tab
  { "<leader>tx", "<cmd>tabclose<CR>", mode = { "n" }, desc = "Close current tab" }, -- close current tab
  { "<leader>tn", "<cmd>tabn<CR>", mode = { "n" }, desc = "Go to next tab" }, --  go to next tab,
  { "<leader>tp", "<cmd>tabp<CR>", mode = { "n" }, desc = "Go to previous tab" }, --  go to previous tab,
  { "<leader>tf", "<cmd>tabnew %<CR>", mode = { "n" }, desc = "Open current buffer in new tab" }, --  move current buffer to new tab

  -- Resize window
  { "<c-leader><Left>", "<C-w><", desc = "Increase window size left", mode = { "n" } },
  { "<c-leader><Right>", "<C-w>>", desc = "Increase window size right", mode = { "n" } },
  { "<c-leader><Up>", "<C-w>+", desc = "Increase window size up", mode = { "n" } },
  { "<c-leader><Down>", "<C-w>-", desc = "Increase window size down", mode = { "n" } },

  -- Move window
  { "<c-h>", "<c-w>h", desc = "Go to left window" },
  { "<c-j>", "<c-w>j", desc = "Go to below window" },
  { "<c-k>", "<c-w>k", desc = "Go to above window" },
  { "<c-l>", "<c-w>l", desc = "Go to right window" },

  -- Window management
  { "<leader>s-", "<c-W>s", desc = "Split window vertically" },
  { "<leader>sv", "<c-W>v", desc = "Split window horizontally" },
  { "<leader>se", "<c-W>=", desc = "Make splits equal size" },
  { "<leader>sx", "<cmd>close<CR>", desc = "Close current split" },

  -- Vim maximizer
  { "<leader>s+", "<cmd>MaximizerToggle<CR>", desc = "Vim Maximizer", mode = { "n" } },

  -- Navigate between quickfix items
  { "<leader>h", "<cmd>cnext<CR>zz", mode = { "n" }, desc = "Forward qfixlist" },
  { "<leader>;", "<cmd>cprev<CR>zz", mode = { "n" }, desc = "Backward qfixlist" },

  {
    "<c-j>",
    mode = { "n" },
    function()
      vim.diagnostic.goto_next()
    end,
  },

  -- Undo tree
  { "<leader>u", vim.cmd.UndotreeToggle, desc = "Undo Tree" },

  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  { "<Esc><Esc>", "<C-\\><C-n>", desc = "Exit terminal mode", mode = { "t" } },

  -- Enhance enter
  {
    "<c-enter>",
    function()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_put({ "" }, "l", true, true)
      vim.api.nvim_win_set_cursor(0, { row + 1, col })
    end,
    mode = { "n", "i" },
  },
  {
    "<s-c-enter>",
    function()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_put({ "" }, "l", false, true)
      vim.api.nvim_win_set_cursor(0, { row, col })
    end,
    mode = { "n", "i" },
  },

  -- Scroll window one line up/down
  -- https://stackoverflow.com/a/14308057
  { "<c-e>", "<c-x><c-e>", mode = "i" },
  { "<c-y>", "<c-x><c-y>", mode = "i" },

  -- Navigation
  -- Mappings for navigating blocks
  {
    "]]",
    mode = { "n" },
    function()
      vim.fn.search("^<(template)<bar>script<bar>style", "W")
    end,
  },
  {
    "[[",
    mode = { "n" },
    function()
      vim.fn.search("^<(template<bar>script<bar>style)", "bW")
    end,
  },

  {
    "/",
    mode = { "i" },
    function()
      local node = vim.treesitter.get_node()
      if not node then
        return "/"
      end

      local first_sibling_node = node:prev_named_sibling()
      if not first_sibling_node then
        return "/"
      end

      local parent_node = node:parent()
      local is_tag_writing_in_progress = node:type() == "text" and parent_node:type() == "element"

      local is_start_tag = first_sibling_node:type() == "start_tag"

      local start_tag_text = vim.treesitter.get_node_text(first_sibling_node, 0)
      local tag_is_already_terminated = string.match(start_tag_text, ">$")

      if is_tag_writing_in_progress and is_start_tag and not tag_is_already_terminated then
        local char_at_cursor = vim.fn.strcharpart(vim.fn.strpart(vim.fn.getline("."), vim.fn.col(".") - 2), 0, 1)
        local already_have_space = char_at_cursor == " "

        return already_have_space and "/>" or " />"
      end

      return "/"
    end,
    expr = true,
    buffer = true,
  },

  {
    "=",
    mode = { "i" },
    function()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local left_of_cursor_range = { cursor[1] - 1, cursor[2] - 1 }

      -- The cursor location does not give us the correct node in this case, so we
      -- need to get the node to the left of the cursor
      local node = vim.treesitter.get_node({ pos = left_of_cursor_range })
      local nodes_active_in = { "attribute_name", "directive_argument", "directive_name" }
      if not node or not vim.tbl_contains(nodes_active_in, node:type()) then
        return "="
      end

      return '=""<left>'
    end,
    expr = true,
    buffer = true,
  },

  -- -- Reset lazyvim lazygit
  -- {
  --   "<leader>gg",
  --   function()
  --     LazyVim.terminal.open("lazygit", {
  --       esc_esc = false,
  --       border = "none",
  --       size = { width = 1, height = 1 },
  --     })
  --   end,
  --   desc = "Lazygit",
  -- },
  --
  -- -- Reset lazyvim float term
  -- { "<leader>ft", nil },
  -- { "<leader>fT", nil },
  -- { "<c-/>", nil, mode = { "n", "t" } },
  -- {
  --   "<c-\\>",
  --   function()
  --     LazyVim.terminal(nil)
  --   end,
  -- },
  -- {
  --   "<c-\\>",
  --   function()
  --     LazyVim.terminal(nil)
  --   end,
  --   mode = { "t" },
  -- },
  --
  -- -- Remap macrp record key
  -- { "Q", "q" },
}

---@type LazyPluginSpec[]
M.plugins = {
  { import = "plugins.extras.keymap.copy-lines-action" },
  --   -- { import = "plugins.extras.keymap.superkey" },

  {
    "hop.nvim",
    keys = {
      { "<leader>hw", "<cmd>HopWord <CR>", "Search by HopWord" },
    },
  },
  {
    "which-key.nvim",
    lazy = false,
    event = "VimEnter",
    opts = {
      icons = {
        keys = vim.g.have_nerd_font and {} or {
          Up = "<Up> ",
          Down = "<Down> ",
          Left = "<Left> ",
          Right = "<Right> ",
          C = "<C-…> ",
          M = "<M-…> ",
          D = "<D-…> ",
          S = "<S-…> ",
          CR = "<CR> ",
          Esc = "<Esc> ",
          ScrollWheelDown = "<ScrollWheelDown> ",
          ScrollWheelUp = "<ScrollWheelUp> ",
          NL = "<NL> ",
          BS = "<BS> ",
          Space = "<Space> ",
          Tab = "<Tab> ",
          F1 = "<F1>",
          F2 = "<F2>",
          F3 = "<F3>",
          F4 = "<F4>",
          F5 = "<F5>",
          F6 = "<F6>",
          F7 = "<F7>",
          F8 = "<F8>",
          F9 = "<F9>",
          F10 = "<F10>",
          F11 = "<F11>",
          F12 = "<F12>",
        },

        spec = {
          { "<leader>gd", group = "+diffview" },
          { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
          { "<leader>d", group = "[D]ocument" },
          { "<leader>r", group = "[R]ename" },
          { "<leader>s", group = "[S]earch" },
          { "<leader>w", group = "[W]orkspace" },
          { "<leader>t", group = "[T]oggle" },
          { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        },
      },
    },
  },
  {
    "nvim-lspconfig",
    opts = function()
      lsp_keymaps({
        { "gK", false },
        { "<c-k>", vim.lsp.buf.signature_help, desc = "Signature help" },
        { "gi", "gI", remap = true, desc = "Goto Implementation" },
        {
          mode = { "n" },
          "gr",
          function()
            vim.lsp.buf.references()
          end,
          desc = "LSP Goto Reference",
        },
        {
          mode = { "n" },
          "gd",
          function()
            vim.lsp.buf.definition()
          end,
          desc = "LSP Goto Definition",
        },
        {
          mode = { "n" },
          "K",
          function()
            vim.lsp.buf.hover()
          end,
          desc = "LSP Hover",
        },
        {
          mode = { "n" },
          "<leader>vws",
          function()
            vim.lsp.buf.workspace_symbol()
          end,
          desc = "LSP Workspace Symbol",
        },
        {
          mode = { "n" },
          "<leader>vd",
          function()
            vim.diagnostic.setloclist()
          end,
          desc = "LSP Show Diagnostics",
        },
        {
          mode = { "n" },
          "[d",
          function()
            vim.diagnostic.goto_next()
          end,
          desc = "Next Diagnostic",
        },
        {
          mode = { "n" },
          "]d",
          function()
            vim.diagnostic.goto_prev()
          end,
          desc = "Previous Diagnostic",
        },
        {
          mode = { "n" },
          "<leader>vca",
          function()
            vim.lsp.buf.code_action()
          end,
          desc = "LSP Code Action",
        },
        {
          mode = { "n" },
          "<leader>vrr",
          function()
            vim.lsp.buf.references()
          end,
          desc = "LSP References",
        },
        {
          mode = { "i" },
          "<C-h>",
          function()
            vim.lsp.buf.signature_help()
          end,
          desc = "LSP Signature Help",
        },
        {
          "<leader>vrn",
          desc = "LSP Rename",
          mode = { "n" },
          function()
            vim.lsp.buf.rename()
          end,
        },
      })
    end,
  },
  --   {
  --     "grug-far.nvim",
  --     keys = {
  --       {
  --         "<leader>sf",
  --         ':lua require("grug-far").grug_far({ prefills = { flags = vim.fn.expand("%") } })<CR>',
  --         desc = "Search on current file",
  --       },
  --       {
  --         "<leader>sf",
  --         ':<C-u>lua require("grug-far").with_visual_selection({ prefills = { flags = vim.fn.expand("%") } })<CR>',
  --         desc = "Search on current file",
  --         mode = { "v" },
  --       },
  --     },
  --   },
  --
  {
    "folke/flash.nvim",
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            search = { forward = true, wrap = false, multi_window = false },
          })
        end,
        desc = "Flash forward",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            search = { forward = false, wrap = false, multi_window = false },
          })
        end,
        desc = "Flash backward",
      },
      {
        "gs",
        function()
          require("flash").jump({
            search = { multi_window = true },
          })
        end,
        desc = "Flash window",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
  --   {
  --     "folke/zen-mode.nvim",
  --     keys = {
  --       { "<leader>wo", ":ZenMode<cr>", desc = "Zen Mode" },
  --     },
  --   },
  {
    "abecodes/tabout.nvim",
    keys = {
      { "<c-l>", "<Plug>(TaboutMulti)", desc = "Goto end of pair", mode = { "i" } },
      { "<c-h>", "<Plug>(TaboutBackMulti)", desc = "Goto start of pair", mode = { "i" } },
    },
  },
  {
    "Wansmer/treesj",
    keys = {
      {
        "<leader>ut",
        function()
          require("treesj").toggle()
        end,
        desc = "Treesitter split/join blocks",
        silent = true,
      },
    },
  },
  {
    "telescope.nvim",
    keys = {
      { "<leader>sh", builtin.help_tags, desc = "[S]earch [H]elp", mode = { "n" } },
      { "<leader>sk", builtin.keymaps, desc = "[S]earch [K]eymaps", mode = { "n" } },
      { "<leader>sf", builtin.find_files, desc = "[S]earch [F]iles", mode = { "n" } },
      { "<leader>ss", builtin.builtin, desc = "[S]earch [S]elect Telescope", mode = { "n" } },
      { "<leader>sw", builtin.grep_string, desc = "[S]earch current [W]ord", mode = { "n" } },
      { "<leader>sg", builtin.live_grep, desc = "[S]earch by [G]rep", mode = { "n" } },
      { "<leader>sd", builtin.diagnostics, desc = "[S]earch [D]iagnostics", mode = { "n" } },
      { "<leader>sr", builtin.resume, desc = "[S]earch [R]esume", mode = { "n" } },
      { "<leader>s.", builtin.oldfiles, desc = '[S]earch Recent Files ("." for repeat)', mode = { "n" } },
      { "<leader><leader>", builtin.buffers, desc = "[ ] Find existing buffers", mode = { "n" } },
      -- Slightly advanced example of overriding default behavior and theme
      {
        "<leader>/",
        mode = { "n" },
        function()
          -- You can pass additional configuration to Telescope to change the theme, layout, etc.
          builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end,
        desc = "[/] Fuzzily search in current buffer",
      },

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      {
        "<leader>s/",
        mode = { "n" },
        function()
          builtin.live_grep({
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
          })
        end,
        desc = "[S]earch [/] in Open Files",
      },

      -- Shortcut for searching your Neovim configuration files
      {
        "<leader>sn",
        mode = { "n" },
        function()
          builtin.find_files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "[S]earch [N]eovim files",
      },

      -- Diagnostic keymaps
      { "<leader>q", mode = { "n" }, vim.diagnostic.setloclist, desc = "Open diagnostic [Q]uickfix list" },

      -- Media searching
      {
        "<leader>sm",
        "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>",
        mode = { "n" },
        desc = "[F]ind [M]edia files",
      },
      {
        "<leader>smc",
        "<cmd>lua require('telescope').extensions.media_files.media_files_console()<cr>",
        mode = { "n" },
        desc = "[F]ind [M]edia files to Console",
      },
    },
  },
  {
    "nvim-pack/nvim-spectre",
    config = function()
      vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
        desc = "Toggle Spectre",
      })
      vim.keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
        desc = "Search current word",
      })
      vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
        desc = "Search current word",
      })
      vim.keymap.set("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
        desc = "Search on current file",
      })
    end,
  },

  {
    "dyng/ctrlsf.vim",
    config = function()
      vim.keymap.set("n", "<leader>F", function()
        -- Prompt the user for input
        local search_term = vim.fn.input("Enter variable to find (default: word under cursor): ")

        -- If input is empty, use the word under the cursor
        if search_term == "" then
          search_term = vim.fn.expand("<cword>") -- Get the word under the cursor
        end

        -- Run the CtrlSF command with the search term
        vim.cmd("CtrlSF " .. search_term)
      end, { desc = "Find variable" })
      -- vim.keymap.set("n", "<leader>Fo", "<cmd>CtrlSFOpen<CR>")
      -- vim.keymap.set("n", "<leader>Fs", "<cmd>CtrlSFStop<CR>")
      -- vim.keymap.set("n", "<leader>Fx", "<cmd>CtrlSFClose<CR>")
      -- vim.keymap.set("n", "<leader>Ff", "<cmd>CtrlSFFocus<CR>")
      -- vim.keymap.set("n", "<leader>Ft", "<cmd>CtrlSFToggle<CR>")
      -- vim.keymap.set("n", "<leader>Fu", "<cmd>CtrlSFUpdate<CR>")
      -- vim.keymap.set("n", "<leader>Fd", "<cmd>CtrlSFClearHL<CR>")
      -- vim.keymap.set("n", "<leader>Fq", "<cmd>CtrlSFQuickfix<CR>")
    end,
  },
}

return M
