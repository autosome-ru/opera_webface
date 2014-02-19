# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

update_data_model_form = (dataModelSelector)->
  $model = $(dataModelSelector)
  data_model_type = ($model.find('.data_model select').prop('value') || '').toUpperCase()
  $data_model_specifiers = $model.filter('.data_model_specifiers')
  if data_model_type == 'PCM'
    $data_model_specifiers.find('.effective_count').hide()
    $data_model_specifiers.find('.pseudocount').show()
    $model.find('.matrix textarea').val( $model.find('.data_model_examples .pcm').text() )
  else if data_model_type == 'PPM'
    $data_model_specifiers.find('.effective_count').show()
    $data_model_specifiers.find('.pseudocount').show()
    $model.find('.matrix textarea').val( $model.find('.data_model_examples .ppm').text() )
  else if data_model_type == 'PWM'
    $data_model_specifiers.find('.effective_count').hide()
    $data_model_specifiers.find('.pseudocount').hide()
    $model.find('.matrix textarea').val( $model.find('.data_model_examples .pwm').text() )

window.register_data_model_form = (dataModelSelector)->
  $model = $(dataModelSelector)
  if $model.find('.matrix textarea').length != 0 && $model.find('.matrix textarea').val().length == 0
    update_data_model_form($model)
  $model.find('.data_model select').change ->
    update_data_model_form($model)

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
    $('#info .parameter_description').html(parameter_description)
    $('#info .parameter_errors').html(parameter_errors)

  $('.expand_button').click ->
    $(this).next('.advanced_options').toggle()
  $('.advanced_options').each ->
    advanced_section = $(this)
    if  advanced_section.find('[data-error]').size() > 0
      advanced_section.show()
