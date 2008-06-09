package {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Control extends MovieClip {
		public var initialState:String;
		public var realWidth:Number;
		
		public static const PLAY_STATE:String = "play";
		public static const PAUSE_STATE:String = "pause";
		
		public var state:String = PLAY_STATE;
	
		/**
		 * Constructor
		 */
		public function Control():void {
			if (this.state == PLAY_STATE) {
				this.pause_mc.visible = false;
			} else {
				this.play_mc.visible = false;
			}
			
			this.realWidth = this.background_mc.width;
			
			background_mc.hover_mc.visible = play_mc.hover_mc.visible = pause_mc.hover_mc.visible = false;
			
			addEventListener(MouseEvent.MOUSE_OVER, function (evt:MouseEvent) {
				_flip(true);
			});

			addEventListener(MouseEvent.MOUSE_OUT, function (evt:MouseEvent) {
				_flip(false);
			});
			
			addEventListener(MouseEvent.CLICK, function (evt:MouseEvent) {
				toggle(true);
			});
			// TODO: releaseoutside
		}
		
		private function _flip(toggle:Boolean):void {
			if (this.state == PLAY_STATE) {
				play_mc.hover_mc.visible = toggle;
			}
			if (this.state == PAUSE_STATE) {
				pause_mc.hover_mc.visible = toggle;
			}
			background_mc.hover_mc.visible = toggle;
		}
		
		public function toggle(broadcast:Boolean = false):void {
			if (this.state == PLAY_STATE) {
				if (broadcast) {
					parent.dispatchEvent(new ControlEvent(ControlEvent.PLAY));
				}
				this.play_mc.visible = false;
				this.play_mc.hover_mc.visible = false;
				this.pause_mc.visible = true;
				this.state = PAUSE_STATE;
			} else {
				if (broadcast) {
					parent.dispatchEvent(new ControlEvent(ControlEvent.PAUSE));
				}
				this.pause_mc.visible = false;
				this.pause_mc.hover_mc.visible = false;
				this.play_mc.visible = true;
				this.state = PLAY_STATE;
			}
		}
		
	}
	
}