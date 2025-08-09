local CURRENT_DIR = "markup.smart_editing."

local config_opts = require("markup.opts")
local filetype_opts = config_opts[vim.bo.filetype]

local smart_edit = {
	headings = require(CURRENT_DIR .. "headings"),
	lists = require(CURRENT_DIR .. "lists"),
}

function smart_edit.start()
	local current_line = vim.api.nvim_get_current_line()

	if filetype_opts.auto_capitalize_headings then
		smart_edit.headings(current_line)
	end

	if filetype_opts.auto_continue_lists then
		smart_edit.lists(current_line)
	end
end

return smart_edit
