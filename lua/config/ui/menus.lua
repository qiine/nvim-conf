local v = vim

-------------------------------------------------------
--File--
-------------------------------------------------------
v.opt.title = true --display file title useful for tabs name

v.opt.confirm = true --Ask for save before quit



--[View]--------------------------------------------------
v.opt.laststatus = 3
--0 → Never show the statusline.
--1 → Show the statusline only when there are multiple windows.
--2 → Always show the statusline in evry window.
--3 → (Global Statusline) A single statusline is displayed at the bottom, shared across all windows.



--[Edit]--------------------------------------------------
--Autocomplete
v.opt.completeopt = "menuone,noinsert,noselect"
--v.opt.completeopt = "menu,menuone,popup,fuzzy" -- modern completion menu
--menuone: always show completion menu even if there is only one match
--noinsert: prevents automatically inserting the first match when completion menu is shown
--noselect: ensures no item is selected by default when completion menu shown.
v.o.pumheight = 10 --max height of completion menu
vim.o.pumblend = 10 --Transparency for popup-menu



--[Context menu]--------------------------------------------------
--To create a new menu item, use the ":menu" commands.  They are mostly like
--the ":map" set of commands (see |map-modes|), but the first argument is a menu
--item name, given as a path of menus and submenus with a '.' between them,
--e.g.: >

--:menu File.Save  :w<CR>
--:inoremenu File.Save  <C-O>:w<CR>
--:menu Edit.Big\ Changes.Delete\ All\ Spaces  :%s/[ ^I]//g<CR>
--v.api.nvim_create_autocmd("VimEnter", {
--    callback = function()
--        v.api.nvim_command [[aunmenu PopUp.How-to\ disable\ mouse]]
--        v.api.nvim_command [[amenu PopUp.References :lua vim.lsp.buf.references()<cr>]]
--        v.api.nvim_command [[vmenu PopUp.Format\ selected :FormatSelected<cr>]]
--    end,
--    desc = "contextual menu",
--})


local contextmenu_items =
{
    "anoremenu PopUp.Open\\ in\\ browser " .. [[gx]],
    "anoremenu PopUp.{}Goto\\ definition ".. [[gd]],
    "anoremenu PopUp.{}References ".. [[<cmd>Trouble lsp_references toggle focus=true<CR>]],
    --"aunmenu PopUp.Inspect ",
    "vnoremenu PopUp.Format\\ selected " .. ":FormatSelected<CR>",
    "amenu     PopUp.───────────────── <NOP>",
    "vnoremenu PopUp.🗐Copy ".. [["+y]],
    "vnoremenu PopUp.✀\\ Cut ".. [["+d]],
    "anoremenu PopUp.🗅Paste ".. [["+p]],
    "vnoremenu PopUp.🗑Delete ".. [["_d]],
    "amenu     PopUp.-──────────────── <NOP>",
    "anoremenu PopUp.🔎Telescope " .. [[<cmd>Telescope<CR>]],
}

vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    group = "UserAutoCmds",
    desc = "Setup context menu",
    callback = function()
        --v.api.nvim_command("aunmenu PopUp") --rem all base entries

        --local menus = vim.fn.execute('menu PopUp')
        --local label = "Go to definition"
        ----local pattern = label:gsub(" ", "\\ ")
        --local mvalid = menus:match(label)

        --if mvalid then
        --    vim.api.nvim_command([[aunmenu PopUp.Go\ to\ definition]])
        --end

        --v.api.nvim_command [[aunmenu PopUp.Go\ to\ definition]]
        v.api.nvim_command [[aunmenu PopUp.How-to\ disable\ mouse]]
        v.api.nvim_command [[aunmenu PopUp.Copy]]
        v.api.nvim_command [[aunmenu PopUp.Cut]]
        v.api.nvim_command [[aunmenu PopUp.Paste]]
        v.api.nvim_command [[aunmenu PopUp.Delete]]
        v.api.nvim_command [[aunmenu PopUp.Inspect]]
        v.api.nvim_command [[aunmenu PopUp.Select\ All]]
        v.api.nvim_command [[aunmenu PopUp.-1-]]
        v.api.nvim_command [[aunmenu PopUp.-2-]]

        --Insert new menu entries
        for _, item in ipairs(contextmenu_items) do
            v.api.nvim_command(item)
        end

        --smart enable/disable based on context
        vim.cmd[[
            amenu disable PopUp.Open\ in\ browser
        ]]

        --if vim.lsp.get_clients({ bufnr = 0 })[1] then
        --    vim.cmd[[
        --        amenu enable PopUp.References
        --    ]]
        --end

        local urls = require("vim.ui")._get_urls()
        if vim.startswith(urls[1], "http") then
             vim.cmd[[
                 amenu enable PopUp.Open\ in\ browser
            ]]
        end
    end,
})

-------------------------------------------------------
-- Dashboard --
-------------------------------------------------------
--vim.api.nvim_create_autocmd("VimEnter", {
--command = "opendashboard"
--})


