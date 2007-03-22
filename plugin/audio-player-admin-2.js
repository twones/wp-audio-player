var AP_Admin = {
	
	setup:function()
	{
		this.tabBar = document.getElementById("ap-tabs");
		if(!this.tabBar) return;

		this.panels = [];
		
		this.tabs = this.tabBar.getElementsByTagName("li");
		
		var divTags = document.getElementsByTagName("div");
		for(var i=divTags.length-1;i>=0;i--)
		{
			if(this.hasClass(divTags[i], "ap-panel")) this.panels[this.panels.length] = divTags[i];
		}
	},
	
	showTab:function(tabID)
	{
		for(var i=0;i<this.panels.length;i++) {
			this.panels[i].style.display = (this.panels[i].id == "ap-panel-" + tabID)?"block":"none";
		}
		for(var i=0;i<this.tabs.length;i++) this.removeClass(this.tabs[i], "active");
		this.addClass(document.getElementById("ap-tab-" + tabID), "active");
	},
	
	hasClass:function(element, className)
	{
		return element.className.match(new RegExp('(?:^|\\s)' + className + '(?:\\s|$)'));
	},

	addClass:function(element, className)
	{
		if(!this.hasClass(element, className)) element.className = (element.className+' '+className);
	},

	removeClass:function(element, className)
	{
		element.className = element.className.replace(new RegExp('(^|\\s)'+className+'(?:\\s|$)'), '$1');
	}
};


addLoadEvent(function() { AP_Admin.setup(); });