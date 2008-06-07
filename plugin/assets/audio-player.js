var AudioPlayer = {
    setup : function (playerURL, defaultOptions) {
        this.playerURL = playerURL;
        this.defaultOptions = defaultOptions;
    },
    
    embed : function (elementID, options) {
        var instanceOptions = {};
        var key;
        var so;
		var bgcolor;
		var wmode;
		
		var flashParams = {};
		var flashVars = {};
		var flashAttributes = {};

        // Merge default options and instance options
		for (key in this.defaultOptions) {
            instanceOptions[key] = this.defaultOptions[key];
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
		flashAttributes.style = "outline: none";

        swfobject.embedSWF(this.playerURL, elementID, instanceOptions.width.toString(), "24", "6.0.0", false, flashVars, flashParams, flashAttributes);
    }
};
