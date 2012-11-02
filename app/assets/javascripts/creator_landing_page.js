$(document).ready(function() {
	if ($('#creator_landing_page').length){
		$('#profileTab').hide();
		$('#reviewTab').hide();
		$('#questionTab').hide();
		
		$(".tabNav").click(function (event) {
			var element = $(this)
			var tabToShow = element.attr('href');
			$('#profileTab').hide();
			$('#courseTab').hide();
			$('#reviewTab').hide();
			$('#questionTab').hide();
			
			$('ul.nav-tabs li.active').removeClass('active')
			$('#' + tabToShow).parent('li').addClass('active')
			$('#' + tabToShow).show();
			event.preventDefault();
		});
				
	}
	
	
});


