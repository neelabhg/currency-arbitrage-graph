fs = require "fs"

getObjectLength = (obj) ->
  Object.keys(obj).length

readJsonFile = (filename, key) ->
  contents = fs.readFileSync filename
  obj = JSON.parse(contents)
  obj = obj[key] if key
  console.log "Read #{getObjectLength obj} entries from #{filename}."
  obj

writeJsonFile = (filename, obj, indent) ->
  fs.writeFileSync filename, JSON.stringify(obj, null, indent)
  console.log "Wrote #{getObjectLength obj} entries to #{filename}."

getCurrencyNames = ->
  readJsonFile "tools/data/currency_names.json"

getCurrencyFlags = ->
  readJsonFile "tools/data/currency_flags.json"

writeCurrenciesJsonFile = (currencies) ->
  writeJsonFile "app/data/currencies.json", currencies, 2
  writeJsonFile "app/data/currencies.min.json", currencies, 0

main = ->
  currencies = {}
  currencyNames = getCurrencyNames()
  currencyFlags = getCurrencyFlags()
  for cur in Object.keys(currencyNames)
    currencyName = currencyNames[cur]
    currencyFlag = currencyFlags[cur]
    if currencyName and currencyFlag
      currencies[cur] =
        name: currencyName
        country: currencyFlag["country"]
        flag_image: currencyFlag["flag_image"]
    else
      console.log "Information not available for currency #{cur}, so it will not be included in currencies.json."
  writeCurrenciesJsonFile currencies

main()
