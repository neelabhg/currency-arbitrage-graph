fs = require("fs")

getCountryCodes = ->
  # File downloaded from http://data.okfn.org/data/core/country-codes/r/country-codes.json
  contents = fs.readFileSync "tools/data/country_codes.json"
  JSON.parse(contents)

getCurrencyCodeToCountryDataMap = (countryCodes) ->
  currencyCodeToCountryDataMap = {}
  for countryInfo in countryCodes
    currencyCodeToCountryDataMap[countryInfo["currency_alphabetic_code"]] =
      name: countryInfo["name"]
      country_code: countryInfo["ISO3166-1-Alpha-2"]
  currencyCodeToCountryDataMap

writeJsonFile = (currencyCodeToCountryDataMap) ->
  content = JSON.stringify currencyCodeToCountryDataMap
  fs.writeFileSync "app/data/currency_code_to_country_data_map.json", content

main = ->
  writeJsonFile getCurrencyCodeToCountryDataMap getCountryCodes()

main()
