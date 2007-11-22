/*extern UFO */

var AudioPlayer = {
    setup : function (playerURL, defaultOptions) {
        this.playerURL = playerURL;
        this.defaultOptions = defaultOptions;
    },
    
    embed : function (elementID, options) {
        var key;
        var instanceOptions = {};
        var flashvars = "";
        var separator = "";
        var realSeparator = "&";
		var wmode;
		var bgcolor;
        
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

        var FO = {
            movie: this.playerURL,
            width: instanceOptions.width.toString(),
            height: "24",
            wmode: wmode,
            menu: "false",
            bgcolor: bgcolor,
            majorversion: "6",
            build: "0",
            id: elementID.replace("-", "_") + "_player",
            name: elementID.replace("-", "_") + "_player",
            swliveconnect: "true"
        };
        
        for (key in instanceOptions) {
			if (["pagebg","width","transparentbg"].indexOf(key) > -1) {
				continue;
			}
            flashvars += separator + key + "=" + instanceOptions[key];
            separator = realSeparator;
        }
        
        FO.flashvars = flashvars;

        UFO.create(FO, elementID);
    }
};