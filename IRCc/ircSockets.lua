local socket = require( "socket" )
local export = {}

connections = {}
selectedServer = nil
serverChannels = {}
joinedChannels = {}
selectedChannel = nil
channelUsers = {}
selectedUser = nil

received = function(text) print("???") end
clear = function(text) print("???") end

function connect( serverAddr, serverPort, serverPass, userNick, userName, userReal )
  local sock = socket.tcp()
  sock:settimeout(10)
  local success, err = sock:connect(serverAddr.text, tonumber(serverPort.text))
  if success == nil then
    print(err)
    connectBt:setEnabled( true )
    connectBt:setFillColor( 1, 0, 0, 1 )
    connectBt:setStrokeColor( 1, 0, 0, 1 )
    return nil, err
  end
  
  local message, err1, partial = sock:receive() --looking up hostname
  if message == nil then
    print(err)
    sock:close()
    return nil, err
  end
  message, err1, partial = sock:receive() --found hostname
  if message == nil then
    print(err)
    sock:close()
    return nil, err
  end
  
  sock:send( "PASS " .. serverPass.text .. "\r\n" )
  sock:send( "NICK " .. userNick.text .. "\r\n" )
  sock:send( "USER " .. userName.text .. " 0 * :" .. userReal.text .. "\r\n" )
  
  message, err1, partial = sock:receive() --welcome
  if message == nil then
    print(err)
    sock:close()
    return nil, err
  end
  local parts = {}
  for i in message:gmatch("(%S+)") do
    table.insert(parts, i)
  end
  --print(table.concat(parts, " ")) --parts[6] <=== 1 ir 12 char yra 0x02
  local serverName = parts[1]:sub(2)
  
  sock:settimeout(0)
  table.insert(connections, {tcpSock = sock, addr = serverAddr.text, port = tonumber(serverPort.text), pass = serverPass.text, serverName = serverName, nick = userNick.text, name = userName.text, real = userReal.text})
  
  if selectedServer == nil then
    selectServer(table.maxn(connections))
  end

  return serverName
end

function parseMsg(conId, msg)
  print(msg)
  local parts = {}
  for i in msg:gmatch("(%S+)") do
    table.insert(parts, i)
  end
  if parts[1] == "PING" then
    connections[conId].tcpSock:send( "PONG " .. connections[conId].nick .. "\r\n" )
  elseif parts[2] == "321" then
    serverChannels = {}
  elseif parts[2] == "322" then
    local chan = {channelName = parts[4], userCount = parts[5], channelTopic = parts[6]:sub(2)}
    table.insert(serverChannels, chan)
  elseif parts[2] == "323" then
    if selectedChannel ~= nil then
      for k, v in pairs(serverChannels) do
        if v.channelName == selectedChannel then
          return
        end
      end
      selectedChannel = nil
    end
  elseif parts[2] == "353" then
    channelUsers = {}
    for i=7, table.maxn(parts) do
      table.insert(channelUsers, parts[i])
    end
  elseif parts[2] == "JOIN" then
    local senderNick = parts[1]:match(":(.+)!")
    --local senderUser = parts[1]:match("!(.+)@")
    --local senderHost = parts[1]:match("@(.+)")
    if connections[conId].nick ~= senderNick then
      table.insert(channelUsers, senderNick)
    end
  elseif parts[2] == "PRIVMSG" then
    local recipient = parts[3]
    local senderNick = parts[1]:match(":(.+)!")
    --local senderUser = parts[1]:match("!(.+)@")
    --local senderHost = parts[1]:match("@(.+)")
    if (selectedUser ~= nil and selectedUser == senderNick and recipient == connections[conId].nick) or (selectedUser == nil and selectedChannel == recipient) then
      received(senderNick .. "  | " .. msg:match(" :(.+)"))
    end
  elseif parts[2] ~= "366" then
    received("Unparsed= " .. msg)
  end
end

function receive( conIndex )
  local connection = connections[conIndex]
  local message, err, partial = connection.tcpSock:receive()
  if message == nil then
    if err == "closed" then
      table.remove(connections, conIndex).tcpSock:close()
      print("rip")
      return
    elseif err == "timeout" then
      return
    end
  end
  
  while message ~= nil do
    parseMsg(conIndex, message)
    message, err, partial = connection.tcpSock:receive()
    if message == nil then
      if err == "closed" then
        table.remove(connections, conIndex).tcpSock:close()
        print("rip")
        return
      end
    end
  end
end

function parseAll()
  while true do
    for k, v in pairs(connections) do
      receive(k)
      coroutine.yield()
    end
    coroutine.yield()
  end
end

function send(text)
  if text:sub(1, 1) == "/" then
    connections[selectedServer].tcpSock:send(text:sub(2) .. "\r\n")
  elseif selectedChannel ~= nil then
    if selectedUser ~= nil then
      connections[selectedServer].tcpSock:send("PRIVMSG " .. selectedUser .. " :" .. text .. "\r\n")
    else
      connections[selectedServer].tcpSock:send("PRIVMSG " .. selectedChannel .. " :" .. text .. "\r\n")
    end
    received(connections[selectedServer].nick .. "  | " .. text)
  else
    received("ERROR: no channel joined!")
  end
end


function selectServer(id)
  selectedServer = id
  connections[selectedServer].tcpSock:send("LIST " .. "\r\n")
  clear()
  selectedChannel = nil
  selectedUser = nil
end

function selectChannel(chan)
  clear()
  selectedChannel = chan
  selectedUser = nil
  if chan ~= nil then
    for k, v in pairs(joinedChannels) do
      if v == chan then
        return
      end
    end
    connections[selectedServer].tcpSock:send("JOIN " .. chan .. "\r\n")
    table.insert(joinedChannels, chan)
  end
end

function selectUser(user)
  clear()
  selectedUser = user
end



export.connect = connect
export.parseAll = parseAll
export.connections = function() return connections end
export.selectServer = selectServer
export.selectedServer = function() return selectedServer end
export.serverChannels = function() return serverChannels end
export.selectChannel = selectChannel
export.joinedChannels = function() return joinedChannels end
export.channelUsers = function() return channelUsers end
export.selectUser = selectUser

export.setReceived = function(fn) received = fn end
export.clearReceived = function(fn) clear = fn end
export.send = send
return export