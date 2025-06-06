return 
{
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    enabled = true,
      
    config = function()
        local lint = require("lint")

        lint.linters_by_ft =  {
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            python = { "pylint" },
            lua = { "luacheck", }, --"selene" 
        }

        --local linter = lint.linters.luacheck
        --linter.args = {
        --    "--ignore 614"
        --}

        --local markdownlint = require("lint").linters.markdownlint
        --markdownlint.args = {
        --"--disable",
        --"MD013", "MD007",
        --"--",    -- Required
        --}

        --vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, { --InsertLeave
        --    callback = function()
        --        -- try_lint without arguments runs the linters defined in `linters_by_ft`
        --        -- for the current filetype
        --        require("lint").try_lint()
        --
        --        -- You can call `try_lint` with a linter name or a list of names to always
        --        -- run specific linters, independent of the `linters_by_ft` configuration
        --        --require("lint").try_lint("luacheck")
        --    end,
        --})

        vim.api.nvim_create_user_command("LintBuf", function()
            require("lint").try_lint()
        end, {})


    end,
}
