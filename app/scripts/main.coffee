writeMessage = (->
  $messages = $("#messages")
  (clear, message) ->
    oldText = if clear then "" else $messages.text() + "\n"
    newText = message ? ""
    $messages.text(oldText + newText))()

getCurrencies = ->
  $.getJSON "data/currencies.min.json"

findArbitrage = ->
  cyGraph = $("#graph").cytoscape("get")
  output = findNegativeCycles cyGraph, (edge) -> -1 * Math.log(edge.data("rate"))

  $negativeCyclesList = $("#negative-cycles-list")
  $negativeCyclesList.empty()

  if output.hasNegativeWeightCycle
    writeMessage false, "Negative weight cycle(s) detected!"
    output.cycles.forEach (cycle) ->
      multiplier = cycle.edges().map((elem) -> elem.data("rate")).reduce((acc, rate) -> acc * rate)
      $negativeCyclesList.append(
        $("<a>")
          .attr("href", "#")
          .attr("class", "list-group-item")
          .click(-> cycle.select())
          .append $("<p>").html(cycle.nodes().map((elem) -> elem.id()).join(" &rarr; "))
          .append $("<p>").text("With 1 unit of the starting currency, you get #{multiplier} units"))
  else
    writeMessage false, "No negative weight cycles detected."
    $negativeCyclesList.append($("<p>").text("No arbitrage opportunities available."))

loadGraph = (includedCurrencies, fxRates, currenciesInfo) ->
  $("#graph").height($(document).height() - 150).cytoscape
    layout:
      name: "circle"
    style: cytoscape.stylesheet()
        .selector("node")
          .css
            width: 50
            height: 33.25
            shape: "rectangle"
            "background-image": "data(flag_image)"
            "background-fit": "cover"
        .selector("node:selected")
          .css
            content: "data(name)"
            "border-width": 2
        .selector("edge")
          .css
            "target-arrow-shape": "triangle"
        .selector("edge:selected")
          .css
            content: "data(rate)"
            "line-color": "black"
            "target-arrow-color": "black"
    elements:
      nodes:
        for currency in includedCurrencies
          currencyData = currenciesInfo[currency]
          data:
            id: currency
            name: currencyData.name
            country: currencyData.country
            flag_image: "images/" + currencyData.flag_image
      edges:
        fxRates.map (rate) ->
          data:
            id: "#{rate.from}/#{rate.to}"
            source: rate.from
            target: rate.to
            rate: rate.rate

  findArbitrage()

loadDemo = (number, currenciesInfo) ->
  $.getJSON("data/demo#{number}.json").then (data) ->
    writeMessage true, "Loading graph with dummy data."
    loadGraph data.currencies, data.rates, currenciesInfo

main = ->
  $currencyListSelect = $("#currency-list-select")
  getCurrencies().then (currencies) ->
    preSelectedCurrencies = ["CAD", "CHF", "EUR", "GBP", "HKD", "INR", "JPY", "KRW", "QAR", "SGD", "USD"]

    $currencyListSelect.select2
      data: Object.keys(currencies).map (cur) ->
        {id: cur, text: "#{cur}: #{currencies[cur]['name']}"}

    $currencyListSelect.select2('val', preSelectedCurrencies)

    $("#load-real-data-graph").click ->
      selectedCurrencies = $currencyListSelect.val()
      if !selectedCurrencies? or selectedCurrencies.length < 2
        console.log "Must include at least two currencies to get exchange rates"
      else
        getCurrentFxRates(selectedCurrencies).then (fxRates) ->
          writeMessage true, "Loading graph with current data from Yahoo Finance."
          loadGraph selectedCurrencies, fxRates, currencies

    $("#load-demo-1").click ->
      loadDemo 1, currencies
    $("#load-demo-2").click ->
      loadDemo 2, currencies

main()
