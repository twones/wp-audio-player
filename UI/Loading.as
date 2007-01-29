class Loading extends MovieClip
{
	public var bar_mc:MovieClip;
	public var track_mc:MovieClip;
	
	/**
	 * Constructor
	 */
	function Loading()
	{
		this.bar_mc._width = 0;
	}
	
	public function update(loaded:Number):Void
	{
		this.bar_mc._width = Math.round(loaded * this.track_mc._width);
	}

	public function resize(newWidth:Number):Void
	{
		var change:Number = newWidth / this.track_mc._width;
		this.track_mc._width = newWidth;
		this.bar_mc._width *= change;
	}
}