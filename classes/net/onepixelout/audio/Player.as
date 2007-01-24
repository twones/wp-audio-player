import mx.utils.Delegate;
import net.onepixelout.audio.*;
import com.freesome.events.LcBroadcast;

class net.onepixelout.audio.Player
{
	private var _playlist:Playlist; // Current loaded playlist
	private var _playlistXML:XML; // XML packet describing the playlist (only used when playlist is loaded from XML file)
	private var _loadingPlaylist:Boolean;

	private var _playhead:Sound; // The player head
	private var _volume:Number;
	
	// For fading volume when pausing
	private var _fadeVolume:Number;
	private var _fadeClearID:Number;
	
	// State constants
	static var NOTFOUND:Number = -1;
	static var INITIALISING:Number = 0;
	static var STOPPED:Number = 1;
	static var PAUSED:Number = 2;
	static var PLAYING:Number = 3;
	
	static var _isBuffering:Boolean;
	static var _isConnecting:Boolean;

	public var duration:Number; // Current song duration (in ms)
	public var position:Number; // Current song position (in ms)
	public var loaded:Number; // Percentage of song loaded (0 to 1)
	public var played:Number; // Percentage of song played (0 to 1)
	
	private var _recordedPosition:Number; // When paused, play head position is stored here
	private var _startPlaying:Boolean;
	
	private var _playCounter:Number;
	private var _lastPosition:Number;
	
	// Initial state
	public var state:Number;

	private var _clearID:Number; // In case we need to stop the periodical function
	
	private var _lcBroadcast:LcBroadcast;
	private var _playOnInit:Boolean;
	
	private var _options:Object = {
		initialVolume:70,
		pauseDownload:false,
		enableCycling:true
	};
	
	function Player(options:Object)
	{
		if(options != undefined) _setOptions(options);
		
		_volume = _options.initialVolume;
		
		this.state = INITIALISING;
		
		_reset();
		
		_clearID = setInterval(this, "_watch", 10);
		
		_playOnInit = false;
		
		// Create listener
		var listen = new Object();
		listen.onBroadcast = Delegate.create(this, _receiveMessage);
		listen.onInit = Delegate.create(this, _activate);
		
		_lcBroadcast = new LcBroadcast();
		
		// Add the listener
		_lcBroadcast.addListener(listen);
		
		_loadingPlaylist = false;
	}
	
	private function _activate():Void
	{
		if(this.state == INITIALISING) this.state = STOPPED;
		if(_playOnInit && !_loadingPlaylist)
		{
			this.play();
			_playOnInit = false;
		}
	}
	
	private function _receiveMessage(ob:Object):Void
	{
		if(ob.id == _lcBroadcast.internalID) return;
		switch(ob.msg)
		{
			case "stop":
				if(this.state == PLAYING) this.pause();
				break;
				
			default:
				break;
		}
	}
	
	private function _setOptions(options:Object):Void
	{
		for(var key:String in options) _options[key] = options[key];
	}
	
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
	
	public function loadPlaylist(songFileList:String):Void
	{
		_playlist = new Playlist(_options.enableCycling);
		_playlist.loadFromList(songFileList);
	}
	
	public function loadXMLPlaylist(xmlURL:String):Void
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
	}
	
	public function getCurrentSong():Song
	{
		return _playlist.getCurrent();
	}
	
	public function play():Void
	{
		if(this.state == PLAYING) return;
		
		if(this.state == INITIALISING)
		{
			_playOnInit = true;
			return;
		}
		
		var currentSong:Song = this.getCurrentSong();
		_playhead = currentSong.load();
		if(_playhead.onSoundComplete == undefined)
		{
			_playhead.onSoundComplete = Delegate.create(this, next);
		}
		
		if(currentSong.isLoaded())
		{
			_start(_recordedPosition);
			return;
		}
		
		if(this.state == STOPPED) _isConnecting = true;
		
		this.state = PLAYING;
		
		_startPlaying = true;
	}
	
	private function _start(newPosition:Number, broadcast:Boolean):Void
	{
		this.state = PLAYING;
		
		// Set buffer
		if(this.getCurrentSong().isLoaded()) _root._soundbuftime = 0;
		else _root._soundbuftime = 5;
		
		this.setVolume();
		_playhead.start(Math.round(newPosition / 1000));
		
		// Broadcast message to other players if required
		if(broadcast == undefined || broadcast) _lcBroadcast.broadcast({msg:"pause", id:_lcBroadcast.internalID});
	}
	
	public function pause():Void
	{
		if(this.state == PAUSED)
		{
			this.play();
			return;
		}
		
		if(this.state < PLAYING) return;
		
		_fadeVolume  = _volume;
		_fadeClearID = setInterval(this, "_fadeOut", 50);
		
		this.state = PAUSED;
	}
	
	private function _fadeOut():Void
	{
		_fadeVolume -= 8;
		if(_fadeVolume <= 0)
		{
			clearInterval(_fadeClearID);
			var currentSong:Song = this.getCurrentSong();
			_recordedPosition = _playhead.position;
			_playhead.stop();
			if(_options.pauseDownload) _playhead = currentSong.unLoad();
		}
		else _playhead.setVolume(_fadeVolume);
	}
	
	public function stop():Void
	{
		_playhead.stop();
		_playhead = this.getCurrentSong().unLoad();
		this.state = STOPPED;
		_reset();
	}
	
	public function moveHead(newPosition:Number):Void
	{
		if(this.state == PAUSED) _recordedPosition = this.duration * newPosition;
		else
		{
			_playhead.stop();
			_start(duration * newPosition);
			_updateStats();
		}
	}
	
	public function next():Void
	{
		if(this.state == INITIALISING) return;
		var startPlaying:Boolean = (this.state == PLAYING);
		this.stop();
		_playlist.next();
		if(startPlaying) this.play();
	}

	public function previous():Void
	{
		if(this.state == INITIALISING) return;
		var startPlaying:Boolean = (this.state == PLAYING);
		this.stop();
		_playlist.previous();
		if(startPlaying) this.play();
	}

	private function _updateStats():Void
	{
		// Update song stats (make sure the song has started loading to calculate the values)
		if(_playhead.getBytesTotal() > 0)
		{
			_isConnecting = false;
			
			this.loaded = _playhead.getBytesLoaded() / _playhead.getBytesTotal();
			
			if(this.loaded == 1) this.duration = _playhead.duration; // Get real duration because the sound is fully loaded
			else if(_playhead.id3.TLEN != undefined) this.duration = parseInt(_playhead.id3.TLEN); // Get duration from ID3 tag
			else this.duration = (1 / this.loaded) * _playhead.duration; // This is an estimate
			
			if(_playhead.position > 0)
			{
				this.position = _playhead.position;
				this.played = this.position / this.duration;
			}
			
			var currentSong:Song = this.getCurrentSong();
			if(!currentSong.isID3Loaded() && _playhead.id3.songname.length > 0) currentSong.setInfo();
		}
	}
	
	private function _watch():Void
	{
		var currentSong:Song = this.getCurrentSong();
		if(this.state > NOTFOUND && !_loadingPlaylist && !currentSong.exists())
		{
			_reset();
			this.state = NOTFOUND;
			return;
		}
		
		if(this.state > STOPPED) _updateStats();
		
		if(_startPlaying)
		{
			// Important: We have to use real values from playhead here
			var playable:Number = _playhead.getBytesLoaded() / _playhead.getBytesTotal() * _playhead.duration;
			if(playable > _recordedPosition)
			{
				_start(_recordedPosition);
				_startPlaying = false;
			}
			else return;
		}

		if(this.state == PLAYING)
		{
			// Buffering detection
			_playCounter++;
			if(_playCounter == 10)
			{
				_playCounter = 0;
				_isBuffering = (this.position == _lastPosition);
				_lastPosition = position;
			}
		}
	}
	
	public function setVolume(newVolume:Number):Void
	{
		// If we have a new value for volume, set it
		if(newVolume != undefined) _volume = newVolume;
		// Set the player volume
		_playhead.setVolume(_volume);
	}
	
	public function isBuffering():Boolean
	{
		return _isBuffering;
	}
	public function isConnecting():Boolean
	{
		return _isConnecting;
	}
}