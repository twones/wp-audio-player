(function ($) {
	var init = function () {
		var tabBar = $("#ap_tabs");
		if (!tabBar) {
			return;
		}
		var panels = [];
		
		tabs = $("#ap_tabs li");
		panels = $("div.ap_panel");
		
		$("#ap_tabs li>a").click(function (evt) {
			var i;
			var target = $(this);
			var tab = target.parent();
			
			evt.preventDefault();
			
			if (tab.attr("class") == "ap_active") {
				return;
			}
			
			tabs.removeClass("ap_active");
			tab.addClass("ap_active");
			
			panels.css("display", "none");
			
			$("#" + target.attr("href").replace(/[^#]*#/, "")).css("display", "block");
			
			/*
			if (Browser.Engine.gecko || Browser.Engine.webkit) {
				if (activeTabID == "ap_panel-colour") {
					this.timer = this.updatePlayer.delay(500, this);
				} else if (this.timer) {
					$clear(this.timer);
				}
			}*/
		});
		$("#ap_tabs li:first").addClass("ap_active");
		
		panels.css("display", "none");
		$("div.ap_panel:first").css("display", "block");
		
		// Add behaviour to transparent checkbox
		$("#ap_transparentpagebg").click(function () {
			var bgField = $("#ap_pagebgcolor");
			if ($("#ap_transparentpagebg").attr("checked")) {
				bgField.attr("disabled", true);
				bgField.css("color", "#999999");
			} else {
				bgField.attr("disabled", false);
				bgField.css("color", "#000000");
			}
		});
		
		// Verify audio folder button 
		$("#ap_audiofolder-check").css("display", "block");
		$("#ap_check-button").click(checkAudioFolder);
		$("#ap_audiowebpath_iscustom").change(setAudioCheckButton);
		setAudioCheckButton();
		
		$("#ap_reset").val("");
		
		$("#ap_resetcolor").click(function () {
			$("#ap_reset").val("1");
			$("#ap_option-form").submit();
		});
		
		$("#ap_fieldselector").change(selectColorField);
		$("#ap_colorvalue").keyup(updateColor);
		
		var themeColorPicker = $("#ap_themecolor");
		if (themeColorPicker) {
			themeColorPicker.css("display", "none");
			//reorderThemeColors();
			themeColorPickerBtn = $("#ap_themecolor-btn");
			themeColorPickerBtn.click(function (evt) {
				themeColorPicker.css({
					top : themeColorPickerBtn.offset().top + themeColorPickerBtn.height() - 4,
					left : themeColorPickerBtn.offset().left + 10
				});
				themeColorPicker.show();
				evt.stopPropagation();
			});
			$("li", themeColorPicker).click(function (evt) {
				var color = $(this).attr("title");
				if (color.length == 4) {
					color = color.replace(/#(.)(.)(.)/, "#$1$1$2$2$3$3");
				}
				$("#ap_colorvalue").val(color);
				updateColor();
				$("#ap_themecolor").css("display", "none");
				evt.stopPropagation();
			});
			$(document).click(function () {
				themeColorPicker.hide();
			});
		}
		
		$("#ap_picker-btn").ColorPicker({
			onChange: function (hsb, hex, rgb) {
				$("#ap_colorvalue").val("#" + hex);
				updateColor();
			},
			
			onShow: function () {
				themeColorPicker.hide();
			}
		});
		
		selectColorField();
	}
	
	var getCurrentColorField = function () {
		return $("#ap_" + $("#ap_fieldselector").val() + "color");
	}
	
	var selectColorField = function () {
		var color = getCurrentColorField().val();
		$("#ap_colorvalue").val(color);
		$("#ap_picker-btn").ColorPickerSetColor(color);
		$("#ap_colorsample").css("background-color", color);
	}
	
	var updateColor = function () {
		var color = $("#ap_colorvalue").val();
		if (color.match(/#?[0-9a-f]{6}/i))
		{
			getCurrentColorField().val(color);
			$("#ap_picker-btn").ColorPickerSetColor(color);
			$("#ap_colorsample").css("background-color", color);
			updatePlayer();
		}
	}
	
	var updatePlayer = function () {
		var player;
		
		if (window.document["ap_demoplayer"]) {
			player = window.document["ap_demoplayer"];
		} else if (!document.all && document.embeds && document.embeds["ap_demoplayer"]) {
			player = document.embeds["ap_demoplayer"];
		} else {
			player = document.getElementById("ap_demoplayer");
		}
		
		if (player) {
			$("#ap_colorselector input[type=hidden]").each(function (i) {
				player.SetVariable($(this).attr("name").replace(/ap_(.+)color/, "$1"), $(this).val().replace("#", ""));
			});
			player.SetVariable("setcolors", 1);
		}
	}
	
	var showThemeColors = function (evt) {
		var displayProp = $("#ap_themecolor").css("display");
		$("#ap_themecolor").css({
			display : displayProp == "none" ? "block" : "none",
			top : $("#ap_themecolor-btn").offset().top + $("#ap_themecolor-btn").height() - 4,
			left : $("#ap_themecolor-btn").offset().left + 10
		});
		evt.stopPropagation();
	}
	
	/*var reorderThemeColors = function () {
		var swatchList = this.themeColorPicker.getElement("ul");
		var swatches = swatchList.getElements("li");
		swatches.sort(function (a, b) {
			var colorA = new Color(a.getProperty("title"));
			var colorB = new Color(b.getProperty("title"));
			colorA = colorA.rgbToHsb();
			colorB = colorB.rgbToHsb();
			if (colorA[2] < colorB[2]) {
				return 1;
			}
			if (colorA[2] > colorB[2]) {
				return -1;
			}
			return 0;
		});
		swatches.each(function (swatch) {
			swatch.injectTop(swatchList);
		});
	}*/
	
	var pickThemeColor = function (evt) {
		var color = target.attr("title");
		if (color.length == 4) {
			color = color.replace(/#(.)(.)(.)/, "#$1$1$2$2$3$3");
		}
		$("#ap_colorvalue").val(color);
		getCurrentColorField().val(color);
		updatePlayer();
		$("#ap_picker-btn").ColorPickerSetColor(color);
		$("ap_colorsample").css("background-color", color);
		$("#ap_themecolor").css("display", "none");
	}
	
	var checkAudioFolder = function () {
		showMessage("checking");
		
		$.post(ap_ajaxRootURL + "check-audio-folder.php", {
			audioFolder: $("#ap_audiowebpath").val()
		}, audioFolderCheckResponse);
	}
	
	var audioFolderCheckResponse = function (data) {
		$("#ap_checking-message").css("display", "none");
		if (data == "ok") {
			showMessage("success");
		} else {
			$("#ap_failure-message strong").text(data);
			showMessage("failure");
		}
	}
	
	var showMessage = function (message) {
		$("#ap_info-message").css("display", "none");
		$("#ap_disabled-message").css("display", "none");
		$("#ap_checking-message").css("display", "none");
		$("#ap_success-message").css("display", "none");
		$("#ap_failure-message").css("display", "none");
		
		if (message != "none") {
			$("#ap_" + message + "-message").css("display", "block");
		}
	}
	
	var setAudioCheckButton = function () {
		if ($("#ap_audiowebpath_iscustom").val() == "false") {
			$("#ap_check-button").attr("disabled", false);
			showMessage("info");
		} else {
			$("#ap_check-button").attr("disabled", true);
			showMessage("disabled");
		}
	}
	
	$(init);
})(jQuery);