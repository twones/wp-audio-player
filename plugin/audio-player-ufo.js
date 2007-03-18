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
		var FO = {
			movie:this.playerURL,
			width:this.width.toString(),
			height:"24",
			wmode:this.wmode,
			menu:"false",
			bgcolor:this.bgcolor,
			majorversion:"6",
			build:"0"
		};
		var key;
		var instanceOptions = {};
		for(key in this.defaultOptions) instanceOptions[key] = this.defaultOptions[key];
		for(key in options) instanceOptions[key] = options[key];
		
		var flashvars = "";
		var separator = "";
		var realSeparator = "&";		
		for(key in instanceOptions)
		{
			flashvars += separator + key + "=" + encodeURIComponent(instanceOptions[key]);
			separator = realSeparator;
		}
		FO.flashvars = flashvars;

		UFO.create(FO, elementID);
	}

};