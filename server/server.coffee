
sio = require 'socket.io'
logger = require 'winston'
static = require 'node-static'
http = require 'http'

# static server
fileServer = new static.Server './../client'
server = http.createServer (request, response) ->
  request.addListener 'end', ->
    fileServer.serve request, response

# setup websocket server
sio = sio.listen server
server.listen 8080

sio.sockets.on 'connection', (socket) ->
  # make it go
  socket.on 'message', (args...) ->
    console.log 'client said', args.join ', '
