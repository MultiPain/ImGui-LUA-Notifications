# API
## Constructor
```lua
notifications = Notifications.new(ImGuiInstance [, iconsTable, languageCode])
```

|  Argument |  Description |  Example |
| ------------ | ------------ | ------------ |
| iconsTable | table that contains icons characters | ``` { Success = utf8.char(0xe86c), Warning = utf8.char(0xf083), Error = utf8.char(0xe888), Info = utf8.char(0xe88e) }```<br/>Icons font: "MaterialIconsRound-Regular" from Google|
| languageCode | Used to display default title<br/>Edit "**Notifications.TRANSLATION**" variable in "**Notification.lua**" | "en-EN", "fr-FR" etc. |

## Push new notification
```lua
notifications:add([windowType, title, content, waitTime, positionFlags])
```
| Argument | Description | Values |
| ------------ | ------------ | ------------ |
| windowType (**string**) | Type of the notification window. Different types have different title color (default: Notifications.NONE) |  Notifications.NONE , Notifications.SUCCESS , Notifications.WARNING , Notifications.ERROR , Notifications.INFO | |
| title (**string**) | window title (if empty of nil, uses default name depending on windowType) | any |
| content (**string**) | shown message (default: "") | any |
| waitTime (**number**) | window display time in seconds (default: 4) | any > 0 |
| positionFlags (**number**) | can be mixed with logical OR operator (default: bottom right) | Notifications.TOP, Notifications.LEFT, Notifications.BOTTOM, Notifications.RIGHT |
```lua
notifications:addCloseable([windowType, title, content, waitTime, position])
```
Same as above, but the window is displayed until the user closes it.\
**Does not work properly when only title is displayed** _(WIP)_
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
