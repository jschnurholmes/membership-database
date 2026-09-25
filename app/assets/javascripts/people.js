// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// These functions are used by the add and delete buttons on the Person and Membership forms
$(document).ready(function() {
  $('form').on('click', '._remove_field', function(event) {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('div.form-group').hide();
    event.preventDefault();
  });

  $('form').on('click', '.add_fields', function(event) {
    var time = new Date().getTime();
    var regexp = new RegExp($(this).data('id'), 'g');
    $(this).closest('fieldset').append($(this).data('fields').replace(regexp, time));
    event.preventDefault();
  });
});
