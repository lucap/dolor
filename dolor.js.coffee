Cells = new Meteor.Collection('cells')

if Meteor.isClient

  current_color = 'cyan'

  Meteor.startup( ->

    cell_id = Session.get('cell_id')
    if !cell_id
      cell_id = Cells.insert({color: "cyan"})
    Session.set('cell_id', cell_id)

    settings = 
      control: "wheel"
      inline: true
      changeDelay: 100
      change: (hex) ->
        Cells.update(Session.get('cell_id'), {color: hex})

    $('#colorpicker').minicolors(settings)
  )

  Meteor.setInterval( ->
    Meteor.call('keepalive', Session.get('cell_id'))
  , 5000)

  Template.cells.colors = -> 
    Cells.find({})

if Meteor.isServer
  Connections = new Meteor.Collection('connections')

  Meteor.methods(
    keepalive: (cell_id) ->
      if !Connections.findOne({cell_id: cell_id})
        Connections.insert({cell_id: cell_id})
      Connections.update({cell_id: cell_id}, {$set: {last_seen: (new Date()).getTime()}})
  )

  Meteor.setInterval( ->
    now = (new Date()).getTime()
    Connections.find({last_seen: {$lt: (now - 60 * 1000)}}).forEach( (connection)->
      Connections.remove(connection._id)
      Cells.remove(connection.cell_id)
    )
  , 5000)

  Meteor.startup( ->

  )