class Ticker
{
	private var _textField:TextField;
	private var _clearID:Number;
	private var _direction:String;
	private var _options:Object;
	
	function Ticker(textField:TextField, options:Object)
	{
		_direction = "fw";
		_textField = textField;
		_clearID = null;
		
		_options = { pause:6000, interval:25, increment:1 };
		if(typeof options == "Object") this.setOptions(options);
	}
	
	public function setOptions(options:Object):Void
	{
		for(var key:String in options) _options[key] = options[key];
	}
	
	public function start():Void
	{
		_clearID = setInterval(this, "_start", _options.pause);
	}
	
	private function _start():Void
	{
		if(_textField.maxhscroll == 0) return;
		clearInterval(_clearID);
		_clearID = setInterval(this, "_scroll", _options.interval);
	}
	
	private function _scroll():Void
	{
		if(_direction == "fw" && _textField.hscroll == _textField.maxhscroll)
		{
			_direction = "bw";
			clearInterval(_clearID);
			_clearID = setInterval(this, "_start", _options.pause);
			return;
		}
		else if(_direction == "bw" && _textField.hscroll == 0)
		{
			_direction = "fw";
			clearInterval(_clearID);
			_clearID = setInterval(this, "_start", _options.pause);
			return;
		}
		
		if(_direction == "fw" ) _textField.hscroll += _options.increment;
		else _textField.hscroll -= _options.increment;
	}
}