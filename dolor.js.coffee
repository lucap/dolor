DEFAULT_COLOR = 'black'

Cells = new Meteor.Collection('cells')

if Meteor.isClient

  Meteor.startup( ->
    Meteor.call 'get_cell', (e, r) ->
                  Session.set('cell_id', r._id)
                  
    settings = 
      control: "wheel"
      inline: true
      changeDelay: 10
      defaultValue: DEFAULT_COLOR
      change: (hex) ->
        Cells.update(Session.get('cell_id'), {color: hex})

    $('#colorpicker').minicolors(settings)

  )

  Meteor.setInterval( ->
    Meteor.call('keepalive', Session.get('cell_id'))
  , 5000)

  Template.cells.colors = -> 
    Cells.find({}, sort="position")

  Template.map.rendered = ->
    window.calendarWeekHour('#map', 400, 400, true)

if Meteor.isServer
  Connections = new Meteor.Collection('connections')

  Meteor.methods(
    keepalive: (cell_id) ->
      if !Connections.findOne({cell_id: cell_id})
        Connections.insert({cell_id: cell_id})
      Connections.update({cell_id: cell_id}, {$set: {last_seen: (new Date()).getTime()}})
  
    get_cell: ->
      cell = Cells.findOne({open: true})
      Cells.update(cell._id, {open: false})
      cell
  )

  Meteor.setInterval( ->
    now = (new Date()).getTime()
    Connections.find({last_seen: {$lt: (now - 60 * 1000)}}).forEach( (connection)->
      Connections.remove(connection._id)
      Cells.update(connection.cell_id, {open: true, color: DEFAULT_COLOR})
    )
  , 5000)

  Meteor.startup( ->
    Cells.remove({})
    for i in [0..5]
      Cells.insert({color: DEFAULT_COLOR, position: i, open: true})
  )


    