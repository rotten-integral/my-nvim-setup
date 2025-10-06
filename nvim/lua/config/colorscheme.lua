-- lua/config/colorscheme.lua

require("tokyonight").setup({
    style = "storm", -- or "night", "moon", or "day"

    -- >>> THE TRANSPARENCY OPTIONS <<<
    transparent = true, -- Set the editor background to transparent
    styles = {
        sidebars = "transparent", -- Make sidebars (like NvimTree) transparent
        floats = "transparent",   -- Make floating windows (like documentation) transparent
    },
    -- >>> END TRANSPARENCY OPTIONS <<<

    -- Other optional settings...
})

vim.cmd("colorscheme tokyonight") 
