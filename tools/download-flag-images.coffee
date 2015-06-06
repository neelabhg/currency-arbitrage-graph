request = require "request"
fs = require "fs"

getObjectLength = (obj) ->
  Object.keys(obj).length

readJsonFile = (filename, key) ->
  contents = fs.readFileSync filename
  obj = JSON.parse(contents)
  obj = obj[key] if key
  console.log "Read #{getObjectLength obj} entries from #{filename}."
  obj

baseUrl = "http://www.currencysymbols.in/"
saveDir = "app/images/"

downloadCount = 0

downloadImage = (imageRelativeUrl, successCallback) ->
  request {baseUrl: baseUrl, url: imageRelativeUrl, encoding: null}, (error, response, body) ->
    if error
      console.log "An error occurred while downloading #{imageRelativeUrl}: ", error
    else
      fs.writeFileSync saveDir + imageRelativeUrl, body
      downloadCount++
      successCallback()

# Recursively calls itself to download files one after the another
downloadImages = (urls) ->
  if urls.length == 0
    console.log "Downloaded #{downloadCount} files."
  else downloadImage urls.shift(), ->
    downloadImages urls

main = ->
  flags = []
  currencyFlags = readJsonFile "tools/data/currency_flags.json"
  for cur of currencyFlags
    flag = currencyFlags[cur]["flag_image"]
    if flag
      flags.push(flag)
    else
      console.log "Currency #{cur} does not have a flag image URL."
  downloadImages flags

main()
