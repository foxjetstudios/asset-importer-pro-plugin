--!strict

--[[
Module script / IDExtractor.luau
]]

local IDExtractor = {}

local patterns = {
	"%?id=(%d+)",
	"/catalog/(%d+)",
	"/asset/(%d+)",
	"/library/(%d+)",
	"/game%-pass/(%d+)",
	"/asset/%?id=(%d+)",
	"rbxassetid://(%d+)"
}

-- extracts the assetid number from the input string
function IDExtractor.extract(input: string): (number?, string?)
	if not input or input:match("^%s*$") then
		return nil, "Input is empty"
	end

	for _, pattern in ipairs(patterns) do
		local id = input:match(pattern)
		if id then
			return tonumber(id), nil
		end
	end

	local rawid = input:match("^(%d+)$")
	if rawid then
		return tonumber(rawid), nil
	end

	return nil, "Could not extract a valid assetid. Please paste a Roblox Url or a numeric Assetid."
end

return IDExtractor