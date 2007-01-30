﻿class Control extends MovieClip
{
	public var play_mc:MovieClip;
	public var pause_mc:MovieClip;
	public var background_mc:MovieClip;
	
	public var initialState:String;
	public var realWidth:Number;
	
	public var state:String;

	public var addListener:Function;
	public var removeListener:Function;
	private var broadcastMessage:Function;

	/**
	 * Constructor
	 */
	function Control()
	{
		AsBroadcaster.initialize(this);
		
		if(this.state == "play") this.pause_mc._visible = false;
		else this.play_mc._visible = false;
		
		this.realWidth = this.background_mc._width;
	}
	
	function onRelease()
	{
		this.toggle(true);
	}
	
	public function toggle(broadcast:Boolean):Void
	{
		if(broadcast == undefined) broadcast = false;
		if(this.state == "play")
		{
			if(broadcast) broadcastMessage("onPlay");
			this.play_mc._visible = false;
			this.pause_mc._visible = true;
			this.state = "pause";
		} else
		{
			if(broadcast) broadcastMessage("onPause");
			this.pause_mc._visible = false;
			this.play_mc._visible = true;
			this.state = "play";
		}
	}
}