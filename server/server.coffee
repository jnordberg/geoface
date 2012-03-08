
sio = require 'socket.io'
logger = require 'winston'
static = require 'node-static'
http = require 'http'
waitlist = require './waitlist.coffee'

# static server
fileServer = new static.Server './../client'
server = http.createServer (request, response) ->
  request.addListener 'end', ->
    fileServer.serve request, response

# setup websocket server
sio = sio.listen server
server.listen 8080

wait = new waitlist.Waitlist

[
  {uid: "516251607", point: [59.33630, 18.02872]},
  {uid: "123123", point: [59.31090, 18.08367]},
  {uid: "123124", point: [59.312569, 18.09267]},
  {uid: "123125", point: [65.640457, 22.012873]}]

clients = {}

new_client = (socket) ->

  socket.on 'hello', (info) ->

    user = uid: info.user.id, point: [info.location.coords.latitude, info.location.coords.longitude]
    clients[user.uid] = client = {user: user, info: info, socket: socket}

    wait.search user, (mate) ->
      console.log('blah')

      if not mate?
        console.log('wait add')
        wait.add user

      else
        console.log('do it')
        console.log user, mate
        client.mate = mate
        mate.mate = mate
        client.socket.emit 'knock', clients[mate.uid].info
        clients[mate.uid].socket.emit info

  socket.on 'privmsg', (uid, msg) ->
    recipient = clients[uid]
    recipient.socket.emit('privmsg', uid, msg)

  #socket.on 'message', (args...) ->
  #  console.log 'client said', args.join ', '
  #  user = uid: "666", point: [55, 18]

sio.sockets.on 'connection', new_client
