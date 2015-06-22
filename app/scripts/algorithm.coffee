# Adapted from https://github.com/cytoscape/cytoscape.js/blob/master/src/collection-algorithms2.js
# And based on http://www.kelvinjiang.com/2010/10/currency-arbitrage-in-99-lines-of-ruby.html
window.findNegativeCycles = (cyGraph) ->
  elements = cyGraph.elements()
  edges = elements.edges().stdFilter((e) -> !e.isLoop())
  nodes = elements.nodes()
  source = nodes[0]
  weightFn = (edge) -> edge.data("weight")

  # mapping: node id -> position in nodes array
  id2position = {};
  for node, i in nodes
    id2position[node.id()] = i

  # Initializations
  cost = [];
  predecessor = [];
  predEdge = [];

  for node, i in nodes
    if node.id() == source.id()
      cost[i] = 0
    else
      cost[i] = Infinity
    predecessor[i] = undefined

  # Edges relaxation
  flag = false;
  for node, i in nodes[1..]
    flag = false;
    for edge, e in edges
      sourceIndex = id2position[edges[e].source().id()];
      targetIndex = id2position[edges[e].target().id()];
      weight = weightFn.apply(edges[e], [edges[e]]);

      temp = cost[sourceIndex] + weight
      if (temp < cost[targetIndex])
        cost[targetIndex] = temp
        predecessor[targetIndex] = sourceIndex
        predEdge[targetIndex] = edges[e]
        flag = true

    if (!flag)
      break;

  if (flag)
    # Check for negative weight cycles
    hasNegativeWeightCycle = false
    cyclic = {}
    for edge, e in edges
      sourceIndex = id2position[edges[e].source().id()];
      targetIndex = id2position[edges[e].target().id()];
      weight = weightFn.apply(edges[e], [edges[e]]);

      temp = cost[sourceIndex] + weight
      if (temp < cost[targetIndex])
        cost[targetIndex] = temp
        hasNegativeWeightCycle = true
        cyclic[targetIndex] = true

  if hasNegativeWeightCycle
    console.log "Negative cycles found!"
    console.log cyclic

  # Build result object
  position2id = [];
  for node in nodes
    position2id.push(node.id())

  cycles = []
  for nodeIndex in Object.keys(cyclic)
    visited = {}
    cycle = []
    v = predecessor[nodeIndex]
    while v? and !visited[v]
      cycle.push(cyGraph.getElementById(position2id[v]))
      cycle.push(predEdge[v])
      visited[v] = true
      v = predecessor[v]
    cycle.push(cycle[0])
    cycle.reverse()
    cycles.push(new cytoscape.Collection(cyGraph, cycle))

  res = {
    hasNegativeWeightCycle: hasNegativeWeightCycle
    cycles: cycles
  }

  return res
