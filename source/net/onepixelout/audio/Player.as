package net.onepixelout.audio {
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.events.Event;
	import flash.utils.*;
	import net.onepixelout.audio.Playlist;
	import flash.events.EventDispatcher;
	
	public class Player extends EventDispatcher {
		private var _playlist:Playlist; // Current loaded playlist
		
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
		function Player(options:Object):void {
			// Write options to internal options structure
			_setOptions(options);
			
			// Initialise properties
			_volume = _options.initialVolume;
			_state = STOPPED;
			_reset();
			
			// Run watcher every 10ms
			_clearID = setInterval(_watch, 50);
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
		}
		
		/**
		* Starts the player
		*/
		public function play():void {
			// If already playing, do nothing
			if (_state == PLAYING) {
				return;
			}
			
			_setBufferTime(_recordedPosition);
			
			// Load current track and get reference to the sound object
			var currentTrack:Track = this.getCurrentTrack();
			_playhead = currentTrack.load();

			_channel = _playhead.play(_recordedPosition);
			this.setVolume();
			
			_state = PLAYING;
			
			// Setup onSoundComplete event
			if (!_channel.hasEventListener(Event.SOUND_COMPLETE)) {
				_channel.addEventListener(Event.SOUND_COMPLETE, next);
			}
			
			// Update stats now (don't wait for watcher to kick in)
			_updateStats();
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
				dispatchEvent(new PlayerEvent(PlayerEvent.TRACK_STOP));
			}
			
			// Stop playhead and unload track (stops download);
			this.getCurrentTrack().unLoad();
			_playhead = null;
			
			_state = STOPPED;
			_reset();
		}
		
		/**
		* Moves player head to a new position
		* @param newPosition a number between 0 and 1
		*/
		public function moveHead(newHeadPosition:Number):void {
			// Ignore if player is not playing or paused
			if (_state < PAUSED) {
				return;
			}
			
			var newPosition:Number = _duration * newHeadPosition;
			
			// Player in paused state: simply record the new position
			if (_state == PAUSED) {
				_recordedPosition = newPosition;
			} else {
				// Otherwise, stop player, calculate new buffer time and restart player
				_channel.stop();
				_setBufferTime(newPosition);
				_channel = _playhead.play(newPosition);
			}
			
			// Update stats now (don't wait for watcher to kick in)
			_updateStats();
		}
		
		/**
		* Moves to next track in playlist
		* If player is playing, start the track
		*/
		public function next():void {
			// Ignore if player is still initialising
			if (_state == INITIALISING) {
				return;
			}
			
			var startPlaying:Boolean = (_state == PLAYING || _state == NOTFOUND);
	
			if (_playlist.next() != null && startPlaying) {
				this.stop(false);
				this.play();
			} else {
				this.stop(true);
			}
		}
	
		/**
		* Moves to previous track in playlist
		* If player is playing, start the track
		*/
		public function previous():void {
			// Ignore if player is still initialising
			if (_state == INITIALISING) {
				return;
			}
			
			var startPlaying:Boolean = (_state == PLAYING);
			
			if (_playlist.previous() != null && startPlaying) {
				this.stop(false);
				this.play();
			} else {
				this.stop(false);
			}
		}
		
		/**
		* Sets the player volume
		* @param newVolume number between 0 and 100
		* @param broadcast if true, a setvolume message is broadcast to any other players to synchronise volumes
		*/
		public function setVolume(newVolume:Number = -1, broadcast:Boolean = false):void {
			clearInterval(_delayID);
			
			// If we have a new value for volume, set it
			if (newVolume != -1) {
				_volume = newVolume;
			}
			
			// Set the player volume
			if (_state > STOPPED) {
				var transform:SoundTransform = _channel.soundTransform;
				transform.volume = _volume / 100;
				_channel.soundTransform = transform;
			}
		}
		
		/**
		* Returns a snapshot of the current state of the player
		* @return a structure of values describing the current state
		*/
		public function getState():Object {
			var result:Object = {};
			
			result.state = _state;
			result.buffering = _isBuffering;
			result.connecting = _isConnecting;
			result.loaded = _loaded;
			result.played = _played;
			result.duration = _duration;
			result.position = _position;
			result.volume = _volume;
			result.trackIndex = _playlist.getCurrentIndex();
			result.hasNext = _playlist.hasNext();
			result.hasPrevious = _playlist.hasPrevious();
			result.trackCount = _playlist.length;
			
			result.trackInfo = this.getCurrentTrack().getInfo();
			
			return result;
		}
		
		/**
		* Fades player out
		*/
		private function _fadeOut():void {
			_fadeVolume -= 20;
			if (_fadeVolume <= 20) {
				clearInterval(_fadeClearID);
				_recordedPosition = _channel.position;
				if (getCurrentTrack().isFullyLoaded()) {
					_channel.stop();
				} else {
					_playhead.close();
				}
			} else {
				var transform:SoundTransform = _channel.soundTransform;
				transform.volume = _fadeVolume / 100;
			}
		}
		
		/**
		* Updates playhead statistics (loaded, played, duration and position)
		* Also triggers track information update (when ID3 is available)
		*/
		private function _updateStats():void {
			if(_state > STOPPED && _playhead.bytesTotal > 0) {
				// Flash has started downloading the file
				_isConnecting = false;
				
				// Get current track
				var currentTrack:Track = this.getCurrentTrack();
				
				// If current track is fully loaded, no need to calculate loaded and duration
				if (currentTrack.isFullyLoaded()) {
					_loaded = 1;
					_duration = _playhead.length;
				} else {
					_loaded = _playhead.bytesLoaded / _playhead.bytesTotal;
				
					// Get real duration because the sound is fully loaded
					if (_loaded == 1) {
						_duration = _playhead.length;
					} else if(_playhead.id3.TLEN != undefined) {
						// Get duration from ID3 tag
						_duration = parseInt(_playhead.id3.TLEN);
					} else {
						// This is an estimate
						_duration = (1 / _loaded) * _playhead.length;
					}
				}
				
				// Update position and played values if playhead is reading
				if (_channel.position > 0) {
					_position = _channel.position;
					_played = _position / _duration;
				}
			}
		}
		
		/**
		* Watches player state. This method is run periodically (see constructor)
		*/
		private function _watch():void {
			// Get current track
			var currentTrack:Track = this.getCurrentTrack();
			
			// If the mp3 file doesn't exit
			if (_state > NOTFOUND && !currentTrack.exists()) {
				// Reset player
				_reset();
				_state = NOTFOUND;
				return;
			}
			
			// Update statistics
			_updateStats();
			
			// Buffering detection
			if (_state == PLAYING) {
				_isBuffering = _playhead.isBuffering;
			}
		}
		
		public function isBuffering():Boolean {
			return _isBuffering;
		}
		
		public function isConnecting():Boolean {
			return _isConnecting;
		}
		
		/**
		* Sets the buffer time to a maximum of 5 seconds (or whatever the bufferTime option is set to).
		* 
		* @param newPosition Position of playhead
		*/
		private function _setBufferTime(newPosition:Number):void {
			// No buffering needed if file is fully loaded
			if (this.getCurrentTrack().isFullyLoaded()) {
				SoundMixer.bufferTime = 0;
				return;
			}
			
			// Otherwise, look at how much audio is playable and set buffer accordingly
			var currentBuffer:Number = Math.round(((_loaded * _duration) - newPosition) / 1000);
			
			if (currentBuffer >= _options.bufferTime) {
				SoundMixer.bufferTime = 0;
			} else {
				SoundMixer.bufferTime = _options.bufferTime - currentBuffer;
			}
		}
		
		/**
		* Loads a list of mp3 files onto a playlist
		* @param trackFileList
		*/
		public function loadPlaylist(trackFileList:String, titleList:String = "", artistList:String = ""):void {
			_playlist = new Playlist(_options.enableCycling);
			_playlist.loadFromList(trackFileList, titleList, artistList);
		}
		
		/**
		* Returns the number of tracks in the playlist
		* @return the number of tracks
		*/
		public function getTrackCount():Number {
			return _playlist.length;
		}
	
		/**
		* Returns current track from the playlist
		* @return the current track object
		*/
		public function getCurrentTrack():Track {
			return _playlist.getCurrent();
		}

	}
	
}