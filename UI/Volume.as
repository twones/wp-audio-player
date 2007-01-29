import mx.utils.Delegate;

class Volume extends MovieClip
{
	public var icon_mc:MovieClip;
	public var mask_mc:MovieClip;
	public var bar_mc:MovieClip;
	public var track_mc:MovieClip;
	public var background_mc:MovieClip;
	
	public var realWidth:Number;
	
	private var _settingVolume:Boolean;
	private var _initialMaskPos:Number;

	public var addListener:Function;
	public var removeListener:Function;
	private var broadcastMessage:Function;

	/**
	 * Constructor
	 */
	function Volume()
	{
		AsBroadcaster.initialize(this);

		_toggleControl(false);
		_settingVolume = false;
		
		_initialMaskPos = this.mask_mc._x;
		
		this.realWidth = this.background_mc._width;
		
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
				broadcastMessage("onSetVolume", _getValue());
			}
		});
		this.background_mc.onRelease = this.background_mc.onReleaseOutside = Delegate.create(this, function() {
			_settingVolume = false;
			_moveVolumeBar();
			broadcastMessage("onSetVolume", _getValue());
		});
	}
	
	/**
	 * Updates volume
	 */
	public function update(volume:Number):Void
	{
		if(!_settingVolume) this.mask_mc._x = _initialMaskPos + Math.round(this.track_mc._width * volume / 100);
	}
	
	private function _moveVolumeBar():Void
	{
		if(this.track_mc._xmouse > this.track_mc._width) this.mask_mc._x = _initialMaskPos + this.track_mc._width;
		else if(this.track_mc._xmouse < 0) this.mask_mc._x = _initialMaskPos;
		else this.mask_mc._x = _initialMaskPos + this.track_mc._xmouse;
	}
	
	/**
	 * Returns the current position of the volume slider as a percentage
	 * @return	number between 0 and 100
	 */
	private function _getValue():Number
	{
		return Math.round((this.mask_mc._x - _initialMaskPos) / this.track_mc._width * 100);
	}
		
	private function _toggleControl(toggle:Boolean):Void
	{
		this.mask_mc._visible = this.bar_mc._visible = this.track_mc._visible = toggle;
		this.icon_mc._visible = !toggle;
	}
}