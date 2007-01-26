class Loading extends MovieClip
{
	public var bar_mc:MovieClip;
	public var track_mc:MovieClip;
	
	private var _stageWidth:Number;
	
	/**
	 * Constructor
	 */
	function Loading()
	{
		this.bar_mc._width = 0;
		_stageWidth = Stage.width;
	}
	
	function onEnterFrame()
	{
		_resizeBar();
	}
	
	private function _resizeBar()
	{
		this.bar_mc._width = Math.round(_global.player.loaded * this.track_mc._width);
	}
	
	function onResize()
	{
		this.track_mc._width += Stage.width - _stageWidth;
		_stageWidth = Stage.width;
		_resizeBar();
	}
}