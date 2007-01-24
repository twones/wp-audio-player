import mx.utils.Delegate;

class Slider
{
	private var theSlider:MovieClip;
	private var bar:MovieClip;
	private var slider:MovieClip;
	public var dragging:Boolean;
	private var onStartDrag:Function;
	private var onRelease:Function;
	private var onDrag:Function;
	private var maxValue:Number;
	
	function Slider(name:String, parent:MovieClip, depth:Number, barColor:Number, sliderColor:Number, callBacks:Object)
	{
		if(callBacks.onStartDrag != undefined) onStartDrag = callBacks.onStartDrag;
		if(callBacks.onRelease != undefined) onRelease = callBacks.onRelease;
		if(callBacks.onDrag != undefined) onDrag = callBacks.onDrag;
		
		theSlider = parent.createEmptyMovieClip(name, depth);
		
		bar = theSlider.createEmptyMovieClip("bar", 0);
		bar.beginFill(barColor);
		bar.lineTo(106,0);
		bar.lineTo(106,6);
		bar.lineTo(0,6);
		bar.lineTo(0,0);
		bar.endFill();
		
		slider = theSlider.createEmptyMovieClip("slider", 1);
		slider.beginFill(sliderColor);
		slider.lineTo(6,0);
		slider.lineTo(6,6);
		slider.lineTo(0,6);
		slider.lineTo(0,0);
		slider.endFill();
		
		dragging = false;
		maxValue = 100;
		
		//bar.trackAsMenu = true;
		
		bar.onRelease = Delegate.create(this, moveSlider);
		
		slider.onPress = Delegate.create(this, startDrag);
		slider.onMouseMove = Delegate.create(this, drag);
		slider.onReleaseOutside = slider.onRelease = Delegate.create(this, stopDrag);
	}
	
	public function moveTo(x, y):Void
	{
		theSlider._x = x;
		theSlider._y = y;
	}
	
	public function startDrag():Void
	{
		slider.startDrag(true,0,0,maxValue,0);
		dragging = true;
		if(dragging && onStartDrag != undefined) onStartDrag(slider._x);
	}
	
	public function stopDrag():Void
	{
		if(onRelease != undefined) onRelease(slider._x / bar._width);
		slider.stopDrag();
		dragging = false;
		updateAfterEvent();
	}
	
	private function drag():Void
	{
		if(dragging && onDrag != undefined) onDrag(slider._x);
	}
	
	public function moveSlider():Void
	{
		if(bar._xmouse > 100) slider._x = 100;
		else slider._x = bar._xmouse;
		if(onRelease != undefined) onRelease(slider._x / bar._width);
		else if(onDrag != undefined) onDrag(slider._x);
	}
	
	public function setPosition(newPos:Number):Void
	{
		if(dragging) return;
		if(newPos > maxValue) newPos = maxValue;
		slider._x = newPos;
	}
	
	public function setMax(newMaxValue:Number):Void
	{
		maxValue = newMaxValue;
	}

}