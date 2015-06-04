require 'shelljs/global'

exec "coffee tools/generate-yahoo-query-url.coffee"
exec "coffee tools/generate-currency-to-country-code-map.coffee"
