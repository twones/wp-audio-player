import net.onepixelout.audio.*;
import com.freesome.events.LcBroadcast;
import mx.utils.Delegate;

/**
* The definitive AS2 mp3 player from 1 Pixel Out
* @author Martin Laine
*/
class net.onepixelout.audio.Player
{
	private var _playlist:Playlist; // Current loaded playlist
	private var _loadingPlaylist:Boolean;

	private var _playhead:Sound; // The player head
	private var _volume:Number;
	
	// For fading volume when pausing
	private var _fadeVolume:Number;
	private var _fadeClearID:Number;
	
	// State
	public var state:Number;

	// State constants
	static var NOTFOUND:Number = -1;
	static var INITIALISING:Number = 0;
	static var STOPPED:Number = 1;
	static var PAUSED:Number = 2;
	static var PLAYING:Number = 3;
	
	private var _isBuffering:Boolean;
	private var _isConnecting:Boolean;

	public var duration:Number; // Current track duration (in ms)
	public var position:Number; // Current track position (in ms)
	public var loaded:Number; // Percentage of track loaded (0 to 1)
	public var played:Number; // Percentage of track played (0 to 1)
	
	private var _recordedPosition:Number; // When paused, play head position is stored here
	private var _startPlaying:Boolean;
	
	// Buffering detection variables
	private var _playCounter:Number;
	private var _lastPosition:Number;
	
	private var _clearID:Number; // In case we need to stop the periodical function
	
	private var _lcBroadcaster:LcBroadcast;
	private var _playOnInit:Boolean;
	
	private var _options:Object = {
		initialVolume:70,
		enableCycling:true
	};
	
	/**
	* Constructor
	* @param options these get written to the internal _options structure
	*/
	function Player(options:Object)
	{
		// Write options to internal options structure
		if(options != undefined) _setOptions(options);
		
		// Initialise properties
		_volume = _options.initialVolume;
		this.state = INITIALISING;
		_loadingPlaylist = false;
		_playOnInit = false;
		_reset();
		
		// Run watcher every 10ms
		_clearID = setInterval(this, "_watch", 50);
		
		// Create listener for local connection broadcaster
		var listen = new Object();
		listen.onBroadcast = Delegate.create(this, _receiveMessage);
		listen.onInit = Delegate.create(this, _activate);
		
		// Create local connection broadcaster
		_lcBroadcaster = new LcBroadcast();
		
		// Add the listener
		_lcBroadcaster.addListener(listen);
	}
	
	/**
	* Writes options object to internal options struct
	* @param	options
	*/
	private function _setOptions(options:Object):Void
	{
		for(var key:String in options) _options[key] = options[key];
	}
	
	/**
	* Resets player
	*/
	private function _reset():Void
	{
		this.duration = 0;
		this.position = 0;
		this.loaded = 0;
		this.played = 0;
		_isBuffering = false;
		_isConnecting = false;
		_recordedPosition = 0;
		_startPlaying = false;
		_lastPosition = 0;
		_playCounter = 0;
	}
	
	/**
	* Starts the player
	*/
	public function play():Void
	{
		// If already playing, do nothing
		if(this.state == PLAYING) return;
		
		// If player is still initialising, wait for it
		if(this.state == INITIALISING)
		{
			_playOnInit = true;
			return;
		}
		
		_setBufferTime(_recordedPosition);
		
		// Load current track and get reference to the sound object
		var currentTrack:Track = this.getCurrentTrack();
		_playhead = currentTrack.load();
		
		// Setup onSoundComplete event
		if(_playhead.onSoundComplete == undefined) _playhead.onSoundComplete = Delegate.create(this, next);
		
		this.setVolume();
		
		_playhead.start(Math.floor(_recordedPosition / 1000));
		
		// Update stats now (don't wait for watcher to kick in)
		_updateStats();
		
		if(this.state == STOPPED) _isConnecting = true;
		this.state = PLAYING;

		// Broadcast message to other players
		_lcBroadcaster.broadcast({msg:"pause", id:_lcBroadcaster.internalID});
	}
	
	/**
	* Pauses the player
	*/
	public function pause():Void
	{
		// Pause button is also play button when player is paused
		if(this.state == PAUSED)
		{
			this.play();
			return;
		}
		
		// If player isn't playing, do nothing
		if(this.state < PLAYING) return;
		
		// Start a fade out
		_fadeVolume  = _volume;
		_fadeClearID = setInterval(this, "_fadeOut", 50);
		
		this.state = PAUSED;
	}

	/**
	* Stops the player (also pauses download)
	*/
	public function stop():Void
	{
		_playhead.stop();
		_playhead = this.getCurrentTrack().unLoad();
		this.state = STOPPED;
		_reset();
	}

	/**
	* Moves player head to a new position
	* @param newPosition a number between 0 and 1
	*/
	public function moveHead(newHeadPosition:Number):Void
	{
		// Ignore if player is not playing or paused
		if(this.state < PAUSED) return;
		
		var newPosition:Number = this.duration * newHeadPosition;
		/*var playable:Number = this.duration * this.loaded;
		
		trace("Play at: " + newPosition);
		trace("Playable: " + playable);
		
		// If track is not fully loaded, never try to play less than 500ms before end of playable audio
		if(this.loaded < 1 && (playable - newPosition) < 1000) newPosition = playable - 1000;

		trace("Really play at: " + newPosition);*/
		
		// Player in paused state: simply record the new position
		if(this.state == PAUSED) _recordedPosition = newPosition;
		else
		{
			// Otherwise, stop player, calculate new buffer time and restart player
			_playhead.stop();
			_setBufferTime(newPosition);
			_playhead.start(Math.floor(newPosition / 1000));
		}
		
		// Update stats now (don't wait for watcher to kick in)
		_updateStats();
	}

	/**
	* Moves to next track in playlist
	* If player is playing, start the track
	*/
	public function next():Void
	{
		// Ignore if player is still initialising
		if(this.state == INITIALISING) return;
		
		var startPlaying:Boolean = (this.state == PLAYING);

		// This stops any downloading that may still be going on
		this.stop();
		
		_playlist.next();
		if(startPlaying) this.play();
	}

	/**
	* Moves to previous track in playlist
	* If player is playing, start the track
	*/
	public function previous():Void
	{
		// Ignore if player is still initialising
		if(this.state == INITIALISING) return;
		
		var startPlaying:Boolean = (this.state == PLAYING);
		
		// This stops any downloading that may still be going on
		this.stop();
		
		_playlist.previous();
		if(startPlaying) this.play();
	}

	/**
	* Sets the player volume
	* @param newVolume number between 0 and 100
	*/
	public function setVolume(newVolume:Number):Void
	{
		// If we have a new value for volume, set it
		if(newVolume != undefined) _volume = newVolume;
		// Set the player volume
		_playhead.setVolume(_volume);
	}
	
	/**
	* Returns current player volume as a percentage
	* @return number between 0 and 100
	*/
	public function getVolume():Number
	{
		return _volume;
	}

	/**
	* Fades player out
	*/
	private function _fadeOut():Void
	{
		_fadeVolume -= 20;
		if(_fadeVolume <= 20)
		{
			clearInterval(_fadeClearID);
			_recordedPosition = _playhead.position;
			_playhead.stop();
		}
		else _playhead.setVolume(_fadeVolume);
	}
	
	/**
	* Updates playhead statistics (loaded, played, duration and position)
	* Also triggers track information update (when ID3 is available)
	*/
	private function _updateStats():Void
	{
		if(_playhead.getBytesTotal() > 0)
		{
			// Flash has started downloading the file
			_isConnecting = false;
			
			// Get current track
			var currentTrack:Track = this.getCurrentTrack();
			
			// If current track is fully loaded, no need to calculate loaded and duration
			if(currentTrack.isFullyLoaded()) {
				this.loaded = 1;
				this.duration = _playhead.duration;
			}
			else
			{
				this.loaded = _playhead.getBytesLoaded() / _playhead.getBytesTotal();
			
				// Get real duration because the sound is fully loaded
				if(this.loaded == 1) this.duration = _playhead.duration;
				// Get duration from ID3 tag
				else if(_playhead.id3.TLEN != undefined) this.duration = parseInt(_playhead.id3.TLEN);
				// This is an estimate
				else this.duration = (1 / this.loaded) * _playhead.duration;
			}
			
			// Update position and played values if playhead is reading
			if(_playhead.position > 0)
			{
				this.position = _playhead.position;
				this.played = this.position / this.duration;
			}
			
			// Update track info if ID3 tags are available
			if(!currentTrack.isID3Loaded() && _playhead.id3.songname.length > 0) currentTrack.setInfo();
		}
	}
	
	/**
	* Watches player state. This method is run periodically (see constructor)
	*/
	private function _watch():Void
	{
		// Get current track
		var currentTrack:Track = this.getCurrentTrack();
		
		// If the mp3 file doesn't exit
		if(this.state > NOTFOUND && !_loadingPlaylist && !currentTrack.exists())
		{
			// Reset player
			_reset();
			this.state = NOTFOUND;
			return;
		}
		
		// Update statistics
		_updateStats();
		
		// Buffering detection
		if(this.state == PLAYING)
		{
			if(++_playCounter == 2)
			{
				_playCounter = 0;
				_isBuffering = (this.position == _lastPosition);
				_lastPosition = this.position;
			}
		}
	}
	
	public function isBuffering():Boolean
	{
		return _isBuffering;
	}
	public function isConnecting():Boolean
	{
		return _isConnecting;
	}

	/**
	* Sets the buffer time to a maximum of 5 seconds.
	* 
	* @param newPosition Position of playhead
	*/
	private function _setBufferTime(newPosition:Number):Void
	{
		// No buffering needed if file is fully loaded
		if(this.getCurrentTrack().isFullyLoaded())
		{
			_root._soundbuftime = 0;
			return;
		}
		
		// Otherwise, look at how much audio is playable and set buffer accordingly
		
		var currentBuffer:Number = Math.round(((this.loaded * this.duration) - newPosition) / 1000);
		
		if(currentBuffer >= 5) _root._soundbuftime = 0;
		else _root._soundbuftime = 5 - currentBuffer;
	}
	
	/**
	* Loads a list of mp3 files onto a playlist
	* @param trackFileList
	*/
	public function loadPlaylist(trackFileList:String):Void
	{
		_playlist = new Playlist(_options.enableCycling);
		_playlist.loadFromList(trackFileList);
	}

	/**
	* Returns current track from the playlist
	* @return the current track object
	*/
	public function getCurrentTrack():Track
	{
		return _playlist.getCurrent();
	}

	/*public function loadXMLPlaylist(xmlURL:String):Void
	{
		if(xmlURL == undefined) xmlURL = "playlist.xml";
		_playlistXML = new XML();
		_playlistXML.ignoreWhite = true;
		_playlistXML.onLoad = Delegate.create(this, _receivePlaylistXML);
		_playlistXML.load(xmlURL);
		_loadingPlaylist = true;
	}
	
	private function _receivePlaylistXML(success:Boolean):Void
	{
		if(!success)
		{
			trace("XML not found");
			this.state = NOTFOUND;
			return;
		}
		_playlist = new Playlist(_options.enableCycling);
		_playlist.loadFromXML(_playlistXML);
		_loadingPlaylist = false;
		if(this.state != INITIALISING && _playOnInit)
		{
			this.play();
			_playOnInit = false;
		}
	}*/
	
	/**
	* Activates player when local connection broadcaster has initialised
	*/
	private function _activate():Void
	{
		if(this.state == INITIALISING) this.state = STOPPED;
		if(_playOnInit && !_loadingPlaylist)
		{
			this.play();
			_playOnInit = false;
		}
	}
	
	/**
	* Receives messages from local connection broadcaster
	* @param parameters contains id (th broadcaster id and the msg string)
	*/
	private function _receiveMessage(parameters:Object):Void
	{
		// Ignore messages from this player
		if(parameters.id == _lcBroadcaster.internalID) return;
		switch(parameters.msg)
		{
			case "pause":
				if(this.state == PLAYING) this.pause();
				break;
				
			default:
				break;
		}
	}
}