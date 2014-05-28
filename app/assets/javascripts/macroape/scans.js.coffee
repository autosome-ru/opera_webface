# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  register_data_model_form('.query_model')

  x_unit = 20; # width of nucleotide letter in pixels
  min_shift = 0
  parse_shift = (row)->
    Number(row.find('td:nth-child(3)')[0].innerText)
  $('.macroape_scan_results tr').each ->
    row = $(this)
    unless row.find('th').size() > 0 # header
      shift = parse_shift(row)
      min_shift = shift  if shift < min_shift
  $('.macroape_scan_results tr').each ->
    row = $(this)
    unless row.find('th').size() > 0 # header
      shift = parse_shift(row)
      logo = row.find('td:last-child')

      padding = (shift - min_shift) * x_unit
      logo.css('padding-left', padding + 'px' )
