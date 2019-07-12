local composer = require( "composer" )
 
local scene = composer.newScene()

local widget = require( "widget" )
local ircSockets = require("ircSockets")

-- create()
function scene:create( event )
  sceneGroup = self.view
  
	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( 1 )	-- white
	sceneGroup:insert( background )
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 
local prevUser = nil
function selectUserListener( event )
  if event.phase == "began" then
    event.target:setFillColor( 1, 0.6, 0.15, 1 )
  elseif event.phase == "ended" then
    if event.target.id == prevUser then
      event.target:setFillColor( 1, 0.8, 0.25, 1 )
      prevUser = nil
      ircSockets.selectUser(nil)
      return
    end
    event.target:setFillColor( 0.1, 0.9, 0.2, 1 )
    if prevUser ~= nil then
      for i=2, scene.view.numChildren do
        if scene.view[i].id == prevUser then
          scene.view[i]:setFillColor( 1, 0.8, 0.25, 1 )
          scene.view[i]:setEnabled(true)
        end
      end
    end
    prevUser = event.target.id
    if prevUser:sub(1, 1) == "@" then
      ircSockets.selectUser(prevUser:sub(2))
    else
      ircSockets.selectUser(prevUser)
    end
  end
end
 
 local buttans = {}
-- show()
function scene:show( event )
  sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
      -- Code here runs when the scene is still off screen (but is about to come on screen)
    for k, v in pairs(ircSockets.channelUsers()) do
      local selectUser = widget.newButton(
        {
          id = v,
          label = v,
          x = display.contentCenterX,
          y = 60 + 40 * k,
          width = display.contentWidth,
          height = 40,
          strokeColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
          strokeWidth = 1,
          emboss = false,
          shape = "rect",
          onEvent = selectUserListener
        }
      )
      sceneGroup:insert(selectUser)
      table.insert(buttans, selectUser)
      if prevUser == v then
        selectUser:setFillColor( 0.1, 0.9, 0.2, 1 )
      else
        selectUser:setFillColor( 1, 0.8, 0.25, 1 )
      end
    end
  elseif ( phase == "did" ) then
      -- Code here runs when the scene is entirely on screen
  end
end
 
 
-- hide()
function scene:hide( event )
  sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
      -- Code here runs when the scene is on screen (but is about to go off screen)

  elseif ( phase == "did" ) then
      -- Code here runs immediately after the scene goes entirely off screen
    for k, v in pairs(buttans) do
      v:removeSelf()
    end
    buttans = {}
  end
end
 
 
-- destroy()
function scene:destroy( event )
  sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene