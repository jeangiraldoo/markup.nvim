local modes = require("markup.style.modes")
local utils = require("markup.style.utils")

local Style = {}

Style.OPTS = {
	"bold",
	"italic",
	"bolditalic",
	"code",
	"quote",
}

local ERROR_LOG = vim.log.levels.ERROR

---Applies a text style either to a visual mode range or at the cursor in normal mode
---
---@param style_data table A table containing:
---   - opts table: Style options for the current filetype
---   - choice string: Name of the style to apply (e.g., "bold", "italic")
---   - range? { start_line: integer, start_col: integer, end_line: integer, end_col: integer }
---     If omitted, the style is applied at the current cursor position in normal mode.
---
--- @return nil
function Style.start(style_data)
	local opts, style_choice, range = style_data.opts, style_data.choice, style_data.range

	if not style_choice then
		vim.notify("No style selected", ERROR_LOG)
		return
	end
	if not vim.list_contains(Style.OPTS, style_choice) then
		vim.notify("No valid style selected", ERROR_LOG)
		return
	end
	if not opts then
		vim.notify("No style options detected for " .. vim.bo.filetype, ERROR_LOG)
		return
	end

	local pattern = opts[style_choice]
	if not pattern then
		utils.notify_error("No style options found", style_choice)
		return
	end

	if range and range.start_line then
		modes.visual(style_choice, pattern, range)
		return
	end

	modes.normal(style_choice, pattern)
end

return Style
