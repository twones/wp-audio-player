<?php
/*
Plugin Name: Audio player
Plugin URI: http://www.1pixelout.net/code/audio-player-wordpress-plugin/
Description: Lets you insert audio mp3 files into your posts. Comes with it's own flash music player.
Version: 0.7.1 beta
Author: Martin Laine
Author URI: http://www.1pixelout.net

Change log:

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

		* Bug fix: the paths to the flash player and the mp3 files didn’t respect the web path option. This caused problems for blogs that don’t live in the root of the domain (eg www.mydomain.com/blog/)

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
add_option('audio_player_bgcolor', '#eaeaea', "Background color", true);
add_option('audio_player_iconcolor', '#000000', "Icon color", true);
add_option('audio_player_textcolor', '#666666', "Text color", true);
add_option('audio_player_barcolor', '#666666', "Bar color", true);
add_option('audio_player_pathcolor', '#FFFFFF', "Path color", true);
add_option('audio_player_buttoncolor', '#D2D2D2', "Button color", true);
add_option('audio_player_buttonhovercolor', '#0099cc', "Button hover color", true);

function ap_insert_player_widgets($content = '') {
	$siteURL = get_settings('siteurl');
	$playerURL = $siteURL . '/wp-content/plugins/audio-player/player.swf';
	$audioDir = $siteURL . get_option("audio_player_web_path");
	$colors = "bgcolor=" . get_option("audio_player_bgcolor");
	$colors = $colors . "&amp;iconcolor=" . get_option("audio_player_iconcolor");
	$colors = $colors . "&amp;textcolor=" . get_option("audio_player_textcolor");
	$colors = $colors . "&amp;barcolor=" . get_option("audio_player_barcolor");
	$colors = $colors . "&amp;pathcolor=" . get_option("audio_player_pathcolor");
	$colors = $colors . "&amp;buttoncolor=" . get_option("audio_player_buttoncolor");
	$colors = $colors . "&amp;buttonhovercolor=" . get_option("audio_player_buttonhovercolor");
	
	$colors = str_replace( "#", "0x", $colors );

	$content = ereg_replace( '\[audio:http://([^]]+)\]', '<object type="application/x-shockwave-flash" data="' . $playerURL . '?' . $colors . '&amp;soundFile=http://\1" width="200" height="30"><param name="movie" value="' . $playerURL . '?' . $colors . '&amp;soundFile=http://\1" /><param name="quality" value="high" /><param name="menu" value="false" /><param name="wmode" value="transparent" /><a href="http://\1">Download \1</a></object>', $content );

	return ereg_replace( '\[audio:([^]]+)\]', '<object type="application/x-shockwave-flash" data="' . $playerURL . '?' . $colors . '&amp;soundFile=' . $audioDir . '/\1" width="200" height="30"><param name="movie" value="' . $playerURL . '?' . $colors . '&amp;soundFile=' . $audioDir . '/\1" /><param name="quality" value="high" /><param name="menu" value="false" /><param name="wmode" value="transparent" /><a href="' . $audioDir . '/\1">Download \1</a></object>', $content );
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

		update_option('audio_player_bgcolor', $_POST['ap_bgcolor']);
		update_option('audio_player_textcolor', $_POST['ap_textcolor']);
		update_option('audio_player_iconcolor', $_POST['ap_iconcolor']);
		update_option('audio_player_pathcolor', $_POST['ap_pathcolor']);
		update_option('audio_player_barcolor', $_POST['ap_barcolor']);
		update_option('audio_player_buttoncolor', $_POST['ap_buttoncolor']);
		update_option('audio_player_buttonhovercolor', $_POST['ap_buttonhovercolor']);
		
		echo '<div class="updated"><strong><p>Options updated.</p></strong></div>';
	}

	$web_path = get_option('audio_player_web_path');
	$ap_bgcolor = get_option('audio_player_bgcolor');
	$ap_textcolor = get_option('audio_player_textcolor');
	$ap_iconcolor = get_option('audio_player_iconcolor');
	$ap_pathcolor = get_option('audio_player_pathcolor');
	$ap_barcolor = get_option('audio_player_barcolor');
	$ap_buttoncolor = get_option('audio_player_buttoncolor');
	$ap_buttonhovercolor = get_option('audio_player_buttonhovercolor');
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
				<th width="33%" valign="top"><label for="ap_bgcolor">Background:</label></th>
				<td>
					<input type="text" id="ap_bgcolor" name="ap_bgcolor" size="40" value="<?php echo( $ap_bgcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_iconcolor">Icons:</label></th>
				<td>
					<input type="text" id="ap_iconcolor" name="ap_iconcolor" size="40" value="<?php echo( $ap_iconcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_iconcolor">Text:</label></th>
				<td>
					<input type="text" id="ap_textcolor" name="ap_textcolor" size="40" value="<?php echo( $ap_textcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_barcolor">Progress bar:</label></th>
				<td>
					<input type="text" id="ap_barcolor" name="ap_barcolor" size="40" value="<?php echo( $ap_barcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_pathcolor">Progress bar path:</label></th>
				<td>
					<input type="text" id="ap_pathcolor" name="ap_pathcolor" size="40" value="<?php echo( $ap_pathcolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_buttoncolor">Button:</label></th>
				<td>
					<input type="text" id="ap_buttoncolor" name="ap_buttoncolor" size="40" value="<?php echo( $ap_buttoncolor ); ?>" /><br />
				</td>
			</tr>
			<tr>
				<th width="33%" valign="top"><label for="ap_buttonhovercolor">Button hover:</label></th>
				<td>
					<input type="text" id="ap_buttonhovercolor" name="ap_buttonhovercolor" size="40" value="<?php echo( $ap_buttonhovercolor ); ?>" /><br />
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