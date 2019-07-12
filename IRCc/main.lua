-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- show default status bar (iOS)
display.setStatusBar( display.DefaultStatusBar )

-- include Corona's "widget" library
local widget = require "widget"
local composer = require "composer"

local ircSockets = require "ircSockets"

-- event listeners for tab buttons:
local function onConnectView( event )
	composer.gotoScene( "connectView" )
  current_scene_no = 1
end

local function onServerView( event )
	composer.gotoScene( "serverView" )
  current_scene_no = 2
end

local function onChannelView( event )
	composer.gotoScene( "channelView" )
  current_scene_no = 3
end

local function onUsersView( event )
	composer.gotoScene( "usersView" )
  current_scene_no = 4
end

local function onChatView( event )
	composer.gotoScene( "chatView" )
  current_scene_no = 5
end


-- create a tabBar widget with two buttons at the bottom of the screen

-- table to setup buttons
local tabButtons = {
	{ label="Connect", defaultFile="connect.png", overFile="connect-down.png", width = 40, height = 40, onPress=onConnectView, selected=true },
	{ label="Servers", defaultFile="server.png", overFile="server-down.png", width = 40, height = 40, onPress=onServerView },
  { label="Channels", defaultFile="channel.png", overFile="channel-down.png", width = 40, height = 40, onPress=onChannelView },
  { label="Users", defaultFile="users.png", overFile="users-down.png", width = 40, height = 40, onPress=onUsersView },
  { label="Chat", defaultFile="chat.png", overFile="chat-down.png", width = 40, height = 40, onPress=onChatView },
}

-- create the actual tabBar widget
local tabBar = widget.newTabBar{
	top = 0,
	buttons = tabButtons,
  height = 80
}

onChatView()
onConnectView()	-- invoke first tab button's onPress event manually
scene_list = {"connectView", "serverView", "channelView", "usersView", "chatView"}
local function swipe_scene(event)
  if event.phase == "ended" then
    if (event.xStart < event.x and (event.x - event.xStart) >= 100 and current_scene_no > 1) then
      local options = {
        effect = "slideRight",
        time = 500
      };
      current_scene_no = current_scene_no - 1;
      tabBar:setSelected(current_scene_no)
      composer.gotoScene(scene_list[current_scene_no], options);
    elseif (event.xStart > event.x and (event.xStart - event.x) >= 100 and current_scene_no < #scene_list) then
      local options = {
        effect = "slideLeft",
        time = 500
      };
      current_scene_no = current_scene_no + 1;
      tabBar:setSelected(current_scene_no)
      composer.gotoScene(scene_list[current_scene_no], options);
  end
  end
  return true;
end

Runtime:addEventListener("touch", swipe_scene);
display.setStatusBar(display.HiddenStatusBar)

local parserCo = coroutine.create(ircSockets.parseAll)
local function timedParsing( event )
  --print("A")
  coroutine.resume(parserCo)
end
timer.performWithDelay(5, timedParsing, 0)