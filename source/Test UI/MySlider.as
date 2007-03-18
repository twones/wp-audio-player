import mx.utils.Delegate;

class MySlider extends MovieClip {
	public var indicator_mc:MovieClip;
	public var bar_mc:MovieClip;
	public var addListener:Function;
	public var removeListener:Function;
	private var broadcastMessage:Function;
	private var _maxValue:Number;
	
	function MySlider() {
		AsBroadcaster.initialize(this);

		_maxValue = 1;
		
		this.bar_mc.onRelease = Delegate.create(this, function() {
			var newValue:Number = this.bar_mc._xmouse / this.bar_mc._width;
			if(newValue > _maxValue) newValue = _maxValue;
			this.indicator_mc._width = newValue * this.bar_mc._width;
			this.broadcastMessage("onSet", { position:newValue });
		} );
	}
	
	public function updateSlider(newPosition:Number)
	{
		if(newPosition > _maxValue) newPosition = _maxValue;
		this.indicator_mc._width = this.bar_mc._width * newPosition;
	}
	
	public function setMaxValue(newMaxValue:Number)
	{
		_maxValue = newMaxValue;
	}
}