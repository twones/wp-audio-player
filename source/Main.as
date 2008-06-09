package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	//import net.onepixelout.audio.*;
	
	[SWF( backgroundColor='0', frameRate='35', height='24', width='290')]
	
	public class Main extends MovieClip
	{
		// Audio Player
		//private static var _player:Player;
		
		// UI Elements
		private var masked_mc:MovieClip;
		private var background_mc:Sprite;
		private var progress_mc:MovieClip;
		private var loading_mc:MovieClip;
		private var next_mc:MovieClip;
		private var previous_mc:MovieClip;
		private var mask_mc:Sprite;
		private var display_mc:MovieClip;
		private var control_mc:MovieClip;
		private var volume_mc:MovieClip;
		
		// State variables
		private var _state:int;
		
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
			bufferTime:5,
			volume:60
		};
		
		public function Main():void {
			_state = CLOSED;
			if (_options.demomode || !_options.animation || _options.autostart) {
				_state = OPEN;
			}
			
			_setStage();
		}
		
		/**
		* Initial stage setup
		* Adds elements to stage and links up various listeners
		*/
		private function _setStage():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			stage.addEventListener(Event.RESIZE, resizeHandler);
			// TODO: look at mouseLeave event
	
			// Add elements to stage
			
			// Masked elements
			masked_mc = new MovieClip();
			background_mc = new Background();
			masked_mc.addChild(background_mc);
			progress_mc = new Progress();
			masked_mc.addChild(progress_mc);
			addEventListener(ProgressEvent.PROGRESS_CHANGE, progressChangeHandler);
			loading_mc = new Loading();
			masked_mc.addChild(loading_mc);
			
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
			addEventListener(VolumeEvent.VOLUME_CHANGE, volumeHandler);
			
			control_mc = new Control();
			addChild(control_mc);
			addEventListener(ControlEvent.PLAY, playHandler);
			addEventListener(ControlEvent.PAUSE, pauseHandler);
			
			_alignAndResize();
			
			if (_options.demomode) {
				control_mc.toggle();
				volume_mc.toggleControl(true);
				volume_mc.update(_options.volume);
				progress_mc.updateProgress(0.3);
				loading_mc.update(0.6);
				display_mc.setText("1 Pixel Out: Demo Mode", 0, true);
				display_mc.setTime(356560, _options.remaining);
				//previous_mc._alpha = 50;
			}
		}
		
		/**
		* Positions and resizes elements on the stage
		*/
		private function _alignAndResize():void {
			// ------------------------------------------------------------
			// Align elements
			background_mc.x = volume_mc.realWidth - 7;
			
			var trackCount:uint = 1;
			//var trackCount:uint = _player.getTrackCount();
			
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
			
			/*if (_options.demomode || trackCount > 1) {
				next_mc.x = stage.stageWidth - 43;
				next_mc.y = 12;
				previous_mc.x = volume_mc.realWidth + 6;
				previous_mc.y = 12;
			}*/
			
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
		public function resizeHandler():void {
			_alignAndResize();
		}
		
		public function playHandler(evt:Event):void {
			//_player.play();
			
			// Show volume control
			volume_mc.toggleControl(true);
			
			// If player is closed and animation is enabled, open the player
			if (_state < OPENING && _options.animation) {
				openPlayer();
			}
		}
		
		public function stopHandler():void {
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
			//_player.pause();
			
			// Hide volume control
			volume_mc.toggleControl(false);
			
			// If player is open and animation is enabled, close the player
			if (_state > CLOSING && _options.animation) {
				closePlayer();
			}
		}
		
		public function progressChangeHandler(evt:Event):void {
			//_player.moveHead(evt.newPosition);
		}
		
		public function volumeHandler(evt:Event):void {
			// Set the volume and force a broadcast of the changed volume
			//_player.setVolume(evt.newVolume, evt.final);
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

	}
	
}