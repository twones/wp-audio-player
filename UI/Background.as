class Background extends MovieClip
{
	private var _stageWidth:Number;
	
	/**
	 * Constructor
	 */
	function Background()
	{
		_stageWidth = Stage.width;
	}
	
	function onResize()
	{
		this._width += Stage.width - _stageWidth;
		_stageWidth = Stage.width;
	}
}