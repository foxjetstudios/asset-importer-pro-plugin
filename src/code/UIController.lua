-- Asset Importer Pro | UIController.lua | Fox Jet Studios

local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")

local IDExtractor        = require(script.Parent.IDExtractor)
local AssetPreview       = require(script.Parent.AssetPreview)
local AssetImporter      = require(script.Parent.AssetImporter)
local Logger             = require(script.Parent.Logger)
local PrepareDsiplayName = require(script.Parent.PrepareDisplayName)

local C = {
	BG           = Color3.fromRGB(22,  24,  30),
	PANEL        = Color3.fromRGB(32,  35,  44),
	PANEL_DEEP   = Color3.fromRGB(26,  28,  36),
	BORDER       = Color3.fromRGB(52,  57,  72),
	ACCENT       = Color3.fromRGB(99,  161, 255),
	ACCENT_DARK  = Color3.fromRGB(66,  120, 210),
	ACCENT_GLOW  = Color3.fromRGB(130, 180, 255),
	TEXT         = Color3.fromRGB(220, 224, 235),
	SUBTEXT      = Color3.fromRGB(130, 140, 165),
	INPUT_BG     = Color3.fromRGB(18,  20,  26),
	SUCCESS      = Color3.fromRGB(72,  200, 120),
	ERROR        = Color3.fromRGB(230,  75,  75),
	WARN_BG      = Color3.fromRGB(55,  44,  16),
	WARN_TEXT    = Color3.fromRGB(255, 210, 100),
	BTN_IMPORT   = Color3.fromRGB(99,  161, 255),
	BTN_PREVIEW  = Color3.fromRGB(55,  60,  78),
	BTN_CLEAR    = Color3.fromRGB(48,  28,  28),
	PREVIEW_BG   = Color3.fromRGB(28,  31,  40),
	THUMB_BG     = Color3.fromRGB(20,  22,  30),
}

local TW_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW_MED  = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW_SLOW = TweenInfo.new(0.4,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function makeFrame(props)
	local f = Instance.new("Frame")
	for k, v in pairs(props) do f[k] = v end
	return f
end

local function makeLabel(props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font                   = Enum.Font.BuilderSansBold
	l.TextColor3             = C.TEXT
	l.TextSize               = 13
	l.TextXAlignment         = Enum.TextXAlignment.Left
	for k, v in pairs(props) do l[k] = v end
	return l
end

local function makeTextbox(props)
	local t = Instance.new("TextBox")
	t.BackgroundColor3  = C.INPUT_BG
	t.BorderSizePixel   = 0
	t.Font              = Enum.Font.Code
	t.TextColor3        = C.TEXT
	t.PlaceholderColor3 = C.SUBTEXT
	t.TextSize          = 12
	t.TextXAlignment    = Enum.TextXAlignment.Left
	t.ClearTextOnFocus  = false
	for k, v in pairs(props) do t[k] = v end
	return t
end

local function makeButton(props)
	local b = Instance.new("TextButton")
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.Font            = Enum.Font.BuilderSansBold
	b.TextSize        = 13
	b.TextColor3      = Color3.fromRGB(255, 255, 255)
	for k, v in pairs(props) do b[k] = v end
	return b
end

local function makeImage(props)
	local i = Instance.new("ImageLabel")
	i.BackgroundTransparency = 1
	i.ScaleType              = Enum.ScaleType.Fit
	for k, v in pairs(props) do i[k] = v end
	return i
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color     = color or C.BORDER
	s.Thickness = thickness or 1
	s.Parent    = parent
end

local function addPadding(parent, all)
	local p = Instance.new("UIPadding")
	p.PaddingLeft   = UDim.new(0, all or 8)
	p.PaddingRight  = UDim.new(0, all or 8)
	p.PaddingTop    = UDim.new(0, all or 8)
	p.PaddingBottom = UDim.new(0, all or 8)
	p.Parent = parent
end

local function addInputPadding(parent)
	local p = Instance.new("UIPadding")
	p.PaddingLeft  = UDim.new(0, 8)
	p.PaddingRight = UDim.new(0, 8)
	p.Parent = parent
end

local function wireHover(btn, normal, hot)
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
		TweenService:Create(s, TW_FAST, {Color = C.ACCENT}):Play()
	end)
	box.FocusLost:Connect(function()
		TweenService:Create(s, TW_FAST, {Color = C.BORDER}):Play()
	end)
end

local function makeDropdown(parent, options, defaultIdx)
	defaultIdx = defaultIdx or 1
	local selected = options[defaultIdx]

	local container = makeFrame({
		BackgroundColor3 = C.INPUT_BG,
		Size             = UDim2.new(1, 0, 0, 30),
	})
	addCorner(container, 6)
	addStroke(container)

	local display = makeLabel({
		Size           = UDim2.new(1, -28, 1, 0),
		Position       = UDim2.new(0, 10, 0, 0),
		Text           = selected,
		Font           = Enum.Font.BuilderSans,
		TextSize       = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent         = container,
	})

	local arrow = makeLabel({
		Size           = UDim2.new(0, 24, 1, 0),
		Position       = UDim2.new(1, -26, 0, 0),
		Text           = "⬇",
		Font           = Enum.Font.BuilderSansBold,
		TextSize       = 14,
		TextColor3     = C.SUBTEXT,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent         = container,
	})

	local clickBtn = Instance.new("TextButton")
	clickBtn.Size                   = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text                   = ""
	clickBtn.ZIndex                 = 5
	clickBtn.Parent                 = container

	local listFrame = makeFrame({
		BackgroundColor3 = C.PANEL,
		ZIndex           = 20,
		Visible          = false,
		ClipsDescendants = true,
		Size             = UDim2.new(1, 0, 0, 0),
	})
	addCorner(listFrame, 6)
	addStroke(listFrame)
	listFrame.Parent = container

	local totalH = #options * 30
	for i, opt in ipairs(options) do
		local ob = makeButton({
			Size             = UDim2.new(1, 0, 0, 30),
			Position         = UDim2.new(0, 0, 0, (i - 1) * 30),
			BackgroundColor3 = C.PANEL,
			Text             = opt,
			Font             = Enum.Font.BuilderSans,
			TextSize         = 12,
			TextColor3       = C.TEXT,
			ZIndex           = 21,
			Parent           = listFrame,
		})
		wireHover(ob, C.PANEL, C.BORDER)
		ob.Activated:Connect(function()
			selected          = opt
			display.Text      = opt
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

local function makeSpinner(parent)
	local spinFrame = makeFrame({
		Size                   = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		Visible                = false,
		Parent                 = parent,
	})

	local arc = Instance.new("ImageLabel")
	arc.Size                   = UDim2.new(1, 0, 1, 0)
	arc.BackgroundTransparency = 1
	arc.Image                  = "rbxassetid://108239616592221"
	arc.ImageColor3            = C.ACCENT
	arc.Parent                 = spinFrame

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

local function shakeFrame(frame)
	local original = frame.Position
	local offsets  = { 6, -6, 4, -4, 2, -2, 0 }
	for _, x in ipairs(offsets) do
		TweenService:Create(frame, TweenInfo.new(0.04), {
			Position = UDim2.new(original.X.Scale, original.X.Offset + x, original.Y.Scale, original.Y.Offset)
		}):Play()
		task.wait(0.04)
	end
	frame.Position = original
end

local UIController = {}
UIController.__index = UIController

function UIController.new(widget, plugin)
	local self = setmetatable({}, UIController)
	self._widget        = widget
	self._plugin        = plugin
	self._lastAssetId   = nil
	self._importing     = false
	self:_buildUI()
	return self
end

function UIController:_buildUI()
	local widget = self._widget

	local root = Instance.new("ScrollingFrame")
	root.Size                 = UDim2.new(1, 0, 1, 0)
	root.BackgroundColor3     = C.BG
	root.BorderSizePixel      = 0
	root.ScrollBarThickness   = 4
	root.ScrollBarImageColor3 = C.BORDER
	root.CanvasSize           = UDim2.new(0, 0, 0, 0)
	root.AutomaticCanvasSize  = Enum.AutomaticSize.Y
	root.Parent               = widget

	local rootPad = Instance.new("UIPadding")
	rootPad.PaddingTop    = UDim.new(0, 14)
	rootPad.PaddingBottom = UDim.new(0, 14)
	rootPad.PaddingLeft   = UDim.new(0, 14)
	rootPad.PaddingRight  = UDim.new(0, 14)
	rootPad.Parent        = root

	local rootLayout = Instance.new("UIListLayout")
	rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rootLayout.Padding   = UDim.new(0, 10)
	rootLayout.Parent    = root

	local titleBar = makeFrame({
		Size             = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = C.PANEL,
		LayoutOrder      = 1,
		Parent           = root,
	})
	addCorner(titleBar, 8)

	local titlelabel = makeLabel({
		Size     = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(0, 12, 0.5, -14),
		Text    = "🧩",
		TextScaled = true,
		Parent   = titleBar,
	})

	makeLabel({
		Size       = UDim2.new(1, -56, 0, 22),
		Position   = UDim2.new(0, 50, 0, 5),
		Text       = "Asset Importer Pro",
		Font       = Enum.Font.BuilderSansBold,
		TextSize   = 16,
		TextColor3 = C.TEXT,
		Parent     = titleBar,
	})

	makeLabel({
		Size       = UDim2.new(1, -56, 0, 14),
		Position   = UDim2.new(0, 50, 0, 28),
		Text       = "Quick asset import & preview  •  Fox Jet Studios",
		Font       = Enum.Font.BuilderSans,
		TextSize   = 10,
		TextColor3 = C.SUBTEXT,
		Parent     = titleBar,
	})

	local permBanner = makeFrame({
		Size             = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = C.WARN_BG,
		LayoutOrder      = 2,
		Parent           = root,
	})
	addCorner(permBanner, 8)
	addStroke(permBanner, Color3.fromRGB(120, 90, 20))

	makeLabel({
		Size           = UDim2.new(0, 28, 0, 28),
		Position       = UDim2.new(0, 10, 0.5, -14),
		Text           = "⚠",
		Font           = Enum.Font.BuilderSansBold,
		TextSize       = 18,
		TextColor3     = C.WARN_TEXT,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent         = permBanner,
	})

	makeLabel({
		Size           = UDim2.new(1, -50, 1, -12),
		Position       = UDim2.new(0, 42, 0, 6),
		Text           = "Script injection permissions are required for LoadAsset to work.\nEnable plugin permissions in Studio Settings → Security.",
		Font           = Enum.Font.BuilderSans,
		TextSize       = 11,
		TextColor3     = C.WARN_TEXT,
		TextWrapped    = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent         = permBanner,
	})

	local idSection = makeFrame({
		Size             = UDim2.new(1, 0, 0, 82),
		BackgroundColor3 = C.PANEL,
		LayoutOrder      = 3,
		Parent           = root,
	})
	addCorner(idSection, 8)

	makeLabel({
		Size       = UDim2.new(1, -28, 0, 18),
		Position   = UDim2.new(0, 14, 0, 10),
		Text       = "Asset ID or URL",
		Font       = Enum.Font.BuilderSansBold,
		TextSize   = 12,
		TextColor3 = C.SUBTEXT,
		Parent     = idSection,
	})

	local idBox = makeTextbox({
		Size            = UDim2.new(1, -28, 0, 34),
		Position        = UDim2.new(0, 14, 0, 34),
		PlaceholderText = "Paste a Roblox URL or numeric Asset ID…",
		Text            = "",
		Parent          = idSection,
	})
	addCorner(idBox, 6)
	addStroke(idBox)
	addInputPadding(idBox)
	wireInputFocus(idBox)
	self._idBox     = idBox
	self._idSection = idSection

	local destSection = makeFrame({
		Size             = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = C.PANEL,
		LayoutOrder      = 4,
		Parent           = root,
	})
	addCorner(destSection, 8)

	makeLabel({
		Size       = UDim2.new(1, -28, 0, 18),
		Position   = UDim2.new(0, 14, 0, 8),
		Text       = "Destination",
		Font       = Enum.Font.BuilderSansBold,
		TextSize   = 12,
		TextColor3 = C.SUBTEXT,
		Parent     = destSection,
	})

	local destContainer = makeFrame({
		Size                   = UDim2.new(1, -28, 0, 30),
		Position               = UDim2.new(0, 14, 0, 30),
		BackgroundTransparency = 1,
		Parent                 = destSection,
	})
	local _, getDestination = makeDropdown(destContainer,
		{"Workspace", "ReplicatedStorage", "ServerStorage", "StarterGui", "Selected Object"}, 1)
	self._getDestination = getDestination

	local btnRow = makeFrame({
		Size                   = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		LayoutOrder            = 5,
		Parent                 = root,
	})

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.SortOrder     = Enum.SortOrder.LayoutOrder
	btnLayout.Padding       = UDim.new(0, 8)
	btnLayout.Parent        = btnRow

	local importBtn = makeButton({
		Size             = UDim2.new(0.55, -4, 1, 0),
		BackgroundColor3 = C.BTN_IMPORT,
		Text             = "⬇  Import Asset",
		LayoutOrder      = 1,
		Parent           = btnRow,
	})
	addCorner(importBtn, 8)
	wireHover(importBtn, C.BTN_IMPORT, C.ACCENT_DARK)
	self._importBtn = importBtn

	local spinFrame, setSpinner = makeSpinner(importBtn)
	spinFrame.Position = UDim2.new(1, -26, 0.5, -9)
	self._setSpinner   = setSpinner

	local previewBtn = makeButton({
		Size             = UDim2.new(0.27, -4, 1, 0),
		BackgroundColor3 = C.BTN_PREVIEW,
		Text             = "👁  Preview",
		LayoutOrder      = 2,
		Parent           = btnRow,
	})
	addCorner(previewBtn, 8)
	wireHover(previewBtn, C.BTN_PREVIEW, C.BORDER)
	self._previewBtn = previewBtn

	local clearBtn = makeButton({
		Size             = UDim2.new(0.18, 0, 1, 0),
		BackgroundColor3 = C.BTN_CLEAR,
		Text             = "🗑",
		LayoutOrder      = 3,
		Parent           = btnRow,
	})
	addCorner(clearBtn, 8)
	wireHover(clearBtn, C.BTN_CLEAR, Color3.fromRGB(80, 30, 30))

	local previewPanel = makeFrame({
		Size             = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = C.PREVIEW_BG,
		LayoutOrder      = 6,
		ClipsDescendants = true,
		Visible          = false,
		Parent           = root,
	})
	addCorner(previewPanel, 8)
	addStroke(previewPanel, C.BORDER)
	self._previewPanel = previewPanel

	makeLabel({
		Size       = UDim2.new(1, -16, 0, 18),
		Position   = UDim2.new(0, 14, 0, 8),
		Text       = "Asset Preview",
		Font       = Enum.Font.BuilderSansBold,
		TextSize   = 12,
		TextColor3 = C.SUBTEXT,
		Parent     = previewPanel,
	})

	local thumbBg = makeFrame({
		Size             = UDim2.new(0, 80, 0, 80),
		Position         = UDim2.new(0, 14, 0, 32),
		BackgroundColor3 = C.THUMB_BG,
		Parent           = previewPanel,
	})
	addCorner(thumbBg, 8)
	addStroke(thumbBg, C.BORDER)

	local thumbImg = makeImage({
		Size             = UDim2.new(1, -8, 1, -8),
		Position         = UDim2.new(0, 4, 0, 4),
		Image            = "",
		BackgroundColor3 = C.THUMB_BG,
		BackgroundTransparency = 1,
		Parent           = thumbBg,
	})
	addCorner(thumbImg, 6)
	self._thumbImg = thumbImg

	local thumbPlaceholder = makeLabel({
		Size           = UDim2.new(1, 0, 1, 0),
		Text           = "?",
		Font           = Enum.Font.BuilderSansBold,
		TextSize       = 28,
		TextColor3     = C.BORDER,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent         = thumbBg,
	})
	self._thumbPlaceholder = thumbPlaceholder

	local previewName = makeLabel({
		Size       = UDim2.new(1, -114, 0, 20),
		Position   = UDim2.new(0, 104, 0, 34),
		Text       = "—",
		Font       = Enum.Font.BuilderSansBold,
		TextSize   = 14,
		TextColor3 = C.TEXT,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent     = previewPanel,
	})
	self._previewName = previewName

	local previewCreator = makeLabel({
		Size       = UDim2.new(1, -114, 0, 14),
		Position   = UDim2.new(0, 104, 0, 58),
		Text       = "",
		Font       = Enum.Font.BuilderSans,
		TextSize   = 11,
		TextColor3 = C.SUBTEXT,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent     = previewPanel,
	})
	self._previewCreator = previewCreator

	local previewIdLabel = makeLabel({
		Size       = UDim2.new(1, -114, 0, 14),
		Position   = UDim2.new(0, 104, 0, 76),
		Text       = "",
		Font       = Enum.Font.Code,
		TextSize   = 11,
		TextColor3 = C.SUBTEXT,
		Parent     = previewPanel,
	})
	self._previewIdLabel = previewIdLabel

	local descDivider = makeFrame({
		Size             = UDim2.new(1, -28, 0, 1),
		Position         = UDim2.new(0, 14, 0, 124),
		BackgroundColor3 = C.BORDER,
		Parent           = previewPanel,
	})

	local previewDesc = makeLabel({
		Size           = UDim2.new(1, -28, 0, 52),
		Position       = UDim2.new(0, 14, 0, 132),
		Text           = "",
		Font           = Enum.Font.BuilderSans,
		TextSize       = 11,
		TextColor3     = C.SUBTEXT,
		TextWrapped    = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent         = previewPanel,
	})
	self._previewDesc = previewDesc

	local logSection = makeFrame({
		Size             = UDim2.new(1, 0, 0, 180),
		BackgroundColor3 = C.PANEL,
		LayoutOrder      = 7,
		ClipsDescendants = true,
		Parent           = root,
	})
	addCorner(logSection, 8)

	makeLabel({
		Size       = UDim2.new(1, -16, 0, 18),
		Position   = UDim2.new(0, 14, 0, 8),
		Text       = "Log",
		Font       = Enum.Font.BuilderSansBold,
		TextSize   = 12,
		TextColor3 = C.SUBTEXT,
		Parent     = logSection,
	})

	local logFrame = Instance.new("ScrollingFrame")
	logFrame.Size                 = UDim2.new(1, -8, 1, -32)
	logFrame.Position             = UDim2.new(0, 4, 0, 28)
	logFrame.BackgroundColor3     = C.INPUT_BG
	logFrame.BorderSizePixel      = 0
	logFrame.ScrollBarThickness   = 3
	logFrame.ScrollBarImageColor3 = C.BORDER
	logFrame.CanvasSize           = UDim2.new(0, 0, 0, 0)
	logFrame.Parent               = logSection
	addCorner(logFrame, 4)

	local logger = Logger.new(logFrame)
	self._logger  = logger
	self._btnRow  = btnRow

	logger:info("Asset Importer Pro ready. Paste an Asset ID or URL above.")

	makeLabel({
		Size           = UDim2.new(1, 0, 0, 16),
		Text           = "Asset Importer Pro  •  MIT License  •  Fox Jet Studios",
		Font           = Enum.Font.BuilderSans,
		TextSize       = 10,
		TextColor3     = C.SUBTEXT,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder    = 8,
		Parent         = root,
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
	self._importBtn.Active  = not busy
	self._previewBtn.Active = not busy
	self._importing         = busy
	self._importBtn.Text    = busy and "  Importing…" or "⬇  Import Asset"
	self._setSpinner(busy)
end

function UIController:_hidePreview()
	TweenService:Create(self._previewPanel, TW_MED, {Size = UDim2.new(1, 0, 0, 0)}):Play()
	task.delay(0.25, function()
		self._previewPanel.Visible = false
	end)
end

function UIController:_showPreview(info: any, assetId: number)
	self._previewName.Text    = info.name
	self._previewCreator.Text = ""
	self._previewIdLabel.Text = "ID: " .. tostring(assetId)
	self._previewDesc.Text    = info.description ~= "" and info.description or "No description provided."
	
	pcall(function()
		if info.creator and type(info.creator) == "table" then
			local name = info.creator.Name
			local hasverifiedbadge = info.creator.HasVerifiedBadge
			
			self._previewCreator.Text = "By " .. tostring(PrepareDsiplayName(name, hasverifiedbadge))
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
	self._previewPanel.Size    = UDim2.new(1, 0, 0, 0)

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
		task.spawn(shakeFrame, self._idSection)
		return
	end

	self._logger:info("Fetching preview for asset " .. assetId .. "…")
	self._previewBtn.Active = false
	self._previewBtn.Text   = "Loading…"

	task.spawn(function()
		local info, err = AssetPreview.fetch(assetId)

		self._previewBtn.Active = true
		self._previewBtn.Text   = "👁  Preview"

		if err then
			self._logger:error(err)
			task.spawn(shakeFrame, self._idSection)
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

		self._logger:success(string.format('Preview loaded: "%s" by %s%s', info.name, info.creator, priceStr))
	end)
end

function UIController:_onImport()
	if self._importing then return end

	local assetId, idErr = self:_getAssetId()
	if idErr then
		self._logger:error(idErr)
		task.spawn(shakeFrame, self._idSection)
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
				self._logger:error("Script injection permissions are not enabled. Go to Studio Settings → Security and allow plugin script injection.")
			else
				self._logger:error(err)
			end
			task.spawn(shakeFrame, self._importBtn)
			self:_flashBtn(self._importBtn, C.ERROR, C.BTN_IMPORT)
			return
		end

		self._logger:success(string.format(
			'Imported asset %d as "%s" into %s ✓', assetId, instance.Name, destination
			))

		self:_flashBtn(self._importBtn, C.SUCCESS, C.BTN_IMPORT)
	end)
end

return UIController