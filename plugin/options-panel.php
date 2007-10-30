<?php if ($ap_updated) { ?>
<div id="message" class="updated fade"><p><strong>Options updated</strong></p></div>
<?php } ?>

<div class="wrap">
	<h2><?php _e('Audio Player options', $ap_globals["textDomain"]) ?></h2>

	<div id="ap-intro">
		<p>
			<?php printf(__('Settings for the Audio Player plugin. Visit <a href="%s">1 Pixel Out</a> for usage information and project news.', $ap_globals["textDomain"]), $ap_globals["docURL"]) ?>
		</p>
		<p><?php _e('Current version', $ap_globals["textDomain"]) ?>: <strong><?php echo $ap_globals["version"]; ?></strong></p>
	</div>

	<form method="post">
	<?php
	if ( function_exists('wp_nonce_field') )
		wp_nonce_field('audio-player-action');
	?>
	<p class="submit" id="ap-top-submit">
		<input name="Submit" value="<?php _e('Update Options &raquo;') ?>" type="submit" />
	</p>
	<ul id="ap-tabs">
		<li id="ap-tab-general"><a href="#ap-panel-general"><?php _e('General', $ap_globals["textDomain"]) ?></a></li>
		<li id="ap-tab-colour"><a href="#ap-panel-colour"><?php _e('Display', $ap_globals["textDomain"]) ?></a></li>
		<li id="ap-tab-feed"><a href="#ap-panel-feed"><?php _e('Feed options', $ap_globals["textDomain"]) ?></a></li>
		<li id="ap-tab-podcasting"><a href="#ap-panel-podcasting"><?php _e('Podcasting', $ap_globals["textDomain"]) ?></a></li>
		<li id="ap-tab-advanced" class="last"><a href="#ap-panel-advanced"><?php _e('Advanced', $ap_globals["textDomain"]) ?></a></li>
	</ul>
	
	<div class="ap-panel" id="ap-panel-general">
		<h3><?php _e('Audio file location', $ap_globals["textDomain"]) ?></h3>
		<p>
			<?php _e('If you use the [audio] syntax, the plugin will assume that all your audio files are located in this folder. By default the path is relative to your blog root. However, you can enter a custom path such as "http://anotherdomain.com/mp3files" if your mp3 files are hosted outside of your blog root. This option does not affect your RSS enclosures or audio files with absolute URLs.', $ap_globals["textDomain"]); ?>
		</p>
		<?php if ($ap_globals["audioAbsPath"] != "" && !file_exists($ap_globals["audioAbsPath"])) { ?>
		<p class="ap_warning">
			<strong>Warning</strong>: the audio file folder was not found (<?php echo $ap_globals["audioAbsPath"] ?>). Check that the folder exists and is in the correct location.
		</p>
		<?php } ?>
		<p>
			<select name="ap_audiowebpath_iscustom">
				<option value="false"<?php if(!$ap_globals["isCustomAudioRoot"]) echo(' selected="selected"') ?>><?php echo get_settings('siteurl') ?></option>
				<option value="true"<?php if($ap_globals["isCustomAudioRoot"]) echo(' selected="selected"') ?>>Custom</option>
			</select>
			<input type="text" id="ap_audiowebpath" name="ap_audiowebpath" size="40" value="<?php echo( get_option("audio_player_web_path") ) ?>" />
			<?php _e('Recommended', $ap_globals["textDomain"]) ?>: /audio
		</p>
		<p><?php _e('Important note about track information (ID3 tags)', $ap_globals["textDomain"]) ?>:<br />
		</p>

		<h3><?php _e('How do you want to use the audio player?', $ap_globals["textDomain"]) ?></h3>
		<p><?php _e('This set of options allows you to customize when your audio players appear.', $ap_globals["textDomain"]) ?></p>
		<ul class="ap-optionlist">
			<li>
				<label for="ap_behaviour_default">
				<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_default" value="default"<?php if(in_array("default", $ap_globals["behaviour"])) echo ' checked="checked"'; ?> />

				<strong><?php _e('Replace [audio] syntax', $ap_globals["textDomain"]) ?></strong></label><br />
				<?php _e('This is the default behaviour and is the only way to apply runtime options to a player instance. Use this option if you want to have more than one audio player per posting.', $ap_globals["textDomain"]) ?>
			</li>
			<li>
				<label for="ap_behaviour_enclosure">
				<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_enclosure" value="enclosure"<?php if(in_array("enclosure", $ap_globals["behaviour"])) echo ' checked="checked"'; ?> />
				<strong><?php _e('Enclosure integration', $ap_globals["textDomain"]) ?></strong></label><br />
				<?php _e('Ideal for podcasting. If you set your enclosures manually, this option will automatically insert a player at the end of posts with an mp3 enclosure. The player will appear at the bottom of your posting.', $ap_globals["textDomain"]) ?>
			</li>
			<li>
				<label for="ap_behaviour_links">
				<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_links" value="links"<?php if(in_array("links", $ap_globals["behaviour"])) echo ' checked="checked"'; ?> />
				<strong><?php _e('Replace all links to mp3 files', $ap_globals["textDomain"]) ?></strong></label><br />
				<?php _e('When selected, this option will replace all your links to mp3 files with a player instance. Be aware that this could produce odd results when links are in the middle of paragraphs.', $ap_globals["textDomain"]) ?>
			</li>
			<li>
				<label for="ap_behaviour_comments">
				<input type="checkbox" name="ap_behaviour[]" id="ap_behaviour_comments" value="comments"<?php if(in_array("comments", $ap_globals["behaviour"])) echo ' checked="checked"'; ?> />
				<strong><?php _e('Enable in comments', $ap_globals["textDomain"]) ?></strong></label><br />
				<?php _e('When selected, Audio Player will be enabled for all comments on your blog.', $ap_globals["textDomain"]) ?>
			</li>
		</ul>

		<h4><?php _e('Alternate content for excerpts', $ap_globals["textDomain"]) ?></h4>
		<p>
			WordPress automatically creates excerpts (summaries) for your posts. These are used by some themes
			to show on archive pages instead of the full post. By default, WordPress strips all HTML from these excerpts. Here you can
			choose what Audio Player inserts in excerpts in place of the player.
		</p>
		<p>
			<label for="ap_excerptalternate">Alternate content for excerpts:</label>
			<input type="text" id="ap_excerptalternate" name="ap_excerptalternate" size="60" value="<?php echo( $ap_globals["excerptAlternate"] ) ?>" />
		</p>
	</div>
	
	<div class="ap-panel" id="ap-panel-colour">
		<h3><?php _e('Player width', $ap_globals["textDomain"]) ?></h3>
		<p>
			<label for="ap_player_width"><?php _e('Player width', $ap_globals["textDomain"]) ?></label>
			<input type="text" id="ap_player_width" name="ap_player_width" value="<?php echo $ap_globals["playerWidth"]; ?>" size="10" />
			<?php _e('You can enter a value in pixels (e.g. 200) or as a percentage (e.g. 100%)', $ap_globals["textDomain"]) ?>
		</p>
		<h3><?php _e('Colour scheme', $ap_globals["textDomain"]) ?></h3>
		<div id="ap-colorscheme">
			<div id="ap-colorselector">
				<input type="hidden" name="ap_bgcolor" id="ap_bgcolor" value="#<?php echo( $ap_globals["playerOptions"]["bg"] ) ?>" />
				<input type="hidden" name="ap_leftbgcolor" id="ap_leftbgcolor" value="#<?php echo( $ap_globals["playerOptions"]["leftbg"] ) ?>" />
				<input type="hidden" name="ap_rightbgcolor" id="ap_rightbgcolor" value="#<?php echo( $ap_globals["playerOptions"]["rightbg"] ) ?>" />
				<input type="hidden" name="ap_rightbghovercolor" id="ap_rightbghovercolor" value="#<?php echo( $ap_globals["playerOptions"]["rightbghover"] ) ?>" />
				<input type="hidden" name="ap_lefticoncolor" id="ap_lefticoncolor" value="#<?php echo( $ap_globals["playerOptions"]["lefticon"] ) ?>" />
				<input type="hidden" name="ap_righticoncolor" id="ap_righticoncolor" value="#<?php echo( $ap_globals["playerOptions"]["righticon"] ) ?>" />
				<input type="hidden" name="ap_righticonhovercolor" id="ap_righticonhovercolor" value="#<?php echo( $ap_globals["playerOptions"]["righticonhover"] ) ?>" />
				<input type="hidden" name="ap_skipcolor" id="ap_skipcolor" value="#<?php echo( $ap_globals["playerOptions"]["skip"] ) ?>" />
				<input type="hidden" name="ap_textcolor" id="ap_textcolor" value="#<?php echo( $ap_globals["playerOptions"]["text"] ) ?>" />
				<input type="hidden" name="ap_loadercolor" id="ap_loadercolor" value="#<?php echo( $ap_globals["playerOptions"]["loader"] ) ?>" />
				<input type="hidden" name="ap_trackcolor" id="ap_trackcolor" value="#<?php echo( $ap_globals["playerOptions"]["track"] ) ?>" />
				<input type="hidden" name="ap_bordercolor" id="ap_bordercolor" value="#<?php echo( $ap_globals["playerOptions"]["border"] ) ?>" />
				<input type="hidden" name="ap_trackercolor" id="ap_trackercolor" value="#<?php echo( $ap_globals["playerOptions"]["tracker"] ) ?>" />
				<input type="hidden" name="ap_voltrackcolor" id="ap_voltrackcolor" value="#<?php echo( $ap_globals["playerOptions"]["voltrack"] ) ?>" />
				<input type="hidden" name="ap_volslidercolor" id="ap_volslidercolor" value="#<?php echo( $ap_globals["playerOptions"]["volslider"] ) ?>" />
				<select id="ap-fieldselector">
				  <option value="bg" selected><?php _e('Background', $ap_globals["textDomain"]) ?></option>
				  <option value="leftbg"><?php _e('Left background', $ap_globals["textDomain"]) ?></option>
				  <option value="lefticon"><?php _e('Left icon', $ap_globals["textDomain"]) ?></option>
				  <option value="voltrack"><?php _e('Volume control track', $ap_globals["textDomain"]) ?></option>
				  <option value="volslider"><?php _e('Volume control slider', $ap_globals["textDomain"]) ?></option>
				  <option value="rightbg"><?php _e('Right background', $ap_globals["textDomain"]) ?></option>
				  <option value="rightbghover"><?php _e('Right background (hover)', $ap_globals["textDomain"]) ?></option>
				  <option value="righticon"><?php _e('Right icon', $ap_globals["textDomain"]) ?></option>
				  <option value="righticonhover"><?php _e('Right icon (hover)', $ap_globals["textDomain"]) ?></option>
				  <option value="text"><?php _e('Text', $ap_globals["textDomain"]) ?></option>
				  <option value="tracker"><?php _e('Progress bar', $ap_globals["textDomain"]) ?></option>
				  <option value="track"><?php _e('Progress bar track', $ap_globals["textDomain"]) ?></option>
				  <option value="border"><?php _e('Progress bar border', $ap_globals["textDomain"]) ?></option>
				  <option value="loader"><?php _e('Loading bar', $ap_globals["textDomain"]) ?></option>
				  <option value="skip"><?php _e('Next/Previous buttons', $ap_globals["textDomain"]) ?></option>
				</select>
				<input name="ap_colorvalue" type="text" id="ap-colorvalue" size="15" maxlength="7" />
				<span id="ap-colorsample"></span>
				<span id="ap-picker_btn"><?php _e('Pick', $ap_globals["textDomain"]) ?></span>
				<span id="ap-themecolor_btn"><?php _e('From your theme', $ap_globals["textDomain"]) ?></span>
				<div id="ap-themecolor">
					<span><?php _e('Theme colors', $ap_globals["textDomain"]) ?></span>
					<ul>
						<?php foreach($ap_theme_colors as $ap_theme_color) { ?>
						<li style="background:#<?php echo $ap_theme_color ?>" title="#<?php echo $ap_theme_color ?>">#<?php echo $ap_theme_color ?></li>
						<?php } ?>
					</ul>
				</div>
			</div>
			<div id="ap-audioplayer-wrapper"<?php if (!$ap_globals["transparentPageBg"]) echo ' style="background-color:#' . $ap_globals["pageBgColor"] . '"' ?>>
				<div id="ap-audioplayer">
					Audio Player
				</div>
			</div>
			<script type="text/javascript">
			AudioPlayer.setup("<?php echo $ap_globals["playerURL"] ?>", "<?php echo $ap_globals["playerWidth"] ?>", "<?php echo $ap_globals["transparentPageBg"]?'transparent':'opaque' ?>", "<?php echo $ap_globals["pageBgColor"]; ?>", <?php echo ap_php2js($ap_globals["playerOptions"]) ?>);
			AudioPlayer.embed("ap-audioplayer", {demomode:"yes"});
			</script>
		</div>
		
		<p style="clear:both">
			Here, you can set the page background of the player. In most cases, simply select "transparent" and it will
			match the background of your page. In some rare cases, the player will stop working in Firefox if you use the
			transparent option. If this happens, untick the transparent box and enter the color of your page background in
			the box below (in the vast majority of cases, it will be white: #FFFFFF).
		</p>
		<p>
			<label for="ap_pagebgcolor"><strong><?php _e('Page background color', $ap_globals["textDomain"]) ?>:</strong></label>
			<input type="text" id="ap_pagebgcolor" name="ap_pagebgcolor" maxlength="7" size="20" value="#<?php echo $ap_globals["pageBgColor"]; ?>"<?php if( $ap_globals["transparentPageBg"] ) echo ' disabled="disabled" style="color:#999999"'; ?> />
			<label for="ap_transparentpagebg">
				<input type="checkbox" name="ap_transparentpagebg" id="ap_transparentpagebg" value="true"<?php if( $ap_globals["transparentPageBg"] ) echo ' checked="checked"'; ?> />
				<?php _e('Transparent', $ap_globals["textDomain"]) ?>
			</label>
		</p>
		<h3><?php _e('Options', $ap_globals["textDomain"]) ?></h3>
		<ul class="ap-optionlist">
			<li>
				<label for="ap_disableAnimation">
				<input type="checkbox" name="ap_disableAnimation" id="ap_disableAnimation" value="true"<?php if(!$ap_globals["enableAnimation"]) echo ' checked="checked"'; ?> />
				<strong><?php _e('Disable animation', $ap_globals["textDomain"]) ?></strong></label><br />
				<?php _e('If you don\'t like the open/close animation, you can disable it here.', $ap_globals["textDomain"]) ?>
			</li>
			<li>
				<label for="ap_showRemaining">
				<input type="checkbox" name="ap_showRemaining" id="ap_showRemaining" value="true"<?php if($ap_globals["showRemaining"]) echo ' checked="checked"'; ?> />
				<strong><?php _e('Show remaining time', $ap_globals["textDomain"]) ?></strong></label><br />
				<?php _e('This will make the time display count down rather than up.', $ap_globals["textDomain"]) ?>
			</li>
			<li>
				<label for="ap_disableTrackInformation">
				<input type="checkbox" name="ap_disableTrackInformation" id="ap_disableTrackInformation" value="true"<?php if($ap_globals["disableTrackInformation"]) echo ' checked="checked"'; ?> />
				<strong><?php _e('Disable track information', $ap_globals["textDomain"]) ?></strong></label><br />
				<?php _e('Select this if you wish to disable track information display (the player won\'t show titles or artist names even if they are available)', $ap_globals["textDomain"]) ?>
			</li>
		</ul>
	</div>
	
	<div class="ap-panel" id="ap-panel-feed">
		<h3><?php _e('Feed options', $ap_globals["textDomain"]) ?></h3>
		<p>
			<?php _e('The following options determine what is included in your feeds. The plugin doesn\'t place a player instance in the feed. Instead, you can choose what the plugin inserts. You have three choices:', $ap_globals["textDomain"]) ?>
		</p>
		<ul>
			<li><strong><?php _e('Download link', $ap_globals["textDomain"]) ?></strong>: <?php _e('Choose this if you are OK with subscribers downloading the file.', $ap_globals["textDomain"]) ?></li>
			<li><strong><?php _e('Nothing', $ap_globals["textDomain"]) ?></strong>: <?php _e('Choose this if you feel that your feed shouldn\'t contain any reference to the audio file.', $ap_globals["textDomain"]) ?></li>
			<li><strong><?php _e('Custom', $ap_globals["textDomain"]) ?></strong>: <?php _e('Choose this to use your own alternative content for all player instances. You can use this option to tell subscribers that they can listen to the audio file if they read the post on your blog.', $ap_globals["textDomain"]) ?></li>
		</ul>
		<p>
			<label for="ap_rssalternate"><?php _e('Alternate content for  feeds', $ap_globals["textDomain"]) ?>:</label>
			<select id="ap_rssalternate" name="ap_rssalternate">
				<option value="download"<?php if( $ap_globals["rssAlternate"] == 'download' ) echo( 'selected="selected"') ?>><?php _e('Download link', $ap_globals["textDomain"]) ?></option>
				<option value="nothing"<?php if( $ap_globals["rssAlternate"] == 'nothing' ) echo( 'selected="selected"') ?>><?php _e('Nothing', $ap_globals["textDomain"]) ?></option>
				<option value="custom"<?php if( $ap_globals["rssAlternate"] == 'custom' ) echo( 'selected="selected"') ?>><?php _e('Custom', $ap_globals["textDomain"]) ?></option>
			</select>
		</p>
		<p>
			<label for="ap_rsscustomalternate"><?php _e('Custom  alternate content', $ap_globals["textDomain"]) ?>:</label>
			<input type="text" id="ap_rsscustomalternate" name="ap_rsscustomalternate" size="60" value="<?php echo( $ap_globals["rssCustomAlternate"] ) ?>" />
		</p>
	</div>
	
	<div class="ap-panel" id="ap-panel-podcasting">
		<h3><?php _e('Pre and Post appended audio clips', $ap_globals["textDomain"]) ?></h3>
		<p>
			<?php _e('You may wish to pre-append or post-append audio clips into your players. The pre-appended audio will be played before the main audio, and the post-appended will come after. A typical podcasting use-case for this feature is adding a sponsorship message or simple instructions that help casual listeners become subscribers. <strong>This will apply to all audio players on your site</strong>. Your chosen audio clips should be substantially shorter than your main feature.', $ap_globals["textDomain"]) ?>
		</p>
		<p>
			<label for="ap_audioprefixwebpath"><?php _e('Pre-appended audio clip URL', $ap_globals["textDomain"]) ?>:</label>
			<input type="text" id="ap_audioprefixwebpath" name="ap_audioprefixwebpath" size="60" value="<?php echo $ap_globals["prefixAudio"]; ?>" /><br />
			<em><?php _e('Leave this value blank for no pre-appended audio', $ap_globals["textDomain"]) ?></em>
		</p>
		<p>
			<label for="ap_audiopostfixwebpath"><?php _e('Post-appended audio clip URL', $ap_globals["textDomain"]) ?>:</label>
			<input type="text" id="ap_audiopostfixwebpath" name="ap_audiopostfixwebpath" size="60" value="<?php echo $ap_globals["postfixAudio"]; ?>" /><br />
			<em><?php _e('Leave this value blank for no post-appended audio', $ap_globals["textDomain"]) ?></em>
		</p>
	</div>
	
	<div class="ap-panel" id="ap-panel-advanced">
		<h3><?php _e('Initial volume', $ap_globals["textDomain"]) ?></h3>
		<p>
			<?php _e('This is the volume at which the player defaults to (0 is off, 100 is full volume)', $ap_globals["textDomain"]) ?>
		</p>
		<p>
			<label for="ap_volume">Initial volume</label>
			<input type="text" id="ap_volume" name="ap_initial_volume" value="<?php echo $ap_globals["initialVolume"]; ?>" size="5" />
		</p>
		<h3><?php _e('Encoding', $ap_globals["textDomain"]) ?></h3>
		<p>
			<?php _e('Enable this to encode the URLs to your mp3 files. This is the only protection possible against people downloading the mp3 file to their computers.', $ap_globals["textDomain"]) ?>
		</p>
		<ul class="ap-optionlist">
			<li>
				<label for="ap_encodeSource">
				<input type="checkbox" name="ap_encodeSource" id="ap_encodeSource" value="true"<?php if($ap_globals["encodeSource"]) echo ' checked="checked"'; ?> />
				<strong><?php _e('Encode mp3 URLs', $ap_globals["textDomain"]) ?></strong></label>
			</li>
		</ul>
		<h3><?php _e('Which embed method do you wish to use?', $ap_globals["textDomain"]) ?></h3>
		<p>
			<?php printf(__('Audio Player allows you to use one of two popular methods for embedding the Flash players: <a href="%s" target="_blank" title="Learn more about the SWFObject method">SWFObject</a> or <a href="%s" target="_blank" title="Learn more about the UFO method">UFO</a>.'), 'http://blog.deconcept.com/swfobject/', 'http://www.bobbyvandersluis.com/ufo/') ?>
		</p>
		<ul class="ap-optionlist">
			<li>
				<label for="ap_embed_ufo">
				<input type="radio" name="ap_embedmethod" id="ap_embed_ufo" value="ufo"<?php if($ap_globals["embedMethod"] == "ufo") echo ' checked="checked"'; ?> />
				<strong><?php _e('use UFO', $ap_globals["textDomain"]) ?></strong></label>
			</li>
			<li>
				<label for="ap_embed_swfobject">
				<input type="radio" name="ap_embedmethod" id="ap_embed_swfobject" value="swfobject"<?php if($ap_globals["embedMethod"] == "swfobject") echo ' checked="checked"'; ?> />
				<strong><?php _e('use SWFObject', $ap_globals["textDomain"]) ?></strong></label>
			</li>
		</ul>
		<h4><?php _e('Include embed method JavaScript file', $ap_globals["textDomain"]) ?></h4>
		<p>
			<?php _e('Only disable this if you know that you have a plugin that includes it already or if you are including it yourself.', $ap_globals["textDomain"]) ?>
		</p>
		<ul class="ap-optionlist">
			<li>
				<label for="ap_includeembedfile">
				<input type="checkbox" name="ap_includeembedfile" id="ap_includeembedfile" value="true"<?php if($ap_globals["includeEmbedFile"]) echo ' checked="checked"'; ?> />
				<strong><?php _e('Include Flash embed file (UFO.js or SWFObject.js)', $ap_globals["textDomain"]) ?></strong></label>
			</li>
		</ul>
	</div>

	<p class="submit">
		<input name="Submit" value="<?php _e('Update Options &raquo;') ?>" type="submit" />
	</p>
	</form>
</div>