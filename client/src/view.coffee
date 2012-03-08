
class View

  template: "<div></div>"

  setupElement: (element) ->

  setElement: (element) ->
    @element = element
    @setupElement @element

  getElement: ->
    if not @element
      @setElement @buildElement()
    @element

  buildElement: ->
    tmp = document.createElement 'div'
    tmp.innerHTML = @template
    return tmp.querySelector '*'

  destroy: ->
    if @element
      @element.destroy()
      @element = undefined

exports.View = View

# alias for mootools
View.prototype.toElement =  View.prototype.getElement
