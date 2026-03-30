return {
  'nvim-java/nvim-java',
  config = function()
    require('java').setup()

    -- New API: replaces require('lspconfig').jdtls.setup(...)
    vim.lsp.config('jdtls', {
      root_dir = function(fname)
        return vim.fs.root(fname, { 'devenv.nix', 'shell.nix', '.git' })
      end,

      settings = {
        java = {
          project = {
            importHint = true,
            referencedLibraries = { "lib/**/*.jar" },
          },
        },
      },
    })

    vim.lsp.enable('jdtls')
  end,
}
