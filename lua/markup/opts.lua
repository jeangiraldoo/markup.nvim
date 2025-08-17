-- Smart editing options:
--   auto_capitalize_headings (boolean) -> Automatically capitalize the first letter of headings
--   auto_continue_lists (boolean)      -> Automatically continue list entries when pressing Enter on an empty line
--
-- Style options (each can be one of the following):
--   - string: A format string with a '%s' placeholder for the text
--   - function: A function that takes the text and returns formatted text
--   - table: A table defining separate formats, where keys map to either strings or functions as above
--        The table can include:
--          inline           -> Format for inline usage
--          multiline        -> Format for multiline usage
--          multiline_repeat -> (optional) A prefix string repeated on each line in multiline usage
--
--   bold       -> Bold style
--   italic     -> Italic style
--   bolditalic -> Combined bold and italic
--   quote      -> Quoted text style
--   code       -> Code block style

return {
	markdown = {
		smart_editing = {
			auto_capitalize_headings = true,
			auto_continue_lists = true,
		},
		style = {
			bold = "**%s**",
			italic = "_%s_",
			bolditalic = "***%s***",
			quote = {
				inline = '"%s"',
				multiline = "> %s",
				multiline_repeat = "> ",
			},
			code = {
				inline = "`%s`",
				multiline = "```\n%s\n```",
			},
		},
		lorem = {
			word = {
				default_item_number = 3,
				random = true,
				max_width = 80,
				window_size = 3,
			},
			sentence = {
				default_item_number = 1,
				random = false,
				window_size = 3,
				max_width = 80,
				minimum_length = 7,
				maximum_length = 12,
				max_commas = 2,
				comma_chance = 0.2,
			},
			paragraph = {
				default_item_number = 1,
				random = true,
				window_size = 3,
				max_width = 80,
				minimum_sentence_length = 7,
				maximum_sentence_length = 12,
				max_sentence_commas = 2,
				sentence_comma_chance = 0.2,
				sentence_number = 3,
			},
		},
	},
	typst = {
		smart_editing = {
			auto_capitalize_headings = true,
			auto_continue_lists = true,
		},
		style = {
			bold = "*%s*",
			italic = "_%s_",
			bolditalic = "_*%s*_",
			quote = {
				inline = '"%s"',
				multiline = "> %s",
				multiline_repeat = "> ",
			},
			code = {
				inline = "`%s`",
				multiline = "```\n%s\n```",
			},
		},
		lorem = {
			builtin_function_pattern = "#lorem(%s)",
			word = {
				default_item_number = 3,
				random = true,
				max_width = 80,
				window_size = 3,
			},
			sentence = {
				default_item_number = 1,
				random = false,
				window_size = 3,
				max_width = 80,
				minimum_length = 7,
				maximum_length = 12,
				max_commas = 2,
				comma_chance = 0.2,
			},
			paragraph = {
				default_item_number = 1,
				random = true,
				window_size = 3,
				max_width = 80,
				minimum_sentence_length = 7,
				maximum_sentence_length = 12,
				max_sentence_commas = 2,
				sentence_comma_chance = 0.2,
				sentence_number = 3,
			},
		},
	},
	tex = {
		smart_editing = {
			auto_capitalize_headings = true,
			auto_continue_lists = true,
		},
		style = {
			bold = "\\textbf{%s}",
			italic = "\\textit{%s}",
			bolditalic = "\\textbf{\\textit{%s}}",
			quote = {
				inline = "``%s''",
				multiline = "\\begin{quote}\n%s\n\\end{quote}",
			},
			code = {
				inline = "\\verb|%s|",
				multiline = "\\begin{verbatim}\n%s\n\\end{verbatim}",
			},
		},
		lorem = {
			builtin_function_pattern = "\\lipsum[%s]", -- Uses the lipsum package
			word = {
				default_item_number = 3,
				random = true,
				max_width = 80,
				window_size = 3,
			},
			sentence = {
				default_item_number = 1,
				random = false,
				window_size = 3,
				max_width = 80,
				minimum_length = 7,
				maximum_length = 12,
				max_commas = 2,
				comma_chance = 0.2,
			},
			paragraph = {
				default_item_number = 1,
				random = true,
				window_size = 3,
				max_width = 80,
				minimum_sentence_length = 7,
				maximum_sentence_length = 12,
				max_sentence_commas = 2,
				sentence_comma_chance = 0.2,
				sentence_number = 3,
			},
		},
	},
}
