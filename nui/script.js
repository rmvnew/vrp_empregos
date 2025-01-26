let bancada = null;

$(document).ready(function(){
	var actionContainer = $("#container");

	window.addEventListener("message",function(event){
	  var data = event.data;

	  if (data.showmenu) {
		actionContainer.fadeIn();
	  }

      if (data.hidemenu) {
        actionContainer.fadeOut();
        $.post('http://vrp_empregos/closeNui',JSON.stringify({}))
      }
	});
  
	document.onkeyup = function(data) {
	  if (data.which == 27) {
		if (actionContainer.is(":visible")) {
			$('body').css('background-color', 'transparent')
			actionContainer.fadeOut();
			$.post('http://vrp_empregos/closeNui',JSON.stringify({}))
		}
	  }
	};	
});


function start(attr) {
	var actionContainer = $("#container");
	actionContainer.fadeOut();
	
    $.post('http://vrp_empregos/'+attr, JSON.stringify({}))
    $.post('http://vrp_empregos/closeNui',JSON.stringify({}))
}