/*
Plugin Name: Audio player
Plugin URI: http://www.1pixelout.net/code/audio-player-wordpress-plugin/
Description: Lets you insert audio mp3 files into your posts. Comes with it's own flash music player.
Version: 1.0.1
Author: Martin Laine
Author URI: http://www.1pixelout.net

License:

    Copyright 2005  Martin Laine  (email : martin@1pixelout.net)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

// ===================================
// Enhancements to original emff code
// ===================================

// Set emff object as a global variable (no need to use the _root. syntax)
_global.emff = emff;

// Create ID3 tag array
emff.id3Tags = new Array(emff.getSoundNumber());

// Populate array with defaults and setup ID3 loaders
// Also set the error flag for all sounds
for(i=0; i < emff.getSoundNumber(); i++) {
	// Set error flag to false (flag is only set to true if sound doesn't load properly)
	emff.mySound[i].error = false;
	// Set reference to index (used in onLoad and onID3 methods)
	emff.mySound[i].index = i;
	emff.id3Tags[i].loaded = false;
	emff.mySound[i].onLoad = function(success) {
		// Error flag is set to true when sound doesn't loads properly
		this.error = !success;
	};
	emff.mySound[i].onID3 = function() {
		emff.id3Tags[this.index] = new Object();
		emff.id3Tags[this.index].data = new Array();
		emff.id3Tags[this.index].data[0] = this.id3.artist;
		emff.id3Tags[this.index].data[1] = this.id3.songname;
		// Set falg to indicate that ID3 tags are loaded
		emff.id3Tags[this.index].loaded = true;
	};
}

// Song info retriever method
emff.getSongInfo = function() {
	return emff.id3Tags[emff.index];
}

// Error flag retreiver
emff.getError = function() {
	return emff.mySound[emff.index].error;
}

// Some shortcut methods (that really should be part of the emff code base)

emff.getPosition = function() {
	return emff.mySound[emff.index].position;
}

emff.getDuration = function() {
	return emff.mySound[emff.index].duration;
}

// ===================================
// Player object
// ===================================

_global.player = new Object();

player.maxVolume = 70;
player.volume = player.maxVolume;
player.fadeOut = false;
player.buffering = true;
player.setcolors = false;

// Player statuses
player.CLOSED = 0;
player.OPENING = 1;
player.OPEN = 2;
player.CLOSING = 3;

// Initial player status
player.status = player.CLOSED;

player.close = function() {
	if( player.status != player.OPEN ) return;
	player.status = player.CLOSING;
	player.fadeOut = true;
	_root.speaker_mc.gotoAndStop("off");
	_root.play();
}

player.open = function() {
	if( player.status != player.CLOSED ) return;
	player.status = player.OPENING;
	_root.play();
}

// ===================================
// User interface
// ===================================

// Only one mc for play and pause functions: action is determined to player status
_root.control_mc.onRelease = function() {
	switch(player.status) {
		case player.CLOSED:
			// Open player when closed
			player.open();
			break;
		case player.OPEN:
			// Open player when open
			player.close();
			break;
	}
}

// Control hover state of control button
_root.control_mc.hover = false;
_root.control_mc.state = "play";
_root.control_mc.onRollOver = function() { _root.control_mc.hover = true; }
_root.control_mc.onRollOut = function() { _root.control_mc.hover = false; }
_root.control_mc.onEnterFrame = function() {
	if(this.state == "play") {
		this.pause_icon_mc._visible = this.pause_hover_icon_mc._visible = false;
		this.play_icon_mc._visible = !this.hover;
		this.play_hover_icon_mc._visible = this.hover;
	} else {
		this.play_icon_mc._visible = this.play_hover_icon_mc._visible = false;
		this.pause_icon_mc._visible = !this.hover;
		this.pause_hover_icon_mc._visible = this.hover;
	}
	this.btn_hover_background_mc._visible = this.hover;
	this.btn_background_mc._visible = !this.hover;
}

// Track slider control
_root.progress_mc.progress_button_mc.onPress = function() {
	// Pause player
	emff.ctrlPause();
	// Set the maximum drag position to the current loaded time
	var maxDrag = Math.floor(181 * emff.getLoaded());
	// Start dragging the slider
	startDrag( this, false, -1, -1, maxDrag, -1 );
	emff.dragpos = true;
}
_root.progress_mc.progress_button_mc.onRelease = _root.progress_mc.progress_button_mc.onReleaseOutside = function() {
	// Stop the slider drag
	stopDrag();
	// Slider position as a ratio
	var selected = ( this._x + 1 ) / 182;
	// ms loaded so far
	var loaded = emff.getLoaded();
	// If selected position is not loaded yet, set it to maximum
	if(selected > loaded) selected = loaded;
	// Change track position
	emff.playedmsec = Math.round((1 / loaded) * emff.getDuration() * selected);
	// Start playing again
	emff.ctrlPlay();
	emff.dragpos = false;
}

// ===================================
// Scrolling song information
// ===================================

// Note: the cycle is handled by the text mask in the songInfo movie clip (last frame calls nextField method)

_root.songInfo_mc.started = false;
_root.songInfo_mc.index = -1;
_root.songInfo_mc.pause = true;
_root.songInfo_mc.pauseLength = 60;
_root.songInfo_mc.scrollStep = 1;
_root.songInfo_mc.pauseCounter = 0;

_root.songInfo_mc.useHandCursor = false;
_root.songInfo_mc.onRelease = function() {
	this.textMask_mc.gotoAndPlay("next");
}

_root.songInfo_mc.nextField = function() {
	// Do nothing if the movie hasn't been started yet (whens the ID3 tags load)
	if(!this.started) this.started = true;
	
	// Get next index
	if( this.index == ( emff.getSongInfo().data.length - 1 ) ) this.index = 0;
	else this.index++;
	
	// Set text and reset flags
	this.input_txt.text = emff.getSongInfo().data[this.index];
	this.input_txt.hscroll = 0;
	this.pause = true;
	this.forward = true;
	this.pauseCounter = 0;

	// Start the cycle
	this.textMask_mc.gotoAndPlay("start");
}

// Scroll loop
_root.songInfo_mc.onEnterFrame = function() {
	// Remove the background (this needs doing all the time otherwise it shows)
	this.input_txt.background = false;

	// Do nothing if text fits in the box
	if( this.input_txt.length == 0 || this.input_txt.maxhscroll == 0 ) return;
	
	// If scrolling is paused, wait
	if(this.pause) {
		if(this.pauseCounter == this.pauseLength) {
			this.pause = false;
			this.pauseCounter = 0;
		} else {
			this.pauseCounter++;
			return;
		}
	}

	if( this.forward ) {
		// We are going forward
		this.input_txt.hscroll += this.scrollStep;

		// If we reached the end, pause scrolling and change direction
		if( this.input_txt.hscroll >= this.input_txt.maxhscroll ) {
			this.forward = false;
			this.pause = true;
			return;
		}
	} else {
		// We are going backward
		this.input_txt.hscroll -= this.scrollStep;

		// We are back to the beginning so pause scrolling and change direction
		if( this.input_txt.hscroll == 0 ) {
			this.pause = true;
			this.forward = true;
			return;
		}
	}
}

// ===================================
// Control loop
// ===================================

// These 2 variables are used for detecting buffering time
lastPosition = 0;
frameCount = 0;

_root.onEnterFrame = function() {
	if(player.setcolors) {
		setColors();
		player.setcolors = false;
	}
	
	// Set the player error flag if there was an error loading the file or if there are no files to load
	if(emff.getSoundNumber() == 0) player.error = true;
	else player.error = emff.getError();

	// Handle errors
	if(player.error) {
		_root.progress_mc.progress_button_mc._visible = false;
		// Swicth speaker off
		_root.speaker_mc.gotoAndStop("off");
		_root.messages_txt.text = "Error opening file";
		_root.messages_txt._visible = ( player.status == player.OPEN );
		_root.position_txt._visible = false;
		_root.songInfo_mc._visible = false;
		return;
	}

	// Ensure time is showing
	_root.position_txt._visible = true;

	// Handle player fade out
	if(player.fadeOut) {
		player.volume -= 8;
		if( player.volume < 10 ) {
			emff.ctrlPause();
			player.fadeOut = false;
		}
	}
	else if(player.status == player.OPEN) player.volume = player.maxVolume;
	// Set volume in emff player
	emff.setVolume(player.volume);

	// Update loading bar
	_root.progress_mc.loading_mc._width = Math.round(emff.getLoaded() * 200);

	if(player.buffering) {
		// Show buffering message
		_root.messages_txt.text = "Buffering...";
		_root.messages_txt._visible = true;
		_root.songInfo_mc._visible = false;
	} else {
		// Hide any messages
		_root.messages_txt._visible = false;
		
		with(_root.songInfo_mc) {
			// Handle ID3 tag display
			if( _global.emff.getSongInfo().loaded ) {
				if(!started) nextField();
				_visible = true;
			} else {
				_visible = false;
			}
		}
	}

	switch(emff.status) {
		case emff.PLAYING:
			// Track is playing
			
			// Detect buffering by comparing position every 5 frames
			frameCount++;
			if( frameCount == 5 ) {
				frameCount = 0;
				player.buffering = ( emff.getPosition() == lastPosition );
				lastPosition = emff.getPosition();
			}
			
			// Show progress bar slider
			_root.progress_mc.progress_button_mc._visible = true;
			// Update slider position if it isn't being dragged
			if( !emff.dragpos ) _root.progress_mc.progress_button_mc._x = Math.round(-1 + emff.getPlayed() * 182);
			// Update time
			_root.position_txt.text = millisecondsToString(emff.getPosition());
			// Show pause button
			_root.control_mc.state = "pause";
		break;
		
		case emff.PAUSED:
			// Track is paused
		
			// Update time
			_root.position_txt.text = millisecondsToString(emff.getPosition());
			// If slider isn't being dragged, show play button
			if(!emff.dragpos) _root.control_mc.state = "play";
		break;
		
		case emff.STOPPED:
			// Track is stopped

			// Re-intialise last position
			lastPosition = 0;
			// Hide slider
			_root.progress_mc.progress_button_mc._visible = false;
			// Set time to 0
			_root.position_txt.text = millisecondsToString(0);
			// Reset slider
			_root.progress_mc.progress_button_mc._x = -1;
			// Show play button
			_root.control_mc.state = "play";
			// Close player
			player.close();
		break;
	}

	// Hide all text if the player is not open
	if( player.status != player.OPEN ) {
		_root.messages_txt._visible = false;
		_root.songInfo_mc._visible = false;
		_root.position_txt._visible = false;
	}
}

// Set colors method

function setColors() {
	var colorObject;
	if( colors.bg != undefined ) {
		colorObject = new Color(background_mc);
		colorObject.setRGB(parseInt(colors.bg,16));
		colorObject = new Color(songInfo_mc.textmask_mc);
		colorObject.setRGB(parseInt(colors.bg,16));
	}
	if( colors.leftbg != undefined ) {
		colorObject = new Color(left_background_mc);
		colorObject.setRGB(parseInt(colors.leftbg,16));
	}
	if( colors.lefticon != undefined ) {
		colorObject = new Color(speaker_mc);
		colorObject.setRGB(parseInt(colors.lefticon,16));
	}
	if( colors.rightbg != undefined ) {
		colorObject = new Color(control_mc.btn_background_mc);
		colorObject.setRGB(parseInt(colors.rightbg,16));
	}
	if( colors.rightbghover != undefined ) {
		colorObject = new Color(control_mc.btn_hover_background_mc);
		colorObject.setRGB(parseInt(colors.rightbghover,16));
	}
	if( colors.righticon != undefined ) {
		colorObject = new Color(control_mc.play_icon_mc);
		colorObject.setRGB(parseInt(colors.righticon,16));
		colorObject = new Color(control_mc.pause_icon_mc);
		colorObject.setRGB(parseInt(colors.righticon,16));
	}
	if( colors.righticonhover != undefined ) {
		colorObject = new Color(control_mc.play_hover_icon_mc);
		colorObject.setRGB(parseInt(colors.righticonhover,16));
		colorObject = new Color(control_mc.pause_hover_icon_mc);
		colorObject.setRGB(parseInt(colors.righticonhover,16));
	}

	if( colors.text != undefined ) {
		messages_txt.textColor = position_txt.textColor = songInfo_mc.input_txt.textColor = parseInt(colors.text,16);
	}
	
	if( colors.slider != undefined ) {
		colorObject = new Color(progress_mc.progress_button_mc);
		colorObject.setRGB(parseInt(colors.slider,16));
	}
	if( colors.track != undefined ) {
		colorObject = new Color(progress_mc.track_mc);
		colorObject.setRGB(parseInt(colors.track,16));
	}
	if( colors.loader != undefined ) {
		colorObject = new Color(progress_mc.loader_mc);
		colorObject.setRGB(parseInt(colors.loader,16));
	}
	if( colors.border != undefined ) {
		colorObject = new Color(progress_mc.border_mc);
		colorObject.setRGB(parseInt(colors.border,16));
	}
}

// Helper function: converts milliseconds to a string (HH:MM:SS)

function millisecondsToString(position) {
	var trkTimeInfo = new Date();
	var seconds, minutes, hours;

	// Populate a date object (to convert from ms to hours/minutes/seconds)
	trkTimeInfo.setSeconds(int(position/1000));
	trkTimeInfo.setMinutes(int((position/1000)/60));
	trkTimeInfo.setHours(int(((position/1000)/60)/60));

	// Get the values from date object
	seconds = trkTimeInfo.getSeconds();
	minutes = trkTimeInfo.getMinutes();
	hours = trkTimeInfo.getHours();

	// Build position string
	if(seconds < 10) seconds = "0" + seconds.toString();
	if(minutes < 10) minutes = "0" + minutes.toString();
	if(hours < 10) hours = "0" + hours.toString();

	return hours + ":" + minutes + ":" + seconds;
}