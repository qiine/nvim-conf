-- _
--| |
--| | _____ _   _ _ __ ___   __ _ _ __  ___
--| |/ / _ \ | | | '_ ` _ \ / _` | '_ \/ __|
--|   <  __/ |_| | | | | | | (_| | |_) \__ \
--|_|\_\___|\__, |_| |_| |_|\__,_| .__/|___/
--           __/ |               | |
--          |___/                |_|

local utils = require("utils.utils")

local v     = vim
local vapi  = vim.api
local vcmd  = vim.cmd
local kmap  = vim.keymap.set
local nvmap = vim.api.nvim_set_keymap
----------------------------------------



--[Doc]--------------------------------------------------
--Setting key example:
--vim.keymap.set("i", "<C-d>", "dd",{noremap = true, silent = true, desc ="ctrl+d delete line"})
--noremap = true,  Ignore any existing remappings will act as if there is no custom mapping.
--silent = true Prevents displaying command in the command-line when executing the mapping.

--to unmap a key use <Nop>
--vim.keymap.set("i", "<C-d>", "<Nop>",{noremap = true"})

--!WARNING! using vim.cmd("Some command") in a setkey will be auto-executed  when the file is sourced !!

--<cmd>
--doesn't change modes which helps perf
--`<cmd>` does need <CR>. while ":" triggers "CmdlineEnter" implicitly

--Keys
--<C-o> allows to execute one normal mode command while staying in insert mode.

--<esc> = \27
--<cr> = \n
--<Tab> = \t
--<C-BS> = ^H

--modes helpers
local modes = { "i", "n", "v", "o", "s", "t", "c" }



--## [Settings]
----------------------------------------------------------------------
vim.opt.timeoutlen = 300 --delay between key press to register shortcuts



--## [Internal]
----------------------------------------------------------------------
--Ctrl+q to quit
kmap(modes, "<C-q>", function() v.cmd("qa!") end, {noremap=true, desc="Force quit all buffer"})

--Quick restart nvim
kmap(modes, "<C-M-r>", "<cmd>Restart<cr>")

--F5reload buffer
kmap({"i","n","v"}, '<F5>', function() vim.cmd("e!") vim.cmd("echo'-File reloaded-'") end, {noremap = true})



--## [File]
----------------------------------------------------------------------
--Create new file
kmap({"i","n","v"}, "<C-n>", function()
    local buff_count = vim.api.nvim_list_bufs()
    local newbuff_num = #buff_count
    v.cmd("enew")
    vim.cmd("e untitled_"..newbuff_num)
end)

--Open file picker
kmap(modes, "<C-o>", function() vim.cmd("FilePicker") end)

--ctrl+s save
kmap(modes, "<C-s>", function()
    local cbuf = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(0)

    if vim.fn.filereadable(path) == 1 then   --Check file exist on disk
        vim.cmd("write")
    else
        if vim.fn.confirm("File does not exist. Create it?", "&Yes\n&No", 1) == 1 then
            vim.ui.input(
                { prompt = "Save as: ", default = path, completion = "dir" },
                function(input)
                    vim.api.nvim_command("redraw") --Hide prompt

                    if input == nil or input == "" then
                        vim.notify("Creation cancelled.", vim.log.levels.INFO) return
                    end

                    vim.api.nvim_buf_set_name(cbuf, input)
                    vim.cmd("write")
                    vim.cmd("edit!") --refresh name
                end
            )
        end
    end
end)

--Save all buffers
kmap(modes, "<C-S-s>", function()
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.fn.filereadable(vim.api.nvim_buf_get_name(buf)) == 1 then
            --nvim_buf_call Ensure proper bufs info
            vim.api.nvim_buf_call(buf, function()
                if vim.bo.modifiable and not vim.bo.readonly and vim.bo.buftype == "" then
                    vim.cmd("write") --we can safely write
                end
            end)
        end
    end
end)

--save as
kmap(modes, "<M-C-S>", function()
    local cbuf = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(0)

    vim.ui.input(
        { prompt = "Save as: ", default = path, completion = "dir"},
        function(input)
            vim.api.nvim_command("redraw") --Hide prompt

            if input == nil or input == "" then
                vim.notify("Save cancelled.", vim.log.levels.INFO) return
            end

            vim.api.nvim_buf_set_name(cbuf, input)
            vim.cmd("write")
            vim.cmd("edit!") --refresh name
        end
    )
end)


--Ressource curr file
kmap(modes, "ç", --"<altgr-r>"
    function()
        local cf = vim.fn.expand("%:p")

        vim.cmd("source "..cf)

        --broadcast
        local fname = '"'..vim.fn.fnamemodify(cf, ":t")..'"'
        vim.cmd(string.format("echo '%s ressourced'", fname))
    end
)



--## [View]
----------------------------------------------------------------------
--alt-z toggle line wrap
kmap({"i", "n", "v"}, "<A-z>",
    function()
        vim.opt.wrap = not vim.opt.wrap:get()  --Toggle wrap
    end
)

--Gutter on/off
kmap({"i","n"}, "<M-g>", function()
    local toggle = "yes"
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.opt.signcolumn = "no"
    vim.opt.foldenable = false
end, {desc = "Toggle Gutter" })


--#[Folding]
-- vmap({"i","n","v}", "<M-f>",
--     function()
--         if v.fn.foldclosed(".") == -1 then
--             v.cmd("foldclose")
--         else
--             v.cmd("foldopen")
--         end
--     end,
-- {noremap = true, silent = true}
-- )

--virt lines
kmap("n", "gl", "<cmd>Toggle_VirtualLines<CR>", {noremap=true})



--## [Tabs]
----------------------------------------------------------------------
--create new tab
kmap( modes,"<C-t>", function()
    vim.cmd("enew")
    vim.cmd("Alpha")
end)

--Tabs close
kmap(modes, "<C-w>", function()
    local bufmodif = vim.api.nvim_get_option_value("modified", { buf = 0 })
    if bufmodif then
        local choice = vim.fn.confirm("Unsaved changes, quit anyway? ", "&Yes\n&No", 1)
        if choice == 2 or choice == 0 then return end
    end

    --try close splits first, in case both splits are same buf
    --avoid killing the shared buffer in this case
    local ok, _ = pcall(vim.cmd, "close")
    if not ok then
        vim.cmd("bd!") --effectively close the tab
    end
end)

--Tabs nav
--next
kmap(modes, "<C-Tab>",  "<cmd>bnext<cr>")
--prev
kmap(modes, "<C-S-Tab>", "<cmd>bp<cr>")



--## [Windows]
----------------------------------------------------------------------
kmap("i", "<M-w>", "<esc><C-w>")
kmap("n", "<M-w>", "<C-w>")
kmap("v", "<M-w>", "<Esc><C-w>")

--To next window
kmap({"i","n","v","c"}, "<M-Tab>", function()
    vim.cmd("normal! w")
end)

kmap("i", "<M-w><C-Left>", "<esc><C-w><")
kmap("n", "<M-w><C-Left>", "<C-w><")



--## [Navigation]
----------------------------------------------------------------------
kmap("n", "<Left>",  "<Left>",  { noremap = true })  --avoid opening folds
kmap("n", "<Right>", "<Right>", { noremap = true })

--Jump to next word
kmap({"i","v"}, '<C-Right>', function()
    local cursr_prevrow = vim.api.nvim_win_get_cursor(0)[1]

    vim.cmd("normal! w")

    if cursr_prevrow ~= vim.api.nvim_win_get_cursor(0)[1] then
        vim.cmd("normal! b")

        if vim.fn.mode() == "v" then vim.cmd("normal! $")
        else                         vim.cmd("normal! A") end
    end
end)

--Jump to previous word
kmap({"i","v"}, '<C-Left>', function()
    local cursr_prevrow = vim.api.nvim_win_get_cursor(0)[1]

    vim.cmd("normal! b")

    if cursr_prevrow ~= vim.api.nvim_win_get_cursor(0)[1] then
        vim.cmd("normal! w")
        vim.cmd("normal! 0")
    end
end)

--to next/prev cursor loc
kmap({"i","v"}, "<M-PageDown>",  "<Esc><C-o>")
kmap("n",       "<M-PageDown>",  "<C-o>")
kmap({"i","v"}, "<M-PageUp>",    "<Esc><C-i>")
kmap("n",       "<M-PageUp>",    "<C-i>")


--#[Fast cursor move]
--Fast left/right move in normal mode
kmap('n', '<C-Right>', "5l")
kmap('n', '<C-Left>',  "5h")

--ctrl+up/down to move fast
kmap("i", "<C-Up>", "<Esc>3ki")
kmap("n", "<C-Up>", "4k")
kmap("v", "<C-Up>", "3k")

kmap("i", "<C-Down>", "<Esc>3ji")
kmap("n", "<C-Down>", "4j")
kmap("v", "<C-Down>", "3j")


--alt+left/right move to start/end of line
kmap("i",       "<M-Left>", "<Esc>0i")
kmap({"n","v"}, "<M-Left>", "0")

kmap("i",       "<M-Right>", "<Esc>$a")
kmap({"n","v"}, "<M-Right>", "$")

--Quick home/end
kmap("i",       "<Home>", "<Esc>gg0i")
kmap({"n","v"}, "<Home>", "gg0")

--kmap("i",       "<M-Up>", "<Esc>gg0i")  --collide with <esc><up>
--kmap({"n","v"}, "<M-Up>", "gg0")

kmap("i",       "<End>", "<esc>G0i")
kmap({"n","v"}, "<End>", "G0")

--kmap("i", "<M-Down>", "<Esc>G0i")  --collide with <esc><up>
--kmap({"n","v"}, "<M-Down>", "G0")

--jump to word
--function JumpToCharAcrossLines(target)
--    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--    local lines = vim.api.nvim_buf_get_lines(0, row - 1, -1, false)

--    -- Adjust first line to start at current column
--    lines[1] = lines[1]:sub(col + 2)

--    local total_offset = col + 1

--    for i, line in ipairs(lines) do
--        local index = line:find(target, 1, true)
--        if index then
--            local target_row = row + i - 1
--            local target_col = (i == 1) and col + index or index - 1
--            vim.api.nvim_win_set_cursor(0, { target_row, target_col })
--            return
--        end
--    end
--end

kmap("n", "f", function()
    --JumpToCharAcrossLines()
end, {remap = true})


--## [Selection]
----------------------------------------------------------------------
--Swap selection anchors
kmap("v", "<M-v>", "o")

--Select word under cursor
kmap("i", "<C-S-w>", "<esc>viw")
kmap("n", "<C-S-w>", "viw")
kmap("v", "<C-S-w>", "<esc>viw")

--shift+arrows visual select
kmap("i", "<S-Left>", "<Esc>hv", {noremap = true})
kmap("n", "<S-Left>", "vh", {noremap = true})
kmap("v", "<S-Left>", "<Left>")

kmap("i", "<S-Right>", "<Esc>v", {noremap = true})
kmap("n", "<S-Right>", "vl", {noremap = true})
kmap("v", "<S-Right>", "<Right>")

kmap("i", "<S-Up>", "<Esc>vk", {noremap=true})
kmap("n", "<S-Up>", "vk", {noremap=true})
kmap("v", "<S-Up>", "k", {noremap=true}) --avoid fast scrolling around

kmap("i", "<S-Down>", "<Esc>vh", {noremap=true})
kmap("n", "<S-Down>", "vj", {noremap=true})
kmap("v", "<S-Down>", "j", {noremap=true}) --avoid fast scrolling around

--Select to home
kmap("i", "<S-Home>", "<Esc>vgg0i")
kmap("n", "<S-Home>", "vgg0")
kmap("v", "<S-Home>", "g0")

--select to end
kmap("i", "<S-End>", "<Esc>vGi")
kmap("n", "<S-End>", "vG")
kmap("v", "<S-End>", "G")

--ctrl+a select all
kmap(modes, "<C-a>", "<Esc>ggVG")


--Visual block selection
kmap({"i","n"}, "<S-M-Left>", "<Esc><C-v>h")
kmap("v", "<S-M-Left>",
    function()
        if vim.fn.mode() == '\22' then  --"\22" is vis block mode
            vim.cmd("normal! h")
        else
            vim.cmd("normal! h")
        end
    end
)

kmap({"i","n"}, "<S-M-Right>", "<Esc><C-v>l")
kmap("v", "<S-M-Right>",
    function()
        if vim.fn.mode() == '\22' then
            vim.cmd("normal! l")
        else
            vim.cmd("normal! l")
        end
    end
)

kmap({"i","n"}, "<S-M-Up>", "<Esc><C-v>k")
kmap("v", "<S-M-Up>",
    function()
        if vim.fn.mode() == '\22' then
            vim.cmd("normal! k")
        else
            vim.cmd("normal! k")
        end
    end
)

kmap({"i","n"}, "<S-M-Down>", "<Esc><C-v>j")
kmap("v", "<S-M-Down>",
    function()
        if vim.fn.mode() == '\22' then
            vim.cmd("normal! j")
        else
            vim.cmd("normal! j")
        end
    end
)


--### [Grow select]
--grow horizontally TODO proper anchor logic
kmap("i", "<C-S-PageDown>", "<Esc>vl")
kmap("n", "<C-S-PageDown>", "vl")
kmap("v", "<C-S-PageDown>", "l")

kmap("i", "<C-S-PageUp>", "<Esc>vh")
kmap("n", "<C-S-PageUp>", "vh")
kmap("v", "<C-S-PageUp>", "oho")

--grow do end/start of line
kmap("i", "<S-PageUp>", "<Esc><S-v>k")
kmap("n", "<S-PageUp>", "<S-v>k")
kmap("v", "<S-PageUp>",
    function ()
        if vim.fn.mode() == "V" then
            vim.cmd("normal! k")
        else
            vim.cmd("normal! Vk")
        end
    end
)

kmap("i", "<S-PageDown>", "<Esc><S-v>j")
kmap("n", "<S-PageDown>", "<S-v>j")
kmap("v", "<S-PageDown>",
    function ()
        local m = vim.api.nvim_get_mode().mode
        if vim.fn.mode() == "V" then
            vim.cmd("normal! j")
        else
            vim.cmd("normal! Vj")
        end
    end
)


--#[select search]
kmap("i", "<C-f>", "<Esc><C-l>:/")
kmap("n", "<C-f>", "/")
kmap("v", "<C-f>", 'y<Esc><C-l>:/<C-r>"')



--## [Editing]
----------------------------------------------------------------------
--toggle insert/normal with insert key
kmap("i", "<Ins>", "<Esc>")
kmap("n", "<Ins>", "i")
kmap("v", "<Ins>", function ()
    --seems to be more relyable
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>i", true, false, true), "n", false)
end)


--To Visual insert mode
kmap("v", "<M-i>", "I")
kmap("v", "î",
    function()
        if vim.fn.mode() == '\22' then  --"\22" is vis block mode
            --"$A" insert at end of each lines from vis block mode
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$A", true, false, true), "n", false)
        else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-v>", true, false, true), "n", false)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$A", true, false, true), "n", false)
        end
    end
)

--Insert literal
--kmap("i", "<C-i>", "<C-v>") --collide with tab :(
kmap("n", "<C-i>", "i<C-v>")

--Insert chars in visual mode
local chars = utils.table_flatten(
    {
        utils.alphabet_lowercase,
        utils.alphabet_uppercase,
        utils.numbers,
        utils.punctuation,
    }
)
for _, char in ipairs(chars) do
    kmap('v', char, '"_d<esc>i'..char, {noremap=true})
end
kmap("v", "<space>", '"_di<space>', {noremap=true})
kmap("v", "<cr>", '"_di<cr>', {noremap=true})


--#[Copy / Paste]
-- ' "+ ' is the os register
--Copy
--Copy whole line in insert
kmap("i", "<C-c>", function()
    local cpos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()

    if line ~= "" then
        vim.cmd('normal! 0"+y$')

        vim.api.nvim_win_set_cursor(0, cpos)

        vim.cmd("echo 'copied!'")
    end
end, {noremap=true} )
kmap("n", "<C-c>", function()
    local char = utils.get_char_at_cursorpos()

    if  char ~= " " and char ~= "" then
        vim.cmd('normal! "+yl')
    end
end, {noremap = true})
kmap("v", "<C-c>", function()
    local cpos = vim.api.nvim_win_get_cursor(0)

    vim.cmd('normal! "+y')

    vim.api.nvim_win_set_cursor(0, cpos)

    vim.cmd("echo 'copied'")
end, {noremap=true})

--copy append
kmap("v", "<M-c>", function()
    local cpos = vim.api.nvim_win_get_cursor(0)
    local reg_prev = vim.fn.getreg("+")

    vim.cmd('normal! "+y')

    --apppend
    vim.fn.setreg("+", reg_prev .. vim.fn.getreg("+"))

    vim.api.nvim_win_set_cursor(0, cpos)

    print("appended to clipboard!")
end)

--Copy word
kmap({"i","n"}, "<C-S-c>", function()
    local cpos = vim.api.nvim_win_get_cursor(0)

    vim.cmd('normal! viw"+y')

    vim.api.nvim_win_set_cursor(0, cpos)

    print("Word Copied")
end)


--cuting
kmap("i", "<C-x>", '<esc>0"+y$"_ddi', { noremap = true})
kmap("n", "<C-x>", '"+x',             { noremap = true})
kmap("v", "<C-x>", '"+d<esc>',        { noremap = true}) --d both delete and copy so..

--cut word
kmap("i", "<C-S-x>", '<esc>viw"+xi')
kmap("n", "<C-S-x>", 'viw"+x')

--Pasting
kmap("i", "<C-v>", '<esc>"+P`[v`]=`]a') --format and place curso at the end
kmap("n", "<C-v>", '"+P`[v`]=`]')
kmap("v", "<C-v>", '"_d"+P`[v`]=')
kmap("c", "<C-v>", '<C-R>+')
kmap("t", "<C-v>", '<C-o>"+P')

--Duplicate
kmap("i", "<C-d>", '<Esc>yypi')
kmap("n", "<C-d>", 'yyp')
kmap("v", "<C-d>", 'yP')


--#[Undo/redo]
--ctrl+z to undo
kmap("i",       "<C-z>", "<C-o>u", {noremap = true})
kmap({"n","v"}, "<C-z>", "u",      {noremap = true})

--redo
kmap("i",       "<C-y>", "<cmd>normal! <C-r><cr>")
kmap({"n","v"}, "<C-y>", "<C-r>")

kmap("i",       "<C-S-z>", "<cmd>normal! <C-r><cr>")
kmap({"n","v"}, "<C-S-z>", "<C-r>")


--#[Deletion]
--##[Backspace]
--BS remove char
--kmap("i", "<BS>", "<C-o>x", {noremap=true, silent=true}) --maybe not needed on wezterm
--kmap("n", "<BS>", '<Esc>"_X<Esc>')
kmap("n", "<BS>", 'r ')
kmap("v", "<BS>", '"_xi')

--remove word left
--<M-S-BS> instead of <C-BS> because of wezterm
kmap("i", "<M-S-BS>", '<esc>"_dbi')
kmap("n", "<M-S-BS>", '"_db')
kmap("v", "<M-S-BS>", '"_d')

--Backspace replace with white spaces, from cursor to line start
--kmap({"i","n"}, "<M-BS>",
--    function()
--        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--        local line = vim.api.nvim_get_current_line()

--        local left = line:sub(1, col)
--        local right = line:sub(col + 1)

--        local spaces = left:gsub(".", " ")
--        vim.api.nvim_set_current_line(spaces .. right)

--        -- Keep cursor pos
--        vim.api.nvim_win_set_cursor(0, {row, col})
--    end
--)

--Remove to start of line
kmap("i", "<M-BS>", '<Esc>"_d0i')
kmap("n", "<M-BS>", '"_d0')

--Shift+backspace clear line
kmap("i", "<S-BS>", '<Esc>"_cc')
kmap("n", "<S-BS>", '"_cc<esc>')
kmap("v", "<S-BS>", '<Esc>"_cc<esc>')


--##[Delete]
kmap("n", "<Del>", 'v"_d<esc>')
kmap("v", "<Del>", '"_di')

--Delete right word
kmap("i",       "<C-Del>", '<C-o>"_dw')
kmap({"n","v"}, "<C-Del>", '"_dw')

--Delete in word
kmap("i", "<C-S-Del>", '<esc>"_diwi')
kmap("n", "<C-S-Del>", '"_diw')

--Smart delete in
kmap({"i","n"}, "<C-M-Del>", function()
    local delete_commands = {
        ["("] = '"_di(', [")"] = '"_di(',
        ["["] = '"_di[', ["]"] = '"_di[',
        ["{"] = '"_di{', ["}"] = '"_di{',
        ["<"] = '"_di<', [">"] = '"_di<',

        ['"'] = '"_di"',
        ["'"] = '"_di',
        ["`"] = '"_di`',
    }

    local crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
    local cline = vim.fn.getline(crow)

    local pchar =  cline:sub(ccol, ccol)
    local cchar =  cline:sub(ccol+1, ccol+1)
    local nchar =  cline:sub(ccol+2, ccol+2)

    local pcommand = delete_commands[pchar]
    local ccommand = delete_commands[cchar]
    local ncommand = delete_commands[nchar]

    if ccommand then
        vim.cmd("normal! " .. ccommand ) return
    elseif pcommand then
        vim.cmd("normal! h" .. pcommand ) return
    elseif ncommand then
        vim.cmd("normal! l" .. ncommand ) return
    end
end)

--del to end of line
kmap("i", "<M-Del>", '<Esc>"_d$i')
kmap("n", "<M-Del>", '"_d$')

--Delete line
kmap("i", "<S-Del>", '<esc>"_ddi')
kmap("n", "<S-Del>", '"_dd')
kmap("v", "<S-Del>", function()
    if vim.fn.mode() == "V" then  --avoid <S-v> on line select, because it would unselect instead
        vim.cmd('normal! "_d')
    else
        vim.cmd('normal! V"_d')
    end
end)


--#[Replace]
--replace selection with char
--kmap("n", "*", "")
--kmap("v", "*", "\"zy:%s/<C-r>z//g<Left><Left>")

kmap("i", "<C-S-R>", "<esc>ciw")
kmap("n", "<C-S-R>", "ciw")

--#[Incrementing]
--vmap("n", "+", "<C-a>")
kmap("v", "+", "<C-a>gv")

--vmap("n", "-", "<C-x>") --Decrement
kmap("v", "-", "<C-x>gv") --Decrement

--To upper/lower case
kmap("n", "<M-+>", "vgU<esc>")
kmap("v", "<M-+>", "gUgv")

kmap("n", "<M-->", "vgu<esc>")
kmap("v", "<M-->", "gugv")

--Smart increment/decrement
kmap({"n"}, "+", function() utils.smartincrement() end)
kmap({"n"}, "-", function() utils.smartdecrement() end)


--#[Formating]
--##[Ident]
--space bar in normal mode
kmap("n", "<space>", "i<space><esc>")

--smart tab in insert
vim.keymap.set("i", "<Tab>",
    function()
        local inword = utils.is_cursor_inside_word()

        if inword then vim.cmd("normal! v>") vim.cmd("normal! 4l")
            else vim.cmd("normal! i\t") --don't care about softab here
        end
    end
)
kmap("n", "<Tab>", "v>")
kmap("v", "<Tab>", ">gv")

kmap("i", "<S-Tab>", "<C-d>")
kmap("n", "<S-Tab>", "v<")
kmap("v", "<S-Tab>", "<gv")


--##[Line break]
kmap("n", "<cr>", "i<cr><esc>")

--breakline above
kmap("i", "<S-cr>", "<Esc>O")
kmap("n", "<S-cr>", "O<esc>")
kmap("v", "<S-cr>", "<esc>O<esc>vgv")

--breakline below
kmap("i", "<M-cr>", "<Esc>o")
kmap("n", "<M-cr>", 'o<Esc>')
kmap("v", "<M-cr>", "<Esc>o<Esc>vgv")

--New line above and below
kmap("i", "<S-M-cr>", "<esc>o<esc>kO<esc>ji")
kmap("n", "<S-M-cr>", "o<esc>kO<esc>j")
kmap("v", "<S-M-cr>", function ()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), "n", false)
    local anchor_start_pos = vim.fn.getpos("'<")

    if (anchor_start_pos[3]-1) ~= cursor_pos[2] then
        vim.cmd("normal! o")
    end
    vim.cmd("normal! gv")

    --vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), "n", false)
    --vim.cmd("normal! O")

end)


--##[Join]
--Join one below
kmap("i", "<C-j>", "<C-o><S-j>")
kmap("n", "<C-j>", "<S-j>")
kmap("v", "<C-j>", "<S-j>")

--Join to upper
kmap("i", "<C-S-j>", "<esc>k<S-j>i")
kmap("n", "<C-S-j>", "k<S-j>")

--##[move text]
--Move single char
kmap("n", "<C-S-Right>", "xp")
kmap("n", "<C-S-Left>", "xhP")
--vmap("n", "<C-S-Up>", "xkp")
--vmap("n", "<C-S-Down>", "xjp")

--Move selected text
--left
kmap("i", "<C-S-Left>", '<esc>viwdhPgvhoho')
kmap("v", "<C-S-Left>", function()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    if vim.fn.mode() == 'v' and col > 0 then
        local cmd = 'dhP<esc>gvhoho'
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, false, true), "n", false)

        local cursor_pos = vim.api.nvim_win_get_cursor(0)

        --Tricks to refresh vim.fn.getpos("'<")
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gv', true, false, true), "n", false)
        local anchor_start_pos = vim.fn.getpos("'<")

        if (anchor_start_pos[3]-1) ~= cursor_pos[2] then
            vim.cmd("normal! o")
        end

        --maybe wrap to next/prev line ?
    end
end)

--right
kmap("i", "<C-S-Right>", '<esc>viwdpgvlolo')
kmap("v", "<C-S-Right>", 'dp<esc>gvlolo')

--move line verticaly
kmap('v', '<C-S-Up>', function()
    local l1 = vim.fn.line("v")
    local l2 = vim.fn.line(".")
    local mode = vim.fn.mode()

    if math.abs(l1 - l2) > 0 or mode == "V" then --move whole line if multi line select
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":m '<-2<cr>gv=gv", true, false, true), "n", false)
    else
        vim.cmd('normal! d')     -- yank and delete selection into register z
        vim.cmd('normal! k')     -- move cursor up one line
        vim.cmd('normal! P')     -- paste from register z

        local anchor_start_pos = vim.fn.getpos("'<")[3]
        vim.cmd('normal! v'..anchor_start_pos..'|') -- reselect visual selection
    end
end)

kmap('v', '<C-S-Down>', function ()
    local l1 = vim.fn.line("v")
    local l2 = vim.fn.line(".")
    local mode = vim.fn.mode()

    if math.abs(l1 - l2) > 0 or mode == "V" then --move whole line if multi line select
        vim.api.nvim_feedkeys( vim.api.nvim_replace_termcodes(":m '>+1<cr>gv=gv", true, false, true), "n", false)
    else
        vim.cmd('normal! d')   -- delete selection into register z
        vim.cmd('normal! j')
        vim.cmd('normal! P')

        local anchor_start_pos = vim.fn.getpos("'<")[3]
        vim.cmd('normal! v'..anchor_start_pos..'|') -- reselect visual selection
    end
end)

--Move whole line
kmap("i", "<C-S-Up>", "<Esc>:m .-2<CR>==i")
kmap("n", "<C-S-Up>", ":m .-2<CR>==")

kmap("i", "<C-S-Down>", "<Esc>:m .+1<cr>==i")
kmap("n", "<C-S-Down>", ":m .+1<cr>==")


--#[Comments]
kmap("i", "<M-a>", "<cmd>normal gcc<cr>", {remap = true}) --remap needed
kmap("n", "<M-a>", "gcc", {remap = true}) --remap needed
kmap("v", "<M-a>", "gcgv",  {remap = true}) --remap needed


--#[record]
kmap("n", "<M-r>", "q", {remap = true})



--## [Text inteligence]
----------------------------------------------------------------------
--Goto deffinition
kmap("i", "<F12>", "<Esc>gdi")
kmap("n", "<F12>", "gd")
kmap("v", "<F12>", "<Esc>gd")

--show hover window
kmap({"i","n","v"}, "<C-h>", function() vim.lsp.buf.hover() end)

--rename symbol
--vmap({"i","n"}, "<F2>", function()
--    vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
--        callback = function()
--            local key = vim.api.nvim_replace_termcodes("<C-f>", true, false, true)
--            vim.api.nvim_feedkeys(key, "c", false)
--            return true
--        end,
--    })
--    vim.lsp.buf.rename()
--end)

--lsp rename
kmap({"i","n"}, "<F2>",
    function()
        --live-rename is a plugin for fancy in buffer rename preview
        require("live-rename").rename({ insert = true })
    end
)

--smart contextual action
kmap({"i","n","v"}, "<C-CR>", function()
    local word = vim.fn.expand("<cfile>")
    local cchar = utils.get_char_at_cursorpos()
    local filetype = vim.bo.filetype

    if word:match("^https?://") then
        vim.cmd("normal! gx")
    elseif vim.fn.filereadable(word) == 1 then
        vim.cmd("normal! gf")
    else
        vim.cmd("normal! %")
    end
    --to tag
    --<C-]>
end)



--[code runner]--------------------------------------------------
--run code at cursor with sniprun
--run curr line only and insert res below
kmap({"i","n"}, "<F32>","<cmd>SnipRunLineInsertResult<CR>")

--<F20> equivalent to <S-F8>
--run selected code in visual mode
kmap("v", "<F20>","<cmd>SnipRunSelectedInsertResult<CR>")

--run whole file until curr line and insert
kmap({"i","n"}, "<F20>","<cmd>SnipRunToLineInsertResult<CR>")


--exec curr line as ex command
kmap({"i","n"}, "<F56>", --equivalent to <M-F8>
    function()
        vim.cmd("stopinsert")
        local row = vim.api.nvim_win_get_cursor(0)[1]  -- Get the current line number
        local line = vim.fn.getline(row)  -- Get the content of the current line
        vim.cmd(line)
    end
)



--[vim cmd]--------------------------------------------------
--Open command line
kmap("i", "œ", "<esc>:")
kmap("n", "œ", ":")
kmap("v", "œ", ":")
kmap("t", "œ", "<Esc> <C-\\><C-n>")

--Open command line in term mode
kmap("i", "<S-Œ>", ":!")
kmap("n", "<S-Œ>", ":!")
kmap("v", "<S-Œ>", ":!")
kmap("c", "<S-Œ>", "<esc>:!")

--cmd completion menu
--vmap("c", "<C-d>", "<C-d>")

--Cmd menu nav
kmap("c", "<Up>", "<C-p>")
kmap("c", "<Down>", "<C-n>")

--accept
kmap("c", "<S-Tab>", "<C-n>")

--Clear cmd in insert
kmap("i", "<C-l>", "<C-o><C-l>")

--Cmd close
kmap("c", "œ", "<C-c><C-L>")  --needs <C-c> and not <Esc> because Neovim behaves as if <Esc> was mapped to <CR> in cmd

--help
--Help for selected
kmap("v", "<F1>", function()
    vim.cmd('normal! y')
    local reg = vim.fn.getreg('"')
    vim.cmd("h " .. reg)
end)



--[Terminal]----------------------------------------
--Open term
kmap({"i","n","v"}, "<M-t>", function() v.cmd("term") end, {noremap=true})

--exit
kmap("t", "<esc>", "<Esc> <C-\\><C-n>", {noremap=true})


