// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
import $ from "jquery"

$(document).ready(function() {
  register_data_model_form('.query_model');

  const x_unit = 20; // width of nucleotide letter in pixels
  let min_shift = 0;
  const parse_shift = row => Number(row.find('td:nth-child(3)')[0].innerText);
  $('.macroape_scan_results tr').each(function() {
    const row = $(this);
    if (!(row.find('th').length > 0)) { // header
      const shift = parse_shift(row);
      if (shift < min_shift) { min_shift = shift; }
    }
  });
  $('.macroape_scan_results tr').each(function() {
    const row = $(this);
    if (!(row.find('th').length > 0)) { // header
      const shift = parse_shift(row);
      const logo = row.find('td:last-child');

      const padding = (shift - min_shift) * x_unit;
      logo.css('padding-left', padding + 'px' );
    }
  });
});
