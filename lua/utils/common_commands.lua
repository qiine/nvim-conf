-------------------------
-- User commands --
-------------------------
local v = vim
local vapi = vim.api
local vcmd = vim.cmd

local utils = require("utils.utils")
-------------------------

vim.api.nvim_create_user_command("WorkDirToCurrent", function()
    vim.cmd("cd %:p:h") -- ":h" rem file name
end, {})

--Quick ressource curr
vim.api.nvim_create_user_command("RessourceCurrent", function()
    local currf = vim.fn.expand("%:p")
    vim.cmd("source " .. currf)
end, {})

--Restart nvim
vim.api.nvim_create_user_command("Restart", function()
    local curfile = vim.fn.expand("%:p") --Get curr file location
    local curdir = vim.fn.fnamemodify(curfile, ':p:h')

    vim.loop.spawn("wezterm", {
        --args = { "-e", "nvim", "--cmd", "cd " .. curdir, curfile },
        --cwd = curdir
        args = { "-e", "nvim", "-S", GLOBAL_SESSION },
    })
    vim.cmd("qa!")
end, {})

vim.api.nvim_create_user_command("RestartSafeMode", function()
    vim.fn.jobstart({ "nvim -u NONE" }, { detach = true })
    vim.cmd("qa!")
end, {})

--Easy lazy plug install
vim.api.nvim_create_user_command("PlugInstall", function(opts)
    local plug_dir = vim.fn.stdpath("config") .. "/lua/plugins/"

    local plug_url = opts.args
    plug_url = plug_url:gsub(",", "")
    plug_url = plug_url:gsub('"', "")
    plug_url = plug_url:gsub("'", "")

    --Check URL empty or malformed
    if plug_url == "" or not plug_url:match(".+/.+") then
        print("Invalid URL. Usage: :PlugInstall user/repo")
        return
    end

    --Extracting plug name
    local last_slash = plug_url:find("/[^/]*$")
    local plug_name = last_slash and plug_url:sub(last_slash + 1)
    --plug_name=plug_name:gsub('.', "-", 1)

    local plug_path = plug_dir .. plug_name .. ".lua"

    -- Check if plugin already installed
    local file_exists = vim.loop.fs_stat(plug_path) ~= nil
    if file_exists then
        print("Plugin '" .. plug_name .. "' already installed.")
        return
    end

    --Creating the file
    local plug_content = 'return{ "' .. plug_url .. '", }'
    local file = io.open(plug_path, "w")
    if file then
        file:write(plug_content)
        file:close()
        print("Installing " .. plug_name .. " in " .. plug_path)
    else
        print("Failed to install" .. plug_name .. " hint: " .. plug_path)
    end
end, { nargs = 1 })

--TODO open help in separate tab
-- vim.api.nvim_create_user_command("H", function(opts)
-- vim.cmd("enew")
-- vim.cmd("setlocal buftype=help")
-- vim.cmd("help "..opts.args)
-- end, { nargs = "*" })



--[Editing]--------------------------------------------------
--Trim select, include tab and break lines
vim.api.nvim_create_user_command("TrimSelectedWhitespaces", function(opts)
    vim.cmd(string.format("s/\\s//g"))
    vim.cmd("normal! <esc>")
end, { range = true })

vim.api.nvim_create_user_command("TrimCurrBufferTrailSpaces", function()
    local curpos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, curpos)
end, {})

vim.api.nvim_create_user_command("ToggleEndOfLineChar", function()
    local listchars = vim.opt.listchars:get()

    if listchars.eol == "¶" then
        vim.opt.listchars:remove("eol")
    else
        vim.opt.listchars:append({ eol = "¶" })
    end
end, {})

--Append underline unicode character to each selected chars
vim.api.nvim_create_user_command("UnderlineSelected", function(opts)
    local start_line = opts.line1 - 1
    local end_line = opts.line2

    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

    local combining = '\u{0332}' --underline unicode
    local function underline(str)
        return str:gsub(".", function(c)
            -- avoid underlining newline or multibyte control chars
            return c:match("[%z\1-\127]") and c .. combining or c
        end)
    end

    for i, line in ipairs(lines) do
        lines[i] = underline(line)
    end

    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
end, { range = true })



--[Formating]
--wrap line into paragraph
vim.api.nvim_create_user_command("WrapSelection", function()
    vim.cmd("normal! gww")
end, { range = true })

vim.api.nvim_create_user_command("ToggleVirtualLines", function()
    local diagconf = vim.diagnostic.config()
    --local virttext = diagconf.virtual_text.enabled
    local virt = diagconf.virtual_lines
vim.diagnostic.Opts.
    vim.diagnostic.config({
            virtual_lines = {
                enabled = not virtenabled,
                current_line = false,
                severity = { min = "WARN" },
            },
            --virtual_text = {
            --    enabled = if virtenabled then false else true end,
            --}
        })

end, {})



vim.api.nvim_create_user_command("DumpMessagesToBuffer", function()
    local cmd_output = vim.fn.execute('messages')

    vim.cmd("enew")

    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(cmd_output, '\n'))
end, {})

