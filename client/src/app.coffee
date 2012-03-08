
{View} = require './view.coffee'
{EventEmitter} = require './event.js'
require './common.coffee'

class TopBar extends View

  template: """
    <section class="top-bar">
      <button name="friend">Beocme friends</button>
      <h1>face2face</h1>
      <button name="next">Next</button>
    </section>
  """

  setupElement: (element) ->
    element.getElement 'button[name=friend]', (event) =>
      event.preventDefault()
      @emit 'friend'
    element.getElement 'button[name=next]', (event) =>
      event.preventDefault()
      @emit 'next'

TopBar.implements EventEmitter

class InputBar extends View

  template: """
    <section class="input-bar">
      <div class="image"></div>
      <div class="input">
        <input type="text" name="message">
        <button name="send">Send</button>
      </div>
    </section>
  """

  setupElement: (element) ->
    input = element.getElement 'input'
    input.addEvent 'keydown', @keyhandler
    button = element.getElement 'button'
    button.addEvent 'click', @sendMessage

  keyhandler: (event) =>
    if event.key == 'enter'
      event.stop()
      @sendMessage @toElement().getElement('input').get('text')

  button: (event) =>
    event.preventDefault()
    @sendMessage @toElement().getElement('input').get('text')

  sendMessage: (message) ->
    if message.length > 2
      @emit 'message', message
    else
      # TODO

class MessageFeed extends View

  template: """
    <section class="message-feed">
      <ul></ul>
    </section>
  """

  buildMessage: (message, userInfo) ->
    item = new Element 'li'
    item.adopt new Element 'img',
      src: "https://graph.facebook.com/#{ userInfo.id }/picture"
    item.adopt new Element 'span',
      class: 'name'
      text: "#{ userInfo.first_name } #{ userInfo.last_name }"
    item.adopt new Element 'span',
      class: 'message'
      text: message
    return item

  addMessage: (message, userInfo) ->
    list = @toElement().getElement 'ul'
    list.adopt @buildMessage message, userInfo

  clear: ->
    list = @toElement().getElement 'ul'
    list.empty()

class App

  constructor: ->
    @socket = io.connect 'http://localhost'
    @socket.on 'start', @onStart

    @bar = new TopBar
    @input = new InputBar
    @messages = new MessageFeed

    @socket.on 'chat', (userID, message) =>
      @messages.addMessage message, @user

    @bar.toElement().inject document.body
    @input.toElement().inject document.body
    @messages.toElement().inject document.body
    @initFB()
    @initGeo()

  initFB: ->
    FB.init
      appId: '126843457444833'
      status: true
      cookie: true
      xfbml: true
      oauth: true
    FB.getLoginStatus @loginHandler

  loginHandler: (response) =>
    if response.status is 'connected'
      @didLogin response.authResponse
    else
      @login()

  login: ->
    FB.login @handleStatusChange,
      scope: 'user_about_me'

  didLogin: (authResponse) ->
    FB.api '/me', (response) =>
      @setUser response

  setUser: (@user) ->
    @tellBackend()

  initGeo: ->
    if not navigator.geolocation?
      alert 'Your device does not support geolocation :-('
    navigator.geolocation.getCurrentPosition @setLocation, ->
      alert 'Could not retrieve your position :-('

  setLocation: (@location) =>
    @tellBackend()

  tellBackend: ->
    if @location? and @user?
      console.log 'telling server', @location, @user
      @socket.emit 'hello',
        user: @user
        location: @location

  onStart: (userID, @toUserInfo) ->











exports.App = App;
