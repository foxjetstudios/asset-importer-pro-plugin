-- Asset Importer Pro | AssetPreview.lua | Fox Jet Studios

local MarketplaceService = game:GetService("MarketplaceService")

local AssetPreview = {}

function AssetPreview.fetch(assetId: number): (any?, string?)
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfoAsync(assetId, Enum.InfoType.Asset)
	end)

	if not ok then
		local msg = tostring(info):lower()
		if msg:find("does not exist") or msg:find("invalid") or msg:find("unknown") then
			return nil, "Asset " .. assetId .. " does not exist or is not a valid asset."
		end
		if msg:find("http") or msg:find("network") then
			return nil, "Network error while fetching asset info. Check your connection."
		end
		return nil, "Failed to fetch asset info: " .. tostring(info)
	end

	if not info then
		return nil, "No data returned for asset " .. assetId
	end

	return {
		name            = info.Name or "Unknown",
		description     = info.Description or "",
		iconId          = info.IconImageAssetId or 0,
		assetTypeId     = info.AssetTypeId,
		creator         = info.Creator,
		isForSale       = info.IsForSale,
		priceInRobux    = info.PriceInRobux,
	}, nil
end

return AssetPreview