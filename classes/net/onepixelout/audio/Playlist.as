import net.onepixelout.audio.Song;
import mx.utils.Delegate;
//import mx.xpath.XPathAPI;

class net.onepixelout.audio.Playlist
{
	private var _songs:Array;
	private var _currentSongIndex:Number;
	public var length:Number;
	static private var _cyclingEnabled:Boolean = true;
	
	public function Playlist(enableCycling:Boolean)
	{
		_songs = new Array();
		_currentSongIndex = 0;
		this.length = 0;
		
		if(enableCycling != undefined) _cyclingEnabled = enableCycling;
	}
	
	public function loadFromList(songList:String):Void
	{
		var songArray:Array = songList.split(",");
		for(var i:Number = 0;i < songArray.length;i++) this.addSong(new Song(songArray[i]));
	}
	
	public function loadFromXML(listXML:XML):Void
	{
		var songs:Array = listXML.firstChild.childNodes;
		for(var i:Number = 0;i < songs.length;i++)
		{
			addSong(new Song(_getNodeValue(songs[i], "src"), _getNodeValue(songs[i], "title"), _getNodeValue(songs[i], "artist")));
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
	
	public function getCurrent():Song
	{
		return _songs[_currentSongIndex];
	}
	
	public function hasNext():Boolean
	{
		return (_currentSongIndex < length-1);
	}
	
	public function next():Song
	{
		if(this.hasNext()) return _songs[++_currentSongIndex];
		else if(_cyclingEnabled)
		{
			_currentSongIndex = 0;
			return _songs[0];
		}
		else return null;
	}

	public function hasPrevious():Boolean
	{
		return (_currentSongIndex > 0);
	}

	public function previous():Song
	{
		if(this.hasPrevious()) return _songs[--_currentSongIndex];
		else if(_cyclingEnabled)
		{
			_currentSongIndex = length-1;
			return _songs[_currentSongIndex];
		}
		else return null;
	}
	
	public function getAtPosition(position:Number):Song
	{
		if(position >= 0 && position < length) return _songs[position];
		else return null;
	}
	
	public function addSong(song:Song):Void
	{
		_songs.push(song);
		length = _songs.length;
	}
	
	public function removeAt(position:Number):Void
	{
		_songs.splice(position, 1);
		length = _songs.length;
	}
}