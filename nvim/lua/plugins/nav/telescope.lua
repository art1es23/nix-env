local actions = require("telescope.actions")

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "ThePrimeagen/harpoon",
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-media-files.nvim",
  },
  opts = {
    defaults = {
      -- preview = {
      --   mime_hook = function(filepath, bufnr, opts)
      --     local is_image = function(filepath)
      --       local image_extensions = { "png", "jpg" } -- Supported image formats
      --       local split_path = vim.split(filepath:lower(), ".", { plain = true })
      --       local extension = split_path[#split_path]
      --       return vim.tbl_contains(image_extensions, extension)
      --     end
      --     if is_image(filepath) then
      --       local term = vim.api.nvim_open_term(bufnr, {})
      --       local function send_output(_, data, _)
      --         for _, d in ipairs(data) do
      --           vim.api.nvim_chan_send(term, d .. "\r\n")
      --         end
      --       end
      --       vim.fn.jobstart({
      --         "catimg",
      --         filepath, -- Terminal image viewer command
      --       }, { on_stdout = send_output, stdout_buffered = true, pty = true })
      --     else
      --       require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
      --     end
      --   end,
      -- },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--vimgrep",
      },
      file_ignore_patterns = {
        ".git/",
        -- node
        "node_modules/",
        -- rust
        "**/debug/",
        "target/release/",
        -- yarn
        ".yarn/*",
      },
      prompt_prefix = "» ",
      selection_caret = " ",
      multi_icon = "",
      selection_strategy = "reset",
      layout_strategy = "flex", -- horiz on wide screen, vert on narrow screen
      path_display = { "smart" },
      dynamic_preview_title = true,
      border = true,
      color_devicons = true,
      set_env = {
        ["COLORTERM"] = "truecolor",
      },
      wrap_results = true,
      sorting_strategy = "ascending",
      layout_config = {
        horizontal = { prompt_position = "top", preview_width = 0.5 },
        vertical = { mirror = false },
      },
    },
    pickers = {
      oldfiles = {
        cwd_only = true,
      },
      buffers = {
        sort_mru = true,
        ignore_current_buffer = true,
        mappings = {
          i = {
            ["<Tab>"] = actions.move_selection_next,
            ["<S-Tab>"] = actions.move_selection_previous,
          },
          n = {
            ["<Tab>"] = actions.move_selection_next,
            ["<S-Tab>"] = actions.move_selection_previous,
          },
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true, -- let me make typos in file names please
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
      ["ui-select"] = {
        require("telescope.themes").get_cursor(),
        require("telescope.themes").get_dropdown(),
      },
      media_files = {
        -- filetypes whitelist
        -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
        filetypes = { "png", "webp", "jpg", "jpeg", "mp4", "webm", "pdf" },
        -- find command (defaults to `fd`)
        find_cmd = "fzf",
      },
    },
  },
}
