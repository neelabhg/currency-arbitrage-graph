generateQueryUrl = (currencies) ->
  console.log currencies
  currencyExchangeRatesUrl

getUSDExchangeRates = (url) ->
  $.getJSON(url).then (data) ->
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

window.getCurrentFxRates = (currencies) ->
  getUSDExchangeRates(generateQueryUrl(currencies)).then getExchangeRates
