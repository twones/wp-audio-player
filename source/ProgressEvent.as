package {
	import flash.events.Event;
	
	public class ProgressEvent extends Event {
		public static const PROGRESS_CHANGE:String = "progress_change";
		
		public var newPosition:Number;
		
		public function ProgressEvent(newPos:Number):void {
			super(PROGRESS_CHANGE, true);
			this.newPosition = newPos;
		}
	}
}