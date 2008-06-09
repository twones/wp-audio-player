package {
	import flash.events.Event;
	
	public class VolumeEvent extends Event {
		public static const VOLUME_CHANGE:String = "volume_change";
		
		public var newVolume:Number;
		public var final:Boolean;
		
		public function VolumeEvent():void {
			super(VOLUME_CHANGE, true);
		}
	}
}