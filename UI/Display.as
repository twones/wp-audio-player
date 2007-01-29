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
	
	public function setText(text:String):Void
	{
		this.display_txt.text = text;
	}
	
	public function resize(newWidth:Number):Void
	{
		this.display_txt._width = newWidth;
	}
}