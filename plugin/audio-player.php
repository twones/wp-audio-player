<?php
/*
Plugin Name: Audio player
Plugin URI: http://www.1pixelout.net/code/audio-player-wordpress-plugin/
Description: Highly configurable single track mp3 player.
Version: 2.0b1
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

if (!class_exists('AudioPlayer')) {
    class AudioPlayer {
		// Name for serialized options saved in database
		var $optionsName = "AudioPlayer_options";

		var $version = "2.0b1";
		
		var $docURL = "http://www.1pixelout.net/code/audio-player-wordpress-plugin/";
		
		// Internationalisation
		var $textDomain = "audio-player";
		var $languageFileLoaded = false;

		// Various path variables
		var $pluginRoot = "";
		var $playerURL = "";
		var $audioRoot = "";
		var $audioAbsPath = "";
		var $isCustomAudioRoot = false;
		
		// Colour scheme keys
		var $colorKeys = array(
			"bg",
			"leftbg",
			"lefticon",
			"voltrack",
			"volslider",
			"rightbg",
			"rightbghover",
			"righticon",
			"righticonhover",
			"text",
			"track",
			"border",
			"loader",
			"tracker",
			"skip"
		);
		
		// Default colour scheme
		var $defaultColorScheme = array(
			"bg" => "E5E5E5",
			"text" => "333333",
			"leftbg" => "CCCCCC",
			"lefticon" => "333333",
			"volslider" => "666666",
			"voltrack" => "FFFFFF",
			"rightbg" => "B4B4B4",
			"rightbghover" => "999999",
			"righticon" => "333333",
			"righticonhover" => "FFFFFF",
			"track" => "FFFFFF",
			"loader" => "009900",
			"border" => "CCCCCC",
			"tracker" => "DDDDDD",
			"skip" => "666666",
			"pagebg" => "FFFFFF",
			"transparentpagebg" => true
		);
		
		// Declare instances global variable
		var $instances = array();
		
		// Initialise playerID (each instance gets unique ID)
		var $playerID = 0;
		
		// Flag for dealing with excerpts
		var $inExcerpt = false;
		
		/**
		 * Constructor
		 */
		function AudioPlayer() {
			$this->pluginRoot = get_settings("siteurl") . "/wp-content/plugins/audio-player/";
			$this->playerURL = $this->pluginRoot . "assets/player.swf";

			// Load options
			$this->options = $this->getOptions();
			
			// Set audio root from options
			$this->setAudioRoot();
			
			// Add action and filter hooks to WordPress

			add_action("init", array(&$this, "optionsPanelAction"));

			add_action("admin_menu", array(&$this, "addAdminPages"));
			add_action("wp_head", array(&$this, "wpHeadIntercept"));
			add_action("admin_head", array(&$this, "wpAdminHeadIntercept"));

			add_filter("the_content", array(&$this, "processContent"));
			if (in_array("comments", $this->options["behaviour"])) {
				add_filter("comment_text", array(&$this, "processContent"));
			}
			add_filter("get_the_excerpt", array(&$this, "inExcerpt"), 1);
			add_filter("get_the_excerpt", array(&$this, "outOfExcerpt"), 12);
			add_filter("the_excerpt", array(&$this, "processContent"));
			add_filter("the_excerpt_rss", array(&$this, "processContent"));
		}
		
		/**
		 * Adds Audio Player options tab to admin menu
		 */
		function addAdminPages() {
			add_options_page("Audio player options", "Audio Player", 8, "audio-player-options", array(&$this, "outputOptionsSubpanel"));
		}

		/**
		 * Loads language files according to locale (only does this once per request)
		 */
		function loadLanguageFile() {
			if(!$this->languageFileLoaded) {
				load_plugin_textdomain($this->textDomain, "wp-content/plugins/audio-player/languages");
				$this->languageFileLoaded = true;
			}
		}
		
		/**
		 * Retrieves options from DB. Also sets defaults if options not set
		 * @return array of options
		 */
		function getOptions() {
			// Set default options array to make sure all the necessary options
			// are available when called
			$options = array(
				"audioFolder" => "/audio",
				"playerWidth" => "290",
				"enableAnimation" => true,
				"showRemaining" => false,
				"encodeSource" => true,
				"embedMethod" => "ufo",
				"includeEmbedFile" => true,
				"behaviour" => array("default"),
				"rssAlternate" => "nothing",
				"rssCustomAlternate" => "[Audio clip: view full post to listen]",
				"excerptAlternate" => "[Audio clip: view full post to listen]",
				"introClip" => "",
				"outroClip" => "",
				"initialVolume" => "60",
				"bufferTime" => "5",
				"noInfo" => false,

				"colorScheme" => $this->defaultColorScheme
			);

			$savedOptions = get_option($this->optionsName);
			if (!empty($savedOptions)) {
				foreach ($savedOptions as $key => $option) {
					$options[$key] = $option;
				}
			}
			
			// 1.x version upgrade
			if (!array_key_exists("version", $options)) {
				if (get_option("audio_player_web_path")) $options["audioFolder"] = get_option("audio_player_web_path");
				if (get_option("audio_player_behaviour")) $options["behaviour"] = explode(",", get_option("audio_player_behaviour"));
				if (get_option("audio_player_rssalternate")) $options["rssAlternate"] = get_option("audio_player_rssalternate");
				if (get_option("audio_player_rsscustomalternate")) $options["rssCustomAlternate"] = get_option("audio_player_rsscustomalternate");
				if (get_option("audio_player_prefixaudio")) $options["introClip"] = get_option("audio_player_prefixaudio");
				if (get_option("audio_player_postfixaudio")) $options["outroClip"] = get_option("audio_player_postfixaudio");

				if (get_option("audio_player_transparentpagebgcolor")) {
					$options["colorScheme"]["bg"] = str_replace("0x", "", get_option("audio_player_bgcolor"));
					$options["colorScheme"]["text"] = str_replace("0x", "", get_option("audio_player_textcolor"));
					$options["colorScheme"]["skip"] = str_replace("0x", "", get_option("audio_player_textcolor"));
					$options["colorScheme"]["leftbg"] = str_replace("0x", "", get_option("audio_player_leftbgcolor"));
					$options["colorScheme"]["lefticon"] = str_replace("0x", "", get_option("audio_player_lefticoncolor"));
					$options["colorScheme"]["volslider"] = str_replace("0x", "", get_option("audio_player_lefticoncolor"));
					$options["colorScheme"]["rightbg"] = str_replace("0x", "", get_option("audio_player_rightbgcolor"));
					$options["colorScheme"]["rightbghover"] = str_replace("0x", "", get_option("audio_player_rightbghovercolor"));
					$options["colorScheme"]["righticon"] = str_replace("0x", "", get_option("audio_player_righticoncolor"));
					$options["colorScheme"]["righticonhover"] = str_replace("0x", "", get_option("audio_player_righticonhovercolor"));
					$options["colorScheme"]["track"] = str_replace("0x", "", get_option("audio_player_trackcolor"));
					$options["colorScheme"]["loader"] = str_replace("0x", "", get_option("audio_player_loadercolor"));
					$options["colorScheme"]["border"] = str_replace("0x", "", get_option("audio_player_bordercolor"));
					$options["colorScheme"]["transparentpagebg"] = get_option("audio_player_transparentpagebgcolor");
					$options["colorScheme"]["pagebg"] = str_replace("#", "", get_option("audio_player_pagebgcolor"));
				}
				
				// TODO: maybe delete old options but not while in beta so easy to revert to old version
			} else if (version_compare($options["version"], $this->version) == -1) {
				// TODO: Upgrade code
			}
			
			// Record current version in DB
			$options["version"] = $this->version;

			// Update DB if necessary
			update_option($this->optionsName, $options);
			
			return $options;
		}
		
		/**
		 * Writes options to DB
		 */
		function saveOptions() {
			update_option($this->optionsName, $this->options);
		}
		
		/**
		 * Sets the real audio root from the audio folder option
		 */
		function setAudioRoot() {
			$this->audioRoot = $this->options["audioFolder"];

			$this->audioAbsPath = "";
			$this->isCustomAudioRoot = true;
			
			if (!$this->isAbsoluteURL($this->audioRoot)) {
				$sysDelimiter = '/';
				if (strpos(ABSPATH, '\\') !== false) $sysDelimiter = '\\';
				$this->audioAbsPath = preg_replace('/[\\\\\/]+/', $sysDelimiter, ABSPATH . $this->audioRoot);
		
				$this->isCustomAudioRoot = false;
				$this->audioRoot = get_settings('siteurl') . $this->audioRoot;
			}
		}
		
		/**
		 * Builds and returns array of options to pass to Flash player
		 * @return array
		 */
		function getPlayerOptions() {
			$playerOptions = array();

			$playerOptions["width"] = $this->options["playerWidth"];
			
			$playerOptions["animation"] = $this->options["enableAnimation"];
			$playerOptions["encode"] = $this->options["encodeSource"];
			$playerOptions["initialvolume"] = $this->options["initialVolume"];
			$playerOptions["remaining"] = $this->options["showRemaining"];
			$playerOptions["noinfo"] = $this->options["noInfo"];
			$playerOptions["buffer"] = $this->options["bufferTime"];
			
			return array_merge($playerOptions, $this->options["colorScheme"]);
		}

		// ------------------------------------------------------------------------------
		// Excerpt helper functions
		// Sets a flag so we know we are in an automatically created excerpt
		// ------------------------------------------------------------------------------
		
		/**
		 * Sets a flag when getting an excerpt
		 * @return excerpt text
		 * @param $text String[optional] unchanged excerpt text
		 */
		function inExcerpt($text = '') {
			// Only set the flag when the excerpt is empty and WP creates one automatically)
			if('' == $text) $this->inExcerpt = true;
		
			return $text;
		}
		
		/**
		 * Resets a flag after getting an excerpt
		 * @return excerpt text
		 * @param $text String[optional] unchanged excerpt text
		 */
		function outOfExcerpt($text = '') {
			$this->inExcerpt = false;
		
			return $text;
		}

		/**
		 * Filter function (inserts player instances according to behaviour option)
		 * @return the parsed and formatted content
		 * @param $content String[optional] the content to parse
		 */
		function processContent($content = '') {
			global $comment;
			
			$this->loadLanguageFile();
			
			// Reset instance array (this is so we don't insert duplicate players)
			$this->instances = array();
		
			// Replace mp3 links (don't do this in feeds and excerpts)
			if ( !is_feed() && !$this->inExcerpt && in_array( "links", $this->options["behaviour"] ) ) {
				$pattern = "/<a ([^=]+=['\"][^\"']+['\"] )*href=['\"](([^\"']+\.mp3))['\"]( [^=]+=['\"][^\"']+['\"])*>[^<]+<\/a>/i";
				$content = preg_replace_callback( $pattern, array(&$this, "insertPlayer"), $content );
			}
			
			// Replace [audio syntax]
			if( in_array( "default", $this->options["behaviour"] ) ) {
				$pattern = "/(<p>)?\[audio:(([^]]+))\](<\/p>)?/i";
				$content = preg_replace_callback( $pattern, array(&$this, "insertPlayer"), $content );
			}
		
			// Enclosure integration (don't do this for feeds, excerpts and comments)
			if( !is_feed() && !$this->inExcerpt && !$comment && in_array( "enclosure", $this->options["behaviour"] ) ) {
				$enclosure = get_enclosed($post_id);
		
				// Insert intro and outro clips if set
				$introClip = $this->options["introClip"];
				if( $introClip != "" ) $introClip .= ",";
				$outroClip = $this->options["outroClip"];
				if( $outroClip != "" ) $outroClip = "," . $outroClip;
		
				if( count($enclosure) > 0 ) {
					for($i = 0;$i < count($enclosure);$i++) {
						// Make sure the enclosure is an mp3 file and it hasn't been inserted into the post yet
						if( preg_match( "/.*\.mp3$/", $enclosure[$i] ) == 1 && !in_array( $enclosure[$i], $this->instances ) ) {
							$content .= "\n\n" . $this->getPlayer( $introClip . $enclosure[$i] . $outroClip );
						}
					}
				}
			}
			
			return $content;
		}
		
		/**
		 * Callback function for preg_replace_callback
		 * @return string to replace matches with
		 * @param $matches Array
		 */
		function insertPlayer($matches) {
			// Split options
			$data = preg_split("/[\|]/", $matches[3]);
			$files = array();
			
			// Alternate content for excerpts (don't do this for feeds)
			if($this->inExcerpt && !is_feed()) {
				return $this->options["excerptAlternate"];
			}
			
			if (!is_feed()) {
				// Insert intro clip if set
				if ( $this->options["introClip"] != "" ) {
					$afile = $this->options["introClip"];
					if (!$this->isAbsoluteURL($afile)) {
						$afile = $this->audioRoot . "/" . $afile;
					}
					array_push( $files, $afile );
				}
			}
		
			// Create an array of files to load in player
			foreach ( explode( ",", $data[0] ) as $afile ) {
				// Get absolute URLs for relative ones
				if (!$this->isAbsoluteURL($afile)) {
					$afile = $this->audioRoot . "/" . $afile;
				}
				
				array_push( $files, $afile );
		
				// Add source file to instances already added to the post
				array_push( $this->instances, $afile );
			}
		
			if (!is_feed()) {
				// Insert outro clip if set
				if ( $this->options["outroClip"] != "" ) {
					$afile = $this->options["outroClip"];
					if (!$this->isAbsoluteURL($afile)) {
						$afile = $this->audioRoot . "/" . $afile;
					}
					array_push( $files, $afile );
				}
			}
		
			// Build runtime options array
			$playerOptions = array();
			for ($i = 1; $i < count($data); $i++) {
				$pair = explode("=", $data[$i]);
				$playerOptions[$pair[0]] = $pair[1]; 
			}
			
			// Return player instance code
			return $this->getPlayer( implode( ",", $files ), $playerOptions );
		}
		
		/**
		 * Generic player instance function (returns player widget code to insert)
		 * @return String the html code to insert
		 * @param $source String list of mp3 file urls to load in player
		 * @param $options Object[optional] options to load in player
		 */
		function getPlayer($source, $playerOptions = array()) {
			// Get next player ID
			$this->playerID++;
			
			// Add source to options and encode if necessary
			$playerOptions["soundFile"] = $source;
			if ($this->options["encodeSource"]) {
				$playerOptions["soundFile"] = $this->encodeSource($source);
			}
			
			if (is_feed()) {
				// We are in a feed so use RSS alternate content option
				switch ( $this->options["rssAlternate"] ) {
		
				case "download":
					// Get filenames from path and output a link for each file in the sequence
					$files = explode(",", $source);
					$links = "";
					for ($i = 0; $i < count($files); $i++) {
						$fileparts = explode("/", $files[$i]);
						$fileName = $fileparts[count($fileparts)-1];
						$links .= '<a href="' . $files[$i] . '">' . __('Download audio file', $this->textDomain) . ' (' . $fileName . ')</a><br />';
					}
					return $links;
					break;
		
				case "nothing":
					return "";
					break;
		
				case "custom":
					return $this->options["rssCustomAlternate"];
					break;
		
				}
			} else {
				// Not in a feed so return player widget
				$playerElementID = "audioplayer_" . $this->playerID;
				$playerCode = '<p class="audioplayer-container" id="' . $playerElementID . '">' . sprintf(__('Audio clip: <a href="%s" title="Download Adobe Flash Player">Adobe Flash Player</a> (version 6 or above) is required to play this audio clip. You also need to have JavaScript enabled in your browser.', $this->textDomain), 'http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash&amp;promoid=BIOW') . '</p>';
				$playerCode .= '<script type="text/javascript"><!--';
				$playerCode .= "\n";
				$playerCode .= 'AudioPlayer.embed("' . $playerElementID . '", ' . $this->php2js($playerOptions) . ');';
				$playerCode .= "\n";
				$playerCode .= '--></script>';
				return $playerCode;
			}
		}

		/**
		 * Outputs the options sub panel
		 */
		function outputOptionsSubpanel() {
			$this->loadLanguageFile();
			
			// Include options panel
			include("php/options-panel.php");
		}
		
		/**
		 * Handles submitted options (validates and saves modified options)
		 */
		function optionsPanelAction() {
			if( $_POST['AudioPlayerReset'] ) {
				// Reset colour scheme back to default values
				$this->options["colorScheme"] = $this->defaultColorScheme;
				$this->saveOptions();

				$goback = add_query_arg("updated", "true", wp_get_referer());
				wp_redirect($goback);
				exit();
			} else 	if( $_POST['AudioPlayerSubmit'] ) {
				check_admin_referer('audio-player-action');
			
				// Set audio web path
				$_POST['ap_audiowebpath'] = trim($_POST['ap_audiowebpath']);
				if ($_POST["ap_audiowebpath_iscustom"] != "true") {
					if ( substr( $_POST['ap_audiowebpath'], -1, 1 ) == "/" ) {
						$_POST['ap_audiowebpath'] = substr( $_POST['ap_audiowebpath'], 0, strlen( $_POST['ap_audiowebpath'] ) - 1 );
					}
					if ( substr( $_POST['ap_audiowebpath'], 0, 1 ) != "/" ) {
						$_POST['ap_audiowebpath'] = "/" . $_POST['ap_audiowebpath'];
					}
					$this->options["audioFolder"] = $_POST['ap_audiowebpath'];
				} else if ($this->isAbsoluteURL($_POST['ap_audiowebpath'])) {
					$this->options["audioFolder"] = $_POST['ap_audiowebpath'];
				}
		
				// Update behaviour and rss alternate content options
				$this->options["embedMethod"] = $_POST['ap_embedmethod'];
		
				$this->options["includeEmbedFile"] = isset( $_POST["ap_includeembedfile"] );
				$this->options["encodeSource"] = isset( $_POST["ap_encodeSource"] );
				$this->options["enableAnimation"] = !isset( $_POST["ap_disableAnimation"] );
				$this->options["showRemaining"] = isset( $_POST["ap_showRemaining"] );
				$this->options["noInfo"] = isset( $_POST["ap_disableTrackInformation"] );
				
				$this->options["behaviour"] = $_POST['ap_behaviour'];
		
				$this->options["excerptAlternate"] = trim(stripslashes($_POST['ap_excerptalternate']));
				$this->options["rssAlternate"] = $_POST['ap_rssalternate'];
				$this->options["rssCustomAlternate"] = trim(stripslashes($_POST['ap_rsscustomalternate']));
				$this->options["introClip"] = trim($_POST['ap_audioprefixwebpath']);
				$this->options["outroClip"] = trim($_POST['ap_audiopostfixwebpath']);
		
				$_POST['ap_player_width'] = trim($_POST['ap_player_width']);
				if ( preg_match("/^[0-9]+%?$/", $_POST['ap_player_width']) == 1 ) {
					$this->options["playerWidth"] = $_POST['ap_player_width'];
				}
		
				$_POST['ap_initial_volume'] = trim($_POST['ap_initial_volume']);
				if ( preg_match("/^[0-9]+$/", $_POST['ap_initial_volume']) == 1 ) {
					$_POST['ap_initial_volume'] = intval($_POST['ap_initial_volume']);
					if ($_POST['ap_initial_volume'] <= 100) {
						$this->options["initialVolume"] = $_POST['ap_initial_volume'];
					}
				}
				
				$_POST['ap_buffertime'] = trim($_POST['ap_buffertime']);
				if ( preg_match("/^[0-9]+$/", $_POST['ap_buffertime']) == 1 ) {
					$_POST['ap_buffertime'] = intval($_POST['ap_buffertime']);
					if ($_POST['ap_buffertime'] > 0) {
						$this->options["bufferTime"] = $_POST['ap_buffertime'];
					}
				}

				// Update colour options
				foreach ( $this->colorKeys as $colorKey ) {
					// Ignore missing or invalid color values
					if ( isset( $_POST["ap_" . $colorKey . "color"] ) && preg_match( "/^#[0-9A-Fa-f]{6}$/", $_POST["ap_" . $colorKey . "color"] ) == 1 ) {
						$this->options["colorScheme"][$colorKey] = str_replace( "#", "", $_POST["ap_" . $colorKey . "color"] );
					}
				}
		
				if ( isset( $_POST["ap_pagebgcolor"] ) && preg_match( "/^#[0-9A-Fa-f]{6}$/", $_POST["ap_pagebgcolor"] ) == 1 ) {
					$this->options["colorScheme"]["pagebg"] = str_replace( "#", "", $_POST['ap_pagebgcolor']);
				}
				$this->options["colorScheme"]["transparentpagebg"] = isset( $_POST["ap_transparentpagebg"] );
				
				$this->saveOptions();

				$goback = add_query_arg("updated", "true", wp_get_referer());
				wp_redirect($goback);
				exit();
			}
		}

		/**
		 * Output necessary stuff to WP head section
		 */
		function wpHeadIntercept() {
			if ($this->options["includeEmbedFile"]) {
				echo '<script type="text/javascript" src="' . $this->pluginRoot . 'assets/lib/' . $this->options["embedMethod"] . '.js"></script>';
				echo "\n";
			}
			
			echo '<script type="text/javascript" src="' . $this->pluginRoot . 'assets/audio-player-' . $this->options["embedMethod"] . '.js"></script>';
			echo "\n";
			echo '<script type="text/javascript">';
			echo "\n";
			echo 'AudioPlayer.setup("' . $this->playerURL . '", ' . $this->php2js($this->getPlayerOptions()) . ');';
			echo "\n";
			echo '</script>';
			echo "\n";
		}

		/**
		 * Output necessary stuff to WP admin head section
		 */
		function wpAdminHeadIntercept() {
			// Do nothing if not on Audio Player options page
			if (!($_GET["page"] == "audio-player-options")) {
				return;
			}
			
			echo '<link href="' . $this->pluginRoot . 'assets/audio-player-admin.css" rel="stylesheet" type="text/css" />';
			echo "\n";
			echo '<link href="' . $this->pluginRoot . 'assets/colorpicker/moocolorpicker.css" rel="stylesheet" type="text/css" />';
			echo "\n";
			echo '<script type="text/javascript" src="' . $this->pluginRoot . 'assets/lib/mootools.js"></script>';
			echo "\n";
			echo '<script type="text/javascript" src="' . $this->pluginRoot . 'assets/colorpicker/moocolorpicker.js"></script>';
			echo "\n";
			echo '<script type="text/javascript" src="' . $this->pluginRoot . 'assets/audio-player-admin.js"></script>';
			echo "\n";
			echo '<script type="text/javascript" src="' . $this->pluginRoot . 'assets/lib/' . $this->options["embedMethod"] . '.js"></script>';
			echo "\n";
			echo '<script type="text/javascript" src="' . $this->pluginRoot . 'assets/audio-player-' . $this->options["embedMethod"] . '.js"></script>';
			echo "\n";
			echo '<script type="text/javascript">';
			echo "\n";
			echo 'var ap_ajaxRootURL = "' . $this->pluginRoot . 'php/";';
			echo "\n";
			echo 'AudioPlayer.setup("' . $this->playerURL . '", ' . $this->php2js($this->getPlayerOptions()) . ');';
			echo "\n";
			echo '</script>';
			echo "\n";
		}
		
		/**
		 * Verifies that the given audio folder exists on the server (Ajax call)
		 */
		function checkAudioFolder() {
			$audioRoot = $_POST["audioFolder"];

			$sysDelimiter = '/';
			if (strpos(ABSPATH, '\\') !== false) $sysDelimiter = '\\';
			$audioAbsPath = preg_replace('/[\\\\\/]+/', $sysDelimiter, ABSPATH . $audioRoot);

			if (!file_exists($audioAbsPath)) {
				echo $audioAbsPath;
			} else {
				echo "ok";
			}
		}

		/**
		 * Parses theme style sheet
		 * @return array of colors from current theme
		 */
		function getThemeColors() {
			$current_theme_data = get_theme(get_current_theme());
		
			$theme_css = implode('', file( get_theme_root() . "/" . $current_theme_data["Stylesheet"] . "/style.css"));
		
			preg_match_all('/:[^:;}]*#([abcdef1234567890]+)/i', $theme_css, $matches);
		
			return array_unique($matches[1]);
		}

		/**
		 * Formats a php associative array into a javascript object
		 * @return formatted string
		 * @param $object Object containing the options to format
		 */
		function php2js($object) {
			$js_options = '{';
			$separator = "";
			$real_separator = ",";
			foreach($object as $key=>$value) {
				// Format booleans
				if (is_bool($value)) $value = $value?"yes":"no";
				$js_options .= $separator . $key . ':"' . rawurlencode($value) .'"';
				$separator = $real_separator;
			}
			$js_options .= "}";
			
			return $js_options;
		}

		/**
		 * @return true if $path is absolute
		 * @param $path Object
		 */
		function isAbsoluteURL($path) {
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
		
		/**
		 * Encodes the given string
		 * @return the encoded string
		 * @param $string String the string to encode
		 */
		function encodeSource($string) {
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
	}
}

// Instantiate the class
if (class_exists('AudioPlayer')) {
	$AudioPlayer = new AudioPlayer();
}

/**
 * Experimental "tag" function for inserting players anywhere (yuk)
 * @return 
 * @param $source Object
 */
function insert_audio_player($source) {
	global $AudioPlayer;
	echo $AudioPlayer->processContent($source);
}

?>