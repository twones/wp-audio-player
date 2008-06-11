var AudioPlayer = function () {
	var instances = [];
	var activeInstance;
	var playerURL = "";
	var defaultOptions = {};
	var currentVolume = -1;
	
	var getMovie = function (name) {
		return document.all ? window[name] : document[name];
	};
	
	return {
		setup: function (url, options) {
	        playerURL = url;
	        defaultOptions = options;
	    },
	    
	    embed: function (elementID, options) {
	        var instanceOptions = {};
	        var key;
	        var so;
			var bgcolor;
			var wmode;
			
			var flashParams = {};
			var flashVars = {};
			var flashAttributes = {};
	
	        // Merge default options and instance options
			for (key in defaultOptions) {
	            instanceOptions[key] = defaultOptions[key];
	        }
	        for (key in options) {
	            instanceOptions[key] = options[key];
	        }
	        
			if (instanceOptions.transparentpagebg == "yes") {
				flashParams.bgcolor = "#FFFFFF";
				flashParams.wmode = "transparent";
			} else {
				flashParams.bgcolor = "#" + instanceOptions.pagebg;
				flashParams.wmode = "opaque";
			}
			
			flashParams.menu = "false";
			
	        for (key in instanceOptions) {
				if (key == "pagebg" || key == "width" || key == "transparentpagebg") {
					continue;
				}
	            flashVars[key] = instanceOptions[key];
	        }
	
			flashAttributes.id = elementID.replace("-", "_") + "_player";
			flashAttributes.name = flashAttributes.id;
			flashAttributes.style = "outline: none";
			
			flashVars.playerID = flashAttributes.id;
			
			swfobject.embedSWF(playerURL, elementID, instanceOptions.width.toString(), "24", "8.0.0", false, flashVars, flashParams, flashAttributes);
			
			instances.push(flashAttributes.id);
	    },
		
		syncVolumes: function (playerID, volume) {	
			currentVolume = volume;
			for (var i = 0; i < instances.length; i++) {
				if (instances[i] != playerID) {
					getMovie(instances[i]).setVolume(currentVolume);
				}
			}
		},
		
		activate: function (playerID) {
			if (activeInstance) {
				activeInstance.closePlayer();
			}
			
			activeInstance = getMovie(playerID);
		},
		
		getVolume: function (playerID) {
			return currentVolume;
		}
		
	}
	
}();
