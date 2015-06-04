fs = require("fs")

getCountryCodes = ->
  # File downloaded from http://data.okfn.org/data/core/country-codes/r/country-codes.json
  contents = fs.readFileSync "tools/data/country_codes.json"
  JSON.parse(contents)

getCurrencyCodeToCountryCodeMap = (countryCodes) ->
  currencyCodeToCountryCodeMap = {}
  for countryInfo in countryCodes
    currencyCodeToCountryCodeMap[countryInfo["currency_alphabetic_code"]] =
      name: countryInfo["name"]
      country_code: countryInfo["ISO3166-1-Alpha-2"]
  currencyCodeToCountryCodeMap

writeJsonFile = (currencyCodeToCountryCodeMap) ->
  content = JSON.stringify currencyCodeToCountryCodeMap
  fs.writeFileSync "app/data/currency_to_country_code_map.json", content

main = ->
  writeJsonFile getCurrencyCodeToCountryCodeMap getCountryCodes()

main()
