$(document).ready(function() {
	$('#avatarupload').fileupload({
		maxNumberOfFiles: 1, //https://github.com/blueimp/jQuery-File-Upload/wiki/Options
	    downloadTemplateId: null,
	    downloadTemplate: function (o) {
	        window.location = '/avatars/crop'
	    }
	});
});