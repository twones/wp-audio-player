import mx.utils.Delegate;

class Progress extends MovieClip
{
	public var bar_mc:MovieClip;
	public var track_mc:MovieClip;
	public var border_mc:MovieClip;
	
	private var _movingHead:Boolean;
	private var _maxPos:Number;
	
	public var addListener:Function;
	public var removeListener:Function;
	private var broadcastMessage:Function;

	/**
	 * Constructor
	 */
	function Progress()
	{
		AsBroadcaster.initialize(this);
		
		this.bar_mc._width = 0;
		_movingHead = false;
		
		this.track_mc.onPress = Delegate.create(this, function() {
			this._movingHead = true;
			this._moveProgressBar();
		});
		this.track_mc.onMouseMove = Delegate.create(this, function() {
			if(this._movingHead) this._moveProgressBar();
		});
		this.track_mc.onRelease = this.track_mc.onReleaseOutside = Delegate.create(this, function() {
			this.broadcastMessage("onMoveHead", this.bar_mc._width / this.track_mc._width);
			this._movingHead = false;
		});
	}
	
	public function updateProgress(played:Number):Void
	{
		if(!_movingHead) bar_mc._width = Math.round(played * track_mc._width);
	}
	
	public function setMaxValue(maxValue:Number):Void
	{
		_maxPos = maxValue * this.track_mc._width;
	}
	
	public function resize(newWidth:Number):Void
	{
		this.track_mc._width = newWidth - 2;
		this.border_mc._width = newWidth;
	}

	private function _moveProgressBar():Void
	{
		var newPos:Number = this._xmouse - 1;
		if(newPos < 0) newPos = 0;
		else if(newPos > _maxPos) newPos = _maxPos;
		this.bar_mc._width = newPos;
	}
}