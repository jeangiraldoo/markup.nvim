local smart_editing = require("markup.smart_editing")

vim.api.nvim_create_autocmd("TextChangedI", {
	pattern = {
		"*.md",
		"*.typ",
		"*.tex",
	},
	callback = function()
		smart_editing.start()
	end,
})
