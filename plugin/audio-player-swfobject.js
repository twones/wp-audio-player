var AudioPlayer = {

	setup:function(playerURL, width, wmode, bgcolor, defaultOptions)
	{
		this.playerURL = playerURL;
		this.width = width;
		this.wmode = wmode;
		this.bgcolor = bgcolor;
		this.defaultOptions = defaultOptions;
	},
	
	embed:function(elementID, options)
	{
		var key;
		var instanceOptions = {};
		for(key in this.defaultOptions) instanceOptions[key] = this.defaultOptions[key];
		for(key in options) instanceOptions[key] = options[key];
		
		var so = new SWFObject(this.playerURL, elementID.replace("-", "_") + "_player", this.width.toString(), "24", "6", this.bgcolor);
		so.addParam("wmode", this.wmode);
		so.addParam("menu", false);
		
		for(key in instanceOptions) so.addVariable(key, instanceOptions[key]);

		so.write(elementID);
	}

};