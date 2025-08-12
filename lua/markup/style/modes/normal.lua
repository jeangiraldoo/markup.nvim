local utils = require("markup.style.utils")

local BOUNDARY_DIRECTIONS = {
	LEFT = "LEFT",
	RIGHT = "RIGHT",
}

---Find the inclusive boundary of a word by moving left or right until whitespace is found
---
---The returned position points exactly to the last character of the word
---in the given direction (inclusive boundary).
---
---Example:
--- Given line: "hello world"
--- Cursor at "w" (col=7)
--- find_word_boundary(line, 7, "LEFT")  -> 7 (start of "world")
--- find_word_boundary(line, 7, "RIGHT") -> 11 (end of "world")
---
---@param line string The line text to search within
---@param start_col integer The column index (1-based) to start from
---@param direction "LEFT" | "RIGHT" Direction of movement
---@return integer pos The inclusive boundary position
local function find_word_boundary(line, start_col, direction)
	assert(BOUNDARY_DIRECTIONS[direction] ~= nil, "Invalid direction: must be 'left' or 'right'")

	local step = direction == BOUNDARY_DIRECTIONS.LEFT and -1 or 1
	local pos = start_col
	while pos >= 1 and pos <= #line and not line:sub(pos, pos):match("%s") do
		pos = pos + step
	end

	pos = pos - step
	return pos
end

---Get the word under the cursor along with its left and right boundaries (1-based index)
---@return string | nil word The word under the cursor, or nil if none found
---@return integer | nil left_boundary Left boundary position
---@return integer | nil right_boundary Right boundary position
local function get_word_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- convert to 1-based

	local is_cursor_outside_line_length = col < 1 or col > #line
	if is_cursor_outside_line_length then
		return nil
	end

	local is_cursor_on_whitespace = line:sub(col, col):match("%s") ~= nil
	if is_cursor_on_whitespace then
		return nil
	end

	-- Move outward to find boundaries (exclusive)
	local left_boundary = find_word_boundary(line, col, BOUNDARY_DIRECTIONS.LEFT)
	local right_boundary = find_word_boundary(line, col, BOUNDARY_DIRECTIONS.RIGHT)
	local word = line:sub(left_boundary, right_boundary)

	return word, left_boundary, right_boundary
end

---Styles the word under the cursor in normal mode by applying the given pattern and style
---Replaces the original word with the styled version directly in the buffer
---@param style string Style identifier (e.g., "bold", "italic")
---@param pattern string Pattern used to format the word
return function(style, pattern)
	local EXCLUDE_BOUNDARY = 1
	local word, left_boundary_col, right_boundary_col = get_word_under_cursor()
	if not word then
		return
	end

	local styled_word = utils.apply_pattern_to_text(word, true, pattern, style)
	if not styled_word then
		return
	end

	local current_line = vim.api.nvim_get_current_line()

	-- Adjust boundaries by ±1 because "left_boundary_col" and "right_boundary_col"
	-- are inclusive positions of the word; Lua’s string.sub uses inclusive indices,
	-- so subtract 1 to exclude the word’s first char from the "before" slice,
	-- and add 1 to exclude the word’s last char from the "after" slice
	local text_before_word = current_line:sub(1, left_boundary_col - EXCLUDE_BOUNDARY)
	local text_after_word = current_line:sub(right_boundary_col + EXCLUDE_BOUNDARY)

	local final_line = text_before_word .. styled_word .. text_after_word

	vim.api.nvim_set_current_line(final_line)
end
