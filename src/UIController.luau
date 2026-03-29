--!strict

--[[
Module script / UIController.luau
]]

local UIController = {}
UIController.__index = UIController

local TweenService = game:GetService("TweenService")

local IDExtractor = require(script.Parent.IDExtractor)
local AssetPreview = require(script.Parent.AssetPreview)
local AssetImporter = require(script.Parent.AssetImporter)
local Logger = require(script.Parent.Logger)
local PrepareDisplayName = require(script.Parent.PrepareDisplayName)

local config = {
	BG = Color3.fromRGB(22, 24, 30),
	PANEL = Color3.fromRGB(32, 35, 44),
	PANEL_DEEP = Color3.fromRGB(26, 28, 36),
	BORDER = Color3.fromRGB(52, 57, 72),
	ACCENT = Color3.fromRGB(99, 161, 255),
	ACCENT_DARK = Color3.fromRGB(66, 120, 210),
	ACCENT_GLOW = Color3.fromRGB(130, 180, 255),
	TEXT = Color3.fromRGB(220, 224, 235),
	SUBTEXT = Color3.fromRGB(130, 140, 165),
	INPUT_BG = Color3.fromRGB(18, 20, 26),
	SUCCESS = Color3.fromRGB(72, 200, 120),
	ERROR = Color3.fromRGB(230, 75, 75),
	WARN_BG = Color3.fromRGB(55, 44, 16),
	WARN_TEXT = Color3.fromRGB(255, 210, 100),
	BTN_IMPORT = Color3.fromRGB(99, 161, 255),
	BTN_PREVIEW = Color3.fromRGB(55, 60, 78),
	BTN_CLEAR = Color3.fromRGB(48, 28, 28),
	PREVIEW_BG = Color3.fromRGB(28, 31, 40),
	THUMB_BG = Color3.fromRGB(20, 22, 30)
}

local TW_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW_MED = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function makeframe(props)
	local frame = Instance.new("Frame")
	for k, v in pairs(props) do
		frame[k] = v
	end
	return frame
end

local function makelabel(props)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.BuilderSansBold
	label.TextColor3 = config.TEXT
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	for k, v in pairs(props) do
		label[k] = v
	end
	return label
end

local function maketextb(props)
	local textbox = Instance.new("TextBox")
	textbox.BackgroundColor3 = config.INPUT_BG
	textbox.BorderSizePixel = 0
	textbox.Font = Enum.Font.Code
	textbox.TextColor3 = config.TEXT
	textbox.PlaceholderColor3 = config.SUBTEXT
	textbox.TextSize = 12
	textbox.TextXAlignment = Enum.TextXAlignment.Left
	textbox.ClearTextOnFocus = false
	for k, v in pairs(props) do
		textbox[k] = v
	end
	return textbox
end

local function makebtn(props)
	local btn = Instance.new("TextButton")
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Font = Enum.Font.BuilderSansBold
	btn.TextSize = 13
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	for k, v in pairs(props) do
		btn[k] = v
	end
	return btn
end

local function makeImage(props)
	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.ScaleType = Enum.ScaleType.Fit
	for k, v in pairs(props) do
		img[k] = v
	end
	return img
end

local function adduicorner(parent, radius)
	local uiC = Instance.new("UICorner")
	uiC.CornerRadius = UDim.new(0, radius or 6)
	uiC.Parent = parent
end

local function adduistroke(parent, color, thickness)
	if not color then
		color = config.BORDER
	end
	if not thickness then
		thickness = 1
	end
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Parent = parent
end

local function addinputpadding(parent)
	local uiP = Instance.new("UIPadding")
	uiP.PaddingLeft = UDim.new(0, 8)
	uiP.PaddingRight = UDim.new(0, 8)
	uiP.Parent = parent
end

local function wirehover(btn, normal, hot)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TW_FAST, {BackgroundColor3 = hot}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TW_FAST, {BackgroundColor3 = normal}):Play()
	end)
end

local function wireInputFocus(box)
	local s = box:FindFirstChildOfClass("UIStroke")
	if not s then return end
	box.Focused:Connect(function()
		TweenService:Create(s, TW_FAST, {Color = config.ACCENT}):Play()
	end)
	box.FocusLost:Connect(function()
		TweenService:Create(s, TW_FAST, {Color = config.BORDER}):Play()
	end)
end

local function makeDropdown(parent, options, defaultIdx)
	defaultIdx = defaultIdx or 1
	
	local selected = options[defaultIdx]

	local container = makeframe({
		BackgroundColor3 = config.INPUT_BG,
		Size = UDim2.new(1, 0, 0, 30),
	})

	adduicorner(container, 6)
	adduistroke(container)

	local display = makelabel({
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Text = selected,
		Font = Enum.Font.BuilderSans,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	local arrow = makelabel({
		Size = UDim2.new(0, 24, 1, 0),
		Position = UDim2.new(1, -26, 0, 0),
		Text = "⬇",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 14,
		TextColor3 = config.SUBTEXT,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = container,
	})

	local clickBtn = Instance.new("TextButton")
	clickBtn.Size = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""
	clickBtn.ZIndex = 5
	clickBtn.Parent = container

	local listFrame = makeframe({
		BackgroundColor3 = config.PANEL,
		ZIndex = 20,
		Visible = false,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 0),
	})
	adduicorner(listFrame, 6)
	adduistroke(listFrame)
	listFrame.Parent = container

	local totalH = #options * 30
	for i, opt in ipairs(options) do
		local ob = makebtn({
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, (i - 1) * 30),
			BackgroundColor3 = config.PANEL,
			Text = opt,
			Font = Enum.Font.BuilderSans,
			TextSize = 12,
			TextColor3 = config.TEXT,
			ZIndex = 21,
			Parent = listFrame,
		})
		wirehover(ob, config.PANEL, config.BORDER)
		ob.Activated:Connect(function()
			selected = opt
			display.Text = opt
			listFrame.Visible = false
			TweenService:Create(arrow, TW_FAST, {Rotation = 0}):Play()
		end)
	end

	local open = false
	clickBtn.Activated:Connect(function()
		open = not open
		listFrame.Visible = open
		if open then
			listFrame.Position = UDim2.new(0, 0, 1, 2)
			TweenService:Create(listFrame, TW_MED, {Size = UDim2.new(1, 0, 0, totalH)}):Play()
			TweenService:Create(arrow, TW_FAST, {Rotation = 180}):Play()
		else
			TweenService:Create(listFrame, TW_MED, {Size = UDim2.new(1, 0, 0, 0)}):Play()
			TweenService:Create(arrow, TW_FAST, {Rotation = 0}):Play()
		end
	end)

	container.Parent = parent
	return container, function() return selected end
end

local function makespinnerimg(parent)
	local spinFrame = makeframe({
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local arc = Instance.new("ImageLabel")
	arc.Size = UDim2.new(1, 0, 1, 0)
	arc.BackgroundTransparency = 1
	arc.Image = "rbxassetid://108239616592221"
	arc.ImageColor3 = config.ACCENT
	arc.Parent = spinFrame

	local spinning = false
	local function setVisible(v)
		spinFrame.Visible = v
		spinning = v
		if v then
			task.spawn(function()
				local r = 0
				while spinning do
					r = r + 8
					arc.Rotation = r
					task.wait(0.016)
				end
				arc.Rotation = 0
			end)
		end
	end

	return spinFrame, setVisible
end

function UIController.new(widget, plugin)
	local self = setmetatable({}, UIController)
	self._widget = widget
	self._plugin = plugin
	self._lastAssetId = nil
	self._importing = false
	self:_buildUI()
	return self
end

function UIController:_buildUI()
	local widget = self._widget

	local root = Instance.new("ScrollingFrame")
	root.Size = UDim2.new(1, 0, 1, 0)
	root.BackgroundColor3 = config.BG
	root.BorderSizePixel = 0
	root.ScrollBarThickness = 4
	root.ScrollBarImageColor3 = config.BORDER
	root.CanvasSize = UDim2.new(0, 0, 0, 0)
	root.AutomaticCanvasSize = Enum.AutomaticSize.Y
	root.Parent = widget

	local rootPad = Instance.new("UIPadding")
	rootPad.PaddingTop = UDim.new(0, 14)
	rootPad.PaddingBottom = UDim.new(0, 14)
	rootPad.PaddingLeft = UDim.new(0, 14)
	rootPad.PaddingRight = UDim.new(0, 14)
	rootPad.Parent = root

	local rootLayout = Instance.new("UIListLayout")
	rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rootLayout.Padding = UDim.new(0, 10)
	rootLayout.Parent = root

	local titleBar = makeframe({
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = config.PANEL,
		LayoutOrder = 1,
		Parent = root,
	})
	adduicorner(titleBar, 8)

	local titlelabel = makelabel({
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(0, 12, 0.5, -14),
		Text = "📦",
		TextScaled = true,
		Parent = titleBar,
	})

	makelabel({
		Size = UDim2.new(1, -56, 0, 22),
		Position = UDim2.new(0, 50, 0, 5),
		Text = "Asset Importer Pro",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 16,
		TextColor3 = config.TEXT,
		Parent = titleBar,
	})

	makelabel({
		Size = UDim2.new(1, -56, 0, 14),
		Position = UDim2.new(0, 50, 0, 28),
		Text = "Quick asset import and preview  •  Fox Jet Studios",
		Font = Enum.Font.BuilderSans,
		TextSize = 10,
		TextColor3 = config.SUBTEXT,
		Parent = titleBar,
	})

	local permBanner = makeframe({
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = config.WARN_BG,
		LayoutOrder = 2,
		Parent = root,
	})
	adduicorner(permBanner, 8)
	adduistroke(permBanner, Color3.fromRGB(120, 90, 20))

	makelabel({
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(0, 10, 0.5, -14),
		Text = "⚠",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 18,
		TextColor3 = config.WARN_TEXT,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = permBanner,
	})

	makelabel({
		Size = UDim2.new(1, -50, 1, -12),
		Position = UDim2.new(0, 42, 0, 6),
		Text = "Script injection permissions are required for LoadAsset to work.\nEnable plugin permissions in Manage Plugins → Asset Importer Pro > Permissions.",
		Font = Enum.Font.BuilderSans,
		TextSize = 11,
		TextColor3 = config.WARN_TEXT,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = permBanner,
	})

	local idSection = makeframe({
		Size = UDim2.new(1, 0, 0, 82),
		BackgroundColor3 = config.PANEL,
		LayoutOrder = 3,
		Parent = root,
	})
	adduicorner(idSection, 8)

	makelabel({
		Size = UDim2.new(1, -28, 0, 18),
		Position = UDim2.new(0, 14, 0, 10),
		Text = "Asset ID or URL",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 12,
		TextColor3 = config.SUBTEXT,
		Parent = idSection,
	})

	local idBox = maketextb({
		Size = UDim2.new(1, -28, 0, 34),
		Position = UDim2.new(0, 14, 0, 34),
		PlaceholderText = "Paste a Roblox URL or numeric Asset ID…",
		Text = "",
		Parent = idSection,
	})
	adduicorner(idBox, 6)
	adduistroke(idBox)
	addinputpadding(idBox)
	wireInputFocus(idBox)
	self._idBox = idBox
	self._idSection = idSection

	local destSection = makeframe({
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = config.PANEL,
		LayoutOrder = 4,
		Parent = root,
	})
	adduicorner(destSection, 8)

	makelabel({
		Size = UDim2.new(1, -28, 0, 18),
		Position = UDim2.new(0, 14, 0, 8),
		Text = "Destination",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 12,
		TextColor3 = config.SUBTEXT,
		Parent = destSection,
	})

	local destContainer = makeframe({
		Size = UDim2.new(1, -28, 0, 30),
		Position = UDim2.new(0, 14, 0, 30),
		BackgroundTransparency = 1,
		Parent = destSection,
	})
	local _, getDestination = makeDropdown(destContainer,
		{"Workspace", "ReplicatedStorage", "ServerStorage", "StarterGui", "Selected Object"}, 1)
	self._getDestination = getDestination

	local btnRow = makeframe({
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		LayoutOrder = 5,
		Parent = root,
	})

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
	btnLayout.Padding = UDim.new(0, 8)
	btnLayout.Parent = btnRow

	local importBtn = makebtn({
		Size = UDim2.new(0.55, -4, 1, 0),
		BackgroundColor3 = config.BTN_IMPORT,
		Text = "⬇ Import Asset",
		LayoutOrder = 1,
		Parent = btnRow,
	})
	adduicorner(importBtn, 8)
	wirehover(importBtn, config.BTN_IMPORT, config.ACCENT_DARK)
	self._importBtn = importBtn

	local spinFrame, setSpinner = makespinnerimg(importBtn)
	spinFrame.Position = UDim2.new(1, -26, 0.5, -9)
	self._setSpinner = setSpinner

	local previewBtn = makebtn({
		Size = UDim2.new(0.27, -4, 1, 0),
		BackgroundColor3 = config.BTN_PREVIEW,
		Text = "👁  Preview",
		LayoutOrder = 2,
		Parent = btnRow,
	})
	adduicorner(previewBtn, 8)
	wirehover(previewBtn, config.BTN_PREVIEW, config.BORDER)
	self._previewBtn = previewBtn

	local clearBtn = makebtn({
		Size = UDim2.new(0.18, 0, 1, 0),
		BackgroundColor3 = config.BTN_CLEAR,
		Text = "🗑",
		LayoutOrder = 3,
		Parent = btnRow,
	})
	adduicorner(clearBtn, 8)
	wirehover(clearBtn, config.BTN_CLEAR, Color3.fromRGB(80, 30, 30))

	local previewPanel = makeframe({
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = config.PREVIEW_BG,
		LayoutOrder = 6,
		ClipsDescendants = true,
		Visible = false,
		Parent = root,
	})
	adduicorner(previewPanel, 8)
	adduistroke(previewPanel, config.BORDER)
	self._previewPanel = previewPanel

	makelabel({
		Size = UDim2.new(1, -16, 0, 18),
		Position = UDim2.new(0, 14, 0, 8),
		Text = "Asset Preview",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 12,
		TextColor3 = config.SUBTEXT,
		Parent = previewPanel,
	})

	local thumbBg = makeframe({
		Size = UDim2.new(0, 80, 0, 80),
		Position = UDim2.new(0, 14, 0, 32),
		BackgroundColor3 = config.THUMB_BG,
		Parent = previewPanel,
	})
	adduicorner(thumbBg, 8)
	adduistroke(thumbBg, config.BORDER)

	local thumbImg = makeImage({
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.new(0, 4, 0, 4),
		Image = "",
		BackgroundColor3 = config.THUMB_BG,
		BackgroundTransparency = 1,
		Parent = thumbBg,
	})
	adduicorner(thumbImg, 6)
	self._thumbImg = thumbImg

	local thumbPlaceholder = makelabel({
		Size = UDim2.new(1, 0, 1, 0),
		Text = "?",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 28,
		TextColor3 = config.BORDER,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = thumbBg,
	})
	self._thumbPlaceholder = thumbPlaceholder

	local previewName = makelabel({
		Size = UDim2.new(1, -114, 0, 20),
		Position = UDim2.new(0, 104, 0, 34),
		Text = "—",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 14,
		TextColor3 = config.TEXT,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = previewPanel,
	})
	self._previewName = previewName

	local previewCreator = makelabel({
		Size = UDim2.new(1, -114, 0, 14),
		Position = UDim2.new(0, 104, 0, 58),
		Text = "",
		Font = Enum.Font.BuilderSans,
		TextSize = 11,
		TextColor3 = config.SUBTEXT,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = previewPanel,
	})
	self._previewCreator = previewCreator

	local previewIdLabel = makelabel({
		Size = UDim2.new(1, -114, 0, 14),
		Position = UDim2.new(0, 104, 0, 76),
		Text = "",
		Font = Enum.Font.Code,
		TextSize = 11,
		TextColor3 = config.SUBTEXT,
		Parent = previewPanel,
	})
	self._previewIdLabel = previewIdLabel

	local descDivider = makeframe({
		Size = UDim2.new(1, -28, 0, 1),
		Position = UDim2.new(0, 14, 0, 124),
		BackgroundColor3 = config.BORDER,
		Parent = previewPanel,
	})

	local previewDesc = makelabel({
		Size = UDim2.new(1, -28, 0, 52),
		Position = UDim2.new(0, 14, 0, 132),
		Text = "",
		Font = Enum.Font.BuilderSans,
		TextSize = 11,
		TextColor3 = config.SUBTEXT,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = previewPanel,
	})
	self._previewDesc = previewDesc

	local logSection = makeframe({
		Size = UDim2.new(1, 0, 0, 180),
		BackgroundColor3 = config.PANEL,
		LayoutOrder = 7,
		ClipsDescendants = true,
		Parent = root,
	})
	adduicorner(logSection, 8)

	makelabel({
		Size = UDim2.new(1, -16, 0, 18),
		Position = UDim2.new(0, 14, 0, 8),
		Text = "Log",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 12,
		TextColor3 = config.SUBTEXT,
		Parent = logSection,
	})

	local logFrame = Instance.new("ScrollingFrame")
	logFrame.Size = UDim2.new(1, -8, 1, -32)
	logFrame.Position = UDim2.new(0, 4, 0, 28)
	logFrame.BackgroundColor3 = config.INPUT_BG
	logFrame.BorderSizePixel = 0
	logFrame.ScrollBarThickness = 3
	logFrame.ScrollBarImageColor3 = config.BORDER
	logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	logFrame.Parent = logSection
	adduicorner(logFrame, 4)

	local logger = Logger.new(logFrame)
	self._logger = logger
	self._btnRow = btnRow

	logger:info("Asset Importer Pro ready. Paste an Asset ID or URL above.")

	makelabel({
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Asset Importer Pro  •  Fox Jet Studios",
		Font = Enum.Font.BuilderSans,
		TextSize = 10,
		TextColor3 = config.SUBTEXT,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 8,
		Parent = root,
	})

	importBtn.Activated:Connect(function() self:_onImport() end)
	previewBtn.Activated:Connect(function() self:_onPreview() end)
	clearBtn.Activated:Connect(function()
		logger:clear()
		self:_hidePreview()
		logger:info("Log cleared.")
	end)
end

function UIController:_setbusy(busy: boolean)
	self._importBtn.Active = not busy
	self._previewBtn.Active = not busy
	self._importing = busy
	self._importBtn.Text = busy and "  Importing…" or "⬇  Import Asset"
	self._setSpinner(busy)
end

function UIController:_hidePreview()
	TweenService:Create(self._previewPanel, TW_MED, {Size = UDim2.new(1, 0, 0, 0)}):Play()
	task.delay(0.25, function()
		self._previewPanel.Visible = false
	end)
end

function UIController:_showPreview(info: any, assetId: number)
	self._previewName.Text = info.name
	self._previewCreator.Text = ""
	self._previewIdLabel.Text = "ID: " .. tostring(assetId)
	self._previewDesc.Text = info.description ~= "" and info.description or "No description provided."

	pcall(function()
		if info.creator and type(info.creator) == "table" then
			local name = info.creator.Name
			local hasverifiedbadge = info.creator.HasVerifiedBadge

			self._previewCreator.Text = "By " .. tostring(PrepareDisplayName(name, hasverifiedbadge))
		end
	end)

	if tonumber(assetId) and assetId ~= 0 then
		self._thumbImg.Image = "rbxthumb://type=Asset&id=" .. assetId .. "&w=420&h=420"
		self._thumbPlaceholder.Visible = false
	else
		self._thumbImg.Image = ""
		self._thumbPlaceholder.Visible = true
	end

	self._previewPanel.Visible = true
	self._previewPanel.Size = UDim2.new(1, 0, 0, 0)

	TweenService:Create(self._previewPanel, TW_MED, {Size = UDim2.new(1, 0, 0, 196)}):Play()
end

function UIController:_flashBtn(btn: TextButton, color: Color3, originalColor: Color3)
	TweenService:Create(btn, TW_FAST, {BackgroundColor3 = color}):Play()
	task.delay(1.2, function()
		TweenService:Create(btn, TW_MED, {BackgroundColor3 = originalColor}):Play()
	end)
end

function UIController:_getAssetId(): (number?, string?)
	local raw = self._idBox.Text
	return IDExtractor.extract(raw)
end

function UIController:_onPreview()
	if self._importing then return end

	local assetId, idErr = self:_getAssetId()
	if idErr then
		self._logger:error(idErr)
		return
	end

	self._logger:info("Fetching preview for asset " .. assetId .. "…")
	self._previewBtn.Active = false
	self._previewBtn.Text = "Loading…"

	task.spawn(function()
		local info, err = AssetPreview.fetch(assetId)

		self._previewBtn.Active = true
		self._previewBtn.Text = "👁  Preview"

		if err then
			self._logger:error(err)
			return
		end

		self._lastAssetId = assetId
		self:_showPreview(info, assetId)

		local priceStr = ""
		if info.priceInRobux and info.priceInRobux > 0 then
			priceStr = "  •  R$ " .. tostring(info.priceInRobux)
		elseif info.isForSale == false then
			priceStr = "  •  Not for sale"
		end

		self._logger:success(string.format('Preview loaded: "%s" by %s%s', info.name, (info.creator and info.creator.Name or "Unknown"), priceStr))
	end)
end

function UIController:_onImport()
	if self._importing then return end

	local assetId, idErr = self:_getAssetId()
	if idErr then
		self._logger:error(idErr)
		return
	end

	local destination = self._getDestination()
	self._logger:info(string.format("Importing asset %d → %s…", assetId, destination))
	self:_setbusy(true)

	task.spawn(function()
		local instance, err = AssetImporter.import(assetId, destination)

		self:_setbusy(false)

		if err then
			if err == "PERMISSION_DENIED" then
				self._logger:error("Script injection permissions are not enabled. Go to Manage Plugin → Asset Importer Pro > allow plugin script injection.")
			else
				self._logger:error(err)
			end
			self:_flashBtn(self._importBtn, config.ERROR, config.BTN_IMPORT)
			return
		end

		self._logger:success(string.format(
			'Imported asset %d as "%s" into %s ✓', assetId, instance.Name, destination
			))

		self:_flashBtn(self._importBtn, config.SUCCESS, config.BTN_IMPORT)
	end)
end

return UIController
