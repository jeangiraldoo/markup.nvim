local last_cursor_row = nil -- Tracks the last processed line to avoid duplicate processing

local WHITESPACE_PATTERNS = {
	LEADING = "^(%s*)",
	ONLY = "^%s*$",
}

local LIST = {
	unfilled_pattern = "^%%s*%s%%s?$",
	filled_pattern = "^%%s*%s%%s+[^%s].+",
	markers = {
		markdown = "-",
		typst = "-",
		tex = "\\item",
	},
}

local filetype = vim.bo.filetype
local list_marker = LIST.markers[filetype]
if not list_marker then
	return
end

local unfilled_list = LIST.unfilled_pattern:format(list_marker)
local filled_list = LIST.filled_pattern:format(list_marker, list_marker)

local function matches_pattern(pattern, line)
	return line:match(pattern) ~= nil
end

local function insert_list_entry_if_needed(current_line)
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
	if cursor_row == last_cursor_row or cursor_row <= 1 then
		return
	end

	if not matches_pattern(WHITESPACE_PATTERNS.ONLY, current_line) then
		return
	end

	local prev_line = vim.api.nvim_buf_get_lines(0, cursor_row - 2, cursor_row - 1, false)[1]

	-- Remove previous unfilled item and stop adding items
	if matches_pattern(unfilled_list, prev_line) then
		vim.api.nvim_buf_set_lines(0, cursor_row - 2, cursor_row - 1, false, { "" })
		prev_line = ""
	end

	-- Continue inserting list items
	if matches_pattern(filled_list, prev_line) then
		local leading_ws = current_line:match(WHITESPACE_PATTERNS.LEADING)
		vim.api.nvim_set_current_line(leading_ws .. list_marker .. " ")
		vim.api.nvim_win_set_cursor(0, { cursor_row, #leading_ws + #list_marker + 1 })
	end

	last_cursor_row = cursor_row
end

return insert_list_entry_if_needed
