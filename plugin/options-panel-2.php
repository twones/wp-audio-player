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
		<li id="ap-tab-general" class="active"><a href="javascript:AP_Admin.showTab('general')">General</a></li>
		<li id="ap-tab-colour"><a href="javascript:AP_Admin.showTab('colour')">Appearance</a></li>
		<li id="ap-tab-feed"><a href="javascript:AP_Admin.showTab('feed')">Feed options</a></li>
		<li id="ap-tab-podcasting"><a href="javascript:AP_Admin.showTab('podcasting')">Podcasting</a></li>
		<li id="ap-tab-advanced" class="last"><a href="javascript:AP_Admin.showTab('advanced')">Advanced</a></li>
	</ul>
	
	<form method="post">
	<div class="ap-panel" style="display:block" id="ap-panel-general">
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
		<ul class="ap_optionlist">
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
	<div class="ap-panel" style="display:none" id="ap-panel-colour">
		<h3>Enable/disable the animation</h3>
		<p>If you don't like the open/close animation, you can disable it here. The player</p>
		<ul class="ap_optionlist">
			<li>
				<label for="ap_disableAnimation">
				<input type="checkbox" name="ap_disableAnimation" id="ap_disableAnimation" value="true"<?php if($ap_enableAnimation == "no") echo ' checked="checked"'; ?> />
				<strong>Disable animation</strong></label>
			</li>
		</ul>
	</div>
	<div class="ap-panel" style="display:none" id="ap-panel-feed">
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
	<div class="ap-panel" style="display:none" id="ap-panel-podcasting">
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
	<div class="ap-panel" style="display:none" id="ap-panel-advanced">
		<h3>Which embed method do you wish to use?</h3>
		<p><strong>Audio Player</strong> allows you to use one of two popular methods for embedding the Flash players: <a href="http://blog.deconcept.com/swfobject/" target="_blank" title="Learn more about the SWFObject method">SWFObject</a> or <a href="http://www.bobbyvandersluis.com/ufo/" target="_blank" title="Learn more about the UFO method">UFO</a>.</p>
		<ul class="ap_optionlist">
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
		<ul class="ap_optionlist">
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