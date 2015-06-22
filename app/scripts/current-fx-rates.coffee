generateQueryUrl = (currencies) ->
  currencyPairs = []
  for cur in currencies
    currencyPairs.push "USD" + cur
  pairs = currencyPairs.map((pair) -> "\"#{pair}\"").join(", ")
  yqlQuery = "select * from yahoo.finance.xchange where pair in (#{pairs})"
  env = "store://datatables.org/alltableswithkeys"
  encodeURI "https://query.yahooapis.com/v1/public/yql?q=#{yqlQuery}&format=json&env=#{env}"

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
