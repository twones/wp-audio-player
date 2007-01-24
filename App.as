import mx.utils.Delegate;
import net.onepixelout.audio.*;

class App
{
	// Enterframe functions
	private var watchers:Array;
	
	// Next depth (incremented everytime it's used)
	private var nextDepth:Number;
	
	// Stage elements
	private var trace_txt:TextField;
	private var play_btn:MovieClip;
	private var pause_btn:MovieClip;
	private var stop_btn:MovieClip;
	private var previous_btn:MovieClip;
	private var next_btn:MovieClip;
	private var volume_slider:Slider;
	private var progress_slider:Slider;
	private var parameters:Object;
	
	private var player:Player;
	
	function App(params:Object)
	{
		parameters = params;
		
		watchers = new Array();
		
		player = new Player({ pauseDownload:true, initialVolume:parameters.initialVolume });
		
		player.loadPlaylist(parameters.src);
		//player.loadXMLPlaylist();

		setStage();
		
		if(parameters.autostart) player.play();
		
		addWatcher(printState);

		_root.onEnterFrame = Delegate.create(this, runWatchers);
	}
	
	private function setStage():Void
	{
		nextDepth = 0;
		trace("Setting stage");
		
		_root.createTextField("trace_txt", nextDepth++, 10, 10, 200, 200);
		trace_txt = _root.trace_txt;
		trace_txt.multiline = true;
		trace_txt.wordWrap = true;
		trace_txt.backgroundColor = 0xFFFFFF;
		trace_txt.border = true;
		
		play_btn = createButton("play_btn", 10, 220, 0xff0000);
		pause_btn = createButton("pause_btn", 70, 220, 0x00ff00);
		stop_btn = createButton("stop_btn", 130, 220, 0x0000ff);
		previous_btn = createButton("previous_btn", 10, 250, 0xdddddd);
		next_btn = createButton("next_btn", 70, 250, 0x666666);
		
		play_btn.onRelease = Delegate.create(player, player.play);
		pause_btn.onRelease = Delegate.create(player, player.pause);
		stop_btn.onRelease = Delegate.create(player, player.stop);
		next_btn.onRelease = Delegate.create(player, player.next);
		previous_btn.onRelease = Delegate.create(player, player.previous);
		
		volume_slider = new Slider("volume_slider", _root, nextDepth++, 0xdddddd, 0x666666, {onDrag:Delegate.create(player, player.setVolume)});
		volume_slider.moveTo(10,280);
		volume_slider.setPosition(parameters.initialVolume);

		progress_slider = new Slider("progress_slider", _root, nextDepth++, 0xdddddd, 0x666666, {onRelease:Delegate.create(player, player.moveHead)});
		progress_slider.moveTo(10,300);

		addWatcher(moveProgressBar);
	}
	
	public function moveProgressBar():Void
	{
		progress_slider.setPosition(player.played * 100);
		progress_slider.setMax(player.loaded * 100);
	}

	private function createButton(name, x, y, color):MovieClip
	{
		var button:MovieClip = _root.createEmptyMovieClip(name, nextDepth++);

		button._x = x;
		button._y = y;
		button.beginFill(color);
		button.moveTo(0,0);
		button.lineTo(50,0);
		button.lineTo(50,20);
		button.lineTo(0,20);
		button.lineTo(0,0);
		button.endFill();
		
		return button;
	}
	
	public function printState():Void
	{
		trace_txt.text = "State: " + player.state + "\n";
		trace_txt.text += "Connecting: " + player.isConnecting() + "\n";
		trace_txt.text += "Buffering: " + player.isBuffering() + "\n";
		trace_txt.text += "Song: " + player.getCurrentSong().getInfo().songname + "\n";
		//trace_txt.text += "Volume: " + player.getVolume() + "\n";
		trace_txt.text += "Position: " + Math.round(player.position / 1000) + "s\n";
		trace_txt.text += "Duration: " + Math.round(player.duration) / 1000 + "s\n";
		trace_txt.text += "Played: " + Math.round(player.played * 100) + "%\n";
		trace_txt.text += "Loaded: " + Math.round(player.loaded * 100) + "%\n";
	}
	
	public function addWatcher(fn:Function):Void
	{
		watchers.push(fn);
	}
	
	public function runWatchers():Void
	{
		var func:Function;
		for(var i:Number=0;i<watchers.length;i++){
			func = watchers[i];
			func.apply(this);
		}
	}
}