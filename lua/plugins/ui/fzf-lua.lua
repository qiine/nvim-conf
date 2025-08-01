return
{
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
        require('fzf-lua').register_ui_select()
        require("fzf-lua").setup({
            defaults = {
                actions = {
                    ["esc"] = ""  --restore esc to normal mode (now quit with C-w)
                },
            },

            winopts = {
                title_pos    = "center",
                border       = "rounded",  --single
                height       = 0.75,            -- window height
                width        = 1,            -- window width
                row          = 0.50,            -- window row position (0=top, 1=bottom)
                col          = 0.51,            -- window col position (0=left, 1=right)
                backdrop     = 100, --opacity
                preview = {
                    --hidden = "hidden",
                    border = "border",
                    layout = "horizontal",
                    horizontal = "right:47%",
                },
            },
            fzf_opts = {
                ["--layout"] = "default",  --reverse

            },

            files = {
                cmd = [[
                    rg --files --hidden \
                    -g 'Downloads/**' \
                    -g '/**' \
                    -g '!.git/**' \
                    -g '!.npm/**' \
                    -g '!*.log' \
                    -g '!.local/share/**' \
                    -g '!.local/share/Trash/**' \
                    -g '!.local/share/nvim/undo/**' \
                    -g '!cache/**' \
                    -g '!.var/**' \
                    -g '!.cache/**' \
                    -g '!node_modules/**' \
                    -g '!.mozilla/**' \
                    -g '!.cargo/**' \
                    -g '!*/steam-runtime-sniper/**' \
                    -g '!**/containers/**'
                ]]
            },

            keymap = {
                --f4 toggle prev
                fzf = {
                    ["tab"] = function() require("fzf-lua").builtin({
                        winopts = {
                            --preview = {hidden = true}
                        }
                    }) end,
                    --["<F5>"] =
                }
            }
        })

        --find files in currdir
        vim.keymap.set({"i","n","v","t"}, "<M-f>c", function()
            require("fzf-lua").files({})
        end, {silent=true, desc="Fuzzy find dir in cwd"})

        --find files in project
        vim.keymap.set({"i","n","v","t"}, "<C-S-f>", function()
            require("fzf-lua").files({
                cwd = require("fzf-lua.path").git_root({}),
            })
        end, { silent = true, desc = "Fuzzy find file in project" })

        --find files in home
        vim.keymap.set({"i","n","v","t"}, "<M-f>", function()
            require("fzf-lua").files({ cwd="~", })
        end, { silent=true, desc="Fuzzy find file in HOME"})

        --find files in notes
        vim.keymap.set({"i","n","t"}, "<F49>", function()   --<M-F1>
            require("fzf-lua").files({
                cwd = "~/Personal/KnowledgeBase/Notes/"
            })
        end)


        --grep curr dir
        vim.keymap.set({"i","n","v","t"}, "<M-f><S-g>", function()
            require("fzf-lua").live_grep({})
        end, { silent = true, desc = "grep" })

        --grep curr project
        vim.keymap.set({"i","n","v","t"}, "<C-S-g>", function()
            require("fzf-lua").live_grep({
                cwd = require("fzf-lua.path").git_root({}),
            })
        end, { noremap = true, silent = true, desc = "live grep project" })

        --grep curr project for selected
        vim.keymap.set("v", "<C-S-g>", function()
            require("fzf-lua").grep_visual({
                cwd = require("fzf-lua.path").git_root({})
            })
        end, {noremap=true, silent=true, desc="live grep selected in project"})

        --grep in home
        vim.keymap.set({"i","n","v","t"}, "<M-f>g", function()
            require("fzf-lua").live_grep({ cwd = "~" })
        end, { silent = true, desc = "Live grep in home" })

        --grep in notes
        vim.keymap.set({"i","n","t"}, "<F13>", function()   --<S-F1>
            require("fzf-lua").live_grep({
                cwd = "~/Personal/KnowledgeBase/Notes/"
            })
        end)

        --grep in help for selected
        vim.keymap.set("v", "<F13>", function()   --<S-F1>
            require("fzf-lua").grep_visual({
                cwd = "~/Personal/KnowledgeBase/Notes/"
            })
        end)


        --fuzzy cd
        vim.keymap.set({"i","n","v","t"}, "<M-f>d", function()
            require("fzf-lua").fzf_exec("fdfind . --type d", { --or fd
                prompt = "~/",
                cwd = "~",
                actions = {
                    ["default"] = function(selected)
                        if selected and #selected > 0 then
                            local root = vim.fn.expand("~").."/"
                            vim.cmd("cd " .. root .. selected[1])
                        end
                    end,
                },
            })
        end, {silent=true, desc="Fuzzy cd to dir under ~"})


        --search ft
        vim.keymap.set({"i","n","v"}, "<M-f>t", function()
            require("fzf-lua").filetypes({})
        end, {silent = true, desc = "search and set filetypes" })

        --search builtins
        vim.keymap.set({"i","n","v","t"}, "<M-f>b", function()
            require("fzf-lua").builtin({})
        end, {silent = true, desc = "Search builtins" })

    end --config
}
