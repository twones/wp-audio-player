package {
	import flash.text.TextField;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	
	class Ticker {
		private var _textField:TextField;
		private var _clearID:Number;
		private var _direction:String;
		private var _options:Object;
		
		public function Ticker(textField:TextField, options:Object):void {
			_direction = "fw";
			_textField = textField;
			
			_options = {
				pause:6000,
				interval:25,
				increment:1
			};
			
			if (typeof options == "Object") {
				this.setOptions(options);
			}
		}
		
		public function setOptions(options:Object):void {
			for (var key:String in options) {
				options[key] = options[key];
			}
		}
		
		public function start():void {
			_clearID = setInterval(_start, _options.pause);
		}
		
		public function reset():void {
			clearInterval(_clearID);
			_textField.scrollH = 0;
			start();
		}
	
		private function _start():void {
			if (_textField.maxScrollH == 0) {
				return;
			}
			clearInterval(_clearID);
			_clearID = setInterval(_scroll, _options.interval);
		}
		
		private function _scroll():void {
			if (_direction == "fw" && _textField.scrollH == _textField.maxScrollH) {
				_direction = "bw";
				clearInterval(_clearID);
				_clearID = setInterval(_start, _options.pause);
				return;
			} else if (_direction == "bw" && _textField.scrollH == 0) {
				_direction = "fw";
				clearInterval(_clearID);
				_clearID = setInterval(_start, _options.pause);
				return;
			}
			
			if (_direction == "fw" ) {
				_textField.scrollH += _options.increment;
			} else {
				_textField.scrollH -= _options.increment;
			}
		}
		
	}
	
}