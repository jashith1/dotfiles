return {
  'nvim-java/nvim-java',
  config = function()
    require('java').setup()
    require('lspconfig').jdtls.setup({
      -- Add 'devenv.nix' to the root detection patterns
      root_dir = require('lspconfig.util').root_pattern('devenv.nix', 'shell.nix', '.git'),
      
      settings = {
        java = {
          -- Helps with errors in single-file homeworks
          project = {
            importHint = true,
            referencedLibraries = { "lib/**/*.jar" },
          },
        },
      },
    })
  end,
}
