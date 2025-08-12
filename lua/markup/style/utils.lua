local utils = {}

local LOG_LEVELS = vim.log.levels

---Notify the user of an error in a standardized format
---@param message string Error message to display
---@param style string Style name (included in the notification for context)
function utils.notify_error(message, style)
	local filetype = vim.bo.filetype
	local base_error = (" (%s - %s style)"):format(filetype, style)
	vim.notify(message .. base_error, LOG_LEVELS.WARN)
end

---Check whether the given option type is valid for pattern handling
---Valid types are "function" and "string"
---@param opt any Value to check
---@return boolean is_valid True if the type is valid, false otherwise
local function _is_option_type_valid(opt)
	return opt == "function" or opt == "string"
end

--- Retrieve the correct custom mode pattern for inline or multiline styles
--- Falls back to notifying an error if no valid pattern is found
--- If "multiline_repeat" is present and multiline mode is used, it prefixes each line
---
--- @param pattern table Table containing "inline" and/or "multiline" keys (and optionally "multiline_repeat")
--- @param is_singleline boolean True if inline mode, false if multiline
--- @param text string The original text to be processed
--- @param style string Style name for error context
--- @return string | function | nil mode_pattern The pattern or function to apply, or nil on error
local function _get_custom_mode_pattern(pattern, is_singleline, text, style)
	local mode_name
	if is_singleline then
		mode_name = "inline"
	else
		mode_name = "multiline"
	end

	if not pattern.multiline and not pattern.inline then
		utils.notify_error("No custom mode patterns set", style)
		return nil
	end

	local mode_pattern = pattern[mode_name]
	local mode_type = type(mode_pattern)
	if not _is_option_type_valid(mode_type) then
		utils.notify_error(("No custom mode pattern set for %s mode"):format(mode_name), style)
		return nil
	end

	if not is_singleline and pattern.multiline_repeat then
		return pattern.multiline_repeat .. text:gsub("\n", "\n" .. pattern.multiline_repeat)
	end

	return mode_pattern
end

--- Apply a pattern to a given text, handling different pattern types accordingly.
---
--- Behavior based on "pattern" type:
--- - **table**: Retrieves the mode-specific pattern via "_get_custom_mode_pattern"
--- - **string**: Formats the pattern with the text unless the text already matches it
--- - **function**: Calls the function with the text as argument
---
--- Notifies an error for unsupported pattern types
---
--- @param text string The text to transform
--- @param is_singleline boolean Whether to treat the selection as a single line
--- @param pattern string|function|table Pattern definition to apply
--- @param style string Style name for error context
--- @return string | nil processed_text The processed text, or nil if unchanged or on error
function utils.apply_pattern_to_text(text, is_singleline, pattern, style)
	local current_pattern = pattern
	if type(current_pattern) == "table" then
		current_pattern = _get_custom_mode_pattern(current_pattern, is_singleline, text, style) or current_pattern
	end

	local pattern_type = type(current_pattern)
	if pattern_type == "string" then
		if text:match(current_pattern) then
			return nil
		end
		return current_pattern:format(text)
	elseif pattern_type == "function" then
		return current_pattern(text)
	else
		utils.notify_error("Style option expected a function, string or table. Received " .. pattern_type, style)
		return nil
	end
end

return utils
