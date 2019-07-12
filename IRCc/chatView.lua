local composer = require( "composer" )
local scene = composer.newScene()

local ircSockets = require "ircSockets"

--Logic
local chatOutput = native.newTextBox( display.contentCenterX, display.contentCenterY + 20, display.contentWidth, display.contentHeight - 50 - 70 )
local userInput = native.newTextField( display.contentCenterX, display.contentHeight - 25, display.contentWidth, 50 )
chatOutput.isEditable = false
--chatOutput:addEventListener("touch", function(e) return false end)
--chatOutput:addEventListener("tap", function(e) return false end)
--chatOutput:addEventListener("click", function(e) return false end)
local function addLineToOutput( text )
  chatOutput.text = chatOutput.text .. text .. "\n"
  chatOutput:setSelection( chatOutput.text:len(), chatOutput.text:len())
end
local function clearOutput()
  chatOutput.text = ""
end

local function textListener( event )
  if ( event.phase == "submitted" ) then
    ircSockets.send(event.target.text)
    event.target.text = ""
  end
end

function scene:create( event )
	local sceneGroup = self.view
	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( 1 )	-- white
	
  userInput:addEventListener( "userInput", textListener )
  ircSockets.setReceived(addLineToOutput)
  ircSockets.clearReceived(clearOutput)
	
	sceneGroup:insert( background )
  sceneGroup:insert( userInput )
  sceneGroup:insert( chatOutput )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
    for i = 1, sceneGroup.numChildren do
      sceneGroup[i].isVisible = true
    end
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
    for i = 1, sceneGroup.numChildren do
      sceneGroup[i].isVisible = false
    end
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

function scene:key(event)
  if ( event.keyName == "back" ) then
    composer.gotoScene( "connectView" )
  end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
