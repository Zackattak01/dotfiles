local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ss', builtin.find_files, {})
vim.keymap.set('n', '<leader>sa', function()
	builtin.grep_string( { search = vim.fn.input("Grep > ") });
end)
