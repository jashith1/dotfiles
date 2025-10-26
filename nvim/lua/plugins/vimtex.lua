return {
  {
    "lervag/vimtex",
    ft = "tex",
    config = function()
      -- Use latexmk (ships with TeX Live / MiKTeX)
      vim.g.vimtex_compiler_method = "latexmk"

      -- Force continuous background build
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "build",     -- optional: keeps clutter out of main folder
        continuous = 1,          -- enables auto build
        executable = "latexmk",
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }

      -- Don’t auto-open any PDF viewer
      vim.g.vimtex_view_enabled = 0

      --auto start compilation
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          vim.cmd("VimtexCompile")
        end,
      })

    end,
  },
}

