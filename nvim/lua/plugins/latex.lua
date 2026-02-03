return {
  'lervag/vimtex',
  ft = { 'tex' },
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = 'zathura'
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

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tex",
      callback = function()
        vim.cmd("VimtexCompile")
      end,
    })

  end,
}
