return
{
    'saghen/blink.cmp',
    enabled = true,
    version = '*',  -- use a release tag to download pre-built binaries
    dependencies = {
        'rafamadriz/friendly-snippets',
        --"moyiz/blink-emoji.nvim",
    },

    opts =
    {
        --the main options
        completion={
            list = { selection = { preselect = true, auto_insert = true } },
            keyword = { range = "prefix" },
            ghost_text = {enabled = false},
            trigger = {
                show_on_insert_on_trigger_character = false,
            },
            menu = {
                draw = {
                    columns = {
                        { "label", "label_description", gap = 1 },
                        {"kind_icon", "kind" }
                    }
                },
            },
            documentation = { auto_show = false, },
        },

        signature = {
            enabled = true,
            trigger = {
                enabled = false, --auto show
                --Show the signature help window after typing any of alphanumerics, `-` or `_`
                show_on_keyword = false,
                --Show the signature help window after typing a trigger character
                show_on_trigger_character = false,
                --Show the signature help window when entering insert mode
                show_on_insert = false,
                --Show the signature help window when the cursor comes after a trigger character when entering insert mode
                show_on_insert_on_trigger_character = false,
                blocked_trigger_characters = {},
                blocked_retrigger_characters = {},
            },
            window = {
                min_width = 1,
                max_width = 100,
                max_height = 10,
                border = nil, -- Defaults to `vim.o.winborder` on nvim 0.11+ or 'padded' when not defined/<=0.10
                winblend = 0,
                winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
                scrollbar = false, -- Note that the gutter will be disabled when border ~= 'none'
                -- Which directions to show the window,
                -- falling back to the next direction when there's not enough space,
                -- or another window is in the way
                direction_priority = { 's' },
                show_documentation = false, --show signature but not the doc
            },
        },

        cmdline = {
            enabled = true,
            -- use 'inherit' to inherit mappings from top level `keymap` config
            keymap = { preset = 'cmdline' },
            completion = {
                trigger = {
                    show_on_blocked_trigger_characters = {},
                    show_on_x_blocked_trigger_characters = {},
                },
                list = {
                    selection = {
                        -- When `true`, will automatically select the first item in the completion list
                        preselect = true,
                        -- When `true`, inserts the completion item automatically when selecting it
                        auto_insert = true,
                    },
                },
                -- Whether to automatically show the window when new completion items are available
                menu = {
                    auto_show = function(ctx)
                        return vim.fn.getcmdtype() == ':'
                        -- enable for inputs as well, with:
                        -- or vim.fn.getcmdtype() == '@'
                    end,
                },
                -- Displays a preview of the selected item on the current line
                ghost_text = { enabled = true }
            },
        },

        appearance = {
            -- Sets the fallback highlight groups to nvim-cmp's highlight groups
            -- Useful for when your theme doesn't support blink.cmp
            -- Will be removed in a future release
            use_nvim_cmp_as_default = true,
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono'
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            min_keyword_length = 2,
            default = { 'lsp', 'path', 'snippets', 'buffer', },
            providers = {
                buffer = {
                    opts = {
                        --use other buffers as source
                        get_bufnrs = function()
                            return vim.tbl_filter(function(bufnr)
                                return vim.bo[bufnr].buftype == ''
                            end, vim.api.nvim_list_bufs())
                        end
                    }
                },
                cmdline = {
                    min_keyword_length = function(ctx)
                        -- when typing a command, only show when the keyword is 2 characters or longer
                        if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 2 end
                        return 0
                    end
                }
            },
        },

        keymap =
        {
            preset = 'none', --or default

            ['<CR>'] = { 'accept', 'fallback' },
            --['<Tab>'] = {
            --     function(cmp)
            --     if cmp.snippet_active() then return cmp.accept()
            --         else return cmp.select_and_accept() end
            --             end,
            --             'snippet_forward',
            --             'fallback'
            --},
            ["<Esc>"] = {"cancel", 'fallback'},

            ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
            ['<C-e>'] = { 'hide' },

            ['<Up>'] = { 'select_prev', 'fallback' },
            ['<Down>'] = { 'select_next', 'fallback' },
            ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
            ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

            ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

            ['<Tab>'] = { 'snippet_forward', 'fallback' },
            ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

            ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },

        },

    },--opts

}--return
