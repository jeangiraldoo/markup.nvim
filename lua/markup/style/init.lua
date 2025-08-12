local modes = require("markup.style.modes")
local utils = require("markup.style.utils")

---Applies a text style either to a visual mode range or at the cursor in normal mode
---
---@param style_data table A table containing:
---   - opts table: Style options for the current filetype
---   - style string: Name of the style to apply (e.g., "bold", "italic")
---   - range? { start_line: integer, start_col: integer, end_line: integer, end_col: integer }
---     If omitted, the style is applied at the current cursor position in normal mode.
---
--- @return nil
return function(style_data)
	local opts, style, range = style_data.opts, style_data.style, style_data.range

	if not opts then
		vim.notify("No style options detected for " .. vim.bo.filetype, vim.log.levels.WARN)
		return
	end

	local pattern = opts[style]
	if not pattern then
		utils.notify_error("No style options found", style)
		return
	end

	if range and range.start_line then
		modes.visual(style, pattern, range)
		return
	end

	modes.normal(style, pattern)
end
