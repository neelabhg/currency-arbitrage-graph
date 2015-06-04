require 'shelljs/global'

mkdir "app/data"
cp "tools/data/currencies.json", "app/data/"
exec "coffee tools/generate-yahoo-query-url.coffee"
