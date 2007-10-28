/*extern UFO */

var AudioPlayer = {
    setup : function (playerURL, width, wmode, bgcolor, defaultOptions) {
        this.playerURL = playerURL;
        this.width = width;
        this.wmode = wmode;
        this.bgcolor = bgcolor;
        this.defaultOptions = defaultOptions;
    },
    
    embed : function (elementID, options) {
        var key;
        var instanceOptions = {};
        var flashvars = "";
        var separator = "";
        var realSeparator = "&";
        
        var FO = {
            movie : this.playerURL,
            width : this.width.toString(),
            height : "24",
            wmode : this.wmode,
            menu : "false",
            bgcolor : this.bgcolor,
            majorversion : "6",
            build : "0",
            id : elementID.replace("-", "_") + "_player",
            name : elementID.replace("-", "_") + "_player",
            swliveconnect : "true"
        };
        
        for (key in this.defaultOptions) {
            instanceOptions[key] = this.defaultOptions[key];
        }
        
        for (key in options) {
        	if (key == "bgcolor") continue;
            instanceOptions[key] = options[key];
        }
        
        for (key in instanceOptions) {
            flashvars += separator + key + "=" + instanceOptions[key];
            separator = realSeparator;
        }
        
        FO.flashvars = flashvars;

        UFO.create(FO, elementID);
    }
};