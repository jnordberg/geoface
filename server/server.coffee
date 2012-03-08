
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
  {id: "516251607", point: [59.33630, 18.02872]},
  {id: "123123", point: [59.31090, 18.08367]},
  {id: "123124", point: [59.312569, 18.09267]},
  {id: "123125", point: [65.640457, 22.012873]}]

clients = {}

new_client = (socket) ->

  clients[socket.id] = {id: socket.id, socket: socket}

  socket.on 'hello', (info) ->

    user = id: socket.id, point: [info.location.coords.latitude, info.location.coords.longitude]
    client = clients[socket.id]
    client.info = info

    wait.search user, (mate) ->
      console.log('blah')

      if not mate?
        console.log('wait add')
        wait.add user

      else
        mate = clients[mate.id]
        console.log('do it', client.id, mate.id)
        client.mate = mate
        mate.mate = client
        client.socket.emit 'knock', {id: mate.id, info: mate.info}
        mate.socket.emit 'knock', {id: client.id, info: client.info}

  socket.on 'privmsg', (id, msg) ->
    console.log(id, msg)
    recipient = clients[id]
    recipient.socket.emit('privmsg', id, msg)

  #socket.on 'message', (args...) ->
  #  console.log 'client said', args.join ', '
  #  user = id: "666", point: [55, 18]

sio.sockets.on 'connection', new_client
