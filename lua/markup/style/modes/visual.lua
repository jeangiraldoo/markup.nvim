local utils = require("markup.style.utils")

---Convert 1-based inclusive range (from Neovim) to 0-based start-inclusive, end-exclusive format
---used by "vim.api.nvim_buf_set_text()"
---
---Start positions are shifted down by 1 to go from 1-based to 0-based
---End column stays the same because it’s already exclusive in this context
---
---@param range table 1-based inclusive {start_line, start_col, end_line, end_col}
---@return table 0-based {start_line, start_col, end_line, end_col} with exclusive end_col
local function get_zero_based_inclusive_start_exclusive_end_range(range)
	return {
		start_line = range.start_line - 1,
		start_col = range.start_col - 1,
		end_line = range.end_line - 1,
		end_col = range.end_col, -- keep as is to convert inclusive -> exclusive
	}
end

--- Get the text inside a visual selection along with the final end column
---@param range table 1-based selection range:
---    { start_line = int, start_col = int, end_line = int, end_col = int }
---@return string | nil selected_text, integer | nil end_col
local function get_visual_selection(range)
	local start_line, start_col = range.start_line, range.start_col
	local end_line, end_col = range.end_line, range.end_col

	-- Neovim's nvim_buf_get_lines uses 0-based start index and exclusive end index
	local buf_start_idx = start_line - 1
	local buf_end_idx = end_line
	local lines = vim.api.nvim_buf_get_lines(0, buf_start_idx, buf_end_idx, false)

	if vim.tbl_isempty(lines) then
		return nil, nil
	end

	local selected_text, is_single_line_selection
	local actual_end_col -- Ensure the end column doesn't exceed the actual line length

	local is_single_line_selection = start_line == end_line
	if is_single_line_selection then
		is_single_line_selection = true
		local line_text = lines[1]

		actual_end_col = math.min(end_col, #line_text)
		selected_text = line_text:sub(start_col, actual_end_col)
	else
		is_single_line_selection = false
		local first_line_from_selection = lines[1]:sub(start_col)

		local last_line_length = #lines[#lines]
		actual_end_col = math.min(end_col, last_line_length)

		local last_line_from_selection = lines[#lines]:sub(1, actual_end_col)

		lines[1] = first_line_from_selection
		lines[#lines] = last_line_from_selection

		selected_text = table.concat(lines, "\n")
	end

	return selected_text, actual_end_col, is_single_line_selection
end

---Applies styling to text within a specified visual range
---@param style string Style identifier (e.g., "bold", "italic")
---@param pattern string Pattern used to style the text
---@param range table Visual selection range { start_line, start_col, end_line, end_col }
return function(style, pattern, range)
	local selected_text, end_col, is_single_line_selection = get_visual_selection(range)
	if not selected_text then
		return
	end

	local styled = utils.apply_pattern_to_text(selected_text, is_single_line_selection, pattern, style)
	if not styled then
		return
	end

	local new_lines = vim.split(styled, "\n", { plain = true })

	range.end_col = end_col
	local zero_based = get_zero_based_inclusive_start_exclusive_end_range(range)

	vim.api.nvim_buf_set_text(
		0,
		zero_based.start_line,
		zero_based.start_col,
		zero_based.end_line,
		zero_based.end_col,
		new_lines
	)
end
