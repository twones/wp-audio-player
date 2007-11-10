/*extern SWFObject */

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
        
        // Merge default options and instance options
		for (key in this.defaultOptions) {
            instanceOptions[key] = this.defaultOptions[key];
        }
        for (key in options) {
            instanceOptions[key] = options[key];
        }
        
		if (instanceOptions.transparentpagebg == "yes") {
			bgcolor = "transparent";
			wmode = "transparent";
		} else {
			bgcolor = "#" + instanceOptions.pagebg;
			wmode = "opaque";
		}
		
        so = new SWFObject(this.playerURL, elementID.replace("-", "_") + "_player", instanceOptions.width.toString(), "24", "6", bgcolor);
        so.addParam("wmode", wmode);
        so.addParam("menu", false);
        
        for (key in instanceOptions) {
			if (["pagebg","width","transparentpagebg"].indexOf(key) > -1) {
				continue;
			}
            so.addVariable(key, instanceOptions[key]);
        }
		
        so.write(elementID);
    }
};