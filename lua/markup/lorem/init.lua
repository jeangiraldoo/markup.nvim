local DEFAULT_LOREM_WORDS = require("markup.lorem.text")

---@class Lorem
---@field OPTS string[] List of supported text types
---@field get_text fun(text_type:string, text_item_number:number, lorem_opts:table<string, table>): string[]
local Lorem = {
	OPTS = {
		"paragraph",
		"sentence",
		"word",
	},
}

math.randomseed(os.time())

---Display an error message in the Neovim notification area.
---@param error_msg string Error message to display
---@param subcommand? string | nil Subcommand name to prefix the message
local function display_error(error_msg, subcommand)
	local msg_template = "[Lorem%s] %s"
	local subcommand_str = subcommand and ("-" .. subcommand) or ""
	local formatted_msg = msg_template:format(subcommand_str, error_msg)
	vim.notify(formatted_msg, vim.log.levels.ERROR)
end

---Generate random words while avoiding immediate repeats
---@param number_of_words number How many words to generate
---@param word_candidates string[] List of words to pick from
---@param window_size number How many recent words to skip when picking the next word (0 allows repeats)
---@return string[] words The generated list of words
local function get_random_words(number_of_words, word_candidates, window_size)
	local previous_words = {}
	local words = {}

	local number_of_word_candidates = #word_candidates

	local allow_repeated_words = number_of_word_candidates <= window_size or window_size == 0

	for _ = 1, number_of_words do
		local random_word

		repeat
			local random_pos = math.random(1, number_of_word_candidates)
			random_word = word_candidates[random_pos]
		until allow_repeated_words or not vim.list_contains(previous_words, random_word)

		table.insert(previous_words, random_word)
		table.insert(words, random_word)

		if #previous_words >= window_size then
			table.remove(previous_words, 1)
		end
	end
	return words
end

---Finalizes a line and appends it to the output lines table
---@param current_line string[] Words in the line being built
---@param lines string[] Table of all finalized lines where the line will be appended
local function finalize_and_append_line(current_line, lines)
	if vim.tbl_isempty(current_line) then
		return
	end

	local line = table.concat(current_line, " ")
	table.insert(lines, line)
end

---Calculates the extra space if a word is appended
---@param current_line string[] Words in the line being built
---@return number 0 if the line is empty, 1 otherwise
local function get_candidate_line_extra_space(current_line)
	local extra_space = #current_line > 0 and 1 or 0
	return extra_space
end

---Checks if adding a word to the current line would exceed the max width
---@param candidate_line string[] The current line being built
---@param candidate_word string The next word being considered for insertion
---@param line_length number Current length of the line
---@param max_width number Maximum allowed width of a line
---@return boolean True if the line would exceed max_width, false otherwise
local function is_candidate_line_too_long(candidate_line, candidate_word, line_length, max_width)
	local extra_space = get_candidate_line_extra_space(candidate_line)
	local candidate_length = line_length + extra_space + #candidate_word

	if candidate_length > max_width then
		return true
	end

	return false
end

---Wraps words into lines, ensuring each line does not exceed max_width
--- Handles hard line breaks ("\n") as blank lines
---@param words string[] Words to wrap into lines
---@param max_line_width number Maximum number of characters allowed before wrapping to a new line
---@return string[] lines Table of wrapped lines
local function wrap_words_into_lines(words, max_line_width)
	local lines = {}
	local current_line = {}
	local line_length = 0

	for _, word in ipairs(words) do
		local is_newline = word == "\n"
		if is_newline then
			finalize_and_append_line(current_line, lines)
			table.insert(lines, "")
			current_line = {}
			line_length = 0
		elseif is_candidate_line_too_long(current_line, word, line_length, max_line_width) then
			finalize_and_append_line(current_line, lines)
			current_line = { word }
			line_length = #word
		else
			table.insert(current_line, word)
			local extra_space = get_candidate_line_extra_space(current_line)
			line_length = line_length + extra_space + #word
		end
	end

	finalize_and_append_line(current_line, lines) -- Finalize any remaining words
	return lines
end

---Returns a function that generates words based on the given settings
---@param is_random boolean Whether to generate words randomly
---@param window_size number Number of recent words to avoid repeating when generating random words
---@param word_candidates? string[] List of words to use (defaults to "default_source_lorem")
---@return fun(length: number):string[] Function that takes a length and returns a list of words
local function get_word_generator(is_random, window_size, word_candidates)
	word_candidates = word_candidates or DEFAULT_LOREM_WORDS

	if is_random then
		return function(length)
			return get_random_words(length, word_candidates, window_size)
		end
	else
		return function(length)
			return vim.list_slice(word_candidates, 1, length)
		end
	end
end

---Generate wrapped Lorem text of a given type
---
--- Depending on "type_name", this function will either:
--- - Generate words directly, or
--- - Delegate to a type-specific module (e.g., "sentence", "paragraph")
---
--- The output is split into lines based on the configured maximum width
---
---@param type_name string The type of text to generate ("word", "sentence", "paragraph", etc.)
---@param provided_num_items number | nil Number of items to generate (defaults to "default_item_number" in config)
---@param config table<string, table> A table mapping type names to their configuration tables
---@return string[] wrapped_lines A list of lines of generated text, wrapped at the maximum width
local function generate_custom_lorem(type_name, provided_num_items, config)
	local type_config = config[type_name]

	local num_items_to_generate = provided_num_items or type_config.default_item_number
	local word_generator = get_word_generator(type_config.random, type_config.window_size, type_config.source)

	local generated_words
	if type_name == "word" then
		generated_words = word_generator(num_items_to_generate)
	else
		local text_type_generator = require("markup.lorem.text_types." .. type_name)
		generated_words = text_type_generator(num_items_to_generate, word_generator, type_config)
	end

	local wrapped_lines = wrap_words_into_lines(generated_words, type_config.max_width)
	return wrapped_lines
end

---Inserts a list of lines into the current buffer at the cursor position
---
---Each element of "text" becomes a separate line in the buffer
---
---@param text string[] Lines of text to insert
local function insert_text_at_cursor(text)
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- 1-based
	local insert_row = row - 1
	vim.api.nvim_buf_set_lines(0, insert_row, insert_row + 1, false, text)
end

---Generates Lorem text of a specified type and inserts it at the cursor
---
---Supported "text_type" values are defined in "Lorem.OPTS"
---If a number argument is provided, that many items are generated; otherwise the type’s default is used
---The generated text is inserted into the current buffer at the cursor position
---
---@param text_type string Type of Lorem text to generate
---@param provided_arg string | nil Optional number of items to generate, as a string
---@param opts table<string, table> Configuration table mapping types to their options
local function generate_type_lorem(text_type, provided_arg, opts)
	if not vim.tbl_contains(Lorem.OPTS, text_type) then
		local error_msg = "Unknown subcommand: " .. text_type
		display_error(error_msg)
		return
	end

	local number_arg = tonumber(provided_arg)
	if provided_arg and not number_arg then
		local error_msg = string.format("Expected a number, got %s '%s'", type(provided_arg), provided_arg)
		display_error(error_msg, text_type)
		return
	end

	if number_arg and number_arg < 0 then
		local error_msg = "Expected a number higher than 0, got " .. number_arg
		display_error(error_msg)
		return
	end

	local text_lines = generate_custom_lorem(text_type, number_arg, opts)

	if not vim.tbl_isempty(text_lines) then
		insert_text_at_cursor(text_lines)
	end
end

---Generates Lorem text using a built-in function pattern and inserts it at the cursor
---
---This function formats the given pattern with an argument and inserts
---the resulting text as a single line in the current buffer
---
---@param function_pattern string A format string representing the built-in Lorem function
---@param arg string | nil Argument to interpolate into the pattern
local function generate_builtin_lorem(function_pattern, arg)
	local text_lines = { string.format(function_pattern, arg or "") }
	insert_text_at_cursor(text_lines)
end

local function is_lorem_argument_number(arg)
	if not tonumber(arg) then
		return false
	end
	return true
end

---Entry point for generating and inserting Lorem text into the current buffer
---@param data { choice: string, opts: table<string, table>, args: string[] }
function Lorem.start(data)
	local lorem_arg, opts, lorem_sub_arg = data.choice, data.opts, data.args[1]

	if not lorem_arg then
		local error_msg = "No argument provided"
		display_error(error_msg)
		return
	end

	local builtin_function_pattern = data.opts.builtin_function_pattern
	if is_lorem_argument_number(lorem_arg) and builtin_function_pattern then
		generate_builtin_lorem(builtin_function_pattern, lorem_arg)
	else
		generate_type_lorem(lorem_arg, lorem_sub_arg, opts)
	end
end

return Lorem
