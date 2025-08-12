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
	},
}
