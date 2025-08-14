local config_opts = require("markup.opts")
local smart_editing = require("markup.smart_editing")

vim.api.nvim_create_autocmd("TextChangedI", {
	pattern = {
		"*.md",
		"*.typ",
		"*.tex",
	},
	callback = function()
		local filetype = vim.bo.filetype
		local filetype_opts = config_opts[filetype]
		local smart_editing_opts = filetype_opts.smart_editing
		smart_editing.start(smart_editing_opts)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "tex",
	callback = function()
		local function my_tex_indent()
			local prev_line = vim.fn.getline(vim.v.lnum - 1)

			-- If current line is after \item, indent exactly like previous line
			if prev_line:match("^%s*\\item") then
				return vim.fn.indent(vim.v.lnum - 1)
			end

			-- fallback: use default indentexpr
			-- Save original indentexpr
			local orig = vim.bo.indentexpr
			if orig and orig ~= "" then
				-- Temporarily unset indentexpr to avoid recursion
				vim.bo.indentexpr = ""
				local indent = vim.fn["GetTeXIndent"]()
				vim.bo.indentexpr = orig
				return indent
			end

			return 0
		end

		-- Set the buffer's indentexpr to call this Lua function
		vim.bo.indentexpr = "v:lua.my_tex_indent()"

		-- Expose the function globally so Vim can call it
		_G.my_tex_indent = my_tex_indent
	end,
})
