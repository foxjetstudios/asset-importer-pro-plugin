--!strict

--[[
Module script / PrepareDisplayName.luau
]]

local ICONS = {
	Verified = "",
}

-- return a prepared display name with the verified badge icon if they have it
local function prepare(displayName: string, hasVerifiedBadge: boolean): string
	if typeof(displayName) ~= "string" then
		return "Player"
	end

	local finalName = displayName

	if hasVerifiedBadge then
		finalName = finalName .. ICONS.Verified
	end

	return finalName
end

return prepare
