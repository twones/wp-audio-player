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
		
		this.colorPicker = new MooColorPicker("ap-colorpicker", {panelMode:false})
		this.colorPicker.attach("ap-colorsample", "background-color");
		this.colorPicker.addEvent("selectColor", (function(color) {
			this.colorField.value = color;
			this.getCurrentColorField().value = color;
			this.updatePlayer();
		}).bind(this));
		
		this.fieldSelector = $("ap-fieldselector");
		this.colorField = $("ap-colorvalue");
		
		this.fieldSelector.addEvent("change", this.selectColorField.bind(this));
		this.colorField.addEvent("keyup", this.updateColor.bind(this));
				
		this.selectColorField();
		
		this.player = null;
	},
	
	selectColorField:function()
	{
		var color = this.getCurrentColorField().getValue();
		this.colorField.value = color;
		this.colorPicker.setColor(color);
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
		$(target.getProperty("href").replace("#", "")).setStyle("display", "block");

		this.colorPicker.update();
	}

});

addLoadEvent(function() { new AP_Admin(); });