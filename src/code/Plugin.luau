-- Asset Importer Pro | plugin.lua | Fox Jet Studios

local toolbar = plugin:CreateToolbar("Fox Jet Studios's Plugins")
local button  = toolbar:CreateButton(
	"Asset Importer Pro",
	"Import and preview Roblox assets by ID or URL",
	"rbxassetid://116730855660254"
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	420,
	600,
	380,
	520
)

local widget = plugin:CreateDockWidgetPluginGuiAsync("AssetImporterProWidget", widgetInfo)
widget.Title = "Asset Importer Pro"
widget.Name  = "AssetImporterProWidget"

local UIController
local widgetOpen = false

button.Click:Connect(function()
	widgetOpen = not widgetOpen
	widget.Enabled = widgetOpen

	if widgetOpen and not UIController then
		local UIModule = require(script.Parent.UIController)
		UIController  = UIModule.new(widget, plugin)
	end
end)

widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	widgetOpen = widget.Enabled
	button:SetActive(widgetOpen)
end)
