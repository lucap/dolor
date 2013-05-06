COLORS = ["yellow", "orange", "red", "pink"]
Cells = new Meteor.Collection('cells')

if Meteor.isClient
  Meteor.subscribe('cells')


  Template.palette.colors = -> 
    COLORS

  Template.colors.color = -> 
    cell =  Cells.findOne()
    console.log "dt: ", cell
    if cell
      return COLORS[cell.color]
    else
      return "black"

  Template.colors.events
    'click, touchstart': (evt) ->
      cell =  Cells.findOne()
      console.log "db: ", cell.color
      if cell.color < (COLORS.length - 1)
        cell.color += 1
      else
        cell.color = 0
      #cell.color = (cell.color + 1) if cell.color < COLORS.length else 0
      Cells.update(cell._id, {color: cell.color})
      console.log "da: ", cell.color
      #console.log cells, evt.currentTarget.id
      #$this = $(evt.target)
      #console.log $this

      #$this.css("background-color", cell.color)
      #$this.toggleClass("orange")

if Meteor.isServer
  Meteor.startup( ->
    if not Cells.findOne({})
      Cells.insert({color: 0})
  )

  Meteor.publish "cells", ->
    Cells.findOne({})