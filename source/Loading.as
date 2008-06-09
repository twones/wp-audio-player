package {
	import flash.display.MovieClip;
	
	public class Loading extends MovieClip {
		
		public function Loading():void {
			bar_mc.width = 0;
		}
		
		public function update(loaded:Number):void {
			bar_mc.width = Math.round(loaded * track_mc.width);
		}
	
		public function resize(newWidth:Number):void {
			var change:Number = newWidth / track_mc.width;
			track_mc.width = newWidth;
			bar_mc.width *= change;
		}
	
	}
	
}