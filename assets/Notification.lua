--!NOEXEC
-- ref: https://github.com/patrickcjk/imgui-notify
-- * Added position lerping
assert(ImGui ~= nil, "ImGui not found!")
if (lerp == nil) then 
	function lerp(a, b, t)
		return a * (1 - t) + b * t
	end
end

local format = string.format
local slen = string.len

Notifications = Core.class()

Notifications.TRANSLATION = {
	["en-US"] = {
		Success = "Success",
		Warning = "Warning",
		Error = "Error",
		Info = "Info",
	},
}
-- Default values:
Notifications.WAIT_TIME = 4			-- (in seconds)
Notifications.FADE_IN_OUT_TIME = 0.1	-- (in seconds)
Notifications.OPACITY = 1
Notifications.PADDING_X = 20
Notifications.PADDING_Y = 20
Notifications.FLAGS	= ImGui.WindowFlags_AlwaysAutoResize | 
	ImGui.WindowFlags_NoDecoration | 
	ImGui.WindowFlags_NoInputs | 
	ImGui.WindowFlags_NoNav |
	ImGui.WindowFlags_NoFocusOnAppearing |
	ImGui.WindowFlags_NoSavedSettings

-- Window types:
Notifications.NONE = "None"
Notifications.SUCCESS = "Success"
Notifications.WARNING = "Warning"
Notifications.ERROR = "Error"
Notifications.INFO = "Info"

-- Position (can be mixed with logical OR operator)
Notifications.TOP = 1
Notifications.LEFT = 2
Notifications.BOTTOM = 4
Notifications.RIGHT = 8

local Notification = Core.class()

-- Appearing
Notification.FADE_IN = 0
Notification.WAIT = 1
Notification.FADE_OUT = 2
Notification.EXPIRED = 3

local function getColor(windowType)
	if (windowType == Notifications.SUCCESS) then
		return 0x00ff00
	elseif (windowType == Notifications.WARNING) then
		return 0xffff00
	elseif (windowType == Notifications.ERROR) then
		return 0xff0000
	elseif (windowType == Notifications.INFO) then
		return 0x009dff
	else
		return 0xffffff
	end
end

local function elapsed(self)
	return os.clock() - self.creationTime
end

local function getPhase(self)
	local elapsed = elapsed(self)
	local fadeTime = Notifications.FADE_IN_OUT_TIME
	
	if (self.waitTime == 0) then 
		return Notification.WAIT
	end
	
	if (elapsed > fadeTime * 2 + self.waitTime) then
		return Notification.EXPIRED
	elseif (elapsed > fadeTime + self.waitTime) then
		return Notification.FADE_OUT
	elseif (elapsed > fadeTime) then
		return Notification.WAIT
	else
		return Notification.FADE_IN
	end
end

local function getFadePercent(self)
	local phase = getPhase(self)
	local elapsed = elapsed(self)
	local fadeTime = Notifications.FADE_IN_OUT_TIME
	local opacity = Notifications.OPACITY

	if (phase == 0) then
		return (elapsed / fadeTime) * opacity
	elseif (phase == 2) then
		return (1 - (((elapsed - fadeTime - self.waitTime) <> 0) / fadeTime)) * opacity
	end
	
	return opacity
end

local function getTitle(self, notification)
	local title = notification.title
	
	if (title and slen(title) > 0) then 
		return title
	else
		return self.translationTable[notification.windowType] or ""
	end
end

function Notification:init(windowType, title, content, waitTime, position)
	self.windowType = windowType or Notifications.NONE
	self.title = title or ""
	self.content = content or ""
	self.waitTime = waitTime or Notifications.WAIT_TIME
	self.position = position or (Notifications.BOTTOM | Notifications.RIGHT)
	self.creationTime = os.clock()
	self.flags = Notifications.FLAGS
	self.pos = 0
	self.appear = true
end

function Notification:makeDisappearable()
	self.waitTime = self.__prevWaitTime or Notifications.WAIT_TIME
	self.flags = self.flags | ImGui.WindowFlags_NoInputs
		| ImGui.WindowFlags_NoDecoration
		~ ImGui.WindowFlags_NoCollapse
	self.closeable = false
end

function Notification:makeCloseable()
	self.__prevWaitTime = self.waitTime
	self.waitTime = 0
	self.flags = self.flags ~ ImGui.WindowFlags_NoInputs
		~ ImGui.WindowFlags_NoDecoration
		| ImGui.WindowFlags_NoCollapse
	self.closeable = true
end

function Notifications:init(imgui, icons, languageCode)
	assert(imgui:getClass() == 'ImGui', "Incorrect ImGui object type!")
	
	self.ui = imgui
	self.notifications = {}
	self.icons = icons or {}
	self.posY = 0
	
	self:setLanguage(languageCode)
end

function Notifications:setLanguage(languageCode)
	languageCode = languageCode or "en-US"
	self.translationTable = Notifications.TRANSLATION[languageCode]
	if (self.translationTable == nil) then 
		self.translationTable = Notifications.TRANSLATION["en-US"]
	end
end

function Notifications:add(windowType, title, content, waitTime, position)
	local notification = Notification.new(windowType, title, content, waitTime, position)
	
	self.notifications[#self.notifications + 1] = notification
	
	return notification
end

function Notifications:addCloseable(windowType, title, content, waitTime, position)
	local notification = Notification.new(windowType, title, content, waitTime, position)
	notification:makeCloseable()
	
	self.notifications[#self.notifications + 1] = notification
	
	return notification
end

function Notifications:draw()
	local ui = self.ui
	
	local displayW, displayH = ui:getIO():getDisplaySize()
	
	local i = 1
	local len = #self.notifications
	
	local padX = Notifications.PADDING_X
	local padY = Notifications.PADDING_Y
	
	local width = 0
	local height = 0
	
	while (i <= len) do
		local notification = self.notifications[i]
		
		if (getPhase(notification) == Notification.EXPIRED) then 
			table.remove(self.notifications, i)
			len -= 1
		else
			local icon = self.icons[notification.windowType]
			local opacity = getFadePercent(notification)
			local iconColor = getColor(notification.windowType)
			local title = getTitle(self, notification)
			local position = notification.position
			
			local defaultBorderColor = ui:getStyleColor(ImGui.Col_Border)
			local defaultSeparatorColor = ui:getStyleColor(ImGui.Col_Separator)
			local defaultTextColor = self.ui:getStyleColor(ImGui.Col_Text)
			
			ui:pushStyleColor(ImGui.Col_Border, defaultBorderColor, opacity)
			ui:pushStyleColor(ImGui.Col_Separator, defaultSeparatorColor, opacity)
			ui:pushStyleColor(ImGui.Col_Text, defaultTextColor, opacity)
			
			ui:setNextWindowBgAlpha(opacity)
			
			local anchorX = 0
			local anchorY = 0
			
			local posX = 0
			local posY = 0
			
			if (position & Notifications.TOP > 0) then 
				if (position & Notifications.LEFT == 0 and position & Notifications.RIGHT == 0) then 
					anchorX = 0.5
					anchorY = 0
					posX = displayW * 0.5
					posY = padY + height
				else
					anchorY = 0
					posY = padY + height
				end
			end
			
			if (position & Notifications.BOTTOM > 0) then
				if (position & Notifications.LEFT == 0 and position & Notifications.RIGHT == 0) then 
					anchorX = 0.5
					anchorY = 1
					posX = displayW * 0.5
					posY = displayH - padY - height
				else
					anchorY = 1
					posY = displayH - padY - height
				end
			end
			
			if (position & Notifications.LEFT > 0) then
				if (position & Notifications.TOP == 0 and position & Notifications.BOTTOM == 0) then 
					anchorX = 0
					anchorY = 0.5
					posX = padX + width
					posY = displayH * 0.5
				else
					anchorX = 0
					posX = padX
				end
			end
			
			if (position & Notifications.RIGHT > 0) then 
				if (position & Notifications.TOP == 0 and position & Notifications.BOTTOM == 0) then 
					anchorX = 1
					anchorY = 0.5
					posX = displayW - padX - width
					posY = displayH * 0.5
				else
					anchorX = 1
					posX = displayW - padX
				end
			end
			
			if (notification.appear) then 
				notification.appear = false
				ui:setNextWindowPos(posX, posY, ImGui.Cond_Once, anchorX, anchorY)
				notification.posX = posX
				notification.posY = posY
			else
				local newPosX = lerp(notification.posX, posX, 0.1)
				local newPosY = lerp(notification.posY, posY, 0.1)
				ui:setNextWindowPos(newPosX, newPosY, ImGui.Cond_Always, anchorX, anchorY)
				notification.posX = newPosX
				notification.posY = newPosY
			end
			
			if (notification.closeable) then 
				if (icon) then 
					title = format("%s %s", icon, title)
				end
				title = format("%s##NOTIFICATION_%d", title, i)
				
				
				ui:pushStyleColor(ImGui.Col_Text, iconColor, opacity)
				local closed = ui:beginWindow(title, notification.closeable, notification.flags ~ ImGui.WindowFlags_AlwaysAutoResize)
				ui:popStyleColor()
				
				if (not closed) then 
					table.remove(self.notifications, i)
					len -= 1
				end
			else
				ui:beginWindow("##NOTIFICATION_"..i, nil, notification.flags)
			end
			
			ui:pushTextWrapPos(displayW / 3)
			
			local haveTitle = false
			
			if (not notification.closeable) then 
				if (icon) then 
					ui:textColored(icon, iconColor, opacity)
					self.ui:sameLine()
					haveTitle = true
				end
				if (title ~= "") then 
					if (icon == nil) then 
						ui:pushStyleColor(ImGui.Col_Text, iconColor, opacity)
					end
					ui:text(title)
					if (icon == nil) then 
						ui:popStyleColor()
					end
					haveTitle = true
				end
			end
			
			if (notification.content and slen(notification.content) > 0) then
				if (haveTitle) then 
					ui:separator()
				end
				
				ui:text(notification.content)
			end
			
			width += ui:getWindowWidth() + padX
			height += ui:getWindowHeight() + padY
			
			ui:endWindow()
			
			ui:popStyleColor(3)
			
			i += 1
		end
	end
	
	self.currentHeight = height
end

