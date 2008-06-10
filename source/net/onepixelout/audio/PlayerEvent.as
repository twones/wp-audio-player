package net.onepixelout.audio {
	import flash.events.Event;
	
	public class PlayerEvent extends Event {
		public static const TRACK_STOP:String = "track_stop";
		
		public function PlayerEvent(type:String):void {
			super(type);
		}
	}
}