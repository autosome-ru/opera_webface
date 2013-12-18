# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  # form_sent = false
  # $('.task_params')
  #   .on('ajax:beforeSend', (xhr)-> 
  #     if form_sent
  #       alert('Please, don\'t submit the same task many times')
  #       false
  #     else
  #       form_sent = true
  #   )

  $('.redirect_to').first().each ->
    url = $(this).data('url')
    timeout = $(this).data('timeout') || 2000
    setTimeout(
      ->
        window.location.href = url
      timeout
    )