jQuery(function($) {

  $('input.friends').click(function(e) {
    $.blockUI({ message: '<h1><img id="spinner" src="/assets/busy.gif" /> Please Wait...</h1>' });
    setTimeout("$('#spinner').attr('src', '/assets/busy.gif');",100); // needed for animated gif to work
  });
  
  $('input.connections').click(function(e) {
    $.blockUI({ message: '<h1><img id="spinner" src="/assets/busy.gif" /> Please Wait...</h1>' });
    setTimeout("$('#spinner').attr('src', '/assets/busy.gif');",100); // needed for animated gif to work
  });
  
  $('a:[href$=linkedin_profile]').click(function(e) {
    $.blockUI({ message: '<h1><img id="spinner" src="/assets/busy.gif" /> Please Wait...</h1>' });
    setTimeout("$('#spinner').attr('src', '/assets/busy.gif');",100); // needed for animated gif to work
  }); 

  $('a:[href*="facebook_friends?page="]').click(function(e) {
    $.blockUI({ message: '<h1><img id="spinner" src="/assets/busy.gif" /> Please Wait...</h1>' });
    setTimeout("$('#spinner').attr('src', '/assets/busy.gif');",100); // needed for animated gif to work
  });

  $('a:[href*="linkedin_connections?page="]').click(function(e) {
    $.blockUI({ message: '<h1><img id="spinner" src="/assets/busy.gif" /> Please Wait...</h1>' });
    setTimeout("$('#spinner').attr('src', '/assets/busy.gif');",100); // needed for animated gif to work
  });

  $.unblockUI();
});