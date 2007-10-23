var AP_Admin = new Class({
	
	initialize:function()
	{
		this.tabBar = $("ap-tabs");
		if(!this.tabBar) return;

		this.panels = [];
		
		this.tabs = this.tabBar.getElements("li");
		
		for(var i=0;i<this.tabs.length;i++)
		{
			tabID = this.tabs[i].getElement("a").getProperty("id");
			this.tabs[i].addEvent("click", this.tabClick.bindWithEvent(this));
			if(i==0) this.tabs[i].addClass("ap-active");
		}
		
		this.panels = document.getElements("div.ap-panel");
		for(var i=1;i<this.panels.length;i++) this.panels[i].setStyle("display", "none");
		
		this.colorPicker = new MooColorPicker({panelMode:true});
		this.colorPicker.hide();
		this.colorPicker.attach("ap-colorsample", "background-color");
		$("ap-colorsample").addEvent("click", (function() {
			this.colorPicker.show();
		}).bind(this));
		this.colorPicker.addEvent("selectColor", (function(color) {
			this.colorField.value = color;
			this.getCurrentColorField().value = color;
			this.updatePlayer();
		}).bind(this));
		
		this.fieldSelector = $("ap-fieldselector");
		this.colorField = $("ap-colorvalue");
		
		this.fieldSelector.addEvent("change", this.selectColorField.bind(this));
		this.colorField.addEvent("keyup", this.updateColor.bind(this));
		
		this.themeColorPicker = $("ap_themecolor");
		this.themeColorPickerBtn = $("ap_themecolor_btn");
		this.themeColorPickerBtn.addEvent("click", this.showHideThemeColors.bindWithEvent(this));
		document.addEvent("click", this.showHideThemeColors.bindWithEvent(this));
		this.themeColorPicker.addEvent("click", this.pickThemeColor.bindWithEvent(this));
		
		this.selectColorField();
		
		this.player = null;
	},
	
	selectColorField:function()
	{
		var color = this.getCurrentColorField().getValue();
		this.colorField.value = color;
		this.colorPicker.setColor(color);
		$("ap-colorsample").setStyle("background-color", color);
	},

	showHideThemeColors:function(evt) {
		var el = $(evt.target);
		do {
			if(el.getProperty("id") == "ap_themecolor")
			{
				evt.stop();
				return;
			}
			if(el.getProperty("id") == "ap_themecolor_btn") {
				var displayProp = this.themeColorPicker.getStyle("display");
				var coords = this.themeColorPickerBtn.getCoordinates();
				this.themeColorPicker.setStyles({
					"display":displayProp == "none"?"block":"none",
					"top":(coords.top + coords.height - 4) + "px",
					"left":(coords.left + 10) + "px"
				});
				evt.stop();
				return;
			}
			el = el.getParent();
		} while(el.getTag() != "body");
		this.themeColorPicker.setStyle("display", "none");
	},
	
	pickThemeColor:function(evt)
	{
		var target = $(evt.target);
		if(target.getTag() != "span") return;
		var color = target.getProperty("title");
		if(color.length == 4) color = color.replace(/#(.)(.)(.)/, "#$1$1$2$2$3$3");
		this.colorField.value = color;
		this.getCurrentColorField().value = color;
		this.updatePlayer();
		this.colorPicker.setColor(color);
		$("ap-colorsample").setStyle("background-color", color);
	},

	updateColor:function()
	{
		var color = this.colorField.value;
		if(color.test(/#?[0-9a-f]{6}/i))
		{
			this.getCurrentColorField().value = color;
			this.colorPicker.setColor(color);
			this.updatePlayer();
		}
	},
	
	updatePlayer:function()
	{
		if(!this.player)
		{
			this.player = document.getElementById("ap_audioplayer_player");
		}
		
		if(this.player)
		{
			this.player.SetVariable(this.fieldSelector.getValue(), this.getCurrentColorField().getValue().replace("#", "0x"));
			this.player.SetVariable("setcolors", 1);
		}
	},
	
	getCurrentColorField:function()
	{
		return $("ap_" + this.fieldSelector.getValue() + "color");
	},
	
	tabClick:function(event)
	{
		event.stop();
		var i;
		var target = $(event.target);

		var tab = target;
		while(tab.getTag() != "li") tab = tab.getParent();
		if(tab.hasClass("ap-active")) return;
		for(i=0;i<this.tabs.length;i++) this.tabs[i].removeClass("ap-active");
		tab.addClass("ap-active");
		
		for(i=0;i<this.panels.length;i++) this.panels[i].setStyle("display", "none");
		$(target.getProperty("href").replace(/[^#]*#/, "")).setStyle("display", "block");

		//this.colorPicker.update();
	}

});

addLoadEvent(function() { new AP_Admin(); });