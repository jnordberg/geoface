
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
    button.addEvent 'click', @button

  keyhandler: (event) =>
    if event.key == 'enter'
      event.stop()
      @sendMessage @toElement().getElement('input').get('value')

  button: (event) =>
    event.preventDefault()
    @sendMessage @toElement().getElement('input').get('value')
    @toElement().getElement('input').set 'value', ''

  sendMessage: (message) =>
    @emit 'message', message


InputBar.implements EventEmitter

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

MessageFeed.implements EventEmitter

class MainView extends View

  template: """
    <section class="app">
      <div class="login visible">
        <p>Chat with random peaople nearby</p>
        <button>Login</button>
      </div>
      <div class="chat"></div>
    </section>
  """

  constructor: (@app) ->
    @bar = new TopBar
    @input = new InputBar
    @messages = new MessageFeed

    @app.socket.on 'privmsg', (userID, message) =>
      @messages.addMessage message, @app.toUserInfo

    @input.on 'message', (message) =>
      @app.socket.emit 'privmsg', @app.toUserInfo.id, message

  setupElement: (element) ->
    element.getElement('button').addEvent 'click', (event) =>
      event.preventDefault()
      @app.login()
    chat = element.getElement '.chat'
    @bar.toElement().inject chat
    @input.toElement().inject chat
    @messages.toElement().inject chat

  lookingForUser: ->
    p = @toElement().getElement '.login p'
    p.set 'text', 'Looking for chat-partner...'

  showChat: ->
    el = @toElement()
    el.getElement('.login').removeClass('visible')
    el.getElement('.chat').addClass('visible')


class App

  constructor: ->
    @socket = io.connect 'http://localhost'
    @socket.on 'knock', @onStart

    @main = new MainView @
    @main.toElement().inject document.body

    window.fbAsyncInit = @initFB
    @initGeo()

  initFB: =>
    FB.init
      appId: '126843457444833'
      status: true
      cookie: true
      xfbml: true
      oauth: true
    #FB.Event.subscribe 'auth.authResponseChange', @loginHandler
    FB.getLoginStatus @loginHandler

  loginHandler: (response) =>
    console.log 'loginHandler', response
    if response.status is 'connected'
      @didLogin response.authResponse

  login: ->
    console.log 'logging in'
    FB.login (->),
      scope: 'user_about_me'

  didLogin: (authResponse) ->
    FB.api '/me', (response) =>
      @setUser response

  setUser: (@user) ->
    @tellBackend()
    @main.lookingForUser()

  initGeo: ->
    if not navigator.geolocation?
      alert 'Your device does not support geolocation :-('
    navigator.geolocation.getCurrentPosition @setLocation, ->
      alert 'Could not retrieve your position :-('

  setLocation: (@location) =>
    @tellBackend()

  tellBackend: ->
    if @location? and @user?
      @socket.emit 'hello',
        user: @user
        location: @location

  onStart: (@toUserInfo) =>
    @toUserInfo = @user
    @main.showChat()








exports.App = App;
