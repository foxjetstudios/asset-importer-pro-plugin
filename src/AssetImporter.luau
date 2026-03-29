--!strict

--[[
Module script / AssetImporter.luau
]]

local InsertService = game:GetService("InsertService")
local Selection = game:GetService("Selection")

local AssetImporter = {}

local DESTINATIONS = {
	Workspace = workspace,
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	ServerStorage = game:GetService("ServerStorage"),
	StarterGui = game:GetService("StarterGui")
}

local function getdest(name: string): (Instance?, string?)
	if name == "Selected Object" then
		local sel = Selection:Get()
		if sel and sel[1] then
			return sel[1], nil
		end
		return nil, "No object selected in the Explorer, make sure to select a parent object first"
	end

	local dest = DESTINATIONS[name]
	if not dest then
		return nil, "Unknown destination? VALUE:" .. tostring(name)
	end

	return dest, nil
end

-- imports the asset with the given id using loadassetasync, then it parents the imported model into the target destination
function AssetImporter.import(assetid: number, destinationname: string): (Instance?, string?)
	local dest, destErr = getdest(destinationname)
	if destErr then
		return nil, destErr
	end

	local ok, result = pcall(function()
		return InsertService:LoadAsset(assetid)
	end)

	if not ok then
		local msg = tostring(result):lower()
		if msg:find("permission") or msg:find("injection") or msg:find("allowed") then
			return nil, "PERMISSION_DENIED"
		end
		if msg:find("does not exist") or msg:find("invalid") then
			return nil, "The asset: " .. assetid .. " could not be loaded. It may not exist or may be restricted."
		end
		return nil, "Import failed, ERROR: " .. tostring(result)
	end

	if not result then
		return nil, "Insertservice returned no result for asset: " .. assetid
	end

	local wrapper = Instance.new("Model")
	wrapper.Name = "Ungroup me [CTRL + U]"

	result.Parent = wrapper
	local succ = pcall(function()
		wrapper.Parent = dest
	end)

	if not succ then
		return nil, "Insufficient plugin permissions: make sure to grant script injection permission via plugin settings and try again"
	end

	Selection:Set({wrapper})

	return wrapper, nil
end

return AssetImporter