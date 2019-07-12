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

local prevChan = nil
function selectChannelListener( event )
  if event.phase == "began" then
    event.target:setFillColor( 1, 0.6, 0.15, 1 )
  elseif event.phase == "ended" then
    if event.target.id == prevChan then
      event.target:setFillColor( 0.7, 0.8, 0.9, 1 )
      prevChan = nil
      ircSockets.selectChannel(nil)
      return
    end
    event.target:setFillColor( 0.1, 0.9, 0.2, 1 )
    if prevChan ~= nil then
      for i=2, scene.view.numChildren do
        if scene.view[i].id == prevChan then
          scene.view[i]:setFillColor( 0.7, 0.8, 0.9, 1 )
          scene.view[i]:setEnabled(true)
        end
      end
    end
    prevChan = event.target.id
    ircSockets.selectChannel(event.target.id)
  end
end
 
 local buttans = {}
-- show()
function scene:show( event )
  sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    --print((ircSockets.selectedChannel() or "none") .. ", +" .. table.concat(ircSockets.joinedChannels(), " +"))
    for k, v in pairs(ircSockets.serverChannels()) do
      --print(v.channelName)
      local selectChannel = widget.newButton(
        {
          id = v.channelName,
          label = v.channelName .. "  (" .. v.channelTopic .. ")  -" .. v.userCount,
          x = display.contentCenterX,
          y = 60 + 40 * k,
          width = display.contentWidth,
          height = 40,
          strokeColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
          strokeWidth = 1,
          emboss = false,
          shape = "rect",
          onEvent = selectChannelListener
        }
      )
      sceneGroup:insert(selectChannel)
      table.insert(buttans, selectChannel)
      if prevChan == v.channelName then
        selectChannel:setFillColor( 0.1, 0.9, 0.2, 1 )
      else
        selectChannel:setFillColor( 1, 0.8, 0.25, 1 )
        for k1, v1 in pairs(ircSockets.joinedChannels()) do
          if v.channelName == v1 then
            selectChannel:setFillColor( 0.7, 0.8, 0.9, 1 )
          end
        end
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