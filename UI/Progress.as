﻿import mx.utils.Delegate;

class Progress extends MovieClip
{
	public var bar_mc:MovieClip;
	public var track_mc:MovieClip;
	public var border_mc:MovieClip;
	
	private var _movingHead:Boolean;
	
	/**
	 * Constructor
	 */
	function Progress()
	{
		this.bar_mc._width = 0;
		_movingHead = false;
		this.track_mc.onPress = Delegate.create(this, function() {
			_movingHead = true;
			_moveProgressBar();
		});
		this.track_mc.onMouseMove = Delegate.create(this, function() {
			if(_movingHead) _moveProgressBar();
		});
		this.track_mc.onRelease = this.track_mc.onReleaseOutside = Delegate.create(this, function() {
			_global.player.moveHead(this.bar_mc._width / this.track_mc._width);
			_movingHead = false;
		});
	}
	
	function onEnterFrame()
	{
		if(!_movingHead && _global.player.state == 3)
		{
			bar_mc._width = Math.round(_global.player.played * track_mc._width);
		}
	}
	
	private function _moveProgressBar()
	{
		var maxPos:Number = _global.player.loaded * this.track_mc._width;
		var newPos:Number = this.track_mc._xmouse;
		if(newPos < 0) newPos = 0;
		else if(newPos > maxPos) newPos = maxPos;
		this.bar_mc._width = newPos;
	}
}