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
	
	// Options structure
	private static var _options:Object = {
		autostart:false,
		loop:false,
		animation:true,
		volume:70
	};

	/**
	* Constructor
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
		masked_mc = _root.createEmptyMovieClip("body_mc", nextDepth++);
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
		loading_mc._y = 22;
		
		mask_mc._x = volume_mc.realWidth - 7;
		
		display_mc._x = volume_mc.realWidth + 7;
		display_mc._y = 3;
		
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
		if(_state == CLOSED && _options.animation) openPlayer();
	}
	
	public static function onStop():Void
	{
		if(_options.animation && _state == OPEN) closePlayer();
		control_mc.toggle();
	}
	
	/**
	* onPause event handler
	*/
	public static function onPause():Void
	{
		_player.pause();
		
		// If player is open and animation is enabled, close the player
		if(_state == OPEN && _options.animation) closePlayer();
	}

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
	
	private static function _update():Void
	{
		var playerState:Object = _player.getState();
		
		volume_mc.update(playerState.volume);

		control_mc.enabled = (playerState.state >= Player.STOPPED);
		
		if(playerState.state != Player.PAUSED) progress_mc.updateProgress(playerState.played);
		
		progress_mc.setMaxValue(playerState.loaded);

		loading_mc.update(playerState.loaded);
		
		switch(playerState.state)
		{
			case Player.NOTFOUND:
				display_mc.setText("File not found");
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
				break;
			default:
				display_mc.setText("");
				break;
		}
	}
}