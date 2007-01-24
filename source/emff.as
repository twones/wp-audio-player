// EMFF (Easy Musikplayer For Flash)
// author: Marc Reichelt (http://www.marcreichelt.de/)
// This flashfilm is under the General Public License (GPL), more informations at:
// http://www.gnu.org/copyleft/gpl.html
// or in the file gpl.txt


emff                 = new Object();				// new objekt "emff"
emff.mySound         = new Array();				// new Array of sound objects

emff.playedmsec      = 0;					// played milliseconds of actual title
emff.index           = 0;					// index of the actual selected title
emff.status          = 0;					// status of player
emff.dragpos         = false;					// is the user dragging the position?
emff.dragvol         = false;					// is he dragging the volume?

emff.STOPPED         = 0;					// some constants for status
emff.PLAYING         = 1;
emff.PAUSED          = 2;

emff.loop            = false;					// now the default values
emff.autostart       = false;
emff.streaming       = true;
emff.src             = src.split(",");
emff.isLoaded        = new Array();

emff.getSoundNumber = function()
{
 return emff.src.length;
}

for(i=0; i < emff.getSoundNumber(); i++)
{
 emff.isLoaded.push(false);
 emff.mySound.push(new Sound());
}



emff.setVolume = function(vol)
{
 if(vol < 0)  { vol=0;   }
 if(vol > 100){ vol=100; }

 for(i=0; i < emff.getSoundNumber(); i++)
 {
  emff.mySound[i].setVolume(vol);
 }
};

emff.setVolume(100);



emff.loadSelectedSound = function()
{
 emff.mySound[emff.index].loadSound(emff.src[emff.index], emff.streaming);
 emff.isLoaded[emff.index] = true;
};



emff.ctrlBegin = function()
{
 if(emff.status != emff.STOPPED)
 {
  emff.mySound[emff.index].stop();
 }

 emff.index = 0;

 if(!emff.isLoaded[emff.index]){ emff.loadSelectedSound(); }
 emff.mySound[emff.index].start();
 emff.status = emff.PLAYING;
};



emff.ctrlStop = function()
{
 if(emff.status != emff.STOPPED)
 {
  emff.mySound[emff.index].stop();
  emff.status = emff.STOPPED;
 }
};



emff.ctrlPause = function()
{
 if(emff.status == emff.PLAYING)
 {
  emff.playedmsec = emff.mySound[emff.index].position;
  emff.mySound[emff.index].stop();
  emff.status = emff.PAUSED;
 }
};



emff.ctrlPlay = function()
{
 if(emff.status == emff.STOPPED)
 {
  if(!emff.isLoaded[emff.index]) { emff.loadSelectedSound(); }
  emff.mySound[emff.index].start();
  emff.status = emff.PLAYING;
 }

 if(emff.status == emff.PAUSED)
 {
  emff.mySound[emff.index].start(Math.round(emff.playedmsec / 1000));
  emff.status = emff.PLAYING;
 }
};



emff.ctrlPrevious = function()
{
 emff.mySound[emff.index].stop();

 if(emff.index <= 0)
 {
  emff.index = emff.getSoundNumber() - 1;
 } else
 {
  emff.index -= 1;
 }

 if(emff.status != emff.STOPPED)
 {
  if(!emff.isLoaded[emff.index]){ emff.loadSelectedSound(); }
  emff.mySound[emff.index].start();
  emff.status = emff.PLAYING;
 }
};



emff.ctrlNext = function()
{
 emff.mySound[emff.index].stop();

 if(emff.index >= emff.getSoundNumber() - 1)
 {
  emff.index = 0;
 } else
 {
  emff.index += 1;
 }

 if(emff.status != emff.STOPPED)
 {
  if(!emff.isLoaded[emff.index]){ emff.loadSelectedSound(); }
  emff.mySound[emff.index].start();
  emff.status = emff.PLAYING;
 }
};



for(i=0; i < emff.getSoundNumber(); i++)
{
 emff.mySound[i].onSoundComplete = function()
 {
  emff.mySound[emff.index].stop();

  if(emff.index < emff.getSoundNumber() - 1)
  {
   emff.ctrlNext();
  } else
  {
   if(emff.loop)
   {
    emff.ctrlNext();
   } else
   {
    emff.index  = 0;
    emff.status = emff.STOPPED;
   }
  }
 };
}



emff.getLoaded = function()
{
 if(!emff.isLoaded[emff.index]){ return 0; }
 return emff.mySound[emff.index].getBytesLoaded() / emff.mySound[emff.index].getBytesTotal();
};



emff.getPlayed = function()
{
 if(emff.status == emff.STOPPED)
 {
  return 0;
 }

 if(emff.status == emff.PLAYING)
 {
  loaded     = emff.mySound[emff.index].getBytesLoaded() / emff.mySound[emff.index].getBytesTotal();
  playedmsec = emff.mySound[emff.index].position;
  totalmsec  = 1 / loaded * emff.mySound[emff.index].duration;
  return playedmsec / totalmsec;
 }

 if(emff.status == emff.PAUSED)
 {
  loaded     = emff.mySound[emff.index].getBytesLoaded() / emff.mySound[emff.index].getBytesTotal();
  playedmsec = emff.playedmsec;
  totalmsec  = 1 / loaded * emff.mySound[emff.index].duration;
  return playedmsec / totalmsec;
 }

 return 0;
};



// now taking over some options
if(autostart == "yes"){ emff.autostart = true;  }
if(loop      == "yes"){ emff.loop      = true;  }
if(streaming == "no") { emff.streaming = false; }


