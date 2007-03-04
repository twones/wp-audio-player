import net.onepixelout.audio.*;

class App
{
	// Audio Player
	private static var _player:Player;
	
	// UI Elements
	private static var masked_mc:MovieClip;
	private static var background_mc:MovieClip;
	private static var progress_mc:MovieClip;
	private static var loading_mc:MovieClip;
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
	private static var _colorKeys:Array = ["bg","leftbg","lefticon","voltrack","volslider","rightbg","rightbghover","righticon","righticonhover","text","track","border","loader","tracker"];
	
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
		text:0x333333,
		slider:0xCCCCCC,
		track:0xFFFFFF,
		border:0xCCCCCC,
		loader:0x009900,
		tracker:0xDDDDDD	
	};
	
	// Options structure
	private static var _options:Object = {
		autostart:false,
		loop:false,
		animation:true,
		volume:80
	};

	/**
	* Starts app
	* @param sourceFile a list of mp3 files to play
	* @param options a structure of options
	*/
	public static function start(sourceFile:String, options:Object)
	{
		if(options != undefined) _setOptions(options);
		
		var playerParams:Object = new Object();

		playerParams.initialVolume = _options.volume;
		playerParams.enableCycling = _options.loop;

		// Create audio player instance and load playlist
		_player = new Player(playerParams);
		_player.loadPlaylist(sourceFile);
		
		_player.addListener(App);
		
		// Initial player state
		_state = CLOSED;
		if(!_options.animation || _options.autostart) _state = OPEN;
		
		_setStage();
		
		_setColors(_colorScheme);

		// Start player automatically if requested
		if(_options.autostart) onPlay();
		
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
		progress_mc.addListener(App);
		loading_mc = masked_mc.attachMovie("Loading", "loading_mc", 2);
		
		// Mask
		mask_mc = _root.attachMovie("Mask", "mask_mc", nextDepth++);
		masked_mc.setMask(mask_mc);
		mask_mc._width = 8;
		
		// Text display
		display_mc = _root.attachMovie("Display", "display_mc", nextDepth++);
		if(_state == CLOSED) display_mc._visible = false;
		
		// Volume control
		volume_mc = _root.attachMovie("Volume", "volume_mc", nextDepth++);
		volume_mc.addListener(App);

		// Play/pause control
		control_mc = _root.attachMovie("Control", "control_mc", nextDepth++, { state:_options.autostart ? "pause" : "play" });
		control_mc.addListener(App);
		
		// Align and resize elements to the stage
		_alignAndResize();
		
		// Set stage listener in case the stage is resized
		Stage.addListener(App);
	}
	
	/**
	* Positions and resizes elements on the stage
	*/
	private static function _alignAndResize():Void
	{
		// ------------------------------------------------------------
		// Align elements
		background_mc._x = volume_mc.realWidth - 7;
		
		progress_mc._x = volume_mc.realWidth + 4;
		progress_mc._y = 2;
		
		loading_mc._x = volume_mc.realWidth + 4;
		loading_mc._y = 20;
		
		mask_mc._x = volume_mc.realWidth - 7;
		
		display_mc._x = volume_mc.realWidth + 7;
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

		// Call resize methods on composite elements
		progress_mc.resize(availSpace - 8);
		loading_mc.resize(availSpace - 8);
		display_mc.resize(availSpace - 12);
	}
	
	/**
	* Applies colour scheme to player
	* @param	colors a structure of color keys (e.g. colors.bg = 0x000000)
	*/
	private static function _setColors(colors:Object):Void
	{
		// Map colours to player elements
		var colorTransforms = [
			{ target:background_mc, color:colors.bg },
			{ target:volume_mc.background_mc, color:colors.leftbg },
			{ target:volume_mc.icon_mc, color:colors.lefticon },
			{ target:volume_mc.control_mc.track_mc, color:colors.voltrack },
			{ target:volume_mc.control_mc.bar_mc, color:colors.volslider },
			{ target:control_mc.background_mc.normal_mc, color:colors.rightbg },
			{ target:control_mc.background_mc.hover_mc, color:colors.rightbghover },
			{ target:control_mc.play_mc.normal_mc, color:colors.righticon },
			{ target:control_mc.play_mc.hover_mc, color:colors.righticonhover },
			{ target:control_mc.pause_mc.normal_mc, color:colors.righticon },
			{ target:control_mc.pause_mc.hover_mc, color:colors.righticonhover },
			{ target:loading_mc.bar_mc, color:colors.loader },
			{ target:loading_mc.track_mc, color:colors.track },
			{ target:progress_mc.track_mc, color:colors.track },
			{ target:progress_mc.bar_mc, color:colors.tracker },
			{ target:progress_mc.border_mc, color:colors.border },
			{ target:display_mc.display_txt, color:colors.text }
		];
		
		// Apply colours
		var tempColor:Color;
		for(var i:Number = 0;i<colorTransforms.length;i++)
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
		// Toggle play button state
		control_mc.toggle();
	}
	
	/**
	* onPause event handler
	*/
	public static function onPause():Void
	{
		_player.pause();
		
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
	public static function onSetVolume(volume:Number):Void
	{
		_player.setVolume(volume);
	}

	// ------------------------------------------------------------
	// Open / close animation
	
	/**
	* Starts open animation
	*/
	public static function openPlayer():Void
	{
		_state = OPENING;
		
		volume_mc.toggleControl(true);

		var targetPosition:Number = Stage.width - control_mc.realWidth;
		if(_clearID != null) clearInterval(_clearID);
		_clearID = setInterval(_animate, 41, targetPosition);
	}

	/**
	* Starts close animation
	*/
	public static function closePlayer():Void
	{
		_state = CLOSING;
		
		// Hide text display (doesn't work under a mask)
		display_mc._visible = false;

		volume_mc.toggleControl(false);

		var targetPosition:Number = volume_mc.realWidth - 6;
		if(_clearID != null) clearInterval(_clearID);
		_clearID = setInterval(_animate, 41, targetPosition);
	}
	
	/**
	* Moves control element to the given target position (with easing)
	* @param	targetX target position of control element
	*/
	private static function _animate(targetX:Number):Void
	{
		var dx:Number = targetX - control_mc._x;
		var speed:Number = 0.5;

		dx = Math.round(dx * speed);

		// Stop animation when we are at less than a pixel from the target
		if(Math.abs(dx) < 1)
		{
			// Position the control element to the exact target position
			control_mc._x = targetX;
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
	
	/**
	* General periodical update method. It performs the following:
	* 	Updates various UI element states (volume, control, progress bar and loading bar)
	*/
	private static function _update():Void
	{
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
		
		// Update text display
		switch(playerState.state)
		{
			case Player.NOTFOUND:
				display_mc.setText("File not found");
				// Also toggle control button
				if(control_mc.state == "pause") control_mc.toggle();
				break;
			case Player.INITIALISING:
				display_mc.setText("Initialising...");
				break;
			case Player.PLAYING:
			case Player.PAUSED:
				if(playerState.connecting) display_mc.setText("Connecting...");
				else if(playerState.buffering) display_mc.setText("Buffering...");
				else if(playerState.trackInfo.artist.length > 0)
				{
					display_mc.setText(playerState.trackInfo.artist + ": " + playerState.trackInfo.songname);
				}
				else display_mc.setText("Playing");
				break;
			default:
				display_mc.setText("");
				break;
		}
		
		// Set colour scheme at runtime
		if(_root.setcolors)
		{
			// Update colour scheme from root variables (can be set via javascript)
			for(var i:Number = 0;i<_colorKeys.length;i++)
			{
				if(_root[_colorKeys[i]] != undefined) _colorScheme[_colorKeys[i]] = _root[_colorKeys[i]];
			}
			
			// Apply the new colour scheme
			_setColors(_colorScheme);

			_root.setcolors = 0;
		}
	}
}