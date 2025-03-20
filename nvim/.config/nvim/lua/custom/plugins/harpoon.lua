return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    config = function()
        local harpoon = require 'harpoon'
        harpoon:setup()

        vim.keymap.set('n', '<leader>ha', function()
            harpoon:list():append()
        end, { desc = 'Harpoon: Add file' })

        vim.keymap.set('n', '<leader>he', function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = 'Harpoon: Toggle menu' })

        vim.keymap.set('n', '<leader>hp', function()
            harpoon:list():prev()
        end, { desc = 'Harpoon: Go to previous file' })

        vim.keymap.set('n', '<leader>hn', function()
            harpoon:list():next()
        end, { desc = 'Harpoon: Go to next file' })

        vim.keymap.set('n', '<leader>hc', function()
            harpoon:list():clear()
        end, { desc = 'Harpoon: Clear all marks' })

        vim.keymap.set('n', '<leader>hr', function()
            harpoon:list():remove()
        end, { desc = 'Harpoon: Remove current file' })

        -- shortcuts
        for i = 1, 3 do
            vim.keymap.set('n', string.format('<leader>%d', i), function()
                harpoon:list():select(i)
            end, { desc = string.format('Harpoon: Jump to file %d', i) })
        end
    end,
}
