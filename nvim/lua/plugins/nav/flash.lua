return {
  "folke/flash.nvim",
  event = "VeryLazy",
  vscode = true,
  opts = {
    modes = {
      search = {
        enabled = false,
      },
      -- disable flit, I use `f` for search/find
      char = {
        enabled = false,
      },
    },
  },
}
