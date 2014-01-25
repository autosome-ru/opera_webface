# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

update_data_model_form = (dataModelClass)->
  data_model = ($(dataModelClass).find('.data_model select').prop('value') || '').toUpperCase()
  if data_model == 'PCM'
    $(dataModelClass + '.data_model_specifiers .effective_count').hide()
    $(dataModelClass + '.data_model_specifiers .pseudocount').show()
  else if data_model == 'PPM'
    $(dataModelClass + '.data_model_specifiers .effective_count').show()
    $(dataModelClass + '.data_model_specifiers .pseudocount').show()
  else if data_model == 'PWM'
    $(dataModelClass + '.data_model_specifiers .effective_count').hide()
    $(dataModelClass + '.data_model_specifiers .pseudocount').hide()

window.register_data_model_form = (dataModelClass)->
  update_data_model_form(dataModelClass)
  $(dataModelClass).find('.data_model select').change ->
    update_data_model_form(dataModelClass)

$(document).ready ->
  update_background_model_form = (background_form)->
    background_form = $(background_form)
    mode = (background_form.find('.mode select').prop('value') || '').toLowerCase()
    if mode == 'wordwise'
      background_form.find('.frequencies').hide()
      background_form.find('.gc_content').hide()
    else if mode == 'gc_content'
      background_form.find('.frequencies').hide()
      background_form.find('.gc_content').show()
    else if mode == 'frequencies'
      background_form.find('.frequencies').show()
      background_form.find('.gc_content').hide()

  register_background_model_form = (background_selector)->
    $(background_selector).each ->
      background_form = $(this)
      update_background_model_form(background_form)
      background_form.find('.mode select').change ->
        update_background_model_form(background_form)

  register_background_model_form('.background_model')


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
    parameter_description = $(this).closest('*[data-parameter-description]').data('parameter-description') || ''
    parameter_errors = $(this).closest('*[data-error]').data('error') || ''
    $('#info .parameter_description').html(parameter_description + "<br/>" + parameter_errors)

  $('.expand_button').click ->
    $(this).next('.advanced_options').toggle()

