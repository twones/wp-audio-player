class Main
{
	static function main()
	{
		if(_root.soundfile != undefined) _root.soundFile = _root.soundfile;
		if(_root.soundFile == undefined) _root.soundFile = "http://www.1pixelout.net/audio/adbusters.mp3,http://downloads.bbc.co.uk/rmhttp/downloadtrial/radio4/inourtime/inourtime_20070315-0900_40_st.mp3";

		//_root.animation = "no";
		
		var options:Object = new Object();
		if(_root.autostart == "yes") options.autostart = true;
		else if(_root.autostart == "no") options.autostart = false;
		if(_root.animation == "no") options.animation = false;
		else if(_root.animation == "yes") options.animation = true;
		if(_root.loop == "yes") options.loop = true;
		else if(_root.loop == "no") options.loop = false;
		if(_root.titles != undefined) options.titles = _root.titles;
		if(_root.artists != undefined) options.artists = _root.artists;
		
		Application.start(_root.soundFile, options);
	}
}