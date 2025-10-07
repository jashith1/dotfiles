return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5", -- or omit for latest
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons", -- for file icons
      "nvim-treesitter/nvim-treesitter", -- for previews
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_config = { width = 0.9, height = 0.9 },
          sorting_strategy = "ascending",
          prompt_prefix = "   ",
        },
      })
      telescope.load_extension("fzf")
    end,
  },
}

