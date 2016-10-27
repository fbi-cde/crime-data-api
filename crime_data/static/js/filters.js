function $(sel) {
  return document.querySelectorAll(sel)
}

function applyParams(params) {
  applyCollapseParam(params)
  applyHideParam(params)
}

function applyCollapseParam(params) {
  var collapse = params['collapse']
  if (!collapse) return
  var ids = collapse.split('+')
  ids.forEach(function(id) {
    var el = $('#' + id + '-filter')[0]
    if (!el) return

    el.setAttribute('aria-expanded', 'false')
  })
}

// function applyDisabledParams(params) {
//   var disabled = params['disabled']
//   if (!disabled) return
//   var ids = disabled.split('+')
//   ids.forEach(function(id) {
//     var el = $('#' + id + '-filter')[0]
//     if (!el) return
//
//     el.setAttribute('disabled', true)
//   })
// }

function applyHideParam(params) {
  var hide = params['hide']
  if (!hide) return
  var ids = hide.split('+')
  ids.forEach(function(id) {
    var el = $('#' + id + '-filter')[0]
    if (!el) return

    el.setAttribute('style', 'display: none;')
  })
}

function getFormValues(formSelector) {
  var form = $(formSelector)[0]
  var values = new FormData(form)
  var entries = {}

  for (let entry of values.entries()) {
    entries[entry[0]] = entry[1]
  }

  return entries
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

function makeBasicText(values) {
  function isOn(key) {
    return values[key] === 'on'
  }

  var sex = []
  var sexText
  var race = []
  if (isOn('female')) sex.push('female')
  if (isOn('male')) sex.push('male')
  if (isOn('unknown-sex')) sex.push('unknown sex')

  if (sex.length === 0 || sex.length === 3) {
    sexText = 'all biological sexes'
  } else {
    sexText = sex.join(' and ')
  }


  return `Loading ${values['location']} ${values['type'].toLowerCase()} data starting from ${values['time-from']} until ${values['time-to']}.`
}

function makeMethodologyText(values) {
  var type

  switch (values['type']) {
    case 'arrest':
      type = 'arrest data'
      break
    default:
      type = values['type']
  }

  return `The data is from <strong>${values['location']} law enforcement agencies</strong> that submitted 12 months of <strong>${type.toLowerCase()}</strong> data for the years <strong>${values['time-from']}</strong> through </strong>${values['time-to']}</strong>. Totals are aggregates of the totals reported by agencies providing data to the UCR Program within each state.`
}

function updateContent() {
  var values = getFormValues('#filters')
  var basicText = $('#basic-text')[0]
  var methodology = $('#methodology')[0]

  if (basicText) basicText.innerHTML = makeBasicText(values)
  if (methodology) methodology.innerHTML = `<p>${makeMethodologyText(values)}</p>`
}

$('#filters')[0].addEventListener('change', updateContent)

$('.filter').forEach(function(el) {
  el.addEventListener('click', function(ev) {
    var disabled = ev.target.getAttribute('disabled')
    var expanded = ev.target.getAttribute('aria-expanded')
    if (expanded === 'false') {
      ev.target.setAttribute('aria-expanded', 'true')
    } else {
      ev.target.setAttribute('aria-expanded', 'false')
    }
  })
})

window.onload = function () {
  var urlParams = getParams()
  applyParams(urlParams)
  updateContent()
}
