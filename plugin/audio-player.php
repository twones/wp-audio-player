<?php
/*
Plugin Name: Audio player
Plugin URI: http://www.1pixelout.net/code/audio-player-wordpress-plugin/
Description: Highly configurable single track mp3 player.
Version: 1.2.3
Author: Martin Laine
Author URI: http://www.1pixelout.net

Change log:

	1.2.3 (01 March 2006)
	
		* Added page background and disable transparency option

	1.2.2 (14 February 2006)
	
		* Fixed a bug for the "replace all mp3 links" option (now case-insensitive)

	1.2.1 (07 February 2006)
	
		* Fixed a bug for the "replace all mp3 links" option (now supports extra attributes in a tags)

	1.2 (07 February 2006)
	
		* Implemented post/pre append clip feature
		* Amended player to allow for clip sequence playback
		* Improved plugn php code syntax
		* Minor improvements to slider bar appearance
		* Added configurable behaviour options: [audio] syntax, enclosure integration and mp3 link replace
		* Added configurable RSS alternate content option: insert download link, nothing or custom content
		* Player now closes automatically if you open another one on the same page
		* Fixed a problem with colour options in Flash 6
		* Added player preview to colour scheme configurator
		* Check for updates and automatic upgrade feature

	1.0.1 (31 December 2005)

		* All text fields now use device fonts (much crisper text rendering, support for many more characters and even smaller player file size)
		* General clean up and commenting of source code

	1.0 (26 December 2005)
		
		* Player now based on the emff player (http://www.marcreichelt.de/)
		* New thinner design (suggested by Don Bledsoe - http://screenwriterradio.com/)
		* More colour options
		* New slider function to move around the track
		* Simple scrolling ID3 tag support for title and artist (thanks to Ari - http://www.adrstudios.com/)
		* Time display now includes hours for very long tracks
		* Support for autostart and loop (suggested by gotjosh - http://gotblogua.gotjosh.net/)
		* Support for custom colours per player instance
		* Fixed an issue with rss feeds. Post content in rss feeds now only shows a link to the file rather than the player (thanks to Blair Kitchen - http://96rpm.the-blair.com/)
		* Better handling of buffering and file not found errors 

	0.7.1 beta (29 October 2005)

		* MP3 files are no longer pre-loaded (saves on bandwidth if you have multiple players on one page)

	0.7 beta (24 October 2005)

		* Added colour customisation.

	0.6 beta (23 October 2005)

		* Fixed bug in flash player: progress bar was not updating properly.

	0.5 beta (19 October 2005)

		* Moved player.swf to plugins folder
		* Default location of audio files is now top-level /audio folder
		* Better handling of paths and URIs
		* Added support for linking to external files

	0.2 beta (19 October 2005)

		* Bug fix: the paths to the flash player and the mp3 files didn?t respect the web path option. This caused problems for blogs that don?t live in the root of the domain (eg www.mydomain.com/blog/)

License:

    Copyright 2005-2006  Martin Laine  (email : martin@1pixelout.net)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

// Option defaults
add_option('audio_player_web_path', '/audio', "Web path to audio files", true);
add_option('audio_player_width', '290', "Player width", true);
add_option('audio_player_enableAnimation', 'yes', "Enable animation", true);
add_option('audio_player_embedmethod', 'ufo', "FLash embed method", true);
add_option('audio_player_includeembedfile', 'yes', "Include embed method file", true);
add_option('audio_player_behaviour', 'default', "Plugin behaviour", true);
add_option('audio_player_rssalternate', 'nothing', "RSS alternate content", true);
add_option('audio_player_rsscustomalternate', '[See post to listen to audio]', "Custom RSS alternate content", true);
add_option('audio_player_prefixaudio', '', "Pre-Stream Audio", true);
add_option('audio_player_postfixaudio', '', "Post-Stream Audio", true);

if(get_option('audio_player_iconcolor') != '' && get_option('audio_player_lefticoncolor') == '') {
	// Upgrade options from version 0.x
	$ap_color = '';
	$ap_color = str_replace("#", "0x", get_option('audio_player_iconcolor'));
	add_option('audio_player_lefticoncolor', $ap_color, "Left icon color", true);
	add_option('audio_player_righticoncolor', $ap_color, "Right icon color", true);
	add_option('audio_player_righticonhovercolor', $ap_color, "Right icon hover color", true);
	delete_option('audio_player_iconcolor');

	update_option('audio_player_textcolor', str_replace("#", "0x", get_option('audio_player_textcolor')));

	$ap_color = str_replace("#", "0x", get_option('audio_player_bgcolor'));
	update_option('audio_player_bgcolor', $ap_color);
	add_option('audio_player_leftbgcolor', $ap_color, "Left background color", true);

	$ap_color = str_replace("#", "0x", get_option('audio_player_buttoncolor'));
	add_option('audio_player_rightbgcolor', $ap_color, "Right background color", true);
	delete_option('audio_player_buttoncolor');

	$ap_color = str_replace("#", "0x", get_option('audio_player_buttonhovercolor'));
	add_option('audio_player_rightbghovercolor', $ap_color, "Right background hover color", true);
	delete_option('audio_player_buttonhovercolor');

	$ap_color = str_replace("#", "0x", get_option('audio_player_pathcolor'));
	add_option('audio_player_trackcolor', $ap_color, "Progress track color", true);
	delete_option('audio_player_pathcolor');

	$ap_color = str_replace("#", "0x", get_option('audio_player_barcolor'));
	add_option('audio_player_loadercolor', $ap_color, "Loader bar color", true);
	add_option('audio_player_bordercolor', $ap_color, "Border color", true);
	delete_option('audio_player_barcolor');

	add_option('audio_player_slidercolor', '0x666666', "Progress slider color", true);
} else {
	// Default color options
	add_option('audio_player_bgcolor', '0xE5E5E5', "Background color", true);
	add_option('audio_player_textcolor', '0x333333', "Text color", true);
	add_option('audio_player_leftbgcolor', '0xCCCCCC', "Left background color", true);
	add_option('audio_player_lefticoncolor', '0x333333', "Left icon color", true);
	add_option('audio_player_volslidercolor', '0x666666', "Volume track color", true);
	add_option('audio_player_voltrackcolor', '0xF2F2F2', "Volume silder color", true);
	add_option('audio_player_rightbgcolor', '0xB4B4B4', "Right background color", true);
	add_option('audio_player_rightbghovercolor', '0x999999', "Right background hover color", true);
	add_option('audio_player_righticoncolor', '0x333333', "Right icon color", true);
	add_option('audio_player_righticonhovercolor', '0xFFFFFF', "Right icon hover color", true);
	add_option('audio_player_trackcolor', '0xFFFFFF', "Progress track color", true);
	add_option('audio_player_loadercolor', '0x009900', "Loader bar color", true);
	add_option('audio_player_bordercolor', '0xCCCCCC', "Border color", true);
	add_option('audio_player_trackercolor', '0xDDDDDD', "Progress bar color", true);
	add_option('audio_player_skipcolor', '0x666666', "Next/Previous button color", true);
}

add_option('audio_player_transparentpagebgcolor', 'true', "Transparent player background", true);
add_option('audio_player_pagebgcolor', '#FFFFFF', "Page background color", true);

//update_option('audio_player_enableAnimation', 'yes');

// Global variables
$ap_version = "2.0 beta";
$ap_updateURL = "http://www.1pixelout.net/download/audio-player-update.txt";
$ap_docURL = "http://www.1pixelout.net/code/audio-player-wordpress-plugin/";
$ap_colorkeys = array("bg","leftbg","lefticon","voltrack","volslider","rightbg","rightbghover","righticon","righticonhover","text","track","border","loader","tracker","skip");
$ap_playerURL = get_settings('siteurl') . '/wp-content/plugins/audio-player/player.swf';
$ap_audioURL = get_settings('siteurl') . get_option("audio_player_web_path");

// Initialise playerID (each instance gets unique ID)
$ap_playerID = 0;

// Convert behaviour options to array
$ap_behaviour = explode( ",", get_option("audio_player_behaviour") );

$ap_options = array();

// Builds global array of color options (we need a function because the options update code further down needs it again)
function ap_set_options() {
	global $ap_options, $ap_colorkeys;
	foreach( $ap_colorkeys as $value ) $ap_options[$value] = get_option("audio_player_" . $value . "color");
	$ap_options["animation"] = get_option("audio_player_enableAnimation");
}

ap_set_options();

// Declare instances global variable
$ap_instances = array();

// Filter function (inserts player instances according to behaviour option)
function ap_insert_player_widgets($content = '') {
	global $ap_behaviour, $ap_instances;
	
	// Reset instance array
	$ap_instances = array();

	// Replace mp3 links
	if( in_array( "links", $ap_behaviour ) ) $content = preg_replace_callback( "/<a ([^=]+=\"[^\"]+\" )*href=\"([^\"]+\.mp3)\"( [^=]+=\"[^\"]+\")*>[^<]+<\/a>/i", "ap_replace", $content );
	
	// Replace [audio syntax]
	if( in_array( "default", $ap_behaviour ) ) $content = preg_replace_callback( "/\[audio:(([^]]+))]/i", "ap_replace", $content );

	// Enclosure integration
	if( in_array( "enclosure", $ap_behaviour ) ) {
		$enclosure = get_enclosed($post_id);

		// Insert prefix and postfix clips if set
		$prefixAudio = get_option( "audio_player_prefixaudio" );
		if( $prefixAudio != "" ) $prefixAudio .= ",";
		$postfixAudio = get_option( "audio_player_postfixaudio" );
		if( $postfixAudio != "" ) $postfixAudio = "," . $postfixAudio;

		if( count($enclosure) > 0 ) {
			for($i = 0;$i < count($enclosure);$i++) {
				// Make sure the enclosure is an mp3 file and it hasn't been inserted into the post yet
				if( preg_match( "/.*\.mp3$/", $enclosure[$i] ) == 1 && !in_array( $enclosure[$i], $ap_instances ) ) {
					$content .= "\n\n" . ap_getplayer( $prefixAudio . $enclosure[$i] . $postfixAudio );
				}
			}
		}
	}
	
	return $content;
}

// Callback function for preg_replace_callback
function ap_replace($matches) {
	global $ap_audioURL, $ap_instances;
	// Split options
	$data = preg_split("/[\|]/", $matches[2]);
	$files = array();
	
	if(!is_feed()) {
		// Insert prefix clip if set
		$prefixAudio = get_option( "audio_player_prefixaudio" );
		if( $prefixAudio != "" ) array_push( $files, $prefixAudio );
	}

	// If file doesn't start with http:// or ftp://, assume it is in the default audio folder
	foreach( explode( ",", $data[0] ) as $afile ) {
		if(strpos($afile, "http://") !== 0 && strpos($afile, "ftp://") !== 0) $afile = $ap_audioURL . "/" . $afile;
		array_push( $files, $afile );

		// Add source file to instances already added to the post
		array_push( $ap_instances, $afile );
	}

	if(!is_feed()) {
		// Insert postfix clip if set
		$postfixAudio = get_option( "audio_player_postfixaudio" );
		if( $postfixAudio != "" ) array_push( $files, $postfixAudio );
	}

	$file = implode( ",", $files );
	
	// Build runtime options array
	$options = array();
	for($i=1;$i<count($data);$i++) {
		$pair = explode("=", $data[$i]);
		$options[$pair[0]] = $pair[1]; 
	}
	
	// Return player instance code
	return ap_getplayer( $file, $options );
}

// Generic player instance function (returns object tag code)
function ap_getplayer($source, $options = array()) {
	global $ap_playerID;
	
	// Get next player ID
	$ap_playerID++;
	
	// Add source to options
	$options["soundFile"] = $source;

	if(is_feed()) {
		// We are in a feed so use RSS alternate content option
		switch( get_option( "audio_player_rssalternate" ) ) {
			case "download":
				// Get filenames from path and output a link for each file in the sequence
				$files = explode(",", $source);
				$links = "";
				for($i=0;$i<count($files);$i++) {
					$fileparts = explode("/", $files[$i]);
					$fileName = $fileparts[count($fileparts)-1];
					$links .= '<a href="' . $files[$i] . '">Download audio file (' . $fileName . ')</a><br />';
				}
				return $links;
				break;
			case "nothing":
				return "";
				break;
			case "custom":
				return get_option( "audio_player_rsscustomalternate" );
				break;
		}
	}
	// Not in a feed so return formatted object tag
	else {
		$playerElementID = "audioplayer_" . $ap_playerID;
		$playerCode = '<div class="audioplayer-container" id="' . $playerElementID . '">Audio Player</div>';
		$playerCode .= '<script type="text/javascript">';
		$playerCode .= 'AudioPlayer.embed("' . $playerElementID . '", ' . ap_php2js($options) . ');';
		$playerCode .= '</script>';
		return $playerCode;
	}
}

// Add filter hook
add_filter('the_content', 'ap_insert_player_widgets');
if(in_array("comments", $ap_behaviour)) add_filter('comment_text', 'ap_insert_player_widgets');

// Helper function for displaying a system message
function ap_showMessage( $message ) {
	echo '<div id="message" class="updated fade"><p><strong>' . $message . '</strong></p></div>';
}

// Option panel functionality
function ap_options_subpanel() {
	global $ap_colorkeys, $ap_options, $ap_version, $ap_updateURL, $ap_docURL;
	
	if( $_POST['ap_updateCheck'] ) {
		// Update check. Gets the file at the update URL , reads and compares it with the current version
		$ap_contents = "";
		if( function_exists( "curl_init" ) ) {
			$source = curl_init();
			curl_setopt( $source, CURLOPT_URL, $ap_updateURL );
			curl_setopt( $source, CURLOPT_CONNECTTIMEOUT, 10 );
			curl_setopt( $source, CURLOPT_FAILONERROR, 1 );
			curl_setopt( $source, CURLOPT_RETURNTRANSFER, 1 );
			$ap_contents = curl_exec( $source );
			if( curl_errno( $source ) > 0 ) {
				$ap_contents = "error";
			} else curl_close( $source );
		} else if( ini_get( "allow_url_fopen" ) ) {
			if( $source = @fopen( $ap_updateURL, "r" ) ) {
				while( !feof( $source ) ) {
					$ap_contents .= fread( $source, 8192 );
				}
				fclose($source);
			} else $ap_contents = "error";
		}

		// Errors
		if( $ap_contents == "error" ) {
			ap_showMessage( 'Failed to contact update server. Please visit <a href="' . $ap_docURL . '">1 Pixel Out</a> to check for updates.' );
		} else if( $ap_contents == "" ) {
			ap_showMessage( 'Some PHP functionality used by the Upgrade wizard are disabled on your server. Please visit <a href="' . $ap_docURL . '">1 Pixel Out</a> to check for updates.' );
		} else if( $ap_contents != $ap_version ) {
			// A new version is available so announce this with a message
			// Check that the zip extension is loaded and the PHP engine is 4.2.0 at least (otherwise the upgrade wizard won't work)
			if( version_compare( phpversion(), "4.2.0" ) == 1 && in_array( "zip", get_loaded_extensions() ) ) {
				ap_showMessage( 'Version ' . $ap_contents . ' of the Audio Player plugin is now available! <a href="javascript:ap_startUpgradeWizard()">Upgrade now</a>.' );
			} else {
				ap_showMessage( 'Version ' . $ap_contents . ' of the Audio Player plugin is now available! Download it <a href="' . $ap_docURL . '">here</a>.' );
			}
		} else {
			// Plugin is up-to-date
			ap_showMessage( "Your copy of Audio Player plugin is up-to-date." );
		}
	} else if( $_POST['Submit'] ) {
		// Update plugin options
	
		// Set audio web path
		if( substr( $_POST['ap_audiowebpath'], -1 ) == "/" ) $_POST['ap_audiowebpath'] = substr( $_POST['ap_audiowebpath'], 0, strlen( $_POST['ap_audiowebpath'] ) - 1 );
		update_option('audio_player_web_path', $_POST['ap_audiowebpath']);

		// Update behaviour and rss alternate content options
		update_option('audio_player_embedmethod', $_POST['ap_embedmethod']);
		update_option('audio_player_includeembedfile', isset( $_POST["ap_includeembedfile"] ));
		if(isset( $_POST["ap_disableAnimation"] )) update_option('audio_player_enableAnimation', "no");
		else update_option('audio_player_enableAnimation', "yes");
		if(count($_POST['ap_behaviour']) > 0) update_option('audio_player_behaviour', implode(",", $_POST['ap_behaviour']));
		else update_option('audio_player_behaviour', '');
		update_option('audio_player_rssalternate', $_POST['ap_rssalternate']);
		update_option('audio_player_rsscustomalternate', $_POST['ap_rsscustomalternate']);
		update_option('audio_player_prefixaudio', $_POST['ap_audioprefixwebpath']);
		update_option('audio_player_postfixaudio', $_POST['ap_audiopostfixwebpath']);

		// Update colour options
		foreach( $ap_colorkeys as $colorkey ) {
			// Ignore missing or invalid color values
			if( isset( $_POST["ap_" . $colorkey . "color"] ) && preg_match( "/#[0-9A-Fa-f]{6}/", $_POST["ap_" . $colorkey . "color"] ) == 1 ) {
				update_option( "audio_player_" . $colorkey . "color", str_replace( "#", "0x", $_POST["ap_" . $colorkey . "color"] ) );
			}
		}

		if(isset( $_POST["ap_pagebgcolor"] )) update_option('audio_player_pagebgcolor', $_POST['ap_pagebgcolor']);
		update_option('audio_player_transparentpagebg', isset( $_POST["ap_transparentpagebg"] ));
		
		// Need to do this again for the player preview on the options panel
		ap_set_options();
		
		// Print confirmation message
		ap_showMessage( "Options updated." );
	}

	$ap_behaviour = explode(",", get_option("audio_player_behaviour"));
	$ap_rssalternate = get_option('audio_player_rssalternate');
	
	// Preview player options
	$ap_demo_options = array();
	$ap_demo_options["autostart"] = "yes";
	$ap_demo_options["loop"] = "yes";
	
	$ap_embedMethod = get_option("audio_player_embedmethod");
	$ap_includeEmbedFile = get_option("audio_player_includeembedfile");
	$ap_enableAnimation = get_option("audio_player_enableAnimation");
	
	// Include options panel
	include( "options-panel-2.php" );
}

// Add options page to admin menu
function ap_post_add_options() {
	add_options_page('Audio player options', 'Audio Player', 8, basename(__FILE__), 'ap_options_subpanel');
}
add_action('admin_menu', 'ap_post_add_options');

// Output script tag in WP front-end head
function ap_wp_head() {
	global $ap_playerID, $ap_options;
	
	if( get_option("audio_player_transparentpagebg") )
	{
		$wmode = "transparent";
		$bgcolor = "transparent";
	} else {
		$wmode = "opaque";
		$bgcolor = get_option("audio_player_pagebgcolor");
	}
	$width = get_option("audio_player_width");
	
	$embedMethod = get_option("audio_player_embedmethod");
	
	if(get_option("audio_player_includeembedfile")) {
		echo '<script type="text/javascript" src="' . get_settings("siteurl") . '/wp-content/plugins/audio-player/' . $embedMethod . '.js"></script>';
		echo "\n";
	}
	echo '<script type="text/javascript" src="' . get_settings("siteurl") . '/wp-content/plugins/audio-player/audio-player-' . $embedMethod . '.js"></script>';
	echo "\n";
	echo '<script type="text/javascript">';
	echo "\n";
	echo 'AudioPlayer.setup("' . get_settings("siteurl") . '/wp-content/plugins/audio-player/player.swf", ' . get_option("audio_player_width") . ', "' . $wmode . '", "' . $bgcolor . '", ' . ap_php2js($ap_options) . ');';
	echo "\n";
	echo '</script>';
	echo "\n";
}
add_action('wp_head', 'ap_wp_head');

// Output script tag in WP admin head
function ap_wp_admin_head() {
	global $ap_playerID;
	if(!($_GET["page"] == "audio-player.php")) return;
	echo '<link href="' . get_settings("siteurl") . '/wp-content/plugins/audio-player/audio-player-admin.css" rel="stylesheet" type="text/css" />';
	echo "\n";
	echo '<link href="' . get_settings("siteurl") . '/wp-content/plugins/audio-player/colorpicker/moocolorpicker.css" rel="stylesheet" type="text/css" />';
	echo "\n";
	echo '<script type="text/javascript" src="' . get_settings("siteurl") . '/wp-content/plugins/audio-player/mootools.js"></script>';
	echo "\n";
	echo '<script type="text/javascript" src="' . get_settings("siteurl") . '/wp-content/plugins/audio-player/colorpicker/moocolorpicker.js"></script>';
	echo "\n";
	echo '<script type="text/javascript" src="' . get_settings("siteurl") . '/wp-content/plugins/audio-player/audio-player-admin-2.js"></script>';
	echo "\n";
	echo '<script type="text/javascript">';
	echo "\n";
	echo 'var ap_updateURL = "' . get_option("siteurl") . '/wp-content/plugins/audio-player/upgrade/";';
	echo "\n";
	echo '</script>';
	echo "\n";
}
add_action('admin_head', 'ap_wp_admin_head');
add_action('admin_head', 'ap_wp_head');

function ap_php2js($object) {
	$js_options = '{';
	$separator = "";
	$real_separator = ",";
	foreach($object as $key=>$value) {
		$js_options .= $separator . $key . ':"' . $value .'"';
		$separator = $real_separator;
	}
	$js_options .= "}";
	
	return $js_options;
}

?>