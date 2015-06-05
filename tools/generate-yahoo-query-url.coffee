fs = require("fs")

getCurrencyList = ->
  contents = fs.readFileSync "tools/data/config.json"
  JSON.parse(contents)["currencies_included"]

getCurrencyPairs = (currencies) ->
  pairs = []
  for cur in currencies
    pairs.push "USD" + cur
  pairs

getYQLQuery = (currencyPairs) ->
  pairs = currencyPairs.map((pair) -> "\"#{pair}\"").join(", ")
  "select * from yahoo.finance.xchange where pair in (#{pairs})"

getQueryUrl = (yqlQuery) ->
  env = "store://datatables.org/alltableswithkeys"
  encodeURI "https://query.yahooapis.com/v1/public/yql?q=#{yqlQuery}&format=json&env=#{env}"

writeScriptFile = (url) ->
  content = "window.currencyExchangeRatesUrl = \"#{url}\""
  fs.writeFileSync "app/scripts/rates-query-url.coffee", content

main = ->
  writeScriptFile getQueryUrl getYQLQuery getCurrencyPairs getCurrencyList()

main()
