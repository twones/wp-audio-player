/*extern Class, MooColorPicker, $ */

var AP_Admin = new Class({
    initialize : function () {
        var i;
        
        this.tabBar = $("ap-tabs");
        if (!this.tabBar) {
            return;
        }

        this.panels = [];
        
        this.tabs = this.tabBar.getElements("li");
        
        for (i = 0;i < this.tabs.length;i++) {
            this.tabs[i].getElement("a").addEvent("click", this.tabClick.bindWithEvent(this));
            if (i === 0) {
                this.tabs[i].addClass("ap-active");
            }
        }
        
        this.panels = document.getElements("div.ap-panel");
        for (i = 1;i < this.panels.length;i++) {
            this.panels[i].setStyle("display", "none");
        }

        $("ap_transparentpagebg").addEvent("click", function () {
            var bgField = $("ap_pagebgcolor");
            if ($("ap_transparentpagebg").checked) {
                bgField.disabled = true;
                bgField.setStyle("color", "#999999");
            } else {
                bgField.disabled = false;
                bgField.setStyle("color", "#000000");
            }
        });
        
        this.colorPicker = new MooColorPicker({panelMode : true});
        this.colorPicker.hide();
        this.colorPicker.attach("ap-colorsample", "background-color");
        $("ap-picker_btn").addEvent("click", (function () {
            this.colorPicker.show();
        }).bind(this));
        this.colorPicker.addEvent("selectColor", (function (color) {
            this.colorField.value = color;
            this.getCurrentColorField().value = color;
            this.updatePlayer();
        }).bind(this));
        
        this.fieldSelector = $("ap-fieldselector");
        this.colorField = $("ap-colorvalue");
        
        this.fieldSelector.addEvent("change", this.selectColorField.bind(this));
        this.colorField.addEvent("keyup", this.updateColor.bind(this));
        
        this.themeColorPicker = $("ap-themecolor");
        this.themeColorPicker.setStyle("display", "none");
        this.reorderThemeColors();
        this.themeColorPickerBtn = $("ap-themecolor_btn");
        this.themeColorPickerBtn.addEvent("click", this.showHideThemeColors.bindWithEvent(this));
        document.addEvent("click", this.showHideThemeColors.bindWithEvent(this));
        document.addEvent("click", this.hideColorPicker.bindWithEvent(this));
        this.themeColorPicker.addEvent("click", this.pickThemeColor.bindWithEvent(this));
        
        this.selectColorField();
        
        this.player = null;
    },
    
    selectColorField : function () {
        var color = this.getCurrentColorField().getValue();
        this.colorField.value = color;
        this.colorPicker.setColor(color);
        $("ap-colorsample").setStyle("background-color", color);
    },
    
    hideColorPicker : function (evt) {
        var el = $(evt.target);
        while (el.getTag() != "body") {
            if (el.getProperty("id") == "ap-picker_btn" || el.hasClass("moocp_color-picker")) {
                return;
            }
            el = el.getParent();
        }
        this.colorPicker.hide();
    },

    showHideThemeColors : function (evt) {
        var el = $(evt.target);
        while (el.getTag() != "body") {
            if (el.getProperty("id") == "ap-themecolor") {
                evt.stop();
                return;
            }
            if (el.getProperty("id") == "ap-themecolor_btn") {
                var displayProp = this.themeColorPicker.getStyle("display");
                var coords = this.themeColorPickerBtn.getCoordinates();
                this.themeColorPicker.setStyles({
                    display : displayProp == "none" ? "block" : "none",
                    top : (coords.top + coords.height - 4) + "px",
                    left : (coords.left + 10) + "px"
                });
                evt.stop();
                return;
            }
            el = el.getParent();
        }
        this.themeColorPicker.setStyle("display", "none");
    },
    
    reorderThemeColors : function () {
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
    },
    
    pickThemeColor : function (evt) {
        var target = $(evt.target);
        if (target.getTag() != "li") {
            return;
        }
        var color = target.getProperty("title");
        if (color.length == 4) {
            color = color.replace(/#(.)(.)(.)/, "#$1$1$2$2$3$3");
        }
        this.colorField.value = color;
        this.getCurrentColorField().value = color;
        this.updatePlayer();
        this.colorPicker.setColor(color);
        $("ap-colorsample").setStyle("background-color", color);
        this.themeColorPicker.setStyle("display", "none");
    },

    updateColor : function () {
        var color = this.colorField.value;
        if (color.test(/#?[0-9a-f]{6}/i))
        {
            this.getCurrentColorField().value = color;
            this.colorPicker.setColor(color);
            $("ap-colorsample").setStyle("background-color", color);
            this.updatePlayer();
        }
    },
    
    updatePlayer : function () {
    	var hiddenColorFields, i, playerElementID;
    	
    	playerElementID = "ap_audioplayer_player";
    	if (window.document[playerElementID]) {
    		this.player = window.document[playerElementID];
    	} else if (!window.ie && document.embeds && document.embeds[playerElementID]) {
    		this.player = document.embeds[playerElementID];
    	} else {
        	this.player = document.getElementById(playerElementID);
    	}

        if (this.player) {
        	hiddenColorFields = $("ap-colorselector").getElements("input[type=hidden]");
        	for (i = 0;i < hiddenColorFields.length; i++) {
	            this.player.SetVariable(hiddenColorFields[i].getProperty("name").replace(/ap_(.+)color/, "$1"), hiddenColorFields[i].getValue().replace("#", ""));
        	}
            this.player.SetVariable("setcolors", 1);
        }
    },
    
    getCurrentColorField : function () {
        return $("ap_" + this.fieldSelector.getValue() + "color");
    },
    
    tabClick : function (evt) {
        var i;
        var target = $(evt.target);
        var tab = target.getParent();
        var activeTabID;
        
        evt.stop();
        
        if (tab.hasClass("ap-active")) {
            return;
        }
        for (i = 0;i < this.tabs.length;i++) {
            this.tabs[i].removeClass("ap-active");
        }
        tab.addClass("ap-active");
        
        for (i = 0;i < this.panels.length;i++) {
            this.panels[i].setStyle("display", "none");
        }
        
        activeTabID = target.getProperty("href").replace(/[^#]*#/, "");
        $(activeTabID).setStyle("display", "block");
        if (window.gecko || window.webkit) {
	        if (activeTabID == "ap-panel-colour") {
	        	this.timer = this.updatePlayer.delay(500, this);
	        } else if (this.timer) {
	        	$clear(this.timer);
	        }
        }
    }

});

window.addEvent("load", function () {
    var ap_admin = new AP_Admin();
});