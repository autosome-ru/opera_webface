// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
import $ from "jquery"

const update_data_model_form = function(dataModelSelector){
  const $model = $(dataModelSelector);
  const data_model_type = ($model.find('.data_model select').prop('value') || '').toUpperCase();
  const $data_model_specifiers = $model.filter('.data_model_specifiers');
  if (data_model_type === 'PCM') {
    $data_model_specifiers.find('.effective_count').hide();
    $data_model_specifiers.find('.pseudocount').show();
  } else if (data_model_type === 'PPM') {
    $data_model_specifiers.find('.effective_count').show();
    $data_model_specifiers.find('.pseudocount').show();
  } else if (data_model_type === 'PWM') {
    $data_model_specifiers.find('.effective_count').hide();
    $data_model_specifiers.find('.pseudocount').hide();
  }
};

window.register_data_model_form = function(dataModelSelector){
  const $model = $(dataModelSelector);
  update_data_model_form($model);
  $model.find('.data_model select').change(() => update_data_model_form($model));
  $(':reset').click(function(event){
    event.preventDefault();
    if ($model.closest('form')[0]) {
      $model.closest('form')[0].reset();
    }
    update_data_model_form($model);
  });
};

$(document).ready(function() {
  const update_background_model_form = function(background_form){
    background_form = $(background_form);
    const mode = (background_form.find('.mode select').prop('value') || '').toLowerCase();
    if (mode === 'wordwise') {
      background_form.find('.frequencies').hide();
      background_form.find('.gc_content').hide();
    } else if (mode === 'gc_content') {
      background_form.find('.frequencies').hide();
      background_form.find('.gc_content').show();
    } else if (mode === 'frequencies') {
      background_form.find('.frequencies').show();
      background_form.find('.gc_content').hide();
    }
  };

  const register_background_model_form = background_selector => $(background_selector).each(function() {
    const background_form = $(this);
    update_background_model_form(background_form);
    background_form.find('.mode select').change(() => update_background_model_form(background_form));
    $(':reset').click(function(event){
      event.preventDefault();
      if (background_form.closest('form')[0]) {
        background_form.closest('form')[0].reset();
      }
      update_background_model_form(background_form);
    });
  });

  register_background_model_form('.background_model');

  $('.redirect_to').first().each(function() {
    const url = $(this).data('url');
    const timeout = $(this).data('timeout') || 2000;
    setTimeout(
      () => window.location.href = url,
      timeout
    );
  });


  $('.task_params *').focus(function(event){
    event.preventDefault();
    const parameter_description = $(this).closest('*[data-parameter-description]').data('parameter-description') || '';
    const parameter_errors = $(this).closest('*[data-error]').data('error') || '';
    $('#info .parameter .description').html(parameter_description);
    $('#info .parameter .errors').html(parameter_errors);
  });

  $('.expand_button').click(function() {
    $(this).next('.advanced_options').toggle();
    if ($(this).next('.advanced_options').css('display') === 'none') {
      $(this).html('<a href="#">[+]</a>');
    } else {
      $(this).html('<a href="#">[&ndash;]</a>');
    }
  });
  $('.advanced_options').each(function() {
    const advanced_section = $(this);
    if  (advanced_section.find('[data-error]').length > 0) {
      advanced_section.show();
      $('.expand_button').html('<a href="#">[&ndash;]</a>');
    }
  });

  // enable button if we return back in history to a page where button was disabled during submission
  $('.task_params input[type="submit"]').attr('disabled', false);
});
