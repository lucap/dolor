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
        if cell.open and Math.random() >= .95
          color = '#'+Math.floor(Math.random()*16777215).toString(16)
          Cells.update(cell._id, {$set: {color: color}})
      ) 
  , 500)

  Meteor.startup( ->
    Cells.remove({})
    for i in [0..99]
      Cells.insert({color: DEFAULT_COLOR, position: i, open: true})
  )


    