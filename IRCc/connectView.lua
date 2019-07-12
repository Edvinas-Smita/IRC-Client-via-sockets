local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local ircSockets = require( "ircSockets" )

local errText = nil

function scene:create( event )
	sceneGroup = self.view
	
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	-- create a white background to fill screen
	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( 1 )	-- white
	sceneGroup:insert( background )
  
  --inputs
  serverAddr = native.newTextField( display.contentCenterX + 80, 125, display.contentWidth - 180, 50 )
  serverPort = native.newTextField( display.contentCenterX + 80, 200, display.contentWidth - 180, 50 )
  serverPass = native.newTextField( display.contentCenterX + 80, 275, display.contentWidth - 180, 50 )
  userNick = native.newTextField( display.contentCenterX + 80, 500, display.contentWidth - 180, 50 )
  userName = native.newTextField( display.contentCenterX + 80, 575, display.contentWidth - 180, 50 )
  userReal = native.newTextField( display.contentCenterX + 80, 650, display.contentWidth - 180, 50 )
  
  serverPort.inputType = "number"
  serverPass.isSecure = true
  
  --debug
    serverAddr.text = "localhost"
    serverPort.text = "10203"
    serverPass.text = "abcd"
    userNick.text = "testNickPC"
    userName.text = "testName"
    userReal.text = "testReal"
  --
  
  serverAddr:addEventListener( "userInput", defaultListener )
  serverPort:addEventListener( "userInput", defaultListener )
  serverPass:addEventListener( "userInput", defaultListener )
  userNick:addEventListener( "userInput", defaultListener )
  userName:addEventListener( "userInput", defaultListener )
  userReal:addEventListener( "userInput", defaultListener )
  
  sceneGroup:insert( serverAddr )
  sceneGroup:insert( serverPort )
  sceneGroup:insert( serverPass )
  sceneGroup:insert( userNick )
  sceneGroup:insert( userName )
  sceneGroup:insert( userReal )
  --
  
  --labels
  local lAddr = display.newText( { text = "Server address:", x = 0, y = 135, width = 340, height = 50, font = native.systemFont, fontSize = 20, align = "right" } )
  local lPort = display.newText( { text = "Server port:", x = 0, y = 210, width = 340, height = 50, font = native.systemFont, fontSize = 20, align = "right" } )
  local lPass = display.newText( { text = "Server password:", x = 0, y = 285, width = 340, height = 50, font = native.systemFont, fontSize = 20, align = "right" } )
  local lNick = display.newText( { text = "Your nickname:", x = 0, y = 510, width = 340, height = 50, font = native.systemFont, fontSize = 20, align = "right" } )
  local lName = display.newText( { text = "Your name:", x = 0, y = 585, width = 340, height = 50, font = native.systemFont, fontSize = 20, align = "right" } )
  local lReal = display.newText( { text = "Your real name:", x = 0, y = 660, width = 340, height = 50, font = native.systemFont, fontSize = 20, align = "right" } )
  
  lAddr:setFillColor( 0 )
  lPort:setFillColor( 0 )
  lPass:setFillColor( 0 )
  lNick:setFillColor( 0 )
  lName:setFillColor( 0 )
  lReal:setFillColor( 0 )
  
  sceneGroup:insert( lAddr )
  sceneGroup:insert( lPort )
  sceneGroup:insert( lPass )
  sceneGroup:insert( lNick )
  sceneGroup:insert( lName )
  sceneGroup:insert( lReal )
  --
  
  connectBt = widget.newButton(
    {
      label = "CONNECT",
      x = display.contentCenterX,
      y = display.contentHeight - 150,
      width = 200,
      height = 40,
      cornerRadius = 2,
      strokeWidth = 4,
      emboss = false,
      shape = "roundedRect",
      onEvent = connectFn
    }
  )
  connectBt:setFillColor( 1, 0.8, 0.25, 1 )
  connectBt:setStrokeColor( 1, 0.8, 0.25, 1 )
  sceneGroup:insert( connectBt )
  
  
  errText = display.newText(
    {
      text = "",
      x = display.contentCenterX,
      y = display.contentHeight - 70,
      width = display.contentWidth,
      height = 60,
      font = native.systemFont,
      fontSize = 20,
      align = "center"
    }
  )
  errText:setFillColor(1, 0, 0, 1)
  sceneGroup:insert(errText)
end

function defaultListener( event )
  if ( event.phase == "editing" ) then
    connectBt:setFillColor( 1, 0.8, 0.25, 1 )
    connectBt:setStrokeColor( 1, 0.8, 0.25, 1 )
    if errText.text ~= "" then
      errText.text = ""
    end
  end
end

function connectFn( event )
  if event.phase == "began" then
    connectBt:setFillColor( 1, 0.6, 0.15, 1 )
    connectBt:setStrokeColor( 1, 1, 1, 1 )
  elseif event.phase == "ended" then
    connectBt:setEnabled( false )
    connectBt:setFillColor( 0.5, 0.5, 0.5, 1 )
    connectBt:setStrokeColor( 0.5, 0.5, 0.5, 1 )
    
    local serverName, err = ircSockets.connect(serverAddr, serverPort, serverPass, userNick, userName, userReal)
    connectBt:setEnabled( true )
    connectBt:setFillColor( 0.1, 0.9, 0.2, 1 )
    connectBt:setStrokeColor( 0.1, 0.9, 0.2, 1 )
    if serverName == nil then
      connectBt:setFillColor( 1, 0, 0, 1 )
      connectBt:setStrokeColor( 1, 0, 0, 1 )
      errText.text = err
    end
  end
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
    for i = 1, sceneGroup.numChildren do
      sceneGroup[i].isVisible = true
    end
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
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

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene