# Adapted from tutorial at http://www.smashingmagazine.com/2015/04/08/web-scraping-with-nodejs/

request = require "request"
cheerio = require "cheerio"
fs = require "fs"

url = "http://www.currencysymbols.in/"

request url, (error, response, body) ->
  if error
    console.log "An error occurred", error
  $ = cheerio.load body

  currencyData = {}
  rows = $("table").children()[1..] # Remove heading row
  rows.each (i, row) ->
      children = $(row).children()
      currencyCode = $(children[3]).text()
      currencyData[currencyCode] =
        country: $(children[1]).text()
        flag_image: $(children[0]).children().attr("src")

  fs.writeFileSync "tools/data/currency_flags.json", JSON.stringify(currencyData, null, 2)
