###
Source: http://bl.ocks.org/bunkat/2605010

calendarWeekHour    Setup a week-hour grid:
7 Rows (days), 24 Columns (hours)
param id           div id tag starting with #
param width        width of the grid in pixels
param height       height of the grid in pixels
param square       true/false if you want the height to
match the (calculated first) width
###
window.calendarWeekHour = (id, width, height, square) ->
  calData = randomData(width, height, square)
  console.log calData
  grid = d3.select(id).append("svg")
                      .attr("width", width)
                      .attr("height", height)
                      .attr("class", "chart")
  
  row = grid.selectAll(".row")
            .data(calData)
            .enter()
            .append("svg:g")
            .attr("class", "row")
  col = row.selectAll(".cell")
    .data((d) -> d)
    .enter()
    .append("svg:rect")
    .attr("class", "cell")
    .attr("x", (d) -> d.x)
    .attr("y", (d) -> d.y)
    .attr("width", (d) -> d.width)
    .attr("height", (d) -> d.height)
    .on("mouseover", -> d3.select(this).style "fill", "#0F0")
    .on("mouseout", -> d3.select(this).style "fill", "#FFF")
    .on("click", -> console.log d3.select(this))
    .style("fill", "#FFF").style("stroke", "#555")


###
randomData()        returns an array: [
[{id:value, ...}],
[{id:value, ...}],
[...],...,
];
~ [
[hour1, hour2, hour3, ...],
[hour1, hour2, hour3, ...]
]
###
randomData = (gridWidth, gridHeight, square) ->
  data = new Array()
  gridItemWidth = gridWidth / 24
  gridItemHeight = (if (square) then gridItemWidth else gridHeight / 7)
  startX = gridItemWidth / 2
  startY = gridItemHeight / 2
  stepX = gridItemWidth
  stepY = gridItemHeight
  xpos = startX
  ypos = startY
  newValue = 0
  count = 0
  index_a = 0

  while index_a < 7
    data.push new Array()
    index_b = 0

    while index_b < 24
      newValue = Math.round(Math.random() * (100 - 1) + 1)
      data[index_a].push
        time: index_b
        value: newValue
        width: gridItemWidth
        height: gridItemHeight
        x: xpos
        y: ypos
        count: count

      xpos += stepX
      count += 1
      index_b++
    xpos = startX
    ypos += stepY
    index_a++
  data    