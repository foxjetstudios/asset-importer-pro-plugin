--!strict

--[[
Module script / AssetPreview.luau
]]

local MarketplaceService = game:GetService("MarketplaceService")
local AssetPreview = {}

-- fetches asset info for a given assetid, then it returns its data in the first argument or an error message in the second argument
function AssetPreview.fetch(assetid: number): (any?, string?)
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfoAsync(assetid, Enum.InfoType.Asset)
	end)

	if not ok then
		local msg = tostring(info):lower()
		if msg:find("does not exist") or msg:find("invalid") or msg:find("unknown") then
			return nil, "This asset " .. assetid .. " does not exist or is not valid."
		end
		if msg:find("http") or msg:find("network") then
			return nil, "A network error occurred while fetching asset info. ERROR: " .. tostring(info)
		end
		return nil, "Failed to fetch asset info, ERROR: " .. tostring(info)
	end

	if not info then
		return nil, "No data returned for assetid: " .. assetid
	end

	return {
		name = info.Name or "Unknown",
		description = info.Description or "",
		iconId = info.IconImageassetid or 0,
		assetTypeId = info.AssetTypeId,
		creator = info.Creator,
		isForSale = info.IsForSale,
		priceInRobux= info.PriceInRobux,
	}, nil
end

return AssetPreview