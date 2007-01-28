﻿import net.onepixelout.audio.*;

class App
{
	private var _player:Player;
	
	private var masked_mc:MovieClip;
	private var background_mc:MovieClip;
	private var progress_mc:MovieClip;
	private var loading_mc:MovieClip;
	private var mask_mc:MovieClip;
	private var display_mc:MovieClip;
	private var control_mc:MovieClip;
	private var volume_mc:MovieClip;
	
	private var _state:Number;
	private var _clearID:Number;
	
	private var CLOSED:Number = 0;
	private var CLOSING:Number = 1;
	private var OPENING:Number = 2;
	private var OPEN:Number = 3;
	
	private var _options:Object = {
		autostart:false,
		loop:false,
		animation:true,
		volume:70
	};

	/**
	* Constructor
	*/
	function App(sourceFile:String, options:Object)
	{
		if(options != undefined) _setOptions(options);
		
		var playerParams:Object = new Object();

		playerParams.initialVolume = _options.volume;
		playerParams.enableCycling = _options.loop;

		// Create audio player instance and load playlist
		_player = new Player(playerParams);
		_player.loadPlaylist(sourceFile);
		
		// TODO: remove need for _global reference
		_global.player = _player;
		
		// Initial player state
		_state = CLOSED;
		if(!_options.animation || _options.autostart) _state = OPEN;
		
		if(_options.autostart) onPlay();

		_setStage();
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
	* Initial stage setup
	* Adds elements to stage and links up various listeners
	*/
	private function _setStage():Void
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

		// Play/pause control
		control_mc = _root.attachMovie("Control", "control_mc", nextDepth++);
		
		control_mc.addListener(this);
		
		// Align and resize elements to the stage
		_alignAndResize();
		
		// Set stage listener in case the stage is resized
		Stage.addListener(this);
	}
	
	/**
	* Positions and resizes elements on the stage
	*/
	private function _alignAndResize():Void
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
	public function onResize():Void
	{
		_alignAndResize();
	}
	
	/**
	* onPlay event handler
	*/
	public function onPlay()
	{
		_player.play();
		
		// If player is already open, stop here
		if(_state == OPEN) return;
		
		_state = OPENING;
		
		var targetPosition:Number = Stage.width - control_mc.realWidth;
		if(_clearID != null) clearInterval(_clearID);
		_clearID = setInterval(this, "_animate", 41, targetPosition);
	}
	
	/**
	* onPause event handler
	*/
	public function onPause()
	{
		_player.pause();
		
		// If animation is disabled, stop here
		if(!_options.animation) return;
		
		_state = CLOSING;
		
		// Hide text display (doesn't work under a mask)
		display_mc._visible = false;

		var targetPosition:Number = volume_mc.realWidth - 6;
		if(_clearID != null) clearInterval(_clearID);
		_clearID = setInterval(this, "_animate", 41, targetPosition);
	}	

	/**
	* Moves control element to the given target position (with easing)
	* @param	targetX target position of control element
	*/
	private function _animate(targetX:Number)
	{
		var dx:Number = targetX - control_mc._x;
		var speed:Number = 0.5;
		
		// Stop animation when we are at less than a pixel from the target
		if(Math.abs(dx) <= 1)
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
			else _state = CLOSED;
			return;
		}
		
		dx = Math.round(dx * speed);
		control_mc._x += dx;
		mask_mc._width += dx;
	}
}