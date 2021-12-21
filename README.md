# ImGui LUA Notifications
 
# API
## Constructor
```lua
notifications = Notifications.new(ImGuiInstance [, iconsTable, languageCode])
```
char table:
{
	Success = utf8.char(0xe86c), 
	Warning = utf8.char(0xf083),
	Error = utf8.char(0xe888), 
	Info = utf8.char(0xe88e)
}
Icons font: "MaterialIconsRound-Regular" from Google

To change language, you need to edit "Notifications.TRANSLATION" variable in "Notification.lua"
languageCode: "en-EN", "fr-FR" etc.

## Push new notification
```lua
notifications:add([windowType, title, content, waitTime, positionFlags])
```
windowType:
	Notifications.NONE
	Notifications.SUCCESS
	Notifications.WARNING
	Notifications.ERROR
	Notifications.INFO
title (string): window title (if empty of nil, uses default name depending on windowType)
content (string): shown message (default: "")
waitTime (number): window display time in seconds (default: 4)
positionFlags (number): (default: Notifications.BOTTOM | Notifications.RIGHT)
	Notifications.TOP
	Notifications.LEFT
	Notifications.BOTTOM
	Notifications.RIGHT
can be mixed with logical OR operator
```lua
notifications:addCloseable([windowType, title, content, waitTime, position])
```
Same as above, but the window is displayed until the user closes it.
## Change language
```lua
notifications:setLanguage(languageCode)
```
# Example
```lua
require "Notification"

ui = ImGui.new()
stage:addChild(ui)
notifications = Notifications.new(ui)


function onEnterFrame(e)
	ui:newFrame(e.deltaTime)
	
	if (ui:button("Add")) then 
		notifications:add(
				Notifications.WARNING, -- message type
				"", -- Default title
				"You've lost your connection", 
				2, -- wait 2 seconds
				Notifications.BOTTOM | Notifications.LEFT -- show in bottom left corner
			)
	end
	notifications:draw()
	
	ui:render()
	ui:endFrame()
end
stage:addEventListener("enterFrame", onEnterFrame)
```