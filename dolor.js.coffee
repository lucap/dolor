COLORS = ["yellow", "orange", "red", "pink", "purple"]

Cells = new Meteor.Collection('cells')

if Meteor.isClient
  Meteor.startup( ->
    cell_id = Session.get('cell_id')
    if !cell_id
      cell_id = Cells.insert({color: "cyan"})
    Session.set('cell_id', cell_id)
  )
  
  Template.palette.colors = -> 
    COLORS

  Template.palette.events
    'click, touchstart': (evt) ->
      $this = $(evt.target)
      selected_color = $this.css('background-color')
      Cells.update(Session.get('cell_id'), {color: selected_color})

  Template.cells.colors = -> 
    cells = Cells.find({})
    console.log cells
    cells

if Meteor.isServer
  Meteor.startup( ->
    {}
  )