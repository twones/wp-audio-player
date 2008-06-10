﻿package {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	
	public class Volume extends MovieClip {
		public var realWidth:Number;
		
		private var _settingVolume:Boolean;
		private var _initialMaskPos:Number;
	
		private var _clearID:Number;
		
		/**
		 * Constructor
		 */
		public function Volume():void {
			control_mc.alpha = 0;
			control_mc.mouseEnabled = false;
			control_mc.mouseChildren = false;
			button_mc.visible = false;
			icon_mc.alpha = 1;
			icon_mc.mouseEnabled = false;
			
			_settingVolume = false;
			
			_initialMaskPos = control_mc.mask_mc.x;
			
			this.realWidth = background_mc.width;
			
			button_mc.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void {
				_settingVolume = true;
				_moveVolumeBar(evt.localX - 5);
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			});
			button_mc.addEventListener(MouseEvent.MOUSE_MOVE, function(evt:MouseEvent):void {
				if (_settingVolume) {
					_moveVolumeBar(evt.localX - 5);
					var volumeEvent:VolumeEvent = new VolumeEvent();
					volumeEvent.newVolume = _getValue();
					volumeEvent.final = false;
					dispatchEvent(volumeEvent);
				}
			});
		}
		
		private function mouseUpHandler(evt:MouseEvent):void {
			_settingVolume = false;
			if (evt.target == button_mc) {
				_moveVolumeBar(evt.localX - 5);
				var volumeEvent:VolumeEvent = new VolumeEvent();
				volumeEvent.newVolume = _getValue();
				volumeEvent.final = true;
				dispatchEvent(volumeEvent);
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		/**
		 * Updates volume
		 */
		public function update(volume:Number):void {
			if (!_settingVolume) {
				this.control_mc.mask_mc.x = _initialMaskPos + Math.round(this.control_mc.track_mc.width * volume / 100);
			}
		}
		
		private function _moveVolumeBar(mouseX:Number):void {
			if (mouseX > this.control_mc.track_mc.width) {
				this.control_mc.mask_mc.x = _initialMaskPos + this.control_mc.track_mc.width;
			} else if (mouseX < 0) {
				this.control_mc.mask_mc.x = _initialMaskPos;
			} else {
				this.control_mc.mask_mc.x = _initialMaskPos + mouseX;
			}
		}
		
		/**
		 * Returns the current position of the volume slider as a percentage
		 * @return	number between 0 and 100
		 */
		private function _getValue():Number {
			return Math.round((this.control_mc.mask_mc.x - _initialMaskPos) / this.control_mc.track_mc.width * 100);
		}
			
		public function toggleControl(toggle:Boolean):void {
			clearInterval(_clearID);
			if (toggle) {
				_clearID = setInterval(_animate, 41, 1, 0, 6);
			} else {
				_clearID = setInterval(_animate, 41, 0, 1, 16);
			}
		}
		
		private function _animate(targetControl:Number, targetIcon:Number, targetIconX:Number):void {
			var dAlphaControl:Number = targetControl - control_mc.alpha;
			var dAlphaIcon:Number = targetIcon - icon_mc.alpha;
			var dAlphaIconX:Number = targetIconX - icon_mc.x;
			var speed:Number = 0.3;
			
			dAlphaControl = dAlphaControl * speed;
			dAlphaIcon = dAlphaIcon * speed;
			dAlphaIconX = dAlphaIconX * speed;
	
			// Stop animation when we are at less than a pixel from the target
			if (Math.abs(dAlphaIconX) < 1) {
				// Position the control element to the exact target position
				control_mc.alpha = targetControl;
				icon_mc.alpha = targetIcon;
				icon_mc.x = targetIconX;
				
				button_mc.visible = (control_mc.alpha == 1);
				
				clearInterval(_clearID);
				return;
			}
			
			control_mc.alpha += dAlphaControl;
			icon_mc.alpha += dAlphaIcon;
			icon_mc.x += dAlphaIconX;
		}
	
	}
	
}