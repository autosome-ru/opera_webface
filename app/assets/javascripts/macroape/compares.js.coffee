# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  update_data_model('.first_model')
  $('.first_model .data_model select').change ->
    update_data_model('.first_model')

  update_data_model('.second_model')
  $('.second_model .data_model select').change ->
    update_data_model('.second_model')

  update_background_model('.background')
  $('.background').each ->
    background_selector = $(this)
    background_selector.find('.background_mode select').change ->
      update_background_model(background_selector)
