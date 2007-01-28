class Control extends MovieClip
{
	public var play_mc:MovieClip;
	public var pause_mc:MovieClip;
	public var background_mc:MovieClip;
	
	public var realWidth:Number;
	
	public var addListener:Function;
	public var removeListener:Function;
	private var broadcastMessage:Function;

	/**
	 * Constructor
	 */
	function Control()
	{
		AsBroadcaster.initialize(this);
		
		this.pause_mc._visible = false;
		
		this.realWidth = this.background_mc._width;
	}
	
	function onRelease()
	{
		if(_global.player.state < 1) return;
		if(_global.player.state < 3)
		{
			broadcastMessage("onPlay");
			this.play_mc._visible = false;
			this.pause_mc._visible = true;
		} else
		{
			broadcastMessage("onPause");
			this.pause_mc._visible = false;
			this.play_mc._visible = true;
		}
	}
}