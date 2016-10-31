function $(sel) {
  return document.querySelector(sel)
}

function getApiKey() {
  var params = getParams()
  if (!params['k']) return false

  return params['k']
}

function getFormValues() {
  return {
    type: $('#type').value,
    location: $('#location').value,
    'time-from': $('#time-from').value,
    'time-to':  $('#time-to').value,
  }
}

function getParams() {
  var search = window.location.search
  if (search === '') return false

  var params = search.split('?')[1].split('&')
    .map(function(param) {
      return param.split('=')
    })
    .reduce(function(prev, cur) {
      var o = {}
      o[cur[0]] = cur[1]
      return Object.assign({}, prev, o)
    }, {})

  return params
}

function makeUrl(values) {
  var k = getApiKey()
  return `/prototypes/filters?k=${k}&collapse=time&values=${JSON.stringify(values)}`
}

$('#find').addEventListener('click', function (ev) {
  ev.preventDefault()
  window.location = makeUrl(getFormValues())
})
