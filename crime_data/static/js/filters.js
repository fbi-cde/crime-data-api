var KEY

function $(selector) {
  var selection = document.querySelectorAll(selector)
  return Array.prototype.slice.apply(selection)
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

function createFixedTableHeader() {
  var table = $('#incident-data')[0].cloneNode(true)
  var target = $('#fixed-table-header')[0]
  var ths = table.querySelectorAll('th')

  table.setAttribute('id', 'fixed-table')
  table.querySelector('caption').remove()
  table.querySelector('tbody').remove()
  target.appendChild(table)
  ths = Array.prototype.slice.apply(ths)

  $('#incident-data th').map(function(th, i) {
    var width = window.getComputedStyle(th).width
    if (width === 'auto') {
      ths[i].setAttribute('style', `display: none;`)
    } else {
      ths[i].setAttribute('style', `min-width: ${width};`)
    }
  });
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
  return fetchData('incidents', query).then(function(incidents) {
    $('#incident-data-row-count')[0].innerText = `(${incidents.length} rows)`
    return incidents.map((function(incident) {
      return makeIncidentRow(incident)
    }))
  }).then(function(html) {
    return html.join('')
  }).then(function(html) {
    $('#incident-data tbody')[0].innerHTML = html
    return
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
  var incidentUrl = makeApiUrl(`incidents/${i.incident_number}`)

  return `<tr>
    <td>
      <a href="${incidentUrl}">${i.incident_number}</a>
    </td>
    <td>2014</td>
    <td>${new Date(i.incident_date)}</td>
    <td>${i.agency.field_office.field_office_name}, ${i.agency.state.state_name}</td>
    <td>${i.agency.pub_agency_name}</td>
    <td>
      <a href="${agencyUrl}">${i.agency.ori}</a>
    </td>
    <td>${makeVictimsText(i.victims)}</td>
    <td>${makeOffensesText(i.offenses)}</td>
    <td>${makeOffendersText(i.offenders)}</td>
    <td>${makeArresteesText(i.arrestees)}</td>
    <td>${makePropertyText(i.property)}</td>
    <td>??</td>
  </tr>`;

  function makeArresteesText(arrestees) {
    var count = arrestees.length
    if (count === 0) return 'No arrestees'
    var text = (count === 1) ? 'One arrestee' : `${count} arrestees`
    return text
  }

  function makeOffendersText(offenders) {
    var count = offenders.length
    if (count === 0) return 'No offenders'
    var text = (count === 1) ? 'One offender' : `${count} offenders`
    return text
  }

  function makeOffensesText(offenses) {
    if (offenses.length === 0) return 'No offenses'
    var text = offenses.map(function(o) {
      var offense_name = o.offense_type.offense_name.toLowerCase()
      var location = o.location.location_name.toLowerCase()
      return `<li>A ${offense_name} offense at a ${location}</li>`
    })
    return `<ul>${text.join('')}</ul>`
  }

  function makePropertyText(property) {
    if (property.length === 0) return 'No properties'
    return 'yo'
  }

  function makeVictimsText(victims) {
    if (victims.length === 0) return 'No victims'
    var text = victims.map(function(v) {
      var age = (v.age && v.age.age_code === 'AG') ? v.age_num : 'not handled'
      var race = (v.race) ? v.race.race_desc.toLowerCase() : 'not handled'
      var sex
      var type = v.victim_type.victim_type_code

      switch(v.sex_code) {
        case 'M':
          sex = 'male'
          break;
        case 'F':
          sex = 'female'
          break;
        case 'U':
          sex = 'unknown'
          break;
      }

      if (age === 'not handled') {
        console.error('age not handled', v)
      }

      if (race === 'not handled') {
        console.error('race not handled', v)
      }

      if (type === 'I') {
        return `<li>A ${race}, ${sex} victim aged ${age}</li>`
      } else {
        return `<li>A ${v.victim_type.victim_type_name}</li>`
      }
    })
    return `<ul>${text.join('')}</ul>`
  }
}

function makeMethodologyText(values) {
  if (properties.length === 0) return 'No properties'
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

  if (values.type && values.type !== 'all') {
    query.push(`offense_code=${values.type}`)
  }

  if (values.location && values.location !== 'United States') {
    query.push(`state_name=${encodeURIComponent(values.location)}`)
  }

  if (values['time-from']) {
    query.push(`incident_date>=${values['time-from']}`)
  }

  if (values['time-to']) {
    query.push(`incident_date<=${values['time-to']}`)
  }

  if (values['offender-asian']) {
    query.push(`offender.race_code=A`)
  } else if (values['offender-black']) {
    query.push(`offender.race_code=B`)
  } else if (values['offender-other-race']) {
    query.push(`offender.race_code=O`)
  } else if (values['offender-race-unknown']) {
    query.push(`offender.race_code=U`)
  } else if (values['offender-white']) {
    query.push(`offender.race_code=W`)
  }

  if (values['offender-female']) {
    query.push(`offender.sex_code=F`)
  } else if (values['offender-male']) {
    query.push(`offender.sex_code=M`)
  } else if (values['offender-unknown-sex']) {
    query.push(`offender.sex_code=U`)
  }

  if (values['victim-asian']) {
    query.push(`victim.race_code=A`)
  } else if (values['victim-black']) {
    query.push(`victim.race_code=B`)
  } else if (values['victim-other-race']) {
    query.push(`victim.race_code=O`)
  } else if (values['victim-race-unknown']) {
    query.push(`victim.race_code=U`)
  } else if (values['victim-white']) {
    query.push(`victim.race_code=W`)
  }

  if (values['victim-female']) {
    query.push(`victim.sex_code=F`)
  } else if (values['victim-male']) {
    query.push(`victim.sex_code=M`)
  } else if (values['victim-unknown-sex']) {
    query.push(`victim.sex_code=U`)
  }

  console.log('query', query)

  return query.join('&')
}

function makeApiUrl(endpoint, search) {
  var api = 'https://crime-data-api-user-testing.fr.cloud.gov'
  var url = `${api}/${endpoint}/?api_key=${KEY}&per_page=100`

  if (!search) return url

  return `${url}&${search}`
}

function toggleTableColumn(tableId, columnNumber, show) {
  var header = $(`#${tableId} th:nth-child(${columnNumber})`)[0]
  var rows = $(`#${tableId} td:nth-child(${columnNumber})`)

  if (show) {
    header.style = 'display: table-cell;'
    rows.forEach(function(el) { el.style = 'display: table-cell;'})
  } else {
    header.style = 'display: none;'
    rows.forEach(function(el) { el.style = 'display: none;'})
  }

  toggleScrollRightText()
}

function toggleScrollRightText() {
  var scrollRight = $('#scroll-for-more')[0]
  var tableContainer = $('#full-table')[0]

  if (tableContainer.scrollWidth > 900) {
    scrollRight.setAttribute('aria-visible', true)
  } else {
    scrollRight.setAttribute('aria-visible', false)
  }
}

function updateContent() {
  var values = getFormValues('#filters')
  var loading = $('#loading')[0]
  var methodology = $('#methodology')[0]
  var toDisable = [
    'clearance-filter',
    'offender-filter',
    'property-filter',
    'victim-filter'
  ]

  loading.className = ''
  //if (methodology) methodology.innerHTML = `<p>${makeMethodologyText(values)}</p>`

  fetchIncidents(values).then(function() {
    loading.className = 'hide'
  })

  toggleScrollRightText()

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

function updatedFixedTableHeaderXPosition() {
  var scrolled = $('#full-table')[0].scrollLeft
  var target = $('#fixed-table')[0]

  target.setAttribute('style', `transform: translateX(-${scrolled}px);`)
}

window.onload = function () {
  var urlParams = getParams()
  applyParams(urlParams)
  updateContent()

  var columnFilter = $('#incident-data-column-filter')[0]
  var columnFilterLegend = $('#incident-data-column-filter legend')[0]
  var filtersForm = $('#filters')[0]
  var fixedTable = false
  var tableContainer = $('#full-table')[0]

  columnFilterLegend.addEventListener('click', function (ev) {
    var current = columnFilter.getAttribute('aria-expanded')
    var next = (current === 'true') ? false : true
    columnFilter.setAttribute('aria-expanded', next)
  })

  columnFilter.addEventListener('change', function (ev) {
    var checkboxes = ev.currentTarget.querySelectorAll('input[type="checkbox"]')
    checkboxes.forEach(function(el, i) {
      if (el !== ev.target) return
      toggleTableColumn('incident-data', i + 1, ev.target.checked)

      if (fixedTable) {
        fixedTable.remove()
        fixedTable = false
      }
    })
  })

  filtersForm.addEventListener('change', updateContent)

  document.addEventListener('scroll', function (ev) {
    var offset = document.body.scrollTop
    if (offset > 370 && !fixedTable) {
      createFixedTableHeader()
      updatedFixedTableHeaderXPosition()
      fixedTable = $('#fixed-table')[0]
    } else if (offset < 370 && fixedTable) {
      fixedTable.remove()
      fixedTable = false
    }
  })

  tableContainer.addEventListener('scroll', function (ev) {
    if (!fixedTable) return
    updatedFixedTableHeaderXPosition()
  })

  $('.filter').forEach(function (el) {
    el.addEventListener('click', function (ev) {
      var disabled = ev.target.getAttribute('disabled')
      var expanded = ev.target.getAttribute('aria-expanded')
      if (expanded === 'false') {
        ev.target.setAttribute('aria-expanded', 'true')
      } else {
        ev.target.setAttribute('aria-expanded', 'false')
      }
    })
  })
}
