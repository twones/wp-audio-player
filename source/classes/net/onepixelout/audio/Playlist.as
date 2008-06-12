import net.onepixelout.audio.Track;

class net.onepixelout.audio.Playlist
{
	private var _tracks:Array;
	private var _currentTrackIndex:Number;
	public var length:Number;
	static private var _cyclingEnabled:Boolean = true;
	
	public function Playlist(enableCycling:Boolean)
	{
		_tracks = new Array();
		_currentTrackIndex = 0;
		this.length = 0;
		
		if(enableCycling != undefined) _cyclingEnabled = enableCycling;
	}
	
	public function loadFromList(trackList:String, titleList:String, artistList:String):Void
	{
		var trackArray:Array = trackList.split(",");

		if(titleList == undefined) titleList = "";
		if(artistList == undefined) artistList = "";
		var titleArray:Array = (titleList.length == 0) ? new Array() : titleList.split(",");
		var artistArray:Array = (artistList.length == 0) ? new Array() : artistList.split(",");
		
		var newTrack:Track;
		
		for(var i:Number = 0;i < trackArray.length;i++)
		{
			newTrack = new Track(trackArray[i]);
			if(i < titleArray.length) {
				newTrack.setTitle(titleArray[i]);
				newTrack.setArtist("");
			}
			if(i < artistArray.length) newTrack.setArtist(artistArray[i]);
			this.addTrack(newTrack);
		}
	}
	
	public function loadFromXML(listXML:XML):Void
	{
		var tracks:Array = listXML.firstChild.childNodes;
		for(var i:Number = 0;i < tracks.length;i++)
		{
			addTrack(new Track(_getNodeValue(tracks[i], "src"), _getNodeValue(tracks[i], "title"), _getNodeValue(tracks[i], "artist")));
		}
	}
	
	private function _getNodeValue(root:XMLNode, nodeName:String):String
	{
		nodeName = nodeName.toLowerCase();
		for(var i:Number = 0;root.childNodes.length;i++)
		{
			if(root.childNodes[i].nodeName.toLowerCase() == nodeName)
			{
				return root.childNodes[i].firstChild.nodeValue;
			}
		}
		return null;
	}
	
	public function getCurrent():Track
	{
		return _tracks[_currentTrackIndex];
	}
	
	public function getCurrentIndex():Number
	{
		return _currentTrackIndex;
	}
	
	public function hasNext():Boolean
	{
		return (_currentTrackIndex < length-1);
	}
	
	public function next():Track
	{
		if(this.hasNext()) return _tracks[++_currentTrackIndex];
		else if(_cyclingEnabled)
		{
			_currentTrackIndex = 0;
			return _tracks[0];
		}
		else return null;
	}

	public function hasPrevious():Boolean
	{
		return (_currentTrackIndex > 0);
	}

	public function previous():Track
	{
		if(this.hasPrevious()) return _tracks[--_currentTrackIndex];
		else if(_cyclingEnabled)
		{
			_currentTrackIndex = length-1;
			return _tracks[_currentTrackIndex];
		}
		else return null;
	}
	
	public function getAtPosition(position:Number):Track
	{
		if(position >= 0 && position < length) return _tracks[position];
		else return null;
	}
	
	public function addTrack(track:Track):Void
	{
		_tracks.push(track);
		length = _tracks.length;
	}
	
	public function removeAt(position:Number):Void
	{
		_tracks.splice(position, 1);
		length = _tracks.length;
	}
}