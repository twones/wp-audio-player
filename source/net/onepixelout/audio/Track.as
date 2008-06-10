package net.onepixelout.audio {
	
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	
	public class Track {
		
		private var _src:String; // URL to mp3 file
		private var _soundObject:Sound; // Sound object used to load sound
		private var _isLoaded:Boolean; // TRUE = file is loaded into soundObject
		private var _isFullyLoaded:Boolean; // TRUE = file is fully loaded into soundObject
		private var _notFound:Boolean; // TRUE = file doesn't exist
		
		private var _id3Loaded:Boolean; // TRUE = ID3 tags already loaded
		private var _id3Tags:Object; // All ID3 tag information (direct link to ID3 structure of sound object)
		
		public function Track(src:String, title:String = "", artist:String = ""):void {
			_soundObject = new Sound();
			_src = src;
			_isLoaded = false;
			_isFullyLoaded = false;
			_id3Loaded = false;
			_notFound = false;
			
			_id3Tags = {};
			
			_id3Tags.songName = "";
			_id3Tags.artist = "";
			
			if (title != "" && artist != "") {
				_id3Tags.songName = title;
				_id3Tags.artist = artist;
				_id3Loaded = true;
			}
		}
		
		public function setTitle(title:String):void {
			_id3Tags.songName = title;
			_id3Loaded = true;
		}
		
		public function setArtist(artist:String):void {
			_id3Tags.artist = artist;
			_id3Loaded = true;
		}
		
		public function load():Sound {
			if (!_isLoaded) {
				_soundObject.addEventListener(IOErrorEvent.IO_ERROR, function (evt:Event) {
					_notFound = true;
				});
				if (!_id3Loaded) {
					_soundObject.addEventListener(Event.ID3, setInfo);
				}
				_soundObject.addEventListener(Event.COMPLETE, function (evt:Event) {
					this._isFullyLoaded = true;
				});
  				_soundObject.load(new URLRequest(_src));
				this._isLoaded = true;
			}
			return _soundObject;
		}
		
		/**
		* Deletes sound object if not fully loaded (stops download)
		*/
		public function unLoad():void {
			_soundObject.close();
		}
		
		public function isFullyLoaded():Boolean {
			return _isFullyLoaded;
		}
		
		public function isLoaded():Boolean {
			return _isLoaded;
		}
		
		public function exists():Boolean {
			return !_notFound;
		}
		
		public function isID3Loaded():Boolean {
			return _id3Loaded;
		}
	
		public function setInfo(evt:Event):void {
			_id3Tags = _soundObject.id3;
			_id3Loaded = true;
		}
		
		public function getInfo():Object {
			return _id3Tags;
		}
	
	}
	
}