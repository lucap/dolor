DEFAULT_COLOR = 'white'

Cells = new Meteor.Collection('cells')


if Meteor.isClient
  grid = null

  Meteor.startup( ->
    Meteor.call 'get_cell', (e, r) ->
                  Session.set('cell_id', r._id)
                  Cells.update(r._id, {color: DEFAULT_COLOR})
                  
    settings = 
      control: "wheel"
      inline: true
      changeDelay: 10
      defaultValue: DEFAULT_COLOR
      change: (hex) ->
        Cells.update(Session.get('cell_id'), {color: hex})

    $('#colorpicker').minicolors(settings)
    grid = window.calendarWeekHour('#map', 400, 400, true)
  )

  Meteor.setInterval( ->
    Meteor.call('keepalive', Session.get('cell_id'))
  , 5000)

  Template.map.rendered = ->
    Deps.autorun ->
      cells = Cells.find({}).fetch()
      if cells.length > 0
        grid.selectAll("rect").transition()
                              .style('fill', (d) ->
                                            c = cells[d.count]
                                            if c
                                              c.color
                                            else 
                                              DEFAULT_COLOR)

if Meteor.isServer
  Connections = new Meteor.Collection('connections')

  Meteor.methods(
    keepalive: (cell_id) ->
      if !Connections.findOne({cell_id: cell_id})
        Connections.insert({cell_id: cell_id})
      Connections.update({cell_id: cell_id}, {$set: {last_seen: (new Date()).getTime()}})
  
    get_cell: ->
      cell = Cells.findOne({open: true})
      Cells.update(cell._id, {open: false, position: cell.position})
      cell
  )

  Meteor.setInterval( ->
    now = (new Date()).getTime()
    Connections.find({last_seen: {$lt: (now - 60 * 1000)}}).forEach( (connection)->
      Connections.remove(connection._id)
      Cells.update(connection.cell_id, {open: true, color: DEFAULT_COLOR})
    )
  , 5000)

  Meteor.setInterval( ->
    Cells.find().forEach( (cell) -> 
        if cell.open and Math.random() >= .98
          color = hsb2hex({h: Math.random() * 360, s: Math.random() * 90, b: 100})
          Cells.update(cell._id, {$set: {color: color}})
      ) 
  , 2000)

  Meteor.startup( ->
    Cells.remove({})
    for i in [0..99]
      Cells.insert({color: DEFAULT_COLOR, position: i, open: true})
  )

hsb2rgb = (hsb) ->
  rgb = {}
  h = Math.round(hsb.h)
  s = Math.round(hsb.s * 255 / 100)
  v = Math.round(hsb.b * 255 / 100)
  if s is 0
    rgb.r = rgb.g = rgb.b = v
  else
    t1 = v
    t2 = (255 - s) * v / 255
    t3 = (t1 - t2) * (h % 60) / 60
    h = 0  if h is 360
    if h < 60
      rgb.r = t1
      rgb.b = t2
      rgb.g = t2 + t3
    else if h < 120
      rgb.g = t1
      rgb.b = t2
      rgb.r = t1 - t3
    else if h < 180
      rgb.g = t1
      rgb.r = t2
      rgb.b = t2 + t3
    else if h < 240
      rgb.b = t1
      rgb.r = t2
      rgb.g = t1 - t3
    else if h < 300
      rgb.b = t1
      rgb.g = t2
      rgb.r = t2 + t3
    else if h < 360
      rgb.r = t1
      rgb.g = t2
      rgb.b = t1 - t3
    else
      rgb.r = 0
      rgb.g = 0
      rgb.b = 0
  r: Math.round(rgb.r)
  g: Math.round(rgb.g)
  b: Math.round(rgb.b)

rgb2hex = (rgb) ->
  hex = [rgb.r.toString(16), rgb.g.toString(16), rgb.b.toString(16)]
  _.each hex, (nr, val) ->
    hex[nr] = "0" + val  if val.length is 1

  "#" + hex.join("")

hsb2hex = (hsb) ->
  rgb2hex hsb2rgb(hsb)
    