package {
	import flash.events.Event;
	
	public class ControlEvent extends Event {
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		
		public function ControlEvent(type:String):void {
			super(type);
		}
	}
}