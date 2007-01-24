<?php
/*
Plugin Name: Audio player
Plugin URI: http://www.1pixelout.net/code/audio-player-wordpress-plugin/
Description: Lets you insert audio mp3 files into your posts. Comes with it's own flash music player.
Version: 1.0
Author: Martin Laine
Author URI: http://www.1pixelout.net

Change log:

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

    Copyright 2005  Martin Laine  (email : martin@1pixelout.net)

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

add_option('audio_player_web_path', '/audio', "Web path to audio files", true);

if(get_option('audio_player_iconcolor') != '' && get_option('audio_player_lefticoncolor') == '') {
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
	add_option('audio_player_bgcolor', '0xf8f8f8', "Background color", true);
	add_option('audio_player_textcolor', '0x666666', "Text color", true);
	add_option('audio_player_leftbgcolor', '0xeeeeee', "Left background color", true);
	add_option('audio_player_lefticoncolor', '0x666666', "Left icon color", true);
	add_option('audio_player_rightbgcolor', '0xcccccc', "Right background color", true);
	add_option('audio_player_rightbghovercolor', '0x999999', "Right background hover color", true);
	add_option('audio_player_righticoncolor', '0x666666', "Right icon color", true);
	add_option('audio_player_righticonhovercolor', '0xffffff', "Right icon hover color", true);
	add_option('audio_player_slidercolor', '0x666666', "Progress slider color", true);
	add_option('audio_player_trackcolor', '0xFFFFFF', "Progress track color", true);
	add_option('audio_player_loadercolor', '0x9FFFB8', "Loader bar color", true);
	add_option('audio_player_bordercolor', '0x666666', "Border color", true);
}

$ap_playerURL = get_settings('siteurl') . '/wp-content/plugins/audio-player/player.swf';
$ap_rootURL = get_settings('siteurl') . get_option("audio_player_web_path");

$ap_options = array();
$ap_options["bg"] = get_option("audio_player_bgcolor");
$ap_options["leftbg"] = get_option("audio_player_leftbgcolor");
$ap_options["lefticon"] = get_option("audio_player_lefticoncolor");
$ap_options["rightbg"] = get_option("audio_player_rightbgcolor");
$ap_options["rightbghover"] = get_option("audio_player_rightbghovercolor");
$ap_options["righticon"] = get_option("audio_player_righticoncolor");
$ap_options["righticonhover"] = get_option("audio_player_righticonhovercolor");
$ap_options["text"] = get_option("audio_player_textcolor");
$ap_options["slider"] = get_option("audio_player_slidercolor");
$ap_options["track"] = get_option("audio_player_trackcolor");
$ap_options["border"] = get_option("audio_player_bordercolor");
$ap_options["loader"] = get_option("audio_player_loadercolor");

function ap_insert_player_widgets($content = '') {
	$preg = "/\[audio:([^]]+)]/";

	return preg_replace_callback( $preg, "ap_replace", $content ); 
}

function ap_replace($matches) {
	global $ap_rootURL, $ap_playerURL, $ap_options;
	$data = preg_split("/[\|\¦]/", $matches[1]);
	$file = $data[0];
	$fileparts = explode("/", $file);
	$fileName = $fileparts[count($fileparts)-1];
	if(strpos($file, "http://") !== 0) $file = $ap_rootURL . "/" . $file;

	$options = $ap_options;
	$i = 1;
	for($i=1;$i<count($data);$i++) {
		$pair = explode("=", $data[$i]);
		$options[$pair[0]] = $pair[1]; 
	}
	$url = $ap_playerURL . '?soundFile=' . rawurlencode($file);
	foreach($options as $key => $value) $url .= '&amp;' . $key . '=' . rawurlencode($value);
	
	if(is_feed()) return '<a href="' . $file . '">Download ' . $fileName . '</a>';
	else return '<object type="application/x-shockwave-flash" data="' . $url . '" width="290" height="24"><param name="movie" value="' . $url . '" /><param name="quality" value="high" /><param name="menu" value="false" /><param name="wmode" value="transparent" /><a href="' . $file . '">Download ' . $fileName . '</a></object>'; 
}

add_filter('the_content', 'ap_insert_player_widgets');

function ap_post_add_options() {
	add_options_page('Audio player options', 'Audio player', 8, basename(__FILE__), 'ap_options_subpanel');
}

function ap_options_subpanel() {
	global $wpdb;
	
	if( $_POST['ap_audiowebpath'] ) {
		// set audio web path
		if( substr( $_POST['ap_audiowebpath'], -1 ) == "/" ) $_POST['ap_audiowebpath'] = substr( $_POST['ap_audiowebpath'], 0, strlen( $_POST['ap_audiowebpath'] ) - 1 );
		update_option('audio_player_web_path', $_POST['ap_audiowebpath']);

		update_option('audio_player_bgcolor', str_replace("#", "0x", $_POST['ap_bgcolor']));
		update_option('audio_player_leftbgcolor', str_replace("#", "0x", $_POST['ap_leftbgcolor']));
		update_option('audio_player_rightbgcolor', str_replace("#", "0x", $_POST['ap_rightbgcolor']));
		update_option('audio_player_rightbghovercolor', str_replace("#", "0x", $_POST['ap_rightbghovercolor']));
		update_option('audio_player_lefticoncolor', str_replace("#", "0x", $_POST['ap_lefticoncolor']));
		update_option('audio_player_righticoncolor', str_replace("#", "0x", $_POST['ap_righticoncolor']));
		update_option('audio_player_righticonhovercolor', str_replace("#", "0x", $_POST['ap_righticonhovercolor']));
		update_option('audio_player_textcolor', str_replace("#", "0x", $_POST['ap_textcolor']));
		update_option('audio_player_slidercolor', str_replace("#", "0x", $_POST['ap_slidercolor']));
		update_option('audio_player_trackcolor', str_replace("#", "0x", $_POST['ap_trackcolor']));
		update_option('audio_player_loadercolor', str_replace("#", "0x", $_POST['ap_loadercolor']));
		update_option('audio_player_bordercolor', str_replace("#", "0x", $_POST['ap_bordercolor']));
		
		echo '<div class="updated"><strong><p>Options updated.</p></strong></div>';
	}

	$web_path = str_replace( "0x", "#", get_option('audio_player_web_path'));
	$ap_bgcolor = str_replace( "0x", "#", get_option('audio_player_bgcolor'));
	$ap_leftbgcolor = str_replace( "0x", "#", get_option('audio_player_leftbgcolor'));
	$ap_rightbgcolor = str_replace( "0x", "#", get_option('audio_player_rightbgcolor'));
	$ap_rightbghovercolor = str_replace( "0x", "#", get_option('audio_player_rightbghovercolor'));
	$ap_lefticoncolor = str_replace( "0x", "#", get_option('audio_player_lefticoncolor'));
	$ap_righticoncolor = str_replace( "0x", "#", get_option('audio_player_righticoncolor'));
	$ap_righticonhovercolor = str_replace( "0x", "#", get_option('audio_player_righticonhovercolor'));
	$ap_textcolor = str_replace( "0x", "#", get_option('audio_player_textcolor'));
	$ap_slidercolor = str_replace( "0x", "#", get_option('audio_player_slidercolor'));
	$ap_trackcolor = str_replace( "0x", "#", get_option('audio_player_trackcolor'));
	$ap_loadercolor = str_replace( "0x", "#", get_option('audio_player_loadercolor'));
	$ap_bordercolor = str_replace( "0x", "#", get_option('audio_player_bordercolor'));
	?>

<div class="wrap">
	<h2>Audio player options</h2>
	<p>Settings for the Audio Player plugin.</p>
	
	<form method="post">
	<fieldset class="options">
		<legend>Paths</legend>
		<table class="editform" cellpadding="5" cellspacing="2" width="100%">
			<tr>
				<th width="33%" valign="top"><label for="ap_audiowebpath">URI of audio files directory:</label></th>
				<td>
					<input type="text" id="ap_audiowebpath" name="ap_audiowebpath" size="40" value="<?php echo( $web_path ); ?>" /><br />
					Recommended: <code>/audio</code>
				</td>
			</tr>
		</table>
	</fieldset>
	<fieldset class="options">
		<legend>Colours</legend>
		<table class="editform" cellpadding="5" cellspacing="2" width="100%">
			<tr>
				<th>Colour map:</th>
				<td><img src="<?php echo( get_settings( "siteurl" ) ); ?>/wp-content/plugins/audio-player/map.gif" width="390" height="124" /></td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_bgcolor">Background:</label></th>
				<td>
					<input type="text" id="ap_bgcolor" name="ap_bgcolor" size="40" value="<?php echo( $ap_bgcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_leftbgcolor">Left background:</label></th>
				<td>
					<input type="text" id="ap_leftbgcolor" name="ap_leftbgcolor" size="40" value="<?php echo( $ap_leftbgcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_rightbgcolor">Right background:</label></th>
				<td>
					<input type="text" id="ap_rightbgcolor" name="ap_rightbgcolor" size="40" value="<?php echo( $ap_rightbgcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_rightbghovercolor">Right background (hover):</label></th>
				<td>
					<input type="text" id="ap_rightbghovercolor" name="ap_rightbghovercolor" size="40" value="<?php echo( $ap_rightbghovercolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_lefticoncolor">Left icon:</label></th>
				<td>
					<input type="text" id="ap_lefticoncolor" name="ap_lefticoncolor" size="40" value="<?php echo( $ap_lefticoncolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_righticoncolor">Right icon:</label></th>
				<td>
					<input type="text" id="ap_righticoncolor" name="ap_righticoncolor" size="40" value="<?php echo( $ap_righticoncolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_righticonhovercolor">Right icon (hover):</label></th>
				<td>
					<input type="text" id="ap_righticonhovercolor" name="ap_righticonhovercolor" size="40" value="<?php echo( $ap_righticonhovercolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_iconcolor">Text:</label></th>
				<td>
					<input type="text" id="ap_textcolor" name="ap_textcolor" size="40" value="<?php echo( $ap_textcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_slidercolor">Slider:</label></th>
				<td>
					<input type="text" id="ap_slidercolor" name="ap_slidercolor" size="40" value="<?php echo( $ap_slidercolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_trackcolor">Progress bar track:</label></th>
				<td>
					<input type="text" id="ap_trackcolor" name="ap_trackcolor" size="40" value="<?php echo( $ap_trackcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_loadercolor">Loader bar:</label></th>
				<td>
					<input type="text" id="ap_loadercolor" name="ap_loadercolor" size="40" value="<?php echo( $ap_loadercolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_bordercolor">Progress bar border:</label></th>
				<td>
					<input type="text" id="ap_bordercolor" name="ap_bordercolor" size="40" value="<?php echo( $ap_bordercolor ); ?>" /><br />
				</td>
			</tr>
		</table>
	</fieldset>
	<p class="submit">
		<input name="Submit" value="Update Options &raquo;" type="submit">
	</p>
	</form>
</div>

<?php

}		

add_action('admin_menu', 'ap_post_add_options');

?>