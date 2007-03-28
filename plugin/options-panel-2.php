<div class="wrap" style>
	<h2>Audio Player options</h2>

	<div id="ap-intro">
		<?php if( function_exists( "curl_init" ) || ini_get( "allow_url_fopen" ) ) { ?>
		<form method="post" class="submit"><input type="submit" class="button" name="ap_updateCheck" value="Check for updates" /></form>
		<?php } ?>
		<p>Settings for the Audio Player plugin. Visit <a href="<?php echo $ap_docURL; ?>">1 Pixel Out</a> for usage information and project news.</p>
		<p>Current version: <strong><?php echo $ap_version; ?></strong><?php if( !function_exists( "curl_init" ) && !ini_get( "allow_url_fopen" ) ) { ?> (Visit <a href="<?php echo $ap_docURL; ?>">1 Pixel Out</a> to check for updates)<?php } ?></p>
	</div>

	<ul id="ap-tabs">
		<li id="ap-tab-general"><a href="#ap-panel-general">General</a></li>
		<li id="ap-tab-colour"><a href="#ap-panel-colour">Appearance</a></li>
		<li id="ap-tab-feed"><a href="#ap-panel-feed">Feed options</a></li>
		<li id="ap-tab-podcasting"><a href="#ap-panel-podcasting">Podcasting</a></li>
		<li id="ap-tab-advanced" class="last"><a href="#ap-panel-advanced">Advanced</a></li>
	</ul>
	
	<form method="post">
	<div class="ap-panel" id="ap-panel-general">
		<h3>Audio file location</h3>
		<p>If you use the <code>[audio]</code> syntax, the plugin will assume that all your audio files are located in this folder. The path is relative
		to your blog root. This option does not affect your RSS enclosures or audio files with absolute URLs.</p>
		<p>
			<label for="ap_audiowebpath">Audio files folder:</label>
			<input type="text" id="ap_audiowebpath" name="ap_audiowebpath" size="40" value="<?php echo( get_option("audio_player_web_path") ); ?>" />
			Recommended: <code>/audio</code>
		</p>

		<h3>How do you want to use the audio player?</h3>
		<p>This set of options allows you to customize when your audio players appear.</p>
		<ul class="ap-optionlist">
			<li>
				<label for="ap_behaviour_default">
				<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_default" value="default"<?php if(in_array("default", $ap_behaviour)) echo ' checked="checked"'; ?> />

				<strong>Replace <code>[audio]</code> syntax</strong> (recommended for beginners)</label><br />
				This is the default behaviour and is the only way to apply runtime options to a player instance. Use this option if you want to have more than one audio player per posting.
			</li>
			<li>
				<label for="ap_behaviour_enclosure">
				<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_enclosure" value="enclosure"<?php if(in_array("enclosure", $ap_behaviour)) echo ' checked="checked"'; ?> />
				<strong>Enclosure integration</strong></label> (for podcasters) <br />
				Ideal for podcasting. If you set your enclosures manually, this option will automatically insert a player at the end of posts with an mp3 enclosure. The player will appear at the bottom of your posting.
			</li>
			<li>
				<label for="ap_behaviour_links">
				<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_links" value="links"<?php if(in_array("links", $ap_behaviour)) echo ' checked="checked"'; ?> />
				<strong>Replace all links to mp3 files</strong></label><br />
				When selected, this option will replace all your links to mp3 files with a player instance. Be aware that this could produce odd results when links are in the middle of paragraphs.
			</li>
			<li>
				<label for="ap_behaviour_comments">
				<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_comments" value="comments"<?php if(in_array("comments", $ap_behaviour)) echo ' checked="checked"'; ?> />
				<strong>Enable in comments</strong></label><br />
				When selected, Audio Player will be enabled for all comments on your blog.
			</li>
		</ul>
	</div>
	<div class="ap-panel" id="ap-panel-colour">
		<h3>Enable/disable the animation</h3>
		<p>If you don't like the open/close animation, you can disable it here. The player</p>
		<ul class="ap-optionlist">
			<li>
				<label for="ap_disableAnimation">
				<input type="checkbox" name="ap_disableAnimation" id="ap_disableAnimation" value="true"<?php if($ap_enableAnimation == "no") echo ' checked="checked"'; ?> />
				<strong>Disable animation</strong></label>
			</li>
		</ul>
		<h3>Colour scheme</h3>
		<div id="ap-colorscheme">
			<div id="ap-colorselector">
				<input type="hidden" name="ap_bgcolor" id="ap_bgcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["bg"] ) ); ?>" />
				<input type="hidden" name="ap_leftbgcolor" id="ap_leftbgcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["leftbg"] ) ); ?>" />
				<input type="hidden" name="ap_rightbgcolor" id="ap_rightbgcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["rightbg"] ) ); ?>" />
				<input type="hidden" name="ap_rightbghovercolor" id="ap_rightbghovercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["rightbghover"] ) ); ?>" />
				<input type="hidden" name="ap_lefticoncolor" id="ap_lefticoncolor" value="<?php echo( str_replace( "0x", "#", $ap_options["lefticon"] ) ); ?>" />
				<input type="hidden" name="ap_righticoncolor" id="ap_righticoncolor" value="<?php echo( str_replace( "0x", "#", $ap_options["righticon"] ) ); ?>" />
				<input type="hidden" name="ap_righticonhovercolor" id="ap_righticonhovercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["righticonhover"] ) ); ?>" />
				<input type="hidden" name="ap_skipcolor" id="ap_skipcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["skip"] ) ); ?>" />
				<input type="hidden" name="ap_textcolor" id="ap_textcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["text"] ) ); ?>" />
				<input type="hidden" name="ap_loadercolor" id="ap_loadercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["loader"] ) ); ?>" />
				<input type="hidden" name="ap_trackcolor" id="ap_trackcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["track"] ) ); ?>" />
				<input type="hidden" name="ap_bordercolor" id="ap_bordercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["border"] ) ); ?>" />
				<input type="hidden" name="ap_trackercolor" id="ap_trackercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["tracker"] ) ); ?>" />
				<input type="hidden" name="ap_voltrackcolor" id="ap_voltrackcolor" value="<?php echo( str_replace( "0x", "#", $ap_options["voltrack"] ) ); ?>" />
				<input type="hidden" name="ap_volslidercolor" id="ap_volslidercolor" value="<?php echo( str_replace( "0x", "#", $ap_options["volslider"] ) ); ?>" />
				<select id="ap-fieldselector">
				  <option value="bg" selected>Background</option>
				  <option value="leftbg">Left background</option>
				  <option value="lefticon">Left icon</option>
				  <option value="voltrack">Volume control track</option>
				  <option value="volslider">Volume control slider</option>
				  <option value="rightbg">Right background</option>
				  <option value="rightbghover">Right background (hover)</option>
				  <option value="righticon">Right icon</option>
				  <option value="righticonhover">Right icon (hover)</option>
				  <option value="text">Text</option>
				  <option value="tracker">Progress bar </option>
				  <option value="track">Progress bar track</option>
				  <option value="border">Progress bar border</option>
				  <option value="loader">Loading bar</option>
				  <option value="skip">Next/Previous buttons</option>
				</select>
				<input name="ap_colorvalue" type="text" id="ap-colorvalue" size="15" maxlength="7" />
				<span id="ap-colorsample"></span>
				<div id="ap-audioplayer">
					Audio Player
				</div>
				<script type="text/javascript">
				AudioPlayer.embed("ap-audioplayer", {soundFile:"<?php echo get_settings("siteurl") ?>/wp-content/plugins/audio-player/test.mp3", autostart:"yes", loop:"yes"});
				</script>
			</div>
			<div id="ap-colorpicker"></div>
		</div>
		<p style="clear:both">
			Here, you can set the page background of the player. In most cases, simply select "transparent" and it will
			match the background of your page. In some rare cases, the player will stop working in Firefox if you use the
			transparent option. If this happens, untick the transparent box and enter the color of your page background in
			the box below (in the vast majority of cases, it will be white: #FFFFFF).
		</p>
		<p>
			<label for="ap_pagebgcolor"><strong>Page background color:</strong></label>
			<input type="text" id="ap_pagebgcolor" name="ap_pagebgcolor" size="20" value="<?php echo( get_option("audio_player_pagebgcolor") ); ?>" />
			<input type="checkbox" name="ap_transparentpagebg" id="ap_transparentpagebg" value="true"<?php if( get_option("audio_player_transparentpagebg") ) echo ' checked="checked"'; ?> onclick="ap_setPagebgField()" />
			<label for="ap_transparentpagebg">Transparent</label>
		</p>
	</div>
	<div class="ap-panel" id="ap-panel-feed">
		<h3>Feed options</h3>
		<p>The following options determine what is included in your feeds. The plugin doesn't place a player instance in the feed. Instead, you can choose what the plugin
		inserts. You have three choices:</p>
		<ul>
			<li><strong>A download link</strong>: Choose this if you are OK with subscribers downloading the file.</li>
			<li><strong>Nothing</strong>: Choose this if you feel that your feed shouldn't contain any reference to the audio file.</li>
			<li><strong>Custom</strong>: Choose this to use your own alternative content for all player instances. You can use this option to tell subscribers that they can listen to the audio file if they read the post on your blog.</li>
		</ul>
		<p>
			<label for="ap_rssalternate">Alternate content for  feeds:</label>
			<select id="ap_rssalternate" name="ap_rssalternate">
				<option value="download"<?php if( $ap_rssalternate == 'download' ) echo( 'selected="selected"'); ?>>Download link</option>
				<option value="nothing"<?php if( $ap_rssalternate == 'nothing' ) echo( 'selected="selected"'); ?>>Nothing</option>
				<option value="custom"<?php if( $ap_rssalternate == 'custom' ) echo( 'selected="selected"'); ?>>Custom</option>
			</select>
		</p>
		<p>
			<label for="ap_rsscustomalternate">Custom  alternate content:</label>
			<input type="text" id="ap_rsscustomalternate" name="ap_rsscustomalternate" size="60" value="<?php echo( get_option("audio_player_rsscustomalternate") ); ?>" />
		</p>
	</div>
	<div class="ap-panel" id="ap-panel-podcasting">
		<h3>Pre and Post appended audio clips</h3>
		<p>You may wish to pre-append or post-append audio clips into your players. The pre-appended audio will be played before the main audio, and the post-appended will come after. A typical podcasting use-case for this feature is adding a sponsorship message or simple instructions that help casual listeners become subscribers. <strong>This will apply to all audio players on your site</strong>. Your chosen audio clips should be substantially shorter than your main feature.</p>
		<p>
			<label for="ap_audioprefixwebpath">Pre-appended audio clip URL:</label>
			<input type="text" id="ap_audioprefixwebpath" name="ap_audioprefixwebpath" size="60" value="<?php echo( get_option("audio_player_prefixaudio") ); ?>" /><br />
			<em>Leave this value blank for no pre-appended audio</em>
		</p>
		<p>
			<label for="ap_audiopostfixwebpath">Post-appended audio clip URL:</label>
			<input type="text" id="ap_audiopostfixwebpath" name="ap_audiopostfixwebpath" size="60" value="<?php echo( get_option("audio_player_postfixaudio") ); ?>" /><br />
			<em>Leave this value blank for no post-appended audio</em>
		</p>
	</div>
	<div class="ap-panel" id="ap-panel-advanced">
		<h3>Which embed method do you wish to use?</h3>
		<p><strong>Audio Player</strong> allows you to use one of two popular methods for embedding the Flash players: <a href="http://blog.deconcept.com/swfobject/" target="_blank" title="Learn more about the SWFObject method">SWFObject</a> or <a href="http://www.bobbyvandersluis.com/ufo/" target="_blank" title="Learn more about the UFO method">UFO</a>.</p>
		<ul class="ap-optionlist">
			<li>
				<label for="ap_embed_ufo">
				<input type="radio" name="ap_embedmethod" id="ap_embed_ufo" value="ufo"<?php if($ap_embedMethod == "ufo") echo ' checked="checked"'; ?> />
				<strong>use UFO</strong></label>
			</li>
			<li>
				<label for="ap_embed_swfobject">
				<input type="radio" name="ap_embedmethod" id="ap_embed_swfobject" value="swfobject"<?php if($ap_embedMethod == "swfobject") echo ' checked="checked"'; ?> />
				<strong>use SWFObject</strong></label>
			</li>
		</ul>
		<h3>Include embed method JavaScript file</h3>
		<p>Only disable this if you know that you have a plugin that includes it already or if you are including it yourself.</p>
		<ul class="ap-optionlist">
			<li>
				<label for="ap_includeembedfile">
				<input type="checkbox" name="ap_includeembedfile" id="ap_includeembedfile" value="true"<?php if($ap_includeEmbedFile) echo ' checked="checked"'; ?> />
				<strong>Include Flash embed file (UFO.js or SWFObject.js)</strong></label>
			</li>
		</ul>
	</div>

	<p class="submit">
		<input name="Submit" value="Update Options &raquo;" type="submit" />
	</p>
	</form>
</div>