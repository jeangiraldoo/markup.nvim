local default_opts = require("markup.opts")

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
return M
