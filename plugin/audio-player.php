<?php
/*
Plugin Name: Audio player
Plugin URI: http://www.1pixelout.net/code/audio-player-wordpress-plugin/
Description: Highly configurable single track mp3 player.
Version: 2.0 beta
Author: Martin Laine
Author URI: http://www.1pixelout.net

License:

Copyright (c) 2007 Martin Laine

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

// Option defaults
add_option('audio_player_web_path', '/audio', "Web path to audio files", true);
add_option('audio_player_width', '290', "Player width", true);
add_option('audio_player_enableAnimation', 'yes', "Enable animation", true);
add_option('audio_player_showRemaining', 'no', "Show remaining", true);
add_option('audio_player_encodeSource', 'yes', "Encode source", true);
add_option('audio_player_embedmethod', 'ufo', "Flash embed method", true);
add_option('audio_player_includeembedfile', 'yes', "Include embed method file", true);
add_option('audio_player_behaviour', 'default', "Plugin behaviour", true);
add_option('audio_player_rssalternate', 'nothing', "RSS alternate content", true);
add_option('audio_player_rsscustomalternate', '[See post to listen to audio]', "Custom RSS alternate content", true);
add_option('audio_player_prefixaudio', '', "Pre-Stream Audio", true);
add_option('audio_player_postfixaudio', '', "Post-Stream Audio", true);
add_option('audio_player_initialvolume', '', "Initial Volume", 80);

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
$ap_docURL = "http://www.1pixelout.net/code/audio-player-wordpress-plugin/";
$ap_colorkeys = array("bg","leftbg","lefticon","voltrack","volslider","rightbg","rightbghover","righticon","righticonhover","text","track","border","loader","tracker","skip");
$ap_pluginRoot = get_settings('siteurl') . '/wp-content/plugins/audio-player/';
$ap_playerURL = $ap_pluginRoot . 'player.swf';
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
	$ap_options["encode"] = get_option("audio_player_encodeSource");
	$ap_options["initialvolume"] = get_option("audio_player_initialvolume");
	$ap_options["remaining"] = get_option("audio_player_showRemaining");
}

ap_set_options();

// Declare instances global variable
$ap_instances = array();

// Filter function (inserts player instances according to behaviour option)
function ap_insert_player_widgets($content = '') {
	global $ap_behaviour, $ap_instances, $comment;
	
	// Reset instance array
	$ap_instances = array();

	// Replace mp3 links
	if( in_array( "links", $ap_behaviour ) ) $content = preg_replace_callback( "/<a ([^=]+=\"[^\"]+\" )*href=\"([^\"]+\.mp3)\"( [^=]+=\"[^\"]+\")*>[^<]+<\/a>/i", "ap_replace", $content );
	
	// Replace [audio syntax]
	if( in_array( "default", $ap_behaviour ) ) $content = preg_replace_callback( "/\[audio:(([^]]+))\]/i", "ap_replace", $content );

	// Enclosure integration
	if( !$comment && in_array( "enclosure", $ap_behaviour ) ) {
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
	if(get_option('audio_player_encodeSource') == "yes") $options["soundFile"] = ap_encodeSource($source);

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
		$playerCode .= '<script type="text/javascript"><!--';
		$playerCode .= "\n";
		$playerCode .= 'AudioPlayer.embed("' . $playerElementID . '", ' . ap_php2js($options) . ');';
		$playerCode .= "\n";
		$playerCode .= '--></script>';
		// TODO: Download links
		/*$files = explode(",", $source);
		for($i=0;$i<count($files);$i++) {
			$fileparts = explode("/", $files[$i]);
			$fileName = $fileparts[count($fileparts)-1];
			$playerCode .= '<p><a href="' . $files[$i] . '">Download audio file (' . $fileName . ')</a></p>';
		}*/
		return $playerCode;
	}
}

function ap_encodeSource($source) {
	$source = utf8_decode($source);
	$ntexto = "";
	$codekey = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-";
	for($i=0; $i< strlen($source); $i++) {
		$ntexto .= substr("0000".base_convert(ord($source{$i}), 10, 2), -8);
	}
	$ntexto .= substr("00000", 0, 6-strlen($ntexto)%6);
	$source = "";
	for ($i=0; $i< strlen($ntexto)-1; $i = $i+6) {
		$source .= $codekey{intval(substr($ntexto, $i, 6), 2)};
	}
	
	return $source;
}

// Add filter hook
add_filter('the_content', 'ap_insert_player_widgets');
if(in_array("comments", $ap_behaviour)) add_filter('comment_text', 'ap_insert_player_widgets');

// Helper function for displaying a system message
function ap_showMessage( $message, $type="updated" ) {
	echo '<div id="message" class="' . $type . ' fade"><p><strong>' . $message . '</strong></p></div>';
}

// Option panel functionality
function ap_options_subpanel() {
	global $ap_colorkeys, $ap_options, $ap_version, $ap_playerURL, $ap_docURL;
	
	// Update plugin options
	if( $_POST['Submit'] ) {
		check_admin_referer('audio-player-action');
	
		// Set audio web path
		if( substr( $_POST['ap_audiowebpath'], -1 ) == "/" ) $_POST['ap_audiowebpath'] = substr( $_POST['ap_audiowebpath'], 0, strlen( $_POST['ap_audiowebpath'] ) - 1 );
		update_option('audio_player_web_path', $_POST['ap_audiowebpath']);

		// Update behaviour and rss alternate content options
		update_option('audio_player_embedmethod', $_POST['ap_embedmethod']);
		update_option('audio_player_includeembedfile', isset( $_POST["ap_includeembedfile"] ));

		if(isset( $_POST["ap_encodeSource"] )) update_option('audio_player_encodeSource', "yes");
		else update_option('audio_player_encodeSource', "no");

		if(isset( $_POST["ap_disableAnimation"] )) update_option('audio_player_enableAnimation', "no");
		else update_option('audio_player_enableAnimation', "yes");

		if(isset( $_POST["ap_showRemaining"] )) update_option('audio_player_showRemaining', "yes");
		else update_option('audio_player_showRemaining', "no");

		if(count($_POST['ap_behaviour']) > 0) update_option('audio_player_behaviour', implode(",", $_POST['ap_behaviour']));
		else update_option('audio_player_behaviour', '');

		update_option('audio_player_rssalternate', $_POST['ap_rssalternate']);
		update_option('audio_player_rsscustomalternate', $_POST['ap_rsscustomalternate']);
		update_option('audio_player_prefixaudio', $_POST['ap_audioprefixwebpath']);
		update_option('audio_player_postfixaudio', $_POST['ap_audiopostfixwebpath']);

		update_option('audio_player_width', $_POST['ap_player_width']);
		update_option('audio_player_initialvolume', $_POST['ap_initial_volume']);

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

	$ap_theme_colors = ap_get_theme_colors();

	$ap_behaviour = explode(",", get_option("audio_player_behaviour"));
	$ap_rssalternate = get_option('audio_player_rssalternate');
	$ap_player_width = get_option("audio_player_width");
	$ap_initial_volume = get_option("audio_player_initialvolume");
	
	$ap_embedMethod = get_option("audio_player_embedmethod");
	$ap_includeEmbedFile = get_option("audio_player_includeembedfile");
	$ap_encodeSource = (get_option("audio_player_encodeSource") == "yes");
	$ap_enableAnimation = get_option("audio_player_enableAnimation");
	$ap_showRemaining = get_option("audio_player_showRemaining");
	
	// Include options panel
	include( "options-panel.php" );
}

function ap_get_theme_colors() {
	$current_theme_data = get_theme(get_current_theme());

	$theme_css = implode('', file( get_theme_root() . "/" . $current_theme_data["Stylesheet"] . "/style.css"));

	preg_match_all('/:[^:;}]*#([abcdef1234567890]+)/i', $theme_css, $matches);

	return array_unique($matches[1]);
}

// Add options page to admin menu
function ap_post_add_options() {
	add_options_page('Audio player options', 'Audio Player', 8, 'audio-player-options', 'ap_options_subpanel');
}
add_action('admin_menu', 'ap_post_add_options');

// Output script tag in WP front-end head
function ap_wp_head() {
	global $ap_options, $ap_pluginRoot, $ap_playerURL;
	
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
		echo '<script type="text/javascript" src="' . $ap_pluginRoot . $embedMethod . '.js"></script>';
		echo "\n";
	}
	echo '<script type="text/javascript" src="' . $ap_pluginRoot . 'audio-player-' . $embedMethod . '.js"></script>';
	echo "\n";
	echo '<script type="text/javascript">';
	echo "\n";
	echo 'AudioPlayer.setup("' . $ap_playerURL . '", "' . get_option("audio_player_width") . '", "' . $wmode . '", "' . $bgcolor . '", ' . ap_php2js($ap_options) . ');';
	echo "\n";
	echo '</script>';
	echo "\n";
}
add_action('wp_head', 'ap_wp_head');

// Output script tag in WP admin head
function ap_wp_admin_head() {
	global $ap_pluginRoot;
	
	if(!($_GET["page"] == "audio-player-options")) return;
	echo '<link href="' . $ap_pluginRoot . 'audio-player-admin.css" rel="stylesheet" type="text/css" />';
	echo "\n";
	echo '<link href="' . $ap_pluginRoot . 'colorpicker/moocolorpicker.css" rel="stylesheet" type="text/css" />';
	echo "\n";
	echo '<script type="text/javascript" src="' . $ap_pluginRoot . 'mootools.js"></script>';
	echo "\n";
	echo '<script type="text/javascript" src="' . $ap_pluginRoot . 'colorpicker/moocolorpicker.js"></script>';
	echo "\n";
	echo '<script type="text/javascript" src="' . $ap_pluginRoot . 'audio-player-admin.js"></script>';
	echo "\n";

	$embedMethod = get_option("audio_player_embedmethod");
	echo '<script type="text/javascript" src="' . $ap_pluginRoot . $embedMethod . '.js"></script>';
	echo "\n";
	echo '<script type="text/javascript" src="' . $ap_pluginRoot . 'audio-player-' . $embedMethod . '.js"></script>';
	echo "\n";
}
add_action('admin_head', 'ap_wp_admin_head');

function ap_php2js($object) {
	$js_options = '{';
	$separator = "";
	$real_separator = ",";
	foreach($object as $key=>$value) {
		$js_options .= $separator . $key . ':"' . rawurlencode($value) .'"';
		$separator = $real_separator;
	}
	$js_options .= "}";
	
	return $js_options;
}

?>