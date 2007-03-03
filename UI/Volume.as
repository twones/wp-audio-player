import mx.utils.Delegate;

class Volume extends MovieClip
{
	public var icon_mc:MovieClip;
	public var control_mc:MovieClip;
	public var background_mc:MovieClip;
	public var button_mc:MovieClip;
	
	public var realWidth:Number;
	
	private var _settingVolume:Boolean;
	private var _initialMaskPos:Number;

	public var addListener:Function;
	public var removeListener:Function;
	private var broadcastMessage:Function;

	private var _clearID:Number;
	
	/**
	 * Constructor
	 */
	function Volume()
	{
		AsBroadcaster.initialize(this);

		control_mc._alpha = 0;
		this.button_mc._visible = false;
		icon_mc._alpha = 100;
		
		_settingVolume = false;
		
		_initialMaskPos = this.control_mc.mask_mc._x;
		
		this.realWidth = this.background_mc._width;
		
		this.button_mc.onPress = Delegate.create(this, function() {
			_settingVolume = true;
			_moveVolumeBar();
		});
		this.button_mc.onMouseMove = Delegate.create(this, function() {
			if(_settingVolume)
			{
				_moveVolumeBar();
				broadcastMessage("onSetVolume", _getValue());
			}
		});
		this.button_mc.onRelease = this.button_mc.onReleaseOutside = Delegate.create(this, function() {
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
		if(!_settingVolume) this.control_mc.mask_mc._x = _initialMaskPos + Math.round(this.control_mc.track_mc._width * volume / 100);
	}
	
	private function _moveVolumeBar():Void
	{
		if(this.control_mc.track_mc._xmouse > this.control_mc.track_mc._width) this.control_mc.mask_mc._x = _initialMaskPos + this.control_mc.track_mc._width;
		else if(this.control_mc.track_mc._xmouse < 0) this.control_mc.mask_mc._x = _initialMaskPos;
		else this.control_mc.mask_mc._x = _initialMaskPos + this.control_mc.track_mc._xmouse;
	}
	
	/**
	 * Returns the current position of the volume slider as a percentage
	 * @return	number between 0 and 100
	 */
	private function _getValue():Number
	{
		return Math.round((this.control_mc.mask_mc._x - _initialMaskPos) / this.control_mc.track_mc._width * 100);
	}
		
	public function toggleControl(toggle:Boolean, immediate:Boolean):Void
	{
		clearInterval(_clearID);
		if(toggle) _clearID = setInterval(this, "_animate", 41, 100, 0);
		else _clearID = setInterval(this, "_animate", 41, 0, 100);
		
		//this.control_mc.mask_mc._visible = this.control_mc.bar_mc._visible = this.control_mc.track_mc._visible = toggle;
		//this.icon_mc._visible = !toggle;
	}
	
	private function _animate(targetControl:Number, targetIcon:Number):Void
	{
		var dAlphaControl:Number = targetControl - control_mc._alpha;
		var dAlphaIcon:Number = targetIcon - icon_mc._alpha;
		var speed:Number = 0.2;
		
		dAlphaControl = Math.round(dAlphaControl * speed);
		dAlphaIcon = Math.round(dAlphaIcon * speed);

		// Stop animation when we are at less than a pixel from the target
		if(Math.abs(dAlphaControl) < 1)
		{
			// Position the control element to the exact target position
			control_mc._alpha = targetControl;
			icon_mc._alpha = targetIcon;
			
			button_mc._visible = (control_mc._alpha == 100);
			
			clearInterval(_clearID);
			return;
		}
		
		control_mc._alpha += dAlphaControl;
		icon_mc._alpha += dAlphaIcon;
	}
}