package net.onepixelout.audio {
	
	import net.onepixelout.audio.Track;
	
	public class Playlist {
		
		private var _tracks:Array;
		private var _currentTrackIndex:uint;
		public var length:uint;
		private var _cyclingEnabled:Boolean;
		
		public function Playlist(enableCycling:Boolean = true):void {
			_tracks = [];
			_currentTrackIndex = 0;
			this.length = 0;
			
			_cyclingEnabled = enableCycling;
		}
		
		public function loadFromList(trackList:String, titleList:String = "", artistList:String = ""):void {
			var trackArray:Array = trackList.split(",");
			
			var titleArray:Array = (titleList.length == 0) ? [] : titleList.split(",");
			var artistArray:Array = (artistList.length == 0) ? [] : artistList.split(",");
			
			var newTrack:Track;
			
			for (var i:uint = 0;i < trackArray.length;i++) {
				newTrack = new Track(trackArray[i]);
				if (i < titleArray.length) {
					newTrack.setTitle(titleArray[i]);
				}
				if (i < artistArray.length) {
					newTrack.setArtist(artistArray[i]);
				}
				this.addTrack(newTrack);
			}
		}
		
		public function getCurrent():Track {
			return _tracks[_currentTrackIndex];
		}
		
		public function getCurrentIndex():uint {
			return _currentTrackIndex;
		}
		
		public function hasNext():Boolean  {
			return (_currentTrackIndex < length-1);
		}
		
		public function next():Track {
			if (this.hasNext()) {
				return _tracks[++_currentTrackIndex];
			} else if (_cyclingEnabled) {
				_currentTrackIndex = 0;
				return _tracks[0];
			} else {
				return null;
			}
		}
	
		public function hasPrevious():Boolean {
			return (_currentTrackIndex > 0);
		}
		
		public function previous():Track {
			if (this.hasPrevious()) {
				return _tracks[--_currentTrackIndex];
			} else if (_cyclingEnabled) {
				_currentTrackIndex = length-1;
				return _tracks[_currentTrackIndex];
			} else {
				return null;
			}
		}
		
		public function getAtPosition(position:uint):Track {
			if (position >= 0 && position < length) {
				return _tracks[position];
			} else {
				return null;
			}
		}
		
		public function addTrack(track:Track):void {
			_tracks.push(track);
			length = _tracks.length;
		}
		
		public function removeAt(position:uint):void {
			_tracks.splice(position, 1);
			length = _tracks.length;
		}
	
	}
	
}