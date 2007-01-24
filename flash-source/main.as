function init() {
	if( bgcolor != undefined ) {
		var backgroundColor:Color = new Color(background_mc);
		backgroundColor.setRGB(parseInt(bgcolor,16));
	}
	if( iconcolor != undefined ) {
		var ledColor:Color = new Color(led_mc);
		ledColor.setRGB(parseInt(iconcolor,16));
		var playColor:Color = new Color(controls_mc.play_mc);
		playColor.setRGB(parseInt(iconcolor,16));
		var pauseColor:Color = new Color(controls_mc.pause_mc);
		pauseColor.setRGB(parseInt(iconcolor,16));
	}
	if( textcolor != undefined ) {
		_root.trackTime_txt.textColor = parseInt(textcolor,16);
		var bufferingColor:Color = new Color(buffering_mc);
		bufferingColor.setRGB(parseInt(textcolor,16));
	}
	if( barcolor != undefined ) {
		var barColor:Color = new Color(progress_mc.bar_mc);
		barColor.setRGB(parseInt(barcolor,16));
		var borderColor:Color = new Color(progress_mc.border_mc);
		borderColor.setRGB(parseInt(barcolor,16));
	}
	if( pathcolor != undefined ) {
		var pathColor:Color = new Color(progress_mc.path_mc);
		pathColor.setRGB(parseInt(pathcolor,16));
	}
	if( buttoncolor != undefined ) {
		var buttonColor:Color = new Color(controls_mc.controlbg_mc);
		buttonColor.setRGB(parseInt(buttoncolor,16));
	}
	if( buttonhovercolor != undefined ) {
		var buttonhoverColor:Color = new Color(controls_mc.controlbghover_mc);
		buttonhoverColor.setRGB(parseInt(buttonhovercolor,16));
	}

	_global.music_sound = new Sound();

	_global.isBuffering = false;
	_global.volume = 70;
	_global.fadeIn = false;
	_global.fadeOut = false;
	_global.isPlaying = false;
	_global.error = false;
	_global.isLoading = false;
	_global.isLoaded = false;

	_global.music_sound.onLoad = function() {
		_global.isLoaded = true;
	}

	_global.music_sound.onSoundComplete = function() {
		// Go back tot beginning and close player
		this.start(0, 0);
		this.stop();
		_root.led_mc.gotoAndStop("off");
		_global.isPlaying = false;
		_root.play();
	}
	
	// Play/pause button event-handler
	_root.controls_mc.control_btn.onRelease = function() {
		// Do nothing if file not found or animation is on
		if( !_global.isMoving && !_global.error ) {
			if( _global.isPlaying ) {
				// Start a fade out
				_global.fadeOut = true;
			} else {
				// Start a fade in and start the file
				_global.fadeIn = true;
				if( !_global.isLoading ) {
					_global.music_sound.loadSound( _global.soundFile, true );
					_global.isLoading = true;
				}
				_global.music_sound.start(_global.music_sound.position / 1000, 0);
			}
			// Start animation
			_root.play();
		}
	}
	
	_root.onEnterFrame = function() {
		if( _global.isLoaded || _global.music_sound.position > 0 ) _global.isBuffering = false;
		else _global.isBuffering = true;

		_root.buffering_mc._visible = _global.isBuffering;

		if( _global.error ) return;
		
		var played = _global.music_sound.getBytesLoaded() / _global.music_sound.getBytesTotal();
		var duration = 1 / played * _global.music_sound.duration;
		
		_root.trackTime_txt.text = millisecondsToString(_global.music_sound.position);
		_root.progress_mc.bar_mc._width = _global.music_sound.position / duration * _root.progress_mc.path_mc._width;

		if( _global.fadeOut ) {
			_global.music_sound.setVolume(_global.volume);
			_global.volume -= 10;
			if( _global.volume < 10 ) {
				_global.music_sound.stop();
				_root.led_mc.gotoAndStop("off");
				_global.isPlaying = false;
				_global.fadeOut = false;
			}
		}

		if( _global.fadeIn ) {
			_global.isPlaying = true;
			_global.music_sound.setVolume(_global.volume);
			_global.volume += 10;
			if( _global.volume >= 70 ) {
				_global.volume = 70;
				if( !_global.isBuffering ) {
					_root.led_mc.gotoAndPlay("on");
					_global.fadeIn = false;
				}
			}
		}
	}
	
	_root.play();
}

// Helper function: converts milliseconds to a string (HH:MM:SS)

function millisecondsToString(position) {
	var trkTimeInfo = new Date();
	var seconds, minutes;

	// Populate a date object (to convert from ms to hours/minutes/seconds)
	trkTimeInfo.setSeconds(int(position/1000));
	trkTimeInfo.setMinutes(int((position/1000)/60));

	// Get the values from date object
	seconds = trkTimeInfo.getSeconds();
	minutes = trkTimeInfo.getMinutes();

	// Build position string
	if(seconds < 10) seconds = "0" + seconds.toString();
	if(minutes < 10) minutes = "0" + minutes.toString();

	return minutes + ":" + seconds;
}