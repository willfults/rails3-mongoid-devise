$(document).ready(function() {
	if ($('#chart_container').length){
		//initialize datepickers
		$('#end_date').datepicker({ maxDate: 0});
		$('#start_date').datepicker({ maxDate: 0});
	}
});
