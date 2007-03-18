class MyButton extends MovieClip {
	public var label:String;
	public var label_txt:TextField;
	
	/**
	 * Constructor
	 */
	function MyButton()
	{
		this.label_txt.text = this.label;
	}
}