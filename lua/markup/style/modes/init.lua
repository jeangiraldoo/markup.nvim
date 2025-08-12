local current_dir = "markup.style.modes."

local function get_module(name)
	return require(current_dir .. name)
end

local modes = {
	normal = get_module("normal"),
	visual = get_module("visual"),
}

return modes
