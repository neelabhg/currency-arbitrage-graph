getCurrencies = ->
  $.getJSON "data/currencies.min.json"

loadGraph = (includedCurrencies, fxRates, currenciesInfo) ->
  $("#graph").cytoscape
    layout:
      name: "circle"
    style: cytoscape.stylesheet()
        .selector("node")
          .css
            width: 50
            height: 33.25
            shape: "rectangle"
            "background-image": "data(flag_image)"
            "background-fit": "cover"
        .selector("node:selected")
          .css
            content: "data(name)"
            "border-width": 2
        .selector("edge")
          .css
            "target-arrow-shape": "triangle"
        .selector("edge:selected")
          .css
            content: "data(rate)"
            "line-color": "black"
            "target-arrow-color": "black"
    elements:
      nodes:
        for currency in includedCurrencies
          currencyData = currenciesInfo[currency]
          data:
            id: currency
            name: currencyData.name
            country: currencyData.country
            flag_image: "images/" + currencyData.flag_image
      edges:
        fxRates.map (rate) ->
          data:
            id: "#{rate.from}/#{rate.to}"
            source: rate.from
            target: rate.to
            rate: rate.rate
            weight: -1 * Math.log(rate.rate)

main = ->
  $currencyListSelect = $("#currency-list-select")
  getCurrencies().then (currencies) ->
    $currencyListSelect.select2
      data: Object.keys(currencies).map (cur, i) ->
        {id: cur, text: "#{cur}: #{currencies[cur]['name']}"}

    $("#load-current-data-graph").click ->
      selectedCurrencies = $currencyListSelect.val()
      if !selectedCurrencies? or selectedCurrencies.length < 2
        console.log "Must include at least two currencies to get exchange rates"
      else
        getCurrentFxRates(selectedCurrencies).then (fxRates) ->
          loadGraph selectedCurrencies, fxRates, currencies
main()
