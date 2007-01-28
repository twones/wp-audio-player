class Display extends MovieClip
{
	public var display_txt:TextField;
	
	private var _ticker:Ticker;
	
	/**
	 * Constructor
	 */
	function Display()
	{
		_ticker = new Ticker(this.display_txt);
		_ticker.start();
	}
	
	public function onEnterFrame():Void
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
	
	public function resize(newWidth:Number):Void
	{
		this.display_txt._width = newWidth;
	}
}