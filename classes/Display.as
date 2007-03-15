import mx.utils.Delegate;

class Display extends MovieClip
{
	public var message_txt:TextField;
	public var time_txt:TextField;
	
	private var _ticker:Ticker;
	
	private var _messages:Array;
	private var _currentSlot:Number;
	
	private var _newWidth:Number;
	
	/**
	 * Constructor
	 */
	function Display()
	{
		// Initialise message storage
		_messages = new Array();
		_currentSlot = 0;
		
		// Initialise and start ticker
		_ticker = new Ticker(this.message_txt);
		_ticker.start();

		// Add event handler to toggle switch (cycles through messages)
	}
	
	/**
	* Load the next message in the queue
	*/
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
	}
	
	/**
	* Sets the time display
	* @param	ms the time to display in milliseconds
	*/
	public function setTime(ms:Number)
	{
		this.time_txt.text = _formatTime(ms);
		this.resize();
	}
	
	/**
	* Clears all messages
	*/
	public function clear():Void
	{
		_messages = new Array();
		_currentSlot = 0;
		this.message_txt.text = "";
		this.time_txt.text = "";
		_ticker.reset();
	}
	
	/**
	* Resizes display
	* @param	newWidth the new display width
	*/
	public function resize(newWidth:Number):Void
	{
		if(newWidth != undefined) _newWidth = newWidth;
		var newMessageWidth = _newWidth;
		newMessageWidth -= ((this.time_txt.text.length > 5) ? 50: 38);
		this.message_txt._width = newMessageWidth;
		this.time_txt._x = _newWidth - (this.time_txt._width - 2);
	}
	
	/**
	* Updates the display and resets the ticker
	*/
	private function _update():Void
	{
		this.message_txt.text = _messages[_currentSlot];
		_ticker.reset();
	}

	private function _formatTime(ms:Number):String
	{
		var trkTimeInfo:Date = new Date();
		var seconds:Number, minutes:Number, hours:Number;
		var result:String;

		// Populate a date object (to convert from ms to hours/minutes/seconds)
		trkTimeInfo.setSeconds(int(ms/1000));
		trkTimeInfo.setMinutes(int((ms/1000)/60));
		trkTimeInfo.setHours(int(((ms/1000)/60)/60));

		// Get the values from date object
		seconds = trkTimeInfo.getSeconds();
		minutes = trkTimeInfo.getMinutes();
		hours = trkTimeInfo.getHours();

		// Build position string
		result = seconds.toString();
		if(seconds < 10) result = "0" + result;
		result = ":" + result;
		result = minutes.toString() + result;
		if(minutes < 10) result = "0" + result;
		if(hours > 0)
		{
			result = ":" + result;
			result = hours.toString() + result;
		}

		return result;
	}
}