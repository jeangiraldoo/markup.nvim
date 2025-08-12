local config_opts = require("markup.opts")
local smart_editing = require("markup.smart_editing")

local CMDS = {
	style = {
		"bold",
		"italic",
		"bolditalic",
		"code",
		"quote",
	},
}

local standalone_cmd_names = vim.tbl_keys(CMDS)

vim.api.nvim_create_user_command("Markup", function(opts)
	local args = vim.split(opts.args or "", "%s+")
	local subcmd = args[1]
	local rest = { unpack(args, 2) }

	if subcmd ~= "style" then
		print("Unknown subcommand: " .. (subcmd or ""))
		return
	end

	local style = rest[1]
	if not style then
		print("No style selected")
		return
	end
	if not vim.list_contains(CMDS.style, style) then
		print("No valid style selected")
		return
	end

	local filetype = vim.bo.filetype
	local filetype_opts = config_opts[filetype]

	local style_data = {
		opts = filetype_opts.style,
		style = style,
	}

	-- If run from a visual selection, pass explicit start/end (line + col) to the style module.
	if opts.range and opts.range > 0 then
		local start_pos = vim.fn.getpos("'<") -- {buf, lnum, col, off}
		local end_pos = vim.fn.getpos("'>")

		-- 1-based positions
		style_data.range = {
			start_line = start_pos[2],
			start_col = start_pos[3],
			end_line = end_pos[2],
			end_col = end_pos[3],
		}
	end
	require("markup.style")(style_data)
end, {
	nargs = "+",
	range = true, -- allow visual selection ranges
	complete = function(_, line, _)
		local args = vim.split(vim.trim(line), "%s+")
		table.remove(args, 1) -- remove "Markup"

		if args[1] == "style" then
			return CMDS.style
		end

		if #args == 0 then
			return standalone_cmd_names
		end

		if #args == 1 then
			return vim.tbl_filter(function(c)
				return c:find("^" .. args[1])
			end, standalone_cmd_names)
		end
	end,
})

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
