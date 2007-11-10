<?php

if (!function_exists('add_action'))
{
	require_once("../../../wp-config.php");
}

if (isset($AudioPlayer)) {
	$AudioPlayer->checkAudioFolder();
}
?>