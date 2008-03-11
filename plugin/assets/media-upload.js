var send_to_editor;

if (send_to_editor != undefined) {
	send_to_editor_backup = send_to_editor;
	
	send_to_editor = function (h) {
		h = h.replace(/<a ([^=]+=['\"][^\"']+['\"] )*href=['\"](([^\"']+\.mp3))['\"]( [^=]+=['\"][^\"']+['\"])*>[^<]+<\/a>/i, "$3");
		return send_to_editor_backup.call(this, "[audio:" + h + "]");
	}	
}