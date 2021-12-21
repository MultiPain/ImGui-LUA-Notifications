

require "ImGui_pre_build"
require "Notification"

local LOREM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
local TYPES = { Notifications.NONE, Notifications.SUCCESS, Notifications.WARNING, Notifications.ERROR, Notifications.INFO }
local currentWindowType = 1
local title = ""
local content = LOREM
local contentDisabled = false
local waitTime = Notifications.DEFAULT_WAIT_TIME
local FLAGS = {
	Notifications.TOP,
	Notifications.LEFT,
	Notifications.BOTTOM,
	Notifications.RIGHT,
	
	Notifications.TOP | Notifications.LEFT,
	Notifications.TOP | Notifications.RIGHT,
	Notifications.BOTTOM | Notifications.LEFT,
	Notifications.BOTTOM | Notifications.RIGHT
}
local FLAGS_NAMES = {
	"TOP",
	"LEFT",
	"BOTTOM",
	"RIGHT",
	"TOP LEFT",
	"TOP RIGHT",
	"BOTTOM LEFT",
	"BOTTOM RIGHT"
}
local positionFlag = 7

local MAIN_WINDOW_FLAGS	= ImGui.WindowFlags_NoBringToFrontOnFocus | ImGui.WindowFlags_MenuBar | ImGui.WindowFlags_NoFocusOnAppearing | ImGui.WindowFlags_NoDecoration  | ImGui.WindowFlags_NoMove  | ImGui.WindowFlags_NoResize  | ImGui.WindowFlags_NoSavedSettings

local ui = ImGui.new()
IO = ui:getIO()	
stage:addChild(ui)

notifications = Notifications.new(ui)

--
function onAppResize()
	local minX, minY, maxX, maxY = application:getLogicalBounds()
	local w = maxX - minX
	local h = maxY - minY
	IO:setDisplaySize(w, h)
	ui:setPosition(minX, minY)
end
--
function onEnterFrame(e)
	ui:newFrame(e.deltaTime)
	
	if (ui:beginFullScreenWindow("Main", nil, MAIN_WINDOW_FLAGS)) then
		
		title = ui:inputText("Title", title, 256)
		
		currentWindowType = ui:listBox("Window type", currentWindowType, TYPES)
		
		ui:beginDisabled(contentDisabled)
		content = ui:inputTextMultiline("Content", content, 1024)
		ui:endDisabled()
		
		ui:sameLine()
		contentDisabled = ui:checkbox("Disabled", contentDisabled)
		
		positionFlag = ui:combo("Position", positionFlag, FLAGS_NAMES)
		waitTime = ui:dragFloat("Wait time", waitTime, 0.1, 0, 10)
		
		if (ui:button("Add")) then 
			local contentCopy = ""
			if (not contentDisabled) then 	
				contentCopy = content
			end
			notifications:add(
				TYPES[currentWindowType + 1], 
				title, 
				contentCopy, 
				waitTime, 
				FLAGS[positionFlag + 1])
		end
		
		ui:endWindow()
	end
	
	notifications:draw()
	
	ui:render()
	ui:endFrame()
end

onAppResize()
stage:addEventListener("enterFrame", onEnterFrame)
stage:addEventListener("applicationResize", onAppResize)