-- Asset Importer Pro | IDExtractor.lua | Fox Jet Studios

local IDExtractor = {}

function IDExtractor.extract(input: string): (number?, string?)
	if not input or input:gsub("%s", "") == "" then
		return nil, "Input is empty."
	end

	input = input:gsub("%s", "")

	local fromUrl = input:match("roblox%.com/[^%?]*[%?&]id=(%d+)")
		or input:match("roblox%.com/catalog/(%d+)")
		or input:match("roblox%.com/library/(%d+)")
		or input:match("roblox%.com/game%-pass/(%d+)")
		or input:match("roblox%.com/bundles/(%d+)")
		or input:match("roblox%.com/asset/%?id=(%d+)")

	if fromUrl then
		return tonumber(fromUrl), nil
	end

	local rawId = input:match("^(%d+)$")
	if rawId then
		return tonumber(rawId), nil
	end

	local rbxId = input:match("rbxassetid://(%d+)")
	if rbxId then
		return tonumber(rbxId), nil
	end

	return nil, "Could not extract a valid Asset ID.\nPaste a Roblox URL or a numeric Asset ID."
end

return IDExtractor