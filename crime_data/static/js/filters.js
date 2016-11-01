var KEY

function $(sel) {
  return document.querySelectorAll(sel)
}

function applyParams(params) {
  applyCollapseParam(params)
  applyHideParam(params)
  applyKeyParam(params)
  applyValueParam(params)
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

function applyKeyParam(params) {
  KEY = params['k'] || false
}

function applyValueParam(params) {
  var values = decodeURI(params.values)
  if (!values || values === 'undefined') return;

  var j = JSON.parse(values)
  var fields = Object.keys(j)
  fields.forEach(function(id) {
    var field = $(`#${id}`)[0]
    var value = j[id]
    switch (field.type) {
      case 'select-one':
        field.value = value.charAt(0).toUpperCase() + value.substring(1)
        break
      case 'checkbox':
        (value === 'true') ? field.checked = true : field.checked = false
        break
      case 'number':
        field.value = value
        break
      default:
        console.log(`no handler for ${field.type}`)
    }
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

function fetchData(endpoint, search) {
  var url = makeApiUrl(endpoint, search)
  console.log('url', url)
  return fetch(url).then(function(data) {
    if (data.status === 200) return data.json()
    throw new Error(data.statusText)
  })
  .then(function(resp) {
    return resp.results
  })
  .catch(function(err) {
    console.error('fetchData() err', err)
  });
}

function fetchIncidents(form) {
  var query = makeApiSearchQuery(form)
  console.log('incident query', query)
  fetchData('incidents', query).then(function(incidents) {
    return incidents.map((function(incident) {
      var i = Object.assign({}, incident, {
        location: form.location
      })
      return makeIncidentRow(i)
    }))
  }).then(function(html) {
    return html.join('')
  }).then(function(html) {
    $('#incident-data tbody')[0].innerHTML = html
  }).catch(function(err) {
    console.error('err', err)
  })
}

function makeIncidentRow(i) {
  function j(data) {
    if (data.length === 0) return 'No data'
    return `${data.length} items`
  }

  var agencyUrl = makeApiUrl(`agencies/${i.agency.ori}`)

  return `<tr>
    <td>${i.incident_number}</td>
    <td>2014</td>
    <td>${new Date(i.incident_date)}</td>
    <td>${i.location}</td>
    <td>${i.agency.pub_agency_name}</td>
    <td>
      <a href="${agencyUrl}">${i.agency.ori}</a>
    </td>
    <td>??</td>
    <td>${j(i.victims)}</td>
    <td>${j(i.offenses)}</td>
    <td>${j(i.offenders)}</td>
    <td>${j(i.arrestees)}</td>
    <td>${j(i.property)}</td>
    <td>??</td>
  </tr>`;
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

function makeApiSearchQuery(values) {
  var query = []
  console.log('values', values);
  if (!values) return false;

  if (values.location && values.location !== 'United States') {
    query.push(`state_name=${encodeURIComponent(values.location)}`)
  }

  console.log('query', query)

  return query.join('&')
}

function makeApiUrl(endpoint, search) {
  var api = 'https://crime-data-api.fr.cloud.gov'
  var url = `${api}/${endpoint}/?api_key=${KEY}&per_page=100`

  if (!search) return url

  return `${url}&${search}`
}

function updateContent() {
  var values = getFormValues('#filters')
  var methodology = $('#methodology')[0]
  var toDisable = [
    'clearance-filter',
    'offender-filter',
    'property-filter',
    'victim-filter'
  ]

  if (methodology) methodology.innerHTML = `<p>${makeMethodologyText(values)}</p>`

  fetchIncidents(values)

  if (values.type.toLowerCase() === 'employee counts') {
    toDisable.forEach(function(id) {
      $(`#${id}`)[0].setAttribute('disabled', true)
    })
  } else {
    toDisable.forEach(function(id) {
      var el = $(`#${id}`)[0]
      if (!el) return
      el.removeAttribute('disabled')
    })
  }
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
