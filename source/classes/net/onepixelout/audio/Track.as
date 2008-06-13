import mx.utils.Delegate;

/**
* Track object. Apart from containing song information such as
* title, artist etc, it contains the actual Sound object so we
* don't load a track twice.
*/
class net.onepixelout.audio.Track
{
	private var _src:String; // URL to mp3 file
	private var _soundObject:Sound; // Sound object used to load sound
	private var _isLoaded:Boolean; // TRUE = file is loaded into soundObject
	private var _isFullyLoaded:Boolean; // TRUE = file is fully loaded into soundObject
	private var _notFound:Boolean; // TRUE = file doesn't exist

	private var _id3Loaded:Boolean; // TRUE = ID3 tags already loaded
	private var _id3Tags:Object; // All ID3 tag information (direct link to ID3 structure of sound object)

	function Track(src:String, title:String, artist:String)
	{
		_soundObject = new Sound();
		_src = src;
		_isLoaded = false;
		_isFullyLoaded = false;
		_id3Loaded = false;
		_notFound = false;
		
		_id3Tags = new Object();

		if(title != undefined && artist != undefined)
		{
			_id3Tags.songname = title;
			_id3Tags.artist = artist;
			_id3Loaded = true;
		}
	}
	
	public function setTitle(title:String):Void
	{
		_id3Tags.songname = title;
		_id3Loaded = true;
	}
	
	public function setArtist(artist:String):Void
	{
		_id3Tags.artist = artist;
		_id3Loaded = true;
	}
	
	public function load():Sound
	{
		if(!_isLoaded)
		{
			_soundObject.onLoad = Delegate.create(this, function(success) {
				this._notFound = !success;
				this._isFullyLoaded = success;
			});
			_soundObject.loadSound(_src, true);
			this._isLoaded = true;
		}
		return _soundObject;
	}
	
	/**
	* Deletes sound object if not fully loaded (stops download)
	*/
	public function unLoad():Void
	{
		if(!_isFullyLoaded)
		{
			delete _soundObject;
			_isLoaded = false;
			_soundObject = new Sound();
		}
	}
	
	public function isFullyLoaded():Boolean
	{
		return _isFullyLoaded;
	}
	
	public function isLoaded():Boolean
	{
		return _isLoaded;
	}
	
	public function exists():Boolean
	{
		return !_notFound;
	}
	
	public function isID3Loaded():Boolean
	{
		return _id3Loaded;
	}

	public function setInfo():Void
	{
		_id3Tags = _soundObject.id3;
		_id3Loaded = true;
	}
	
	public function getInfo():Object
	{
		return _id3Tags;
	}
}