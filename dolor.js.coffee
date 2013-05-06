COLORS = ["yellow", "orange", "red", "pink"]
Cells = new Meteor.Collection('cells')

if Meteor.isClient
  Meteor.subscribe('cells')

  Template.palette.colors = -> 
    COLORS

  Template.palette.events
    'click, touchstart': (evt) ->
      $this = $(evt.target)
      selected_color = $this.css('background-color')

      cell =  Cells.findOne()
      Cells.update(cell._id, {color: selected_color})

  Template.colors.color = -> 
    cell =  Cells.findOne()
    if cell
      return cell.color
    else
      return "black"

if Meteor.isServer
  Meteor.startup( ->
    if not Cells.findOne({})
      Cells.insert({color: "black"})
  )

  Meteor.publish "cells", ->
    Cells.findOne({})