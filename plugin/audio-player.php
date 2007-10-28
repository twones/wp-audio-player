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

// ------------------------------------------------------------------------------
// Global variables for Audio Player
// ------------------------------------------------------------------------------

$ap_globals = array();

$ap_globals["version"] = "2.0 beta";
$ap_globals["docURL"] = "http://www.1pixelout.net/code/audio-player-wordpress-plugin/";
$ap_globals["colorkeys"] = array("bg","leftbg","lefticon","voltrack","volslider","rightbg","rightbghover","righticon","righticonhover","text","track","border","loader","tracker","skip");
$ap_globals["pluginRoot"] = get_settings('siteurl') . '/wp-content/plugins/audio-player/';
$ap_globals["playerURL"] = $ap_globals["pluginRoot"] . 'player.swf';

// Declare instances global variable
$ap_globals["instances"] = array();

// Initialise playerID (each instance gets unique ID)
$ap_globals["playerID"] = 0;

// Flag for dealing with excerpts
$ap_globals["in_excerpt"] = false;

function ap_setGlobals() {
	global $ap_globals;

	$ap_globals["audioRoot"] = get_option("audio_player_web_path");

	$ap_globals["audioAbsPath"]	= "";
	$ap_globals["isCustomAudioRoot"] = true;
	if (!ap_isAbsoluteURL($ap_globals["audioRoot"])) {
		$sysDelimiter = '/';
		if (strpos(ABSPATH, '\\') !== false) $sysDelimiter = '\\';
		$ap_globals["audioAbsPath"] = preg_replace('/[\\\\\/]+/', $sysDelimiter, ABSPATH . $ap_globals["audioRoot"]);

		$ap_globals["isCustomAudioRoot"] = false;
		$ap_globals["audioRoot"] = get_settings('siteurl') . $ap_globals["audioRoot"];
	}

	$ap_globals["behaviour"] = explode( ",", get_option("audio_player_behaviour") );
	$ap_globals["rssalternate"] = get_option("audio_player_rssalternate");
	$ap_globals["playerWidth"] = get_option("audio_player_width");
	$ap_globals["initialVolume"] = get_option("audio_player_initialvolume");
	$ap_globals["embedMethod"] = get_option("audio_player_embedmethod");
	
	// Make sure these values are converted to real boolean values
	$ap_globals["includeEmbedFile"] = (get_option("audio_player_includeembedfile") == "yes");
	$ap_globals["encodeSource"] = (get_option("audio_player_encodeSource") == "yes");
	$ap_globals["enableAnimation"] = (get_option("audio_player_enableAnimation") == "yes");
	$ap_globals["showRemaining"] = (get_option("audio_player_showRemaining") == "yes");
	$ap_globals["disableTrackInformation"] = (get_option("audio_player_noinfo") == "yes");
	$ap_globals["transparentPageBg"] = (get_option("audio_player_transparentpagebgcolor") == "yes");

	$ap_globals["pageBgColor"] = get_option("audio_player_pagebgcolor");

	$ap_globals["prefixAudio"] = get_option("audio_player_prefixaudio");
	$ap_globals["postfixAudio"] = get_option("audio_player_postfixaudio");

	$ap_globals["rssAlternate"] = get_option("audio_player_rssalternate");
	$ap_globals["rssCustomAlternate"] = get_option("audio_player_rsscustomalternate");
	
	$ap_globals["excerptAlternate"] = get_option("audio_player_excerptalternate");

	// Player options set (options passed to Flash Player)
	$playerOptions = array();

	foreach ( $ap_globals["colorkeys"] as $value ) {
		$playerOptions[$value] = get_option("audio_player_" . $value . "color");
	}
	$playerOptions["animation"] = get_option("audio_player_enableAnimation");
	$playerOptions["encode"] = get_option("audio_player_encodeSource");
	$playerOptions["initialvolume"] = get_option("audio_player_initialvolume");
	$playerOptions["remaining"] = get_option("audio_player_showRemaining");
	$playerOptions["noinfo"] = get_option("audio_player_noinfo");

	$ap_globals["playerOptions"] = $playerOptions;
}

// ------------------------------------------------------------------------------
// Options setup
// ------------------------------------------------------------------------------

// Option defaults

add_option('audio_player_web_path', '/audio');
add_option('audio_player_width', '290');
add_option('audio_player_enableAnimation', 'yes');
add_option('audio_player_showRemaining', 'no');
add_option('audio_player_encodeSource', 'yes');
add_option('audio_player_embedmethod', 'ufo');
add_option('audio_player_includeembedfile', 'yes');
add_option('audio_player_behaviour', 'default');
add_option('audio_player_rssalternate', 'nothing');
add_option('audio_player_rsscustomalternate', '[Audio clip: view full post to listen]');
add_option('audio_player_excerptalternate', '[Audio clip: view full post to listen]');
add_option('audio_player_prefixaudio', '');
add_option('audio_player_postfixaudio', '');
add_option('audio_player_initialvolume', '60');
add_option('audio_player_noinfo', 'no');

// Color options

// Update old color options (remove '0x')
if (get_option('audio_player_version') == '' && get_option('audio_player_bgcolor') != '') {
	foreach ( $ap_globals["colorkeys"] as $value ) {
		$colorOptionValue = get_option("audio_player_" . $value . "color");
		if ($colorOptionValue != '') update_option("audio_player_" . $value . "color", str_replace("0x", "", $colorOptionValue));
	}
	update_option('audio_player_pagebgcolor', str_replace("#", "", get_option('audio_player_pagebgcolor')));
}

add_option('audio_player_version', $ap_globals["version"]);

// Default color options
add_option('audio_player_bgcolor', 'E5E5E5');
add_option('audio_player_textcolor', '333333');
add_option('audio_player_leftbgcolor', 'CCCCCC');
add_option('audio_player_lefticoncolor', '333333');
add_option('audio_player_volslidercolor', '666666');
add_option('audio_player_voltrackcolor', 'FFFFFF');
add_option('audio_player_rightbgcolor', 'B4B4B4');
add_option('audio_player_rightbghovercolor', '999999');
add_option('audio_player_righticoncolor', '333333');
add_option('audio_player_righticonhovercolor', 'FFFFFF');
add_option('audio_player_trackcolor', 'FFFFFF');
add_option('audio_player_loadercolor', '009900');
add_option('audio_player_bordercolor', 'CCCCCC');
add_option('audio_player_trackercolor', 'DDDDDD');
add_option('audio_player_skipcolor', '666666');

add_option('audio_player_transparentpagebgcolor', 'yes');
add_option('audio_player_pagebgcolor', 'FFFFFF');

// Set globals
ap_setGlobals();

// ------------------------------------------------------------------------------
// Player widget functions
// ------------------------------------------------------------------------------

// Filter function (inserts player instances according to behaviour option)
function ap_insert_player_widgets($content = '') {
	global $ap_globals, $comment;
	
	// Reset instance array (this is so we don't insert duplicate players)
	$ap_globals["instances"] = array();

	// Replace mp3 links (don't do this in feeds and excerpts)
	if ( !is_feed() && !$ap_globals["in_excerpt"] && in_array( "links", $ap_globals["behaviour"] ) ) {
		$pattern = "/<a ([^=]+=\"[^\"]+\" )*href=\"(([^\"]+\.mp3))\"( [^=]+=\"[^\"]+\")*>[^<]+<\/a>/i";
		$content = preg_replace_callback( $pattern, "ap_replace", $content );
	}
	
	// Replace [audio syntax]
	if( in_array( "default", $ap_globals["behaviour"] ) ) {
		$pattern = "/(<p>)?\[audio:(([^]]+))\](<\/p>)?/i";
		$content = preg_replace_callback( $pattern, "ap_replace", $content );
	}

	// Enclosure integration (don't do this for feeds, excerpts and comments)
	if( !is_feed() && !$ap_globals["in_excerpt"] && !$comment && in_array( "enclosure", $ap_globals["behaviour"] ) ) {
		$enclosure = get_enclosed($post_id);

		// Insert prefix and postfix clips if set
		$prefixAudio = $ap_globals["prefixAudio"];
		if( $prefixAudio != "" ) $prefixAudio .= ",";
		$postfixAudio = $ap_globals["postfixAudio"];
		if( $postfixAudio != "" ) $postfixAudio = "," . $postfixAudio;

		if( count($enclosure) > 0 ) {
			for($i = 0;$i < count($enclosure);$i++) {
				// Make sure the enclosure is an mp3 file and it hasn't been inserted into the post yet
				if( preg_match( "/.*\.mp3$/", $enclosure[$i] ) == 1 && !in_array( $enclosure[$i], $ap_globals["instances"] ) ) {
					$content .= "\n\n" . ap_getplayer( $prefixAudio . $enclosure[$i] . $postfixAudio );
				}
			}
		}
	}
	
	return $content;
}

// Callback function for preg_replace_callback
function ap_replace($matches) {
	global $ap_globals;
	
	// Split options
	$data = preg_split("/[\|]/", $matches[3]);
	$files = array();
	
	// Alternate content for excerpts (don't do this for feeds)
	if($ap_globals["in_excerpt"] && !is_feed()) {
		return $ap_globals["excerptAlternate"];
	}
	
	if (!is_feed()) {
		// Insert prefix clip if set
		if ( $ap_globals["prefixAudio"] != "" ) {
			$afile = $ap_globals["prefixAudio"];
			if (!ap_isAbsoluteURL($afile)) {
				$afile = $ap_globals["audioRoot"] . "/" . $afile;
			}
			array_push( $files, $afile );
		}
	}

	// Create an array of files to load in player
	foreach ( explode( ",", $data[0] ) as $afile ) {
		// Get absolute URLs for relative ones
		if (!ap_isAbsoluteURL($afile)) {
			$afile = $ap_globals["audioRoot"] . "/" . $afile;
		}
		
		array_push( $files, $afile );

		// Add source file to instances already added to the post
		array_push( $ap_globals["instances"], $afile );
	}

	if (!is_feed()) {
		// Insert postfix clip if set
		if ( $ap_globals["postfixAudio"] != "" ) {
			$afile = $ap_globals["postfixAudio"];
			if (!ap_isAbsoluteURL($afile)) {
				$afile = $ap_globals["audioRoot"] . "/" . $afile;
			}
			array_push( $files, $afile );
		}
	}

	// Build runtime options array
	$options = array();
	for ($i = 1; $i < count($data); $i++) {
		$pair = explode("=", $data[$i]);
		$options[$pair[0]] = $pair[1]; 
	}
	
	// Return player instance code
	return ap_getplayer( implode( ",", $files ), $options );
}

// Generic player instance function (returns object tag code)
function ap_getplayer($source, $options = array()) {
	global $ap_globals;
	
	// Get next player ID
	$ap_globals["playerID"]++;
	
	// Add source to options and encode if necessary
	$options["soundFile"] = $source;
	if ($ap_globals["encodeSource"]) {
		$options["soundFile"] = ap_encodeSource($source);
	}
	
	if (is_feed()) {
		// We are in a feed so use RSS alternate content option
		switch ( $ap_globals["rssAlternate"] ) {

		case "download":
			// Get filenames from path and output a link for each file in the sequence
			$files = explode(",", $source);
			$links = "";
			for ($i = 0; $i < count($files); $i++) {
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
			return $ap_globals["rssCustomAlternate"];
			break;

		}
	} else {
		// Not in a feed so return player widget
		$playerElementID = "audioplayer_" . $ap_globals["playerID"];
		$playerCode = '<p class="audioplayer-container" id="' . $playerElementID . '">Audio clip: <a href="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash&amp;promoid=BIOW" title="Download Adobe Flash Player">Adobe Flash Player</a> (version 6 or above) is required to play this audio clip. You also need to have JavaScript enabled in your browser.</p>';
		$playerCode .= '<script type="text/javascript"><!--';
		$playerCode .= "\n";
		$playerCode .= 'AudioPlayer.embed("' . $playerElementID . '", ' . ap_php2js($options) . ');';
		$playerCode .= "\n";
		$playerCode .= '--></script>';
		return $playerCode;
	}
}

// ------------------------------------------------------------------------------
// Excerpt helper functions
// Sets a flag so we know we are in an automatically created excerpt
// ------------------------------------------------------------------------------

// Sets a flag when getting an excerpt
function ap_in_excerpt($text = '') {
	global $ap_globals;

	// Only set the flag when the excerpt is empty and WP creates one automatically)
	if('' == $text) $ap_globals["in_excerpt"] = true;

	return $text;
}

// Resets a flag after getting an excerpt
function ap_outof_excerpt($text = '') {
	global $ap_globals;

	$ap_globals["in_excerpt"] = false;

	return $text;
}

// ------------------------------------------------------------------------------
// Option panel functionality
// ------------------------------------------------------------------------------

function ap_options_subpanel() {
	global $ap_globals;
	
	$ap_updated = false;
	
	// Update plugin options
	if( $_POST['Submit'] ) {
		check_admin_referer('audio-player-action');
	
		// Set audio web path
		if ( substr( $_POST['ap_audiowebpath'], -1 ) == "/" ) {
			$_POST['ap_audiowebpath'] = substr( $_POST['ap_audiowebpath'], 0, strlen( $_POST['ap_audiowebpath'] ) - 1 );
		}
		update_option('audio_player_web_path', $_POST['ap_audiowebpath']);

		// Update behaviour and rss alternate content options
		update_option('audio_player_embedmethod', $_POST['ap_embedmethod']);

		if(isset( $_POST["ap_includeembedfile"] )) {
			update_option('audio_player_includeembedfile', "yes");
		} else {
			update_option('audio_player_includeembedfile', "no");
		}

		if(isset( $_POST["ap_encodeSource"] )) {
			update_option('audio_player_encodeSource', "yes");
		} else {
			update_option('audio_player_encodeSource', "no");
		}

		if(isset( $_POST["ap_disableAnimation"] )) {
			update_option('audio_player_enableAnimation', "no");
		} else {
			update_option('audio_player_enableAnimation', "yes");
		}

		if(isset( $_POST["ap_showRemaining"] )) {
			update_option('audio_player_showRemaining', "yes");
		} else {
			update_option('audio_player_showRemaining', "no");
		}

		if(isset( $_POST["ap_disableTrackInformation"] )) {
			update_option('audio_player_noinfo', "yes");
		} else {
			update_option('audio_player_noinfo', "no");
		}

		if(count($_POST['ap_behaviour']) > 0) {
			update_option('audio_player_behaviour', implode(",", $_POST['ap_behaviour']));
		} else {
			update_option('audio_player_behaviour', '');
		}

		update_option('audio_player_excerptalternate', stripslashes($_POST['ap_excerptalternate']));

		update_option('audio_player_rssalternate', $_POST['ap_rssalternate']);
		update_option('audio_player_rsscustomalternate', stripslashes($_POST['ap_rsscustomalternate']));
		update_option('audio_player_prefixaudio', $_POST['ap_audioprefixwebpath']);
		update_option('audio_player_postfixaudio', $_POST['ap_audiopostfixwebpath']);

		update_option('audio_player_width', $_POST['ap_player_width']);
		update_option('audio_player_initialvolume', $_POST['ap_initial_volume']);

		// Update colour options
		foreach ( $ap_globals["colorkeys"] as $colorkey ) {
			// Ignore missing or invalid color values
			if( isset( $_POST["ap_" . $colorkey . "color"] ) && preg_match( "/#[0-9A-Fa-f]{6}/", $_POST["ap_" . $colorkey . "color"] ) == 1 ) {
				update_option( "audio_player_" . $colorkey . "color", str_replace( "#", "", $_POST["ap_" . $colorkey . "color"] ) );
			}
		}

		if ( isset( $_POST["ap_pagebgcolor"] ) && preg_match( "/#[0-9A-Fa-f]{6}/", $_POST["ap_pagebgcolor"] ) == 1 ) {
			update_option('audio_player_pagebgcolor', str_replace( "#", "", $_POST['ap_pagebgcolor']));
		}
		if(isset( $_POST["ap_transparentpagebg"] )) {
			update_option('audio_player_transparentpagebgcolor', "yes");
		} else {
			update_option('audio_player_transparentpagebgcolor', "no");
		}
		
		// Need to do this again for the player preview on the options panel
		ap_setGlobals();
		
		// Print confirmation message
		$ap_updated = true;
	}

	// Get the current theme colors for the theme color picker
	$ap_theme_colors = ap_get_theme_colors();

	// Include options panel
	include( "options-panel.php" );
}

// ------------------------------------------------------------------------------
// Header content (css and javascript)
// ------------------------------------------------------------------------------

// Output necessary stuff to WP head section
function ap_wp_head() {
	global $ap_globals;
	
	if ( $ap_globals["transparentPageBg"] ) {
		$wmode = "transparent";
		$bgcolor = "transparent";
	} else {
		$wmode = "opaque";
		$bgcolor = $ap_globals["pageBgColor"];
	}
	
	if ($ap_globals["includeEmbedFile"]) {
		echo '<script type="text/javascript" src="' . $ap_globals["pluginRoot"] . 'lib/' . $ap_globals["embedMethod"] . '.js"></script>';
		echo "\n";
	}
	
	echo '<script type="text/javascript" src="' . $ap_globals["pluginRoot"] . 'assets/audio-player-' . $ap_globals["embedMethod"] . '.js"></script>';
	echo "\n";
	echo '<script type="text/javascript">';
	echo "\n";
	echo 'AudioPlayer.setup("' . $ap_globals["playerURL"] . '", "' . $ap_globals["playerWidth"] . '", "' . $wmode . '", "' . $bgcolor . '", ' . ap_php2js($ap_globals["playerOptions"]) . ');';
	echo "\n";
	echo '</script>';
	echo "\n";
}

// Output necessary stuff to WP admin head section
function ap_wp_admin_head() {
	global $ap_globals;
	
	// Do nothing if not on Audio Player options page
	if (!($_GET["page"] == "audio-player-options")) {
		return;
	}
	
	echo '<link href="' . $ap_globals["pluginRoot"] . 'assets/audio-player-admin.css" rel="stylesheet" type="text/css" />';
	echo "\n";
	echo '<link href="' . $ap_globals["pluginRoot"] . 'colorpicker/moocolorpicker.css" rel="stylesheet" type="text/css" />';
	echo "\n";
	echo '<script type="text/javascript" src="' . $ap_globals["pluginRoot"] . 'lib/mootools.js"></script>';
	echo "\n";
	echo '<script type="text/javascript" src="' . $ap_globals["pluginRoot"] . 'colorpicker/moocolorpicker.js"></script>';
	echo "\n";
	echo '<script type="text/javascript" src="' . $ap_globals["pluginRoot"] . 'assets/audio-player-admin.js"></script>';
	echo "\n";
	echo '<script type="text/javascript" src="' . $ap_globals["pluginRoot"] . 'lib/' . $ap_globals["embedMethod"] . '.js"></script>';
	echo "\n";
	echo '<script type="text/javascript" src="' . $ap_globals["pluginRoot"] . 'assets/audio-player-' . $ap_globals["embedMethod"] . '.js"></script>';
	echo "\n";
}

// ------------------------------------------------------------------------------
// WP hooks
// ------------------------------------------------------------------------------

add_action('wp_head', 'ap_wp_head');
add_action('admin_head', 'ap_wp_admin_head');
function ap_post_add_options() {
	add_options_page('Audio player options', 'Audio Player', 8, 'audio-player-options', 'ap_options_subpanel');
}
add_action('admin_menu', 'ap_post_add_options');

// Filters
add_filter('the_content', 'ap_insert_player_widgets');
if(in_array("comments", $ap_globals["behaviour"])) {
	add_filter('comment_text', 'ap_insert_player_widgets');
}
add_filter('get_the_excerpt', 'ap_in_excerpt', 1);
add_filter('get_the_excerpt', 'ap_outof_excerpt', 12);
add_filter('the_excerpt', 'ap_insert_player_widgets');
add_filter('the_excerpt_rss', 'ap_insert_player_widgets');

// ------------------------------------------------------------------------------
// Helper functions
// ------------------------------------------------------------------------------

// Parses theme style sheet and returns an array of color codes
function ap_get_theme_colors() {
	$current_theme_data = get_theme(get_current_theme());

	$theme_css = implode('', file( get_theme_root() . "/" . $current_theme_data["Stylesheet"] . "/style.css"));

	preg_match_all('/:[^:;}]*#([abcdef1234567890]+)/i', $theme_css, $matches);

	return array_unique($matches[1]);
}

// Formats a php associative array into a javascript object
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

// Returns true if $path is absolute
function ap_isAbsoluteURL($path) {
	if (strpos($path, "http://") === 0) {
		return true;
	}
	if (strpos($path, "https://") === 0) {
		return true;
	}
	if (strpos($path, "ftp://") === 0) {
		return true;
	}
	return false;
}

// Encodes the given string
function ap_encodeSource($string) {
	$source = utf8_decode($string);
	$ntexto = "";
	$codekey = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-";
	for ($i = 0; $i < strlen($string); $i++) {
		$ntexto .= substr("0000".base_convert(ord($string{$i}), 10, 2), -8);
	}
	$ntexto .= substr("00000", 0, 6-strlen($ntexto)%6);
	$string = "";
	for ($i = 0; $i < strlen($ntexto)-1; $i = $i + 6) {
		$string .= $codekey{intval(substr($ntexto, $i, 6), 2)};
	}
	
	return $string;
}

?>