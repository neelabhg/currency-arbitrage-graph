# Adapted from https://github.com/cytoscape/cytoscape.js/blob/master/src/collection-algorithms2.js
# And based on http://www.kelvinjiang.com/2010/10/currency-arbitrage-in-99-lines-of-ruby.html

window.findNegativeCycles = (cyGraph, weightFn) ->
  elements = cyGraph.elements()
  edges = elements.edges().stdFilter((e) -> !e.isLoop())
  nodes = elements.nodes()
  source = nodes[0]

  # Initializations
  cost = {}
  predecessor = {}
  predEdge = {}

  for node in nodes
    cost[node.id()] = Infinity
    predecessor[node.id()] = undefined
  cost[source.id()] = 0

  # Edges relaxation
  for [1..nodes.length-1]
    for edge in edges
      edgeSourceId = edge.source().id()
      edgeTargetId = edge.target().id()
      weight = weightFn.apply(edge, [edge])

      temp = math.add(cost[edgeSourceId], weight)
      if (math.smaller(temp, cost[edgeTargetId]))
        cost[edgeTargetId] = temp
        predecessor[edgeTargetId] = edgeSourceId
        predEdge[edgeTargetId] = edge

  # Check for negative weight cycles
  hasNegativeWeightCycle = false
  cyclic = {}
  for edge in edges
    edgeSourceId = edge.source().id()
    edgeTargetId = edge.target().id()
    weight = weightFn.apply(edge, [edge])

    temp = math.add(cost[edgeSourceId], weight)
    if (math.smaller(temp, cost[edgeTargetId]))
      cost[edgeTargetId] = temp
      hasNegativeWeightCycle = true
      cyclic[edgeTargetId] = true

  cycles = []
  for nodeId in Object.keys(cyclic)
    visited = {}
    cycle = []
    v = nodeId
    while v? and !visited[v]
      cycle.push(cyGraph.getElementById(v))
      cycle.push(predEdge[v])
      visited[v] = true
      v = predecessor[v]
    cycle.pop() # Take out the last element, the extra edge
    # Add an edge from the first node to the last node
    # This works because there is an edge from every node to every other node
    cycle.push(cyGraph.getElementById("#{cycle[0].id()}/#{cycle[cycle.length-1].id()}"))
    cycle.push(cycle[0]) # Add the first node to complete the cycle
    # The nodes and edges are in reverse order because the predecessor array was used,
    # so need to reverse the order
    cycle.reverse()
    cycles.push(new cytoscape.Collection(cyGraph, cycle))

  res = {
    hasNegativeWeightCycle: hasNegativeWeightCycle
    cycles: cycles
  }

  return res
