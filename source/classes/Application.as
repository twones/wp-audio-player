import net.onepixelout.audio.*;

class Application
{
	// Audio Player
	private static var _player:Player;
	
	// UI Elements
	private static var masked_mc:MovieClip;
	private static var background_mc:MovieClip;
	private static var progress_mc:MovieClip;
	private static var loading_mc:MovieClip;
	private static var next_mc:MovieClip;
	private static var previous_mc:MovieClip;
	private static var mask_mc:MovieClip;
	private static var display_mc:MovieClip;
	private static var control_mc:MovieClip;
	private static var volume_mc:MovieClip;
	
	// State variables
	private static var _state:Number;
	
	private static var CLOSED:Number = 0;
	private static var CLOSING:Number = 1;
	private static var OPENING:Number = 2;
	private static var OPEN:Number = 3;

	// Interval ID for animation
	private static var _clearID:Number;
	
	// List of color keys
	private static var _colorKeys:Array = ["bg","leftbg","lefticon","voltrack","volslider","rightbg","rightbghover","righticon","righticonhover","text","track","border","loader","tracker","skip"];
	
	// Holds the current colour scheme (initialise with default colour scheme)
	private static var _colorScheme:Object = {
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
	private static var _options:Object = {
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

	/**
	* Starts app
	* @param sourceFile a list of mp3 files to play
	* @param options a structure of options
	*/
	public static function start(sourceFile:String, options:Object):Void
	{
		if(options != undefined) _setOptions(options);
		
		if(!_options.demomode && _options.encode) sourceFile = _sixBitDecode(sourceFile);
		
		if(!_options.demomode) {
			var playerParams:Object = new Object();
	
			playerParams.initialVolume = _options.volume;
			playerParams.bufferTime = _options.bufferTime;
			playerParams.enableCycling = _options.loop;

			// Create audio player instance and load playlist
			_player = new Player(playerParams);
			
			var trackTitles:String = (_options.titles != undefined) ? _options.titles : "";
			var trackArtists:String = (_options.artists != undefined) ? _options.artists : "";
			_player.loadPlaylist(sourceFile, trackTitles, trackArtists);
		
			if(!_options.demomode) _player.addListener(Application);
		}
		
		// Initial player state
		_state = CLOSED;
		if(_options.demomode || !_options.animation || _options.autostart) _state = OPEN;
		
		_setStage();
		
		_setColors(true);

		// Start player automatically if requested
		if(!_options.demomode && _options.autostart) onPlay();
		
		setInterval(_update, 100);
	}
	
	/**
	* Writes options object to internal options struct
	* @param	options
	*/
	private static function _setOptions(options:Object):Void
	{
		for(var key:String in options) _options[key] = options[key];
	}
	
	/**
	* Initial stage setup
	* Adds elements to stage and links up various listeners
	*/
	private static function _setStage():Void
	{
		// Align UI to left and make sure it isn't scaled
		Stage.align = "L";
		Stage.scaleMode = "noScale";

		// Add elements to stage
		
		// Depth counter
		var nextDepth:Number = _root.getNextHighestDepth();
		
		// Masked elements
		masked_mc = _root.createEmptyMovieClip("masked_mc", nextDepth++);
		background_mc = masked_mc.attachMovie("Background", "background_mc", 0);
		progress_mc = masked_mc.attachMovie("Progress", "progress_mc", 1);
		progress_mc.addListener(Application);
		loading_mc = masked_mc.attachMovie("Loading", "loading_mc", 2);
		
		// Next and previous buttons (if needed)
		if(_options.demomode || _player.getTrackCount() > 1)
		{
			next_mc = masked_mc.attachMovie("Toggle", "next_mc", 3);
			previous_mc = masked_mc.attachMovie("Toggle", "previous_mc", 4);
			// Make it point the other way
			previous_mc._rotation = -180;
			
			if(!_options.demomode) {
				// Add event handlers
				next_mc.onRelease = function() {
					Application._player.next();
					// Reset time display
					Application.display_mc.setTime(0);
				};
				previous_mc.onRelease = function() {
					Application._player.previous();
					// Reset time display
					Application.display_mc.setTime(0);
				};
			}
		}
		
		// Mask
		mask_mc = _root.attachMovie("Mask", "mask_mc", nextDepth++);
		masked_mc.setMask(mask_mc);
		mask_mc._width = 8;
		
		// Text display
		display_mc = _root.attachMovie("Display", "display_mc", nextDepth++);
		if(_state == CLOSED) display_mc._visible = false;
		
		// Volume control
		volume_mc = _root.attachMovie("Volume", "volume_mc", nextDepth++);
		volume_mc.addListener(Application);

		// Play/pause control
		control_mc = _root.attachMovie("Control", "control_mc", nextDepth++, { state:_options.autostart ? "pause" : "play" });
		control_mc.addListener(Application);
		
		// Align and resize elements to the stage
		_alignAndResize();

		if(_options.demomode) {
			control_mc.toggle();
			volume_mc.toggleControl(true);
			volume_mc.update(_options.volume);
			progress_mc.updateProgress(0.3);
			loading_mc.update(0.6);
			display_mc.setText("1 Pixel Out: Demo Mode", 0, true);
			display_mc.setTime(356560, _options.remaining);
			previous_mc._alpha = 50;
		}
		
		// Set stage listener in case the stage is resized
		Stage.addListener(Application);
	}
	
	/**
	* Positions and resizes elements on the stage
	*/
	private static function _alignAndResize():Void
	{
		// ------------------------------------------------------------
		// Align elements
		background_mc._x = volume_mc.realWidth - 7;
		
		var trackCount = _player.getTrackCount();
		
		progress_mc._x = volume_mc.realWidth + 4;
		if(_options.demomode || trackCount > 1) progress_mc._x += 8;
		progress_mc._y = 2;
		
		loading_mc._x = volume_mc.realWidth + 4;
		if(_options.demomode || trackCount > 1) loading_mc._x += 8;
		loading_mc._y = 20;
		
		if(_options.demomode || trackCount > 1)
		{
			next_mc._x = Stage.width - 43;
			next_mc._y = 12;
			previous_mc._x = volume_mc.realWidth + 6;
			previous_mc._y = 12;
		}
		
		mask_mc._x = volume_mc.realWidth - 7;
		
		display_mc._x = volume_mc.realWidth + 6;
		if(_options.demomode || trackCount > 1) display_mc._x += 8;
		display_mc._y = 2;
		
		// Control element alignment depends on whether player is open or closed
		if(_state == CLOSED) control_mc._x = volume_mc.realWidth - 6;
		else control_mc._x = Stage.width - control_mc.realWidth;

		// ------------------------------------------------------------
		// Resize elements
		
		// Available space between volume and control elements
		var availSpace:Number = Stage.width - (control_mc.realWidth + volume_mc.realWidth);

		background_mc._width = availSpace + 14;
		// Only resize mask if player is open
		if(_state == OPEN) mask_mc._width = availSpace + 14;
		
		if(_options.demomode || trackCount > 1) availSpace -= 12;

		// Call resize methods on composite elements
		progress_mc.resize(availSpace - 8);
		loading_mc.resize(availSpace - 8);
		display_mc.resize(availSpace - 12);
	}
	
	/**
	* Applies colour scheme to player
	* @param	force if true, don't check _root.setcolors
	*/
	private static function _setColors(force:Boolean):Void
	{
		var i:Number;
		var colorValue:String;
		
		if (!force && !_root.setcolors) {
			return;
		}
		
		// Update colour scheme from root variables (set via javascript)
		for (i = 0;i < _colorKeys.length;i++)
		{
			if (_root[_colorKeys[i]] != undefined) {
				// Handle missing '0x' prefixes
				colorValue = _root[_colorKeys[i]];
				if (colorValue.indexOf("0x") == -1) {
					colorValue = "0x" + colorValue;
				}
				_colorScheme[_colorKeys[i]] = colorValue;
			}
		}
		
		_root.setcolors = 0;
		
		// Map colours to player elements
		var colorTransforms:Array = [
			{ target:background_mc, color:_colorScheme.bg },
			{ target:volume_mc.background_mc, color:_colorScheme.leftbg },
			{ target:volume_mc.icon_mc, color:_colorScheme.lefticon },
			{ target:volume_mc.control_mc.track_mc, color:_colorScheme.voltrack },
			{ target:volume_mc.control_mc.bar_mc, color:_colorScheme.volslider },
			{ target:control_mc.background_mc.normal_mc, color:_colorScheme.rightbg },
			{ target:control_mc.background_mc.hover_mc, color:_colorScheme.rightbghover },
			{ target:control_mc.play_mc.normal_mc, color:_colorScheme.righticon },
			{ target:control_mc.play_mc.hover_mc, color:_colorScheme.righticonhover },
			{ target:control_mc.pause_mc.normal_mc, color:_colorScheme.righticon },
			{ target:control_mc.pause_mc.hover_mc, color:_colorScheme.righticonhover },
			{ target:loading_mc.bar_mc, color:_colorScheme.loader },
			{ target:loading_mc.track_mc, color:_colorScheme.track },
			{ target:progress_mc.track_mc, color:_colorScheme.track },
			{ target:progress_mc.bar_mc, color:_colorScheme.tracker },
			{ target:progress_mc.border_mc, color:_colorScheme.border },
			{ target:next_mc, color:_colorScheme.skip },
			{ target:previous_mc, color:_colorScheme.skip },
			{ target:display_mc.message_txt, color:_colorScheme.text },
			{ target:display_mc.time_txt, color:_colorScheme.text }
		];
		
		// Apply colours
		var tempColor:Color;
		for(i = 0;i<colorTransforms.length;i++)
		{
			if(typeof(colorTransforms[i].target) == "movieclip")
			{
				tempColor = new Color(colorTransforms[i].target);
				tempColor.setRGB(colorTransforms[i].color);
			} else colorTransforms[i].target.textColor = colorTransforms[i].color;
		}
	}
	
	// ------------------------------------------------------------
	// Event handlers
	
	/**
	* onResize event handler
	*/
	public static function onResize():Void
	{
		_alignAndResize();
	}
	
	/**
	* onPlay event handler
	*/
	public static function onPlay():Void
	{
		_player.play();
		
		// Show volume control
		volume_mc.toggleControl(true);
		
		// If player is closed and animation is enabled, open the player
		if(_state < OPENING && _options.animation) openPlayer();
	}
	
	/**
	* onStop event handler
	*/
	public static function onStop():Void
	{
		// If player is open and animation is enabled, close the player
		if(_options.animation && _state > CLOSING) closePlayer();
		
		// Hide volume control
		volume_mc.toggleControl(false);
		
		// Toggle play button state (only if it's in pause state)
		if(control_mc.state == "pause") control_mc.toggle();
	}
	
	/**
	* onPause event handler
	*/
	public static function onPause():Void
	{
		_player.pause();
		
		// Hide volume control
		volume_mc.toggleControl(false);
		
		// If player is open and animation is enabled, close the player
		if(_state > CLOSING && _options.animation) closePlayer();
	}

	/**
	* onMoveHead event handler
	* @param	newPositon number form 0 to 1
	*/
	public static function onMoveHead(newPosition:Number):Void
	{
		_player.moveHead(newPosition);
	}
	
	/**
	 * onSetVolume event handler
	 */
	public static function onSetVolume(volume:Number, final:Boolean):Void
	{
		if(final == undefined) final = true;
		// Set the volume and force a broadcast of the changed volume
		_player.setVolume(volume, final);
	}

	// ------------------------------------------------------------
	// Open / close animation
	
	/**
	* Starts open animation
	*/
	public static function openPlayer():Void
	{
		_state = OPENING;
		
		var targetPosition:Number = Stage.width - control_mc.realWidth;
		if(_clearID != null) clearInterval(_clearID);
		_clearID = setInterval(_animate, 40, targetPosition);
	}

	/**
	* Starts close animation
	*/
	public static function closePlayer():Void
	{
		_state = CLOSING;
		
		// Hide text display (doesn't work under a mask)
		display_mc._visible = false;

		var targetPosition:Number = volume_mc.realWidth - 6;
		if(_clearID != null) clearInterval(_clearID);
		_clearID = setInterval(_animate, 40, targetPosition);
	}
	
	/**
	* Moves control element to the given target position (with easing)
	* @param	targetX target position of control element
	*/
	private static function _animate(targetX:Number):Void
	{
		var dx:Number = targetX - control_mc._x;
		var speed:Number = 0.5;

		dx = dx * speed;

		// Stop animation when we are at less than a pixel from the target
		if(Math.abs(dx) < 1)
		{
			// Position the control element to the exact target position
			control_mc._x = targetX;
			mask_mc._width += (dx*2);
			clearInterval(_clearID);
			if(_state == OPENING)
			{
				// Show text display
				display_mc._visible = true;
				_state = OPEN;
			}
			else{
				_state = CLOSED;
			}
			return;
		}
		
		control_mc._x += dx;
		mask_mc._width += dx;
	}
	
	// ------------------------------------------------------------
	// Periodical update method

	/**
	* General periodical update method. It performs the following:
	* Updates various UI element states (volume, control, progress bar and loading bar)
	*/
	private static function _update():Void
	{
		// Set colour scheme at runtime
		_setColors(false);

		if(_options.demomode) {
			return;
		}
		
		// Get player state (head positions, stats etc)
		var playerState:Object = _player.getState();
		
		// Update volume control state
		volume_mc.update(playerState.volume);

		// Enable / disable control button
		control_mc.enabled = (playerState.state >= Player.STOPPED);
		
		// Update progress bar if necessary
		if(playerState.state != Player.PAUSED) progress_mc.updateProgress(playerState.played);
		
		// Tell progress bar how far it can go
		progress_mc.setMaxValue(playerState.loaded);

		// Update loading bar state
		loading_mc.update(playerState.loaded);
		
		if(playerState.trackCount > 1)
		{
			next_mc.enabled = playerState.hasNext;
			previous_mc.enabled = playerState.hasPrevious;
			if(playerState.hasNext) next_mc._alpha = 100;
			else next_mc._alpha = 50;
			if(playerState.hasPrevious) previous_mc._alpha = 100;
			else previous_mc._alpha = 50;
		}
		
		var trackNumber:String = "";
		
		// Update text display
		switch(playerState.state)
		{
			case Player.NOTFOUND:
				if(playerState.trackCount > 1) trackNumber = (playerState.trackIndex + 1) + " - ";
				display_mc.setText(trackNumber + "File not found", 0);
				// Also toggle control button
				if(control_mc.state == "pause") control_mc.toggle();
				display_mc.setTime(0);
				break;
			case Player.INITIALISING:
				display_mc.setText("Initialising...", 0);
				display_mc.setTime(0);
				break;
			default:
				var message = "";
				if(playerState.connecting) message = "Connecting...";
				else
				{
					if(!_options.noinfo && playerState.trackCount > 1) message = (playerState.trackIndex + 1) + ": ";
					if(playerState.buffering) message += "Buffering...";
					else if(!_options.noinfo) {
						if(playerState.trackInfo.artist.length > 0 || playerState.trackInfo.songname.length > 0)
						{
							message += playerState.trackInfo.artist;
							if(playerState.trackInfo.artist.length > 0) message += " - ";
							message += playerState.trackInfo.songname;
						}
						else message = "Track #" + (playerState.trackIndex + 1);
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
	private static function _sixBitDecode(sourceStr)
	{
		var ntexto = "";
		var nntexto = "";
		var codeKey = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
		var charCode, charChar, charCodeBin, i;
		for(i=0; i<sourceStr.length; i++)
		{
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
		return (nntexto);
	}
}