class Main
{
	static function main()
	{
		var params:Object = new Object();
		
		params.src = "http://downloads.bbc.co.uk/rmhttp/downloadtrial/radio4/inourtime/inourtime_20070104-0900_40_st.mp3"; // Simulate for now. Should be: _root.src;
		//params.src = "09_Dancing_with_Kadafi.mp3,04_Halfway_To_A_Threeway.mp3,adbusters.mp3";
		params.initialVolume = 5; // Simulate for now. Should be: _root.volume;
		params.loop = false; // Simulate for now. Should be: _root.loop;
		params.autostart = false; // Simulate for now. Should be: _root.autostart;
		
		var app = new App(params);
	}
}