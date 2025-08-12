local config_opts = require("markup.opts")
local modes = require("markup.style.modes")
local utils = require("markup.style.utils")

---Applies a text style either to a visual mode range or at the cursor in normal mode
---@param style string Name of the style to apply (e.g., "bold", "italic")
---@param range? { start_line: integer, start_col: integer, end_line: integer, end_col: integer }
---Optional range of text to apply the style to
---If omitted, the style is applied in normal mode at the current cursor position
---@return nil
return function(style, range)
	local filetype = vim.bo.filetype
	local filetype_opts = (config_opts[filetype] or {}).style

	if not filetype_opts then
		vim.notify("No style options detected for " .. filetype, vim.log.levels.WARN)
		return
	end

	local pattern = filetype_opts[style]
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
