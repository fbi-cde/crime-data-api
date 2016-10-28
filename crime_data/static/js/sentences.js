function $(sel) {
  return document.querySelector(sel)
}

function getFormValues() {
  return {
    type: $('#type').value,
    location: $('#location').value,
    'time-from': $('#time-from').value,
    'time-to':  $('#time-to').value,
  }
}

function makeUrl(values) {
  return `/prototypes/filters?collapse=time&values=${JSON.stringify(values)}`
}

$('#find').addEventListener('click', function (ev) {
  ev.preventDefault()
  window.location = makeUrl(getFormValues())
})
