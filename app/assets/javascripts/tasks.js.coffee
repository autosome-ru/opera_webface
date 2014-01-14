# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.update_data_model = (modelClass)->
  $(modelClass).empty
  data_model = ($(modelClass).find('.data_model select').prop('value') || '').toUpperCase()
  if data_model == 'PCM'
    $(modelClass + '.data_model_specifiers .effective_count').hide()
    $(modelClass + '.data_model_specifiers .pseudocount').show()
  else if data_model == 'PPM'
    $(modelClass + '.data_model_specifiers .effective_count').show()
    $(modelClass + '.data_model_specifiers .pseudocount').show()
  else if data_model == 'PWM'
    $(modelClass + '.data_model_specifiers .effective_count').hide()
    $(modelClass + '.data_model_specifiers .pseudocount').hide()

window.update_background_model = (background_selector)->
  background_selector = $(background_selector)
  background_mode = (background_selector.find('.background_mode select').prop('value') || '').toLowerCase()
  if background_mode == 'wordwise'
    background_selector.find('.background_frequencies').hide()
    background_selector.find('.background_gc_content').hide()
  else if background_mode == 'gc_content'
    background_selector.find('.background_frequencies').hide()
    background_selector.find('.background_gc_content').show()
  else if background_mode == 'frequencies'
    background_selector.find('.background_frequencies').show()
    background_selector.find('.background_gc_content').hide()

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

  $('.task_params *').focus (event)->
    event.preventDefault()
    $('#info .parameter_description').html($(this).closest('*[data-parameter-description]').data('parameter-description') || '')

  $('.expand_button').click ->
    $(this).next('.advanced_options').toggle()

