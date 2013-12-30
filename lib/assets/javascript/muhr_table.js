$(function() {
//  $( '.muhr_date' ).datepicker( { dateFormat:"yy M dd", buttonImage: '/assets/calendar.png', buttonImageOnly:true, buttonText:'Blah bar', showOn:'button' });
  $( '.muhr_input_date' ).datepicker( { dateFormat:"yy M dd" });

  $('.muhr_reset').click(function() {
    $('.muhr_form input').val( '' );
  });

  $('.muhr_submit').click(function() {
    $('.muhr_form').submit()
  });

  $('.muhr_form').submit(function() {
    // can't get it to work right when I use a selector like input[value='']
    $('input').each(function() {
      if ($(this).val()=='') {
        $(this).prop( 'name', '' );
      }
    });
  });
});
