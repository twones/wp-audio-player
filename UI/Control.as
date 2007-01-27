class Control extends MovieClip
{
	public var play_mc:MovieClip;
	public var pause_mc:MovieClip;
	public var background_mc:MovieClip;

	private var _stageWidth:Number;

	/**
	 * Constructor
	 */
	function Control()
	{
		this.pause_mc._visible = false;
		_stageWidth = Stage.width;
	}
	
	function onRelease()
	{
		if(_global.player.state < 1) return;
		if(_global.player.state < 3)
		{
			_root.open();
			_global.player.play();
			this.play_mc._visible = false;
			this.pause_mc._visible = true;
		} else
		{
			_root.close();
			_global.player.pause();
			this.pause_mc._visible = false;
			this.play_mc._visible = true;
		}
	}
	
	public function onResize()
	{
		this._x += Stage.width - _stageWidth;
		_stageWidth = Stage.width;
	}
}