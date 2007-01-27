import mx.utils.Delegate;

class Volume extends MovieClip
{
	public var icon_mc:MovieClip;
	public var mask_mc:MovieClip;
	public var bar_mc:MovieClip;
	public var track_mc:MovieClip;
	public var background_mc:MovieClip;
	
	private var _settingVolume:Boolean;
	private var _initialMaskPos:Number;
	
	/**
	 * Constructor
	 */
	function Volume()
	{
		_toggleControl(false);
		_settingVolume = false;
		
		_initialMaskPos = this.mask_mc._x;
		
		this.background_mc.onRollOver = Delegate.create(this, function() {
			_toggleControl(true);
		});
		this.background_mc.onRollOut = Delegate.create(this, function() {
			_toggleControl(false);
		});
		
		this.background_mc.onPress = Delegate.create(this, function() {
			_settingVolume = true;
			_moveVolumeBar();
		});
		this.background_mc.onMouseMove = Delegate.create(this, function() {
			if(_settingVolume)
			{
				_moveVolumeBar();
				_global.player.setVolume(_getValue());
			}
		});
		this.background_mc.onRelease = this.background_mc.onReleaseOutside = Delegate.create(this, function() {
			_settingVolume = false;
			_moveVolumeBar();
			_global.player.setVolume(_getValue());
		});
	}
	
	function onEnterFrame()
	{
		if(!_settingVolume) this.mask_mc._x = _initialMaskPos + Math.round(this.track_mc._width * _global.player.getVolume() / 100);
	}

	private function _moveVolumeBar()
	{
		if(this.track_mc._xmouse > this.track_mc._width) this.mask_mc._x = _initialMaskPos + this.track_mc._width;
		else if(this.track_mc._xmouse < 0) this.mask_mc._x = _initialMaskPos;
		else this.mask_mc._x = _initialMaskPos + this.track_mc._xmouse;
	}
	
	private function _getValue():Number
	{
		return Math.round((this.mask_mc._x - _initialMaskPos) / this.track_mc._width * 100);
	}
		
	private function _toggleControl(toggle:Boolean)
	{
		this.mask_mc._visible = this.bar_mc._visible = this.track_mc._visible = toggle;
		this.icon_mc._visible = !toggle;
	}
}