$(document).ready(function() {
	if ($('#sign_up_form').length){
		$('#user_email').change(function() {  
			$.ajax({
			  url: '/is_valid?email=' + $(this).val(),
			  success: function(data) {
			     if (data == "true"){
			     	$('.alert').show();
			     }else{
			     	$('.alert').hide();
			     }
			  }
			});
		});
	}
	
	//search button
	$('#searchSubmit').click(function(e) {  
			e.preventDefault();
			$('#search_form').submit();
	});
	
	//kera demo script
	(function(w,d){var script=d.createElement('script');script.type='text/javascript';
	script.async=true;script.src='https://www.kera.io/embed.js',entry=d.getElementsByTagName('script')[0];entry.parentNode.insertBefore(script,entry);w.Kera=w.Kera||{};
	Kera._ready=[];Kera.ready=function(cb){Kera._ready.push(cb)};Kera.app_id='toomtzyo';
	}(window,document));

});

