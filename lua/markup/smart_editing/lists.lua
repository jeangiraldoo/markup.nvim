local last_cursor_row = nil -- Tracks the last processed line to avoid duplicate processing

local PATTERNS = {
	WHITESPACE = {
		LEADING = "^(%s*)",
		ONLY = "^%s*$",
	},
	LIST = {
		UNFILLED_ITEM = "^%s*%-%s?$", -- "- " or "-"
		FILLED_ITEM = "^%s*%-+%s*.+", -- "- something"
		LATEX_ITEM = "^%s*\\item%s?.*", -- \item or \item something
		UNFILLED_LATEX_ITEM = "^%s*\\item%s*$",
	},
}

local function matches_pattern(pattern, line)
	return line:match(pattern) ~= nil
end

local function insert_list_entry_if_needed(current_line)
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
	if cursor_row == last_cursor_row or cursor_row <= 1 then
		return
	end

	if not matches_pattern(PATTERNS.WHITESPACE.ONLY, current_line) then
		return
	end

	local prev_line = vim.api.nvim_buf_get_lines(0, cursor_row - 2, cursor_row - 1, false)[1]

	-- Remove previous unfilled item and stop adding items
	if
		matches_pattern(PATTERNS.LIST.UNFILLED_ITEM, prev_line)
		or matches_pattern(PATTERNS.LIST.UNFILLED_LATEX_ITEM, prev_line)
	then
		vim.api.nvim_buf_set_lines(0, cursor_row - 2, cursor_row - 1, false, { "" })
		prev_line = ""
	end

	-- Continue Markdown/Typst dash list
	if matches_pattern(PATTERNS.LIST.FILLED_ITEM, prev_line) then
		local leading_ws = current_line:match(PATTERNS.WHITESPACE.LEADING)
		vim.api.nvim_set_current_line(leading_ws .. "- ")
		vim.api.nvim_win_set_cursor(0, { cursor_row, #leading_ws + 2 })
	end

	-- Continue LaTeX \item list
	if matches_pattern(PATTERNS.LIST.LATEX_ITEM, prev_line) then
		local leading_ws = current_line:match(PATTERNS.WHITESPACE.LEADING)
		vim.api.nvim_set_current_line(leading_ws .. "\\item ")
		vim.api.nvim_win_set_cursor(0, { cursor_row, #leading_ws + 6 })
	end

	last_cursor_row = cursor_row
end

return insert_list_entry_if_needed
