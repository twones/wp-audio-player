package {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import net.onepixelout.audio.*;
	
	[SWF( backgroundColor='0', frameRate='35', height='24', width='290')]
	
	public class Main extends MovieClip {
		
		// Audio Player
		private var _player:Player;
		
		// UI Elements
		private var masked_mc:Sprite;
		private var background_mc:Sprite;
		private var progress_mc:MovieClip;
		private var loading_mc:MovieClip;
		private var next_mc:Sprite;
		private var previous_mc:Sprite;
		private var mask_mc:Sprite;
		private var display_mc:MovieClip;
		private var control_mc:MovieClip;
		private var volume_mc:MovieClip;
		
		// State variables
		private var _state:uint;
		
		private static const CLOSED:uint = 0;
		private static const CLOSING:uint = 1;
		private static const OPENING:uint = 2;
		private static const OPEN:uint = 3;
	
		// Interval ID for animation
		private var _clearID:uint;
		
		// List of color keys
		private var _colorKeys:Array = ["bg","leftbg","lefticon","voltrack","volslider","rightbg","rightbghover","righticon","righticonhover","text","track","border","loader","tracker","skip"];
		
		// Holds the current colour scheme (initialise with default colour scheme)
		private var _colorScheme:Object = {
			bg:0xE5E5E5,
			leftbg:0xCCCCCC,
			lefticon:0x333333,
			voltrack:0xF2F2F2,
			volslider:0x666666,
			rightbg:0xB4B4B4,
			rightbghover:0x999999,
			righticon:0x333333,
			righticonhover:0xFFFFFF,
			skip:0x666666,
			text:0x333333,
			slider:0xCCCCCC,
			track:0xFFFFFF,
			border:0xCCCCCC,
			loader:0x009900,
			tracker:0xDDDDDD	
		};
		
		// Options structure
		private var _options:Object = {
			encode:false,
			autostart:false,
			loop:false,
			animation:true,
			remaining:false,
			noinfo:false,
			demomode:false,
			buffer:5,
			initialVolume:60,
			titles:"",
			artists:""
		};
		
		public function Main():void {
			var params:Object = loaderInfo.parameters;
			
			var options:Object = {};
			var soundFile:String = "";
			
			for (var key:String in params) {
				if (key == "soundfile" || key == "soundFile") {
					soundFile = params[key];
				} else if (params[key] == "yes") {
					options[key] = true;
				} else if (params[key] == "no") {
					options[key] = false;
				} else {
					options[key] = params[key];
				}
			}
			
			_setOptions(options);
			
			if (!_options.demomode && _options.encode) {
				soundFile = _sixBitDecode(soundFile);
			}
			
			if (!_options.demomode) {
				var playerParams:Object = {};
		
				playerParams.initialVolume = _options.initialVolume;
				playerParams.bufferTime = _options.buffer;
				playerParams.enableCycling = _options.loop;
	
				// Create audio player instance and load playlist
				_player = new Player(playerParams);
				
				_player.loadPlaylist(soundFile, _options.titles, _options.artists);
				
				if (!_options.demomode) {
					_player.addEventListener(PlayerEvent.TRACK_STOP, stopHandler);
				}
			}
			
			_state = CLOSED;
			if (_options.demomode || !_options.animation || _options.autostart) {
				_state = OPEN;
			}
			
			_setStage();
			
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("closePlayer", stop);
			}
			
			setInterval(_update, 100);
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
		* Initial stage setup
		* Adds elements to stage and links up various listeners
		*/
		private function _setStage():void {
			// Stage settings
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			stage.addEventListener(Event.RESIZE, resizeHandler);
			// TODO: look at mouseLeave event
	
			// Add elements to stage
			
			// Masked elements (this elements are hidden when the player is closed)
			masked_mc = new Sprite();
			
			background_mc = new Background();
			masked_mc.addChild(background_mc);
			progress_mc = new Progress();
			masked_mc.addChild(progress_mc);
			progress_mc.addEventListener(ProgressEvent.PROGRESS_CHANGE, progressChangeHandler);
			loading_mc = new Loading();
			masked_mc.addChild(loading_mc);
			
			// Next and previous buttons (if needed)
			if (_options.demomode || _player.getTrackCount() > 1) {
				next_mc = new Toggle();
				masked_mc.addChild(next_mc);
				previous_mc = new Toggle();
				masked_mc.addChild(previous_mc);
				
				// Make it point the other way
				previous_mc.rotation = -180;
				
				if(!_options.demomode) {
					// Add event handlers
					next_mc.addEventListener(MouseEvent.CLICK, function() {
						_player.next();
						// Reset time display
						display_mc.setTime(0);
					});
					previous_mc.addEventListener(MouseEvent.CLICK, function() {
						_player.previous();
						// Reset time display
						display_mc.setTime(0);
					});
				}
			}
			
			addChild(masked_mc);
			
			// Mask
			mask_mc = new Mask();
			masked_mc.mask = mask_mc;
			mask_mc.width = 8;
			
			addChild(mask_mc);

			// Text display
			display_mc = new Display();
			if (_state == CLOSED) {
				display_mc.visible = false;
			}
			addChild(display_mc);
			
			// Volume control
			volume_mc = new Volume();
			addChild(volume_mc);
			volume_mc.addEventListener(VolumeEvent.VOLUME_CHANGE, volumeHandler);
			
			control_mc = new Control();
			addChild(control_mc);
			control_mc.addEventListener(ControlEvent.PLAY, playHandler);
			control_mc.addEventListener(ControlEvent.PAUSE, pauseHandler);
			
			_alignAndResize();
			
			if (_options.demomode) {
				control_mc.toggle();
				volume_mc.toggleControl(true);
				volume_mc.update(_options.volume);
				progress_mc.updateProgress(0.3);
				loading_mc.update(0.6);
				display_mc.setText("1 Pixel Out: Demo Mode", 0, true);
				display_mc.setTime(356560, _options.remaining);
				previous_mc.alpha = 0.5;
			}
		}
		
		/**
		* Positions and resizes elements on the stage
		*/
		private function _alignAndResize():void {
			// ------------------------------------------------------------
			// Align elements
			background_mc.x = volume_mc.realWidth - 7;
			
			var trackCount:uint = _player.getTrackCount();
			
			progress_mc.x = volume_mc.realWidth + 4;
			if (_options.demomode || trackCount > 1) {
				progress_mc.x += 8;
			}
			progress_mc.y = 2;
			
			loading_mc.x = volume_mc.realWidth + 4;
			if (_options.demomode || trackCount > 1) {
				loading_mc.x += 8;
			}
			loading_mc.y = 20;
			
			if (_options.demomode || trackCount > 1) {
				next_mc.x = stage.stageWidth - 43;
				next_mc.y = 12;
				previous_mc.x = volume_mc.realWidth + 6;
				previous_mc.y = 12;
			}
			
			mask_mc.x = volume_mc.realWidth - 7;
			
			display_mc.x = volume_mc.realWidth + 6;
			if (_options.demomode || trackCount > 1) {
				display_mc.x += 8;
			}
			display_mc.y = 2;
			
			// Control element alignment depends on whether player is open or closed
			if (_state == CLOSED) {
				control_mc.x = volume_mc.realWidth - 6;
			} else {
				control_mc.x = stage.stageWidth - control_mc.realWidth;
			}
	
			// ------------------------------------------------------------
			// Resize elements
			
			// Available space between volume and control elements
			var availSpace:Number = stage.stageWidth - (control_mc.realWidth + volume_mc.realWidth);
	
			background_mc.width = availSpace + 14;
			// Only resize mask if player is open
			if (_state == OPEN) {
				mask_mc.width = availSpace + 14;
			}
			
			if (_options.demomode || trackCount > 1) {
				availSpace -= 12;
			}
	
			// Call resize methods on composite elements
			progress_mc.resize(availSpace - 8);
			loading_mc.resize(availSpace - 8);
			display_mc.resize(availSpace - 12);
		}

		/**
		* onResize event handler
		*/
		public function resizeHandler(evt:Event):void {
			_alignAndResize();
		}
		
		public function playHandler(evt:Event):void {
			_player.play();
			
			// Show volume control
			volume_mc.toggleControl(true);
			
			// If player is closed and animation is enabled, open the player
			if (_state < OPENING && _options.animation) {
				openPlayer();
			}
		}
		
		public function stopHandler(evt:Event):void {
			// If player is open and animation is enabled, close the player
			if (_options.animation && _state > CLOSING) {
				closePlayer();
			}
			
			// Hide volume control
			volume_mc.toggleControl(false);
			
			// Toggle play button state (only if it's in pause state)
			if (control_mc.state == "pause") {
				control_mc.toggle();
			}
		}
		
		public function pauseHandler(evt:Event):void {
			_player.pause();
			
			// Hide volume control
			volume_mc.toggleControl(false);
			
			// If player is open and animation is enabled, close the player
			if (_state > CLOSING && _options.animation) {
				closePlayer();
			}
		}
		
		public function progressChangeHandler(evt:ProgressEvent):void {
			_player.moveHead(evt.newPosition);
		}
		
		public function volumeHandler(evt:VolumeEvent):void {
			// Set the volume and force a broadcast of the changed volume
			_player.setVolume(evt.newVolume, evt.final);
		}
		
		
		// ------------------------------------------------------------
		// Open / close animation
		
		public function openPlayer():void {
			_state = OPENING;
			
			var targetPosition:Number = stage.stageWidth - control_mc.realWidth;
			clearInterval(_clearID);
			_clearID = setInterval(_animate, 40, targetPosition);
		}
	
		public function closePlayer():void {
			_state = CLOSING;
			
			// Hide text display (doesn't work under a mask)
			display_mc.visible = false;
	
			var targetPosition:Number = volume_mc.realWidth - 6;
			clearInterval(_clearID);
			_clearID = setInterval(_animate, 40, targetPosition);
		}
		
		private function _animate(targetX:Number):void {
			var dx:Number = targetX - control_mc.x;
			var speed:Number = 0.5;
	
			dx = dx * speed;
	
			// Stop animation when we are at less than a pixel from the target
			if (Math.abs(dx) < 1) {
				// Position the control element to the exact target position
				control_mc.x = targetX;
				mask_mc.width += (dx*2);
				clearInterval(_clearID);
				if (_state == OPENING) {
					// Show text display
					display_mc.visible = true;
					_state = OPEN;
				} else {
					_state = CLOSED;
				}
				return;
			}
			
			control_mc.x += dx;
			mask_mc.width += dx;
		}
		
		
		// ------------------------------------------------------------
		// Periodical update method
	
		/**
		* General periodical update method. It performs the following:
		* Updates various UI element states (volume, control, progress bar and loading bar)
		*/
		private function _update():void {
			// Set colour scheme at runtime
			//_setColors(false);
			
			if (_options.demomode) {
				return;
			}
			
			// Get player state (head positions, stats etc)
			var playerState:Object = _player.getState();
			
			// Update volume control state
			volume_mc.update(playerState.volume);
			
			// Enable / disable control button
			control_mc.mouseEnabled = (playerState.state != Player.INITIALISING);
			
			// Update progress bar if necessary
			if (playerState.state != Player.PAUSED) {
				progress_mc.updateProgress(playerState.played);
			}
			
			// Tell progress bar how far it can go
			progress_mc.setMaxValue(playerState.loaded);
	
			// Update loading bar state
			loading_mc.update(playerState.loaded);
			
			if (playerState.trackCount > 1) {
				next_mc.mouseEnabled = playerState.hasNext();
				previous_mc.mouseEnabled = playerState.hasPrevious();
				
				if (playerState.hasNext) {
					next_mc.alpha = 1;
				} else {
					next_mc.alpha = 0.5;
				}
				
				if (playerState.hasPrevious) {
					previous_mc.alpha = 1;
				} else {
					previous_mc.alpha = 0.5;
				}
			}
			
			var trackNumber:String = "";
			
			// Update text display
			switch (playerState.state) {
				case Player.NOTFOUND:
					if (playerState.trackCount > 1) {
						trackNumber = (playerState.trackIndex + 1) + " - ";
					}
					display_mc.setText(trackNumber + "File not found", 0);
					display_mc.setTime(0);
					break;
					
				case Player.INITIALISING:
					display_mc.setText("Initialising...", 0);
					display_mc.setTime(0);
					break;
					
				default:
					var message:String = "";
					if (playerState.connecting) {
						message = "Connecting...";
					} else {
						if (!_options.noinfo && playerState.trackCount > 1) {
							message = (playerState.trackIndex + 1) + ": ";
						}
						if (playerState.buffering) {
							message += "Buffering...";
						} else if (!_options.noinfo) {
							if (playerState.trackInfo.artist.length > 0 || playerState.trackInfo.songName.length > 0) {
								message += playerState.trackInfo.artist;
								if (playerState.trackInfo.artist.length > 0) {
									message += " - ";
								}
								message += playerState.trackInfo.songName;
							} else {
								message = "Track #" + (playerState.trackIndex + 1);
							}
						}
					}
					display_mc.setText(message, 0, true);
					display_mc.setTime(_options.remaining ? playerState.duration - playerState.position : playerState.position, _options.remaining);
					break;
			}
		}

	
		/**
		* Decodes a 6-bit encoded string
		* Thanks to mattiasdh (mattias_d@excite.com) for this
		* http://modxcms.com/forums/index.php/topic,9340.0.html
		* @param	source the string to decode
		* @return	the decoded string
		*/
		private function _sixBitDecode(sourceStr) {
			var ntexto:String = "";
			var nntexto:String = "";
			var codeKey:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
			var charCode:uint;
			var charChar:String;
			var charCodeBin:String;
			var i:uint;
			for (i=0; i<sourceStr.length; i++) {
				charCode = codeKey.indexOf(sourceStr.substr(i,1)); // char index
				charCodeBin = ("000000" + charCode.toString(2)).substr(-6,6); // char index in binary, 6 bits
				ntexto += charCodeBin;
			}
			for (i=0; i< ntexto.length; i+=8) {
				charCodeBin = ntexto.substr(i, 8); // char code in binary
				charCode = parseInt(charCodeBin, 2);
				charChar = String.fromCharCode(charCode);
				nntexto += charChar;
			}
			return nntexto;
		}

	}
	
}