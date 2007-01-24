import mx.utils.Delegate;
import net.onepixelout.audio.Playlist;
import net.onepixelout.audio.Song;
import com.freesome.events.LcBroadcast;

class net.onepixelout.audio.Player
{
	private var playlist:Playlist; // Current loaded playlist
	private var playhead:Sound; // The player head
	public var duration:Number; // Current song duration (in ms)
	public var position:Number; // Current song position (in ms)
	public var loaded:Number; // Percentage of song loaded (0 to 1)
	public var played:Number; // Percentage of song played (0 to 1)
	private var volume:Number; // Player volume
	
	// State constants
	static var INITIALISING:String = "initialising";
	static var LOADING:String = "loading";
	static var BUFFERING:String = "buffering";
	static var PLAYING:String = "playing";
	static var STOPPED:String = "stopped";
	static var PAUSED:String = "paused";
	static var NOTFOUND:String = "not found";

	// Initial state
	public var state:String;
	public var songIsLoaded:Boolean;
	
	// Buffering detection
	private var frameCounter:Number;
	private var lastPosition:Number;
	
	// For delayed start
	private var clearID:Number;
	
	private var lcBroadcast:LcBroadcast;
	
	private var playOnInit:Boolean;

	public function Player()
	{
		state = INITIALISING;
		
		duration = 0;
		position = 0;
		loaded = 0;
		played = 0;
		
		frameCounter = 0;
		
		songIsLoaded = false;
		playOnInit = false;
		
		// Create listener
		var listen = new Object();
		listen.onBroadcast = Delegate.create(this, receiveMessage);
		listen.onInit = Delegate.create(this, activate);

		lcBroadcast = new LcBroadcast();

		// Add the listener
		lcBroadcast.addListener(listen);
	}
	
	private function activate():Void
	{
		if(state == INITIALISING) state = STOPPED;
		if(playOnInit)
		{
			play();
			playOnInit = false;
		}
	}
	
	public function receiveMessage(ob:Object):Void
	{
		if(ob.id == lcBroadcast.internalID) return;
		switch(ob.msg)
		{
			case "stop":
				if(state == PLAYING || state == BUFFERING) pause();
				break;
				
			default:
				break;
		}
	}
	
	public function loadPlaylist(songFileList:String, cyclingEnabled:Boolean):Void
	{
		trace("Loading playlist");
		
		if(cyclingEnabled == undefined) cyclingEnabled = true;
		
		// Create the playlist
		playlist = new Playlist(cyclingEnabled, songFileList.split(","));
		
		trace("Playlist loaded: " + playlist.length + " songs loaded");
	}
	
	public function loadSong():Void
	{
		if(state == INITIALISING) return;
		
		// Initialise the playhead
		playhead = new Sound();
		
		// Get the current song from the playlist
		var currentSong:Song = playlist.getCurrent();
		
		trace("Loading song '" + currentSong.src + "'");
		
		// Load the sound clip
		if(state != PAUSED) state = LOADING;
		playhead.loadSound(currentSong.src, true);
		//playhead.stop();
		songIsLoaded = true;
		
		// This will check whether the player was able to load the sound file
		playhead.onLoad = Delegate.create(Player, loadDone);
		playhead.onSoundComplete = Delegate.create(Player, next);
	}
	
	public function loadDone(success):Void
	{
		trace("Loaded");
		// If success is false, the player failed to load the file
		if(!success) state = NOTFOUND;
	}
	
	public function loadID3():Void
	{
		playlist.getCurrent().setInfo(playhead.id3.songname, playhead.id3.artist);
	}
	
	public function getCurrentSong():Song
	{
		return playlist.getCurrent();
	}
	
	public function getVolume():Number
	{
		return volume;
	}
	
	public function setVolume(newVolume:Number):Void
	{
		// If we have a new value for volume, set it
		if(newVolume != undefined) volume = newVolume;
		// Set the player volume
		playhead.setVolume(volume);
	}
	
	public function play(force:Boolean):Void
	{
		if(state == INITIALISING)
		{
			playOnInit = true;
			return;
		}

		// Default value for force. When true, we ignore the player state
		if(force == undefined) force = false;
		
		// Unless we want to force play, ignore the request if the player is already playing
		if(!force && (state == PLAYING || state == BUFFERING)) return;
		
		trace("Play!");
		
		// Load the song if needed
		if(!songIsLoaded)
		{
			loadSong();
			setVolume(); // The volume might have changed while the player was paused
			clearID = setInterval(Delegate.create(this, delayedStart), 500);
			return;
		}
		setVolume(); // The volume might have changed while the player was paused
		
		delayedStart();
	}
	
	public function delayedStart():Void
	{
		lcBroadcast.broadcast({msg:"stop", id:lcBroadcast.internalID});
		clearInterval(clearID);

		state = PLAYING;
		// Start at current position
		playhead.start(Math.round(position / 1000));
		// Update stats (for smooth transitions of slider bars)
		updateStats();
	}

	public function pause():Void
	{
		if(state == INITIALISING) return;

		trace("Pause!");
		
		if(state == PAUSED) play(); // If the player was in a paused state, start playing again
		else
		{
			// Otherwise, pause the player
			state = PAUSED;
			delete playhead;
			songIsLoaded = false;
		}
	}

	public function stop():Void
	{
		if(state == INITIALISING) return;

		trace("Stop!");
		
		state = STOPPED;
		playhead.stop();
		
		// Reset the playhead (this stops the download)
		// TODO: Make this an option
		playhead = new Sound();
		songIsLoaded = false;
	}
	
	public function moveHead(newPos:Number):Void
	{
		if(state == INITIALISING) return;

		trace("Moving head");
		// Calculate new position
		position = Math.round(duration * newPos / 100);
		
		// If the player is currently playing, force play at new position
		if(state == PLAYING) play(true);
		else
		{
			// Move the play head to new position and stop player
			playhead.start(Math.round(position / 1000));
			playhead.stop();
			
			// Force stats update
			updateStats();
		}
	}
	
	public function next():Void
	{
		if(state == INITIALISING) return;

		trace("Next!");
		stop();
		if(playlist.getNext() == null) return;
		play();
	}

	public function previous():Void
	{
		if(state == INITIALISING) return;

		trace("Previous!");
		stop();
		if(playlist.getPrevious() == null) return;
		play();
	}
	
	public function updateSongInfo():Void
	{
		var currentSong:Song = playlist.getCurrent();
		if(!currentSong.infoLoaded && playhead.id3.songname.length > 0)
		{
			currentSong.setInfo(playhead.id3.songname, playhead.id3.artist);
		}
	}

	public function updateStats():Void
	{
		// Update song stats (make sure the song has started loading to calculate the values)
		if(playhead.getBytesTotal() > 0)
		{
			loaded = playhead.getBytesLoaded() / playhead.getBytesTotal();
			duration = (1 / loaded) * playhead.duration;
			position = playhead.position;
			played = position / duration;
		}
	}
	
	public function updateState():Void
	{
		switch(state)
		{
			case PAUSED:
				frameCounter = 0;
				break;

			case BUFFERING:
			case PLAYING:
				// Buffering detection
				frameCounter++;
				if(frameCounter == 5)
				{
					frameCounter = 0;
					if(position == lastPosition) state = BUFFERING;
					else state = PLAYING;
					lastPosition = position
				}
				
				updateStats();
				break;
				
			default:
				// Reset values
				loaded = 0;
				played = 0;
				duration = 0;
				position = 0;
				lastPosition = 0;
				frameCounter = 0;
				break;
		}
	}
}