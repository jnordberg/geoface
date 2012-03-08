async = require 'async'

RADIUS = 6378135

_deg2rad = (v) -> (v / 180.0) * Math.PI

distance = (p1, p2) ->
  # Great circle distance between two points (law of cosines).
  # The 2D great-circle distance between the two given points, in meters.
  [p1lat, p1lon] = _deg2rad p1[0], _deg2rad p1[1]
  [p2lat, p2lon] = _deg2rad p2[0], _deg2rad p2[1]
  angle = (Math.sin(p1lat) * Math.sin(p2lat) +
           Math.cos(p1lat) * Math.cos(p2lat) *
           Math.cos(p2lon - p1lon))
  return RADIUS * Math.acos(Math.min(Math.max(angle, -1.0), 1.0))

class __Search
  threshold: base: 100, max: 500

  constructor: (@user, @waitlist) ->

  _threshold: (tolerance) ->
    delta = @threshold.max - @threshold.base
    return @threshold.base + tolerance * delta

  first: (callback, tolerance = 0.0) ->
    threshold = @_threshold(tolerance)
    async.sortBy waitlist, @score, (err, results) -> callback(err, results[0])

class Waitlist
  constructor: (users = []) ->
    @_users = []
    for user in users
      @_users[user.uid] = user

  add: (user) ->
    @_users[user.uid] = user

  search: (user, callback) ->
    score = (other, callback) -> callback null, distance(user.point, other.point)
    async.sortBy (@_users[u] for u of @_users), score, (err, results) =>
      for user in results
        delete @_users[user.uid]
        return callback user
      return callback null

exports.Waitlist = Waitlist
