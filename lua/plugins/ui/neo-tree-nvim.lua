return
{
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
    },

    config = function()
        require("neo-tree").setup({

            --source_selector = {
            --  winbar = true,
            --  statusline = true,
            --  show_scrolled_off_parent_node = false,
            --  sources = {
            --    { source = "filesystem" },
            --    { source = "buffers" },
            --    { source = "git_status" },
            --  },
            --},

            default_component_configs = {
                container = {
                  enable_character_fade = false,
                  width = "100%",
                  right_padding = 0,
                 },
            },

            window = {
                position = "left", --left, right, top, bottom, float, current
                width = 28, -- applies to left and right positions
                height = 15, -- applies to top and bottom positions
                auto_expand_width = false, -- expand the window when file exceeds the window width. does not work with position = "float"
                popup = { -- settings that apply to float position only
                    size = {
                    height = "70%",
                    width = "50%",
                    },
                    position = "50%", -- 50% means center it
                },
            },
            
            filesystem = {

                use_libuv_file_watcher = true, -- Auto-refresh
                bind_to_cwd = true,  -- Enable 2-way binding between Neovim's cwd and Neo-tree's root
                cwd_target = {
                  sidebar = "global",   --"global", "tab"
                  current = "cwd" 
                },
                hijack_netrw = true,

                filtered_items = {
                    visible = true, -- when true, they will just be displayed differently than normal items
                    show_hidden_count = true, --show number of hidden items in each folder as the last entry
                    hide_dotfiles = true,
                    hide_gitignored = true,
                    hide_hidden = false, --only works on Windows for hidden files/directories
                    hide_by_name = {
                        ".DS_Store",
                        --"node_modules",
                    },
                },
                
                window = {
                    --Detect project root using LSP or common markers (.git)
                    --follow_current_file = true, --Auto-open curr file's dir
                    --use_libuv_file_watcher = true, --os Auto-refresh on files change
                    mappings = {
                        ["<Mouse-Left>"] = "open",
                        ["H"] = hide_hidden,
                        ["P"] = {
                            "toggle_preview",
                            config = {
                                use_float = false,
                                -- use_image_nvim = true,
                                -- title = 'Neo-tree Preview',
                            },
                        },
                       ["<Del>"] = {"delete", config = {confirm = false}},
                       ["<F2>"] = "rename",
                       ["N"] = "add_directory",
                        ["n"] = {
                        "add",
                        -- some commands may take optional config options, see `:h neo-tree-mappings` for details
                        config = {
                          show_path = "none", --"none", "relative", "absolute"
                        }
                        },
                    },
                },
            }

        })--setup
        --cmd samples:
        --:Neotree toggle
        --:Neotree toggle current reveal_force_cwd<cr>
        --:Neotree reveal<cr>
        --:Neotree float reveal_file=<cfile> reveal_force_cwd<cr>
        vim.keymap.set(
            {"i","n","v"},
            "<C-b>",
            "<esc><cmd>Neotree toggle <cr>",
            {noremap = true}
        )
    end,
}
