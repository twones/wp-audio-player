package net.onepixelout.audio {
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.events.Event;
	
	public class Player {
		private var _playlist:Playlist; // Current loaded playlist
		private var _loadingPlaylist:Boolean;
	
		private var _playhead:Sound; // The player head
		private var  _channel:SoundChannel;
		private var _volume:Number;
		
		// For fading volume when pausing
		private var _fadeVolume:Number;
		private var _fadeClearID:Number;
		
		// State
		private var _state:Number;
	
		// State constants
		public static const NOTFOUND:Number = -1;
		public static const INITIALISING:Number = 0;
		public static const STOPPED:Number = 1;
		public static const PAUSED:Number = 2;
		public static const PLAYING:Number = 3;
		
		private var _isBuffering:Boolean;
		private var _isConnecting:Boolean;
	
		private var _duration:Number; // Current track duration (in ms)
		private var _position:Number; // Current track position (in ms)
		private var _loaded:Number; // Percentage of track loaded (0 to 1)
		private var _played:Number; // Percentage of track played (0 to 1)
		
		private var _recordedPosition:Number; // When paused, play head position is stored here
		private var _startPlaying:Boolean;
		
		// Buffering detection variables
		private var _playCounter:Number;
		private var _lastPosition:Number;
		
		private var _clearID:Number; // In case we need to stop the periodical function
		private var _delayID:Number; // For calling a method with a delay
		
		// Local connection broadcaster
		//private var _lcBroadcaster:LcBroadcast;
		
		private var _playOnInit:Boolean;
		
		// Options structure
		private var _options:Object = {
			initialVolume:60,
			enableCycling:true,
			syncVolumes:true,
			killDownloads:true,
			bufferTime:5
		};
		
		/**
		* Constructor
		* @param options these get written to the internal _options structure
		*/
		function Player(options:Object = {}):void {
			// Write options to internal options structure
			_setOptions(options);
			
			// Initialise properties
			_volume = _options.initialVolume;
			_state = INITIALISING;
			_loadingPlaylist = false;
			_playOnInit = false;
			_reset();
			
			// Run watcher every 10ms
			_clearID = setInterval(_watch, 50);
			
			// Create listener for local connection broadcaster
			/*var listen = new Object();
			listen.onBroadcast = Delegate.create(this, _receiveMessage);
			listen.onInit = Delegate.create(this, _activate);*/
			
			// Create local connection broadcaster
			//_lcBroadcaster = new LcBroadcast("net.1pixelout.audio.Player");
			
			// Add the listener
			//_lcBroadcaster.addListener(listen);
		}
		
		/**
		* Writes options object to internal options struct
		* @param	options
		*/
		private function _setOptions(options:Object):void {
			for (var key:String in options) {
				_options[key] = options[key];
			}
		}
	
		/**
		* Resets player
		*/
		private function _reset():void {
			_duration = 0;
			_position = 0;
			_loaded = 0;
			_played = 0;
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
		public function play():void {
			// If already playing, do nothing
			if (_state == PLAYING) {
				return;
			}
			
			// If player is still initialising, wait for it
			if (_state == INITIALISING) {
				_playOnInit = true;
				return;
			}
			
			_setBufferTime(_recordedPosition);
			
			// Load current track and get reference to the sound object
			var currentTrack:Track = this.getCurrentTrack();
			_playhead = currentTrack.load();
			
			if (_state == STOPPED) {
				_isConnecting = true;
			}
			_state = PLAYING;
	
			this.setVolume();
			
			_channel = _playhead.play(Math.floor(_recordedPosition / 1000));
			
			// Setup onSoundComplete event
			//if(_playhead.onSoundComplete == undefined) _playhead.onSoundComplete = Delegate.create(this, next);
			_channel.addEventListener(Event.SOUND_COMPLETE, next);
			
			// Update stats now (don't wait for watcher to kick in)
			_updateStats();
			
			// Tell any other players to stop playing (don't want no cacophony do we?)
			//_lcBroadcaster.broadcast({msg:"pause", id:_lcBroadcaster.internalID});
		}
		
		/**
		* Pauses the player
		*/
		public function pause():void {
			// Pause button is also play button when player is paused
			if (_state == PAUSED) {
				this.play();
				return;
			}
			
			// If player isn't playing, do nothing
			if (_state < PLAYING) {
				return;
			}
			
			// Start a fade out
			_fadeVolume  = _volume;
			_fadeClearID = setInterval(_fadeOut, 50);
			
			_state = PAUSED;
		}
		
		/**
		* Stops the player (also pauses download)
		*/
		public function stop(broadcast:Boolean = true):void {
			// Tell anyone interested that the player has stopped
			if (broadcast) {
				//broadcastMessage("onStop");
			}
			
			// Stop playhead and unload track (stops download);
			_playhead.stop();
			this.getCurrentTrack().unLoad();
			_playhead = null;
			
			_state = STOPPED;
			_reset();
		}

	}
	
}