
clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance

exports.clone = clone

extend = (obj, mixin) ->
  for name, method of mixin
    obj[name] = method

exports.extend = extend

implements = (classes...) ->
  for klass in classes
    # static properties
    for prop of klass
      @[prop] = klass[prop]
    # prototype properties
    for prop of klass.prototype
      getter = klass::__lookupGetter__(prop)
      setter = klass::__lookupSetter__(prop)
      if getter || setter
        @::__defineGetter__(prop, getter) if getter
        @::__defineSetter__(prop, setter) if setter
      else
        @::[prop] = klass::[prop]
  return this

if Object.defineProperty
  Object.defineProperty Function.prototype, 'implements', value: implements
else
  Function::implements = implements

exports.implements = implements
