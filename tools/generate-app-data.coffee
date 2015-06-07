# Run this script after editing the included currencies in config.json

require 'shelljs/global'

exec "coffee tools/generate-yahoo-query-url.coffee"
exec "coffee tools/generate-currencies-json.coffee"
