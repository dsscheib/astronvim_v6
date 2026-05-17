-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  { "echasnovski/mini.nvim", version = false, config = function() require("mini.surround").setup() end },
}
