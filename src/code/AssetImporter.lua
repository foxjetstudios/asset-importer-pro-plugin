-- Asset Importer Pro | AssetImporter.lua | Fox Jet Studios

local InsertService = game:GetService("InsertService")
local Selection     = game:GetService("Selection")

local AssetImporter = {}

local DESTINATIONS = {
	Workspace         = workspace,
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	ServerStorage     = game:GetService("ServerStorage"),
	StarterGui        = game:GetService("StarterGui"),
}

local function getDestination(name: string): (Instance?, string?)
	if name == "Selected Object" then
		local sel = Selection:Get()
		if sel and sel[1] then
			return sel[1], nil
		end
		return nil, "No object selected in the Explorer. Select a parent object first."
	end

	local dest = DESTINATIONS[name]
	if not dest then
		return nil, "Unknown destination: " .. tostring(name)
	end

	return dest, nil
end

function AssetImporter.import(assetId: number, destinationName: string): (Instance?, string?)
	local dest, destErr = getDestination(destinationName)
	if destErr then
		return nil, destErr
	end

	local ok, result = pcall(function()
		return InsertService:LoadAsset(assetId)
	end)

	if not ok then
		local msg = tostring(result):lower()
		if msg:find("permission") or msg:find("script injection") or msg:find("not allowed") then
			return nil, "PERMISSION_DENIED"
		end
		if msg:find("does not exist") or msg:find("invalid") then
			return nil, "Asset " .. assetId .. " could not be loaded. It may not exist or may be restricted."
		end
		return nil, "Import failed: " .. tostring(result)
	end

	if not result then
		return nil, "InsertService returned no result for asset " .. assetId
	end

	local wrapper = Instance.new("Model")
	wrapper.Name  = "Ungroup me [CTRL + U]"

	result.Parent  = wrapper
	local succ = pcall(function()
		wrapper.Parent = dest
	end)
	
	if not succ then
		return nil, "Insufficient permissions: make sure to grant script injection permission"
	end

	Selection:Set({ wrapper })

	return wrapper, nil
end

return AssetImporter