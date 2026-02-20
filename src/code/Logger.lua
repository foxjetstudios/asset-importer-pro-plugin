-- Asset Importer Pro | Logger.lua | Fox Jet Studios

local Logger = {}
Logger.__index = Logger

local LOG_COLORS = {
	info    = Color3.fromRGB(180, 200, 220),
	success = Color3.fromRGB(100, 220, 130),
	warn    = Color3.fromRGB(255, 200, 80),
	error   = Color3.fromRGB(255, 90, 90),
}

local LOG_PREFIX = {
	info    = "[INFO]  ",
	success = "[OK]    ",
	warn    = "[WARN]  ",
	error   = "[ERROR] ",
}

function Logger.new(logFrame: ScrollingFrame)
	local self = setmetatable({}, Logger)
	self._logFrame = logFrame
	self._entries  = {}
	return self
end

function Logger:_createEntry(message: string, level: string): TextLabel
	local label = Instance.new("TextLabel")
	label.Font                   = Enum.Font.Code
	label.TextSize               = 12
	label.TextColor3             = LOG_COLORS[level] or LOG_COLORS.info
	label.BackgroundTransparency = 1
	label.TextXAlignment         = Enum.TextXAlignment.Left
	label.TextWrapped            = true
	label.AutomaticSize          = Enum.AutomaticSize.Y
	label.Size                   = UDim2.new(1, -8, 0, 0)
	label.Position               = UDim2.new(0, 4, 0, 0)
	label.Text                   = (LOG_PREFIX[level] or "") .. message
	return label
end

function Logger:log(message: string, level: string?)
	level = level or "info"

	if #self._entries >= 120 then
		local oldest = table.remove(self._entries, 1)
		oldest:Destroy()
	end

	local entry = self:_createEntry(message, level)
	entry.Parent = self._logFrame
	table.insert(self._entries, entry)

	local y = 4
	for _, e in ipairs(self._entries) do
		e.Position = UDim2.new(0, 4, 0, y)
		y = y + e.AbsoluteSize.Y + 2
	end

	self._logFrame.CanvasSize     = UDim2.new(0, 0, 0, y + 4)
	self._logFrame.CanvasPosition = Vector2.new(0, math.max(0, y - self._logFrame.AbsoluteSize.Y))
end

function Logger:clear()
	for _, e in ipairs(self._entries) do e:Destroy() end
	self._entries = {}
	self._logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

function Logger:info(msg)    pcall(function() self:log(msg or "Unknown info", "info") end)    end
function Logger:success(msg) pcall(function() self:log(msg or "Unknown success", "success") end) end
function Logger:warn(msg)    pcall(function() self:log(msg or "Unknown warn", "warn") end)    end
function Logger:error(msg)   pcall(function() self:log(msg or "Unknown error", "error") end)   end

return Logger