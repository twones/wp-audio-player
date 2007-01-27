class Display extends MovieClip
{
	public var display_txt:TextField;
	
	private var _ticker:Ticker;
	
	private var _stageWidth:Number;
	
	/**
	 * Constructor
	 */
	function Display()
	{
		_stageWidth = Stage.width;
		_ticker = new Ticker(this.display_txt);
		_ticker.start();
	}
	
	function onEnterFrame()
	{
		switch(_global.player.state)
		{
			case -1:
				this.display_txt.text = "File not found";
				break;
			case 0:
				this.display_txt.text = "Initialising...";
				break;
			case 1:
				this.display_txt.text = "Stopped";
				break;
			default:
				if(_global.player.isConnecting()) this.display_txt.text = "Connecting...";
				else if(_global.player.isBuffering()) this.display_txt.text = "Buffering...";
				else {
					this.display_txt.text = _global.player.getCurrentTrack().getInfo().songname;
				}
				break;
		}
	}
	
	function onResize()
	{
		this.display_txt._width += Stage.width - _stageWidth;
		_stageWidth = Stage.width;
	}
}