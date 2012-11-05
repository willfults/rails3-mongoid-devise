jQuery(function($) {
  // create a convenient toggleLoading function
  var toggleLoading = function() { $("#loading").toggle() };

  bookmarkBinding();

  enableScormUpload();

  $.unblockUI();
});

function bookmarkBinding() {
  $('table.search-results a.bookmark, div.search_result a.bookmark, div.course_completion a.bookmark')
    .bind("ajax:complete", function() {
      $(this).parent().html('<span class="label" title="This course can be found on your Courses page" >Bookmarked</span>');
    });
  $('div.course-view a.bookmark')
    .bind("ajax:complete", function() {
      var parent = $(this).parent()
      $(this).remove();
      $(parent).prepend('<span class="label" title="This course can be found on your Courses page" >Bookmarked</span>');
    });
}

function enableScormUpload() {
  $('input[value="Upload Scorm File"]').attr("disabled", "disabled")
  $('#course_scorm_file').change(function() {
    if ($('#course_scorm_file').val().match(/.zip$/)) {
      $('input[value="Upload Scorm File"]').removeAttr("disabled");
    } else {
      $('input[value="Upload Scorm File"]').attr("disabled", "disabled")
    }
  });

  $('input[value="Upload Scorm File"]').click(function(e) {
    $.blockUI({ message: '<h1><img id="spinner" src="/assets/busy.gif" /> Please Wait...</h1>' });
    setTimeout("$('#spinner').attr('src', '/assets/busy.gif');",200); // needed for animated gif to work
  });
  $('input[value="Delete Scorm File"]').click(function(e) {
    $.blockUI({ message: '<h1><img id="spinner" src="/assets/busy.gif" /> Please Wait...</h1>' });
    setTimeout("$('#spinner').attr('src', '/assets/busy.gif');",200); // needed for animated gif to work
  });

}
