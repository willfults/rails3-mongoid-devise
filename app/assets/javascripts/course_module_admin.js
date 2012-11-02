$(document).ready(function() {
	if ($('.class_type').length){
		$('.class_type').click(function() {
			showHide();
		});	
		showHide();
	}
    // Initialize the jQuery File Upload widget:
	$('#fileupload').fileupload({
		maxNumberOfFiles: 1, //https://github.com/blueimp/jQuery-File-Upload/wiki/Options
	    downloadTemplateId: null,
	    downloadTemplate: function (o) {
	        window.location = '/courses/' + course_id + '/course_modules'
	    }
	});
	
	$('#fileupload').bind('fileuploadadded', function (e, data) {
		    $("#fileupload .creationButton").click(function (event) {
		    	//place all your form validation here
		    	valid = false;
		    	name = $('#course_module_name').val()
				if (name.length > 0 ){
					valid = true;
					var ext = $('#fileUploadName').html().split('.').pop().toLowerCase();
					if($.inArray(ext, ['gif','png','jpg','jpeg']) != -1) {
					    //set class type to image
					    $('.class_type').val('Image')
					}
				    else if($.inArray(ext, ['mp4']) != -1) {
					    //set class type to video
					    $('.class_type').val('Video')
					}
				    else if($.inArray(ext, ['mp3']) != -1) {
					    //set class type to audio
					    $('.class_type').val('Audio')
					}else{
						$('#errors_div').html("SocialU currently accepts only gif, png, jpg, mp4 or mp3 files.")
						$('#errors_div').show();
						valid = false;
					}
				
				}else{
					$('#errors_div').html("Name is required.")
					$('#errors_div').show();
				}
				
				
		        if(!valid){
		        	event.stopImmediatePropagation();
		    		return false;
		        }
		    });
		    $("#fileupload .creationButton").selectable();
	});
	
	$('.submitButton').click(function (e) {
		e.stopImmediatePropagation();
		if($(".uploaded_item").length > 0) {
		  $(".edit_course_module").submit();
		}
		tinyMCE.triggerSave()
		if ($("#fileupload .creationButton").length > 0){
			$("#fileupload .creationButton").click();
		}else{
			$('#errors_div').html("You must select a file to upload first.")
			$('#errors_div').show();
		}
		
	});
	
});

function showHide(){
	if ($('#course_module_class_type_youtube').is(':checked')){
		$('.youtube_container').show();
		$('#video_file_container').hide();
		$('#jquerySubmitButton').hide();
	}else{
		$('.youtube_container').hide();
		$('#video_file_container').show();
		$('#jquerySubmitButton').show();				
	}
}
