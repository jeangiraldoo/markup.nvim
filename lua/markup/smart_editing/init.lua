local CURRENT_DIR = "markup.smart_editing."

local smart_edit = {
	headings = require(CURRENT_DIR .. "headings"),
	lists = require(CURRENT_DIR .. "lists"),
}

function smart_edit.start(opts)
	local current_line = vim.api.nvim_get_current_line()

	if opts.auto_capitalize_headings then
		smart_edit.headings(current_line)
	end

	if opts.auto_continue_lists then
		smart_edit.lists(current_line)
	end
end

return smart_edit
