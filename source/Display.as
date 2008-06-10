package {
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class Display extends MovieClip {
		private var _ticker:Ticker;
		
		private var _messages:Array;
		private var _currentSlot:uint;
		
		private var _newWidth:Number;
		
		public function Display():void {
			// Initialise message storage
			_messages = new Array();
			_currentSlot = 0;
			
			mouseEnabled = false;
			mouseChildren = false;
			
			// Initialise and start ticker
			_ticker = new Ticker(message_txt, {});
			_ticker.start();
		}
		
		/**
		* Load the next message in the queue
		*/
		private function next():void {
			_currentSlot = (++_currentSlot == _messages.length) ? 0 : _currentSlot;
			_update();
		}
		
		/**
		* Sets the text in the given message slot
		* @param	text the message
		* @param	slot the slot to store it in (integer 0-n)
		*/
		public function setText(text:String, slot:uint, forceDisplay:Boolean = false):void {
			var update:Boolean = false;
			if (_currentSlot == slot && _messages[slot] != text) {
				update = true;
			}
			if (forceDisplay && _messages[slot] != text) {
				_currentSlot = slot;
				update = true;
			}
			_messages[slot] = text;
			
			// Only update display if currently viewing the updated slot and it has changed
			if (update) {
				_update();
			}
		}
		
		/**
		* Sets the time display
		* @param	ms the time to display in milliseconds
		*/
		public function setTime(ms:Number, isRemaining:Boolean):void {
			var timeDisplay:String = (isRemaining && ms > 0) ? "-" : "";
			time_txt.text = timeDisplay + _formatTime(ms);
			resize();
		}
		
		/**
		* Clears all messages
		*/
		public function clear():void {
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
		public function resize(newWidth:Number = 0):void {
			if (newWidth > 0) {
				_newWidth = newWidth;
			}
			var newMessageWidth = _newWidth;
			newMessageWidth -= ((this.time_txt.text.length > 5) ? 50: 38);
			this.message_txt.width = newMessageWidth;
			this.time_txt.x = _newWidth - this.time_txt.width + 1;
		}
		
		/**
		* Updates the display and resets the ticker
		*/
		private function _update():void {
			this.message_txt.text = _messages[_currentSlot];
			_ticker.reset();
		}
	
		private function _formatTime(ms:Number):String {
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
			if (seconds < 10) {
				result = "0" + result;
			}
			result = ":" + result;
			result = minutes.toString() + result;
			if (hours > 0) {
				if(minutes < 10) result = "0" + result;
				result = ":" + result;
				result = hours.toString() + result;
			}
	
			return result;
		}
	}
	
}