class Main
{
	static function main()
	{
		if(_root.soundfile == undefined) _root.soundfile = "http://www.1pixelout.net/audio/adbusters.mp3";

		var options:Object = new Object();
		if(_root.autostart == "yes") options.autostart = true;
		else if(_root.autostart == "no") options.autostart = false;
		if(_root.animation == "no") options.animation = false;
		else if(_root.animation == "yes") options.animation = true;
		if(_root.loop == "yes") options.loop = true;
		else if(_root.loop == "no") options.loop = false;
		
		Application.start(_root.soundfile, options);
	}
}