-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

return function()
  -- Enable Neovim's built-in man page plugin
  vim.cmd "runtime ftplugin/man.vim"
end
