local last_cursor_row = nil -- Tracks the last processed line to avoid duplicate processing

local WHITESPACE_PATTERNS = {
	LEADING = "^(%s*)",
	ONLY = "^%s*$",
}

local LIST = {
	unfilled_pattern = "^%%s*%s%%s?$",
	filled_pattern = "^%%s*%s%%s+[^%s].+",
	markers = {
		markdown = {
			"-",
			"*",
			"+",
		},
		typst = "-",
		tex = "\\item",
	},
}

local filetype = vim.bo.filetype
local markers = LIST.markers[filetype]
if not markers then
	return
end

local function clear_line(line)
	vim.api.nvim_buf_set_lines(0, line, line + 1, false, { "" })
end

local function insert_list_item(list_marker, current_line, cursor_row)
	local leading_ws = current_line:match(WHITESPACE_PATTERNS.LEADING)

	local item = leading_ws .. list_marker .. " "
	vim.api.nvim_set_current_line(item)
	vim.api.nvim_win_set_cursor(0, { cursor_row, #item })
end

local function process_list_marker(data, marker)
	local unfilled_item_pattern = LIST.unfilled_pattern:format(marker)
	local is_prev_line_unfilled_item = data.prev_line:match(unfilled_item_pattern) ~= nil

	if is_prev_line_unfilled_item then
		local prev_line_row = data.cursor_row - 2
		clear_line(prev_line_row)
		return
	end

	local filled_item_pattern = LIST.filled_pattern:format(marker, marker)
	local is_prev_line_filled_item = data.prev_line:match(filled_item_pattern) ~= nil

	if is_prev_line_filled_item then
		insert_list_item(marker, data.current_line, data.cursor_row)
	end
end

local function insert_list_entry_if_needed(current_line)
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
	if cursor_row == last_cursor_row or cursor_row <= 1 then
		return
	end

	if not current_line:match(WHITESPACE_PATTERNS.ONLY) then
		return
	end

	local processal_data = {
		prev_line = vim.api.nvim_buf_get_lines(0, cursor_row - 2, cursor_row - 1, false)[1],
		current_line = current_line,
		cursor_row = cursor_row,
	}
	if type(markers) == "string" then
		process_list_marker(processal_data, markers)
	else
		for _, mark in ipairs(markers) do
			process_list_marker(processal_data, mark)
		end
	end

	last_cursor_row = cursor_row
end

return insert_list_entry_if_needed
