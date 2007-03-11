import mx.utils.Delegate;

class Display extends MovieClip
{
	public var display_txt:TextField;
	public var toggle_mc:MovieClip;
	
	private var _ticker:Ticker;
	
	private var _messages:Array;
	private var _currentSlot:Number;
	
	/**
	 * Constructor
	 */
	function Display()
	{
		// Initialise message storage
		_messages = new Array();
		_currentSlot = 0;
		
		// Initialise and start ticker
		_ticker = new Ticker(this.display_txt);
		_ticker.start();

		// Add event handler to toggle switch (cycles through messages)
		this.toggle_mc.onRelease = Delegate.create(this, next);
	}
	
	private function next():Void
	{
		_currentSlot = (++_currentSlot == _messages.length) ? 0 : _currentSlot;
		_update();
	}
	
	/**
	* Sets the text in the given message slot
	* @param	text the message
	* @param	slot the slot to store it in (integer 0-n)
	*/
	public function setText(text:String, slot:Number, forceDisplay:Boolean):Void
	{
		if(forceDisplay == undefined) forceDisplay = false;
		
		var update:Boolean = false;
		if(_currentSlot == slot && _messages[slot] != text) update = true;
		if(forceDisplay && _messages[slot] != text)
		{
			_currentSlot = slot;
			update = true;
		}
		_messages[slot] = text;
		
		// Only update display if currently viewing the updated slot and it has changed
		if(update) _update();
		
		// Show / hide toggle switch
		this.toggle_mc._visible = (_messages.length > 1);
	}
	
	/**
	* Clears all messages
	*/
	public function clear():Void
	{
		_messages = new Array();
		_currentSlot = 0;
		this.display_txt.text = "";
		this.toggle_mc._visible =  false;
		_ticker.reset();
	}
	
	/**
	* Resizes display
	* @param	newWidth the new display width
	*/
	public function resize(newWidth:Number):Void
	{
		this.display_txt._width = newWidth - 15;
		this.toggle_mc._x = newWidth - 12;
	}
	
	/**
	* Updates the display and resets the ticker
	*/
	private function _update():Void
	{
		this.display_txt.text = _messages[_currentSlot];
		_ticker.reset();
	}
}