$graph = $("#graph")
$dataSourceInfo = $("#data-source-info")
$graphPlaceholder = $("#graph-placeholder")
$arbitrageOpportunities = $("#arbitrage-opportunities")

showLoadingMessage = (->
  loading = """
        <div class="center-block" style="width: 20%">
          <h3>Loading Graph</h3>
          <div class="progress">
            <div class="progress-bar progress-bar-striped active" role="progressbar" style="width: 100%">
              <span class="sr-only">Loading graph</span>
            </div>
          </div>
        </div>
      """
  (-> $graphPlaceholder.html(loading)))()

hideLoadingMessage = -> $graphPlaceholder.empty()

getCurrencies = ->
  $.getJSON "data/currencies.min.json"

findArbitrage = ->
  cyGraph = $graph.cytoscape("get")
  output = findNegativeCycles cyGraph, (edge) -> -1 * Math.log(edge.data("rate"))

  $negativeCyclesList = $("<div>").attr("class", "list-group")
  $arbitrageOpportunities
    .empty()
    .append("<h3>Arbitrage Opportunities</h3>")
    .append($negativeCyclesList)

  arbitrages = []
  if output.hasNegativeWeightCycle
    arbitrages =
      for cycle in output.cycles
        multiplier: cycle.edges().map((elem) -> elem.data("rate")).reduce((acc, rate) -> acc * rate)
        cycle: cycle
    arbitrages = (arbitrage for arbitrage in arbitrages when arbitrage.multiplier > 1)

  if arbitrages.length > 0
    arbitrages.sort (a, b) -> math.subtract(b.multiplier, a.multiplier)
    arbitrages.forEach (arbitrage) ->
      $negativeCyclesList.append(
        $("<a>")
          .attr("href", "#")
          .attr("class", "list-group-item")
          .click(-> cyGraph.elements().unselect(); arbitrage.cycle.select())
          .append $("<p>").html(arbitrage.cycle.nodes().map((elem) -> elem.id()).join(" &rarr; "))
          .append $("<p>").text("With 1 unit of the starting currency, you get ~#{arbitrage.multiplier.toFixed(4)} units"))
    $arbitrageOpportunities.append("<p>Note: All possible arbitrage opportunities may not be shown.</p>")
  else
    $arbitrageOpportunities.append("<p>No arbitrage opportunities available.</p>")

loadGraph = (includedCurrencies, fxRates, currenciesInfo) ->
  $graph.height($(document).height() - 150).cytoscape
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
  $graph.empty()
  showLoadingMessage()
  $.getJSON("data/demo#{number}.json").then (data) ->
    $dataSourceInfo.html("Example data from <a target='_blank' href='#{data.source.url}'>#{data.source.name}</a>.")
    hideLoadingMessage()
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
        $graph.empty()
        showLoadingMessage()
        getCurrentFxRates(selectedCurrencies).then (fxRates) ->
          $dataSourceInfo.html("Latest currency exchange rate data from the
            <a target='_blank'
              href='https://developer.yahoo.com/yql/console/?q=show%20tables&env=store://datatables.org/alltableswithkeys#h=desc+yahoo.finance.xchange'>
              yahoo.finance.xchange community datatable on the Yahoo Query Language platform</a>.")
          hideLoadingMessage()
          loadGraph selectedCurrencies, fxRates, currencies

    $("#load-demo-1").click ->
      loadDemo 1, currencies
    $("#load-demo-2").click ->
      loadDemo 2, currencies

main()
