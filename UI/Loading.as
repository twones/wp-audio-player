class Loading extends MovieClip
{
	public var bar_mc:MovieClip;
	public var track_mc:MovieClip;
	
	/**
	 * Constructor
	 */
	function Loading()
	{
		this.bar_mc._width = 0;
	}
	
	public function onEnterFrame():Void
	{
		_resizeBar();
	}
	
	public function resize(newWidth:Number):Void
	{
		this.track_mc._width = newWidth;
		_resizeBar();
	}
	
	private function _resizeBar():Void
	{
		this.bar_mc._width = Math.round(_global.player.loaded * this.track_mc._width);
	}
}