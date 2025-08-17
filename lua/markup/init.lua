local default_opts = require("markup.opts")

local SUBCMDS = {
	"style",
	"lorem",
}

local M = {}

local function override_defaults(defaults, overrides)
	for key, override_val in pairs(overrides) do
		local base_val = defaults[key]
		if type(base_val) == "table" and type(override_val) == "table" then
			override_defaults(base_val, override_val)
		else
			defaults[key] = override_val
		end
	end
end

function M.setup(config)
	override_defaults(default_opts, config or {})
end

---Parses the arguments passed to the `:Markup` command.
---
--- This function takes the raw string following the ":Markup" command
--- (from "opts.args" in "nvim_create_user_command"), and splits it into:
---   1. The first word, considered to be the subcommand name
---   2. Any remaining words, treated as subcommand arguments
---
--- The ":Markup" part itself is never included in "args_str"; Neovim strips
--- it automatically before passing it to the command handler
---
--- Example:
---   User input: ":Markup format file.md"
---   args_str   = "format file.md"
---   returns    = "format", { "file.md" }
---
---@param args_str string The raw arguments after ":Markup" (may be empty)
---@return string | nil subcmd The first word, or nil if no arguments were given
---@return table subcmd_args List of remaining words after the subcommand
local function parse_command_args(args_str)
	local parts = vim.split(args_str or "", "%s+")
	local subcmd = parts[1]
	local subcmd_args = { unpack(parts, 2) }
	return subcmd, subcmd_args
end

local function get_visual_range(opts)
	if opts.range and opts.range > 0 then
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		return {
			start_line = start_pos[2],
			start_col = start_pos[3],
			end_line = end_pos[2],
			end_col = end_pos[3],
		}
	end
end

vim.api.nvim_create_user_command("Markup", function(opts)
	local subcmd, subcmd_args = parse_command_args(opts.args)

	if not vim.list_contains(SUBCMDS, subcmd) then
		vim.notify("Unknown subcommand: " .. (subcmd or ""), vim.log.levels.ERROR)
		return
	end

	local filetype = vim.bo.filetype
	local filetype_opts = default_opts[filetype]

	local data = {
		choice = subcmd_args[1],
		opts = filetype_opts[subcmd],
		range = get_visual_range(opts),
		args = { unpack(subcmd_args, 2) },
	}

	local component_path = "markup." .. subcmd
	require(component_path).start(data)
end, {
	nargs = "+",
	range = true,
	complete = function(_, line, _)
		local full_command_line = vim.trim(line)
		local split_words = vim.split(full_command_line, "%s+")

		table.remove(split_words, 1) -- Remove "Markup"

		if vim.tbl_isempty(split_words) then
			return SUBCMDS
		end

		local typed_subcmd = split_words[1]

		if vim.list_contains(SUBCMDS, typed_subcmd) then
			return require("markup." .. typed_subcmd).OPTS or {}
		end

		local user_typed_partial_subcmd = #split_words == 1
		if user_typed_partial_subcmd then
			return vim.tbl_filter(function(candidate_subcmd)
				local candidate_starts_with_typed = candidate_subcmd:sub(1, #typed_subcmd) == typed_subcmd
				return candidate_starts_with_typed
			end, SUBCMDS)
		end
	end,
})

return M
