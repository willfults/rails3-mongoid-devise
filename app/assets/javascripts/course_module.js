$(document).ready(function() {
	if ($('.module_reorder .modules_list').length){
	 $('.upArrow').click(function(){
	 	$(this).parents('li').addClass('markedLi');
	 	var current = $('.markedLi');
	 	var id = parseInt(current.attr('id'))
	 	var topelement = $('#' + (id - 1))
	 	topelement.before(current);
  		renumber_modules();
  		current.attr('id',id - 1)
  		topelement.attr('id',id)
  		current.removeClass('markedLi');
  		showHideArrows();
  		save_module_order();
	 });
	 
	 $('.downArrow').click(function(){
	 	$(this).parents('li').addClass('markedLi');
	 	var current = $('.markedLi');
	 	var id = parseInt(current.attr('id'))
	 	id += 1
	 	var bottomelement = $('#' + id)
	 	bottomelement.after(current);
  		renumber_modules();
  		current.attr('id',id)
  		id -= 1
  		bottomelement.attr('id',id)
  		current.removeClass('markedLi');
  		showHideArrows();
  		save_module_order();
	 });
	 showHideArrows();
  }
  

  /*
   * Commenting out this section of code as does not look like its needed as is causing some styling issues. 
   if ($("[id^=mini_player]").length){
  	$("[id^=mini_player]").each(function(index, element){
  		player_id = element.id
		jwplayer(player_id).setup({
			flashplayer : "/jwplayer/player.swf"
		});  	
	});
  }*/
	
	if ($('#container').length){
		var playStatTracked = false
		var completionStatTracked = false
		jwplayer("container").setup({
			flashplayer : "/jwplayer/player.swf"
		});
		
		jwplayer().onComplete(function() {
			if(!completionStatTracked){
			 	 completionStatTracked = true //only increase completion stat once
				 $.post(video_id + '/done/', function(data) {
				 	
				 });
			 }
		});
		
		jwplayer().onPlay(function() {
			//trigger tracking, this method gets triggered everytime a user clicks play
			 if(!playStatTracked){
			 	 playStatTracked = true //only increase play stat once
				 $.post(video_id + '/play/', function(data) {
				 	
				 });
			 }
		});
	}
	
	$(".input-check.correct_answer").change(function() {
    $(this).parents("fieldset").find(".input-check.correct_answer").not(this).removeAttr("checked");
  });
	
});

function showHideArrows(){
	//hides first up arrow and last down arrow
	$('.upArrow').show()
	$('.downArrow').show()
	$('.upArrow:first').hide();
	$('.downArrow:last').hide()
}

function renumber_modules()
{
  var new_order = "";
  $('#modules_list li').each(function(index, element){
    if (index > 0)
    {
      new_order += ",";
    }
    new_order += $(element).attr( 'style' );
  });

  $('#module_order').val(new_order);
}

function save_module_order() 
{
  var url = $(".edit_course").attr("action");
  var module_order = $(".edit_course #module_order").val();
  //$.post(url, {module_order: module_order}, function(data){
  //  alert("saved")
  //})
  $.ajax({
          type: "POST",
          url: url,
          data: { _method:'PUT', module_order : module_order},
          dataType: 'json',
          success: function(data) {
            if(data.result == "success")
              $.jGrowl( "Saved module order" );
          }
  });

  
}
