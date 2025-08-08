local HEADING = {
	pattern = "^%%s*%s+%%s*%%d*%%s*(%%a)",
	markers = {
		markdown = "#",
		typst = "=",
		tex = {
			"\\section{",
			"\\subsection{",
			"\\subsubsection{",
			"\\paragraph{",
			"\\subparagraph{",
			"\\part{",
			"\\chapter{",
		},
	},
}

local filetype = vim.bo.filetype
local heading_marker, heading_pattern = HEADING.markers[filetype], HEADING.pattern
if not heading_marker then
	return
end

local function build_new_header(prefix, first_letter, current_line)
	local non_prefix = current_line:gsub("^" .. prefix, "")

	local upper_case_letter = first_letter:upper()
	local new_header = prefix .. non_prefix:gsub(first_letter, upper_case_letter, 1)

	return new_header
end

local function get_prefix_and_first_letter(marker, line)
	if type(marker) == "string" then
		local pattern = heading_pattern:format(marker)
		local first_letter = line:match(pattern)
		return marker, first_letter
	end
	for _, mark in ipairs(marker) do
		local pattern = heading_pattern:format(mark)
		local first_letter = line:match(pattern)
		if first_letter then
			return mark, first_letter
		end
	end
end

local function make_heading_uppercase_if_needed(current_line)
	local prefix, first_letter = get_prefix_and_first_letter(heading_marker, current_line)

	if not first_letter then -- Line is not a heading, or heading contains no letters
		return
	end

	local new_header = build_new_header(prefix, first_letter, current_line)
	vim.api.nvim_set_current_line(new_header)
end

return make_heading_uppercase_if_needed
