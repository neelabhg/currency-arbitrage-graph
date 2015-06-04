getCurrencies = ->
  $.getJSON "data/currencies.json"

getUSDExchangeRates = ->
  $.getJSON(currencyExchangeRatesUrl).then (data) ->
    rates = data.query.results.rate
    rates.filter (rate) ->
       rate.Rate != "N/A"
    .map (rate) ->
      currencies = rate.Name.split("/")
      from: currencies[0]
      to: currencies[1]
      rate: rate.Rate

getExchangeRates = (usdFxRates) ->
  usdRateMap = {}
  usdFxRates.forEach (rate) ->
    usdRateMap[rate.to] = rate.rate

  # https://openexchangerates.org/documentation#how-to-use
  fxRates = []
  for cur1 of usdRateMap
    for cur2 of usdRateMap
      fxRates.push
        from: cur1
        to: cur2
        rate: usdRateMap[cur1] * (1 / usdRateMap[cur2])
  fxRates

Promise.all([getUSDExchangeRates(), getCurrencies()]).then ([usdFxRates, currencies]) ->
  console.log usdFxRates
  console.log currencies

  fxRates = getExchangeRates usdFxRates

  $("#graph").cytoscape
    layout:
      name: "grid"
    style: cytoscape.stylesheet()
        .selector("node")
          .css
            content: "data(id)"
    elements:
      nodes:
        usdFxRates.map (rate) ->
          currency = rate.to
          data:
            id: currency
            name: currencies[currency]
      edges:
        fxRates.map (rate) ->
          data:
            id: "#{rate.from}/#{rate.to}"
            source: rate.from
            target: rate.to
            rate: rate.rate
            weight: -1 * Math.log(rate.rate)
