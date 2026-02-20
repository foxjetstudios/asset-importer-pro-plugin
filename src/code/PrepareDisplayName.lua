-- PrepareDisplayName.lua | Logger.lua | Fox Jet Studios

local ICONS = {
	Verified = "",
}

local function prepare(displayName: string, hasVerifiedBadge: boolean): string
	if typeof(displayName) ~= "string" then
		return "Player"
	end

	local finalName = displayName

	if hasVerifiedBadge then
		finalName ..= ICONS.Verified
	end

	return finalName
end

return prepare