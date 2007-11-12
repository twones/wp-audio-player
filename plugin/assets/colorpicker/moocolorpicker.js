var MooColorPicker = new Class({
	
	options: {
		initialColor:"#000000",
		classPrefix:"moocp_",
		panelMode:false,
		container:null
	},
	
	/**
	 * Constructor
	 */
	initialize:function(options)
	{
		this.setOptions(options);
		
		// Timer for delayed operations
		this._timer = 0;

		this._buildColorPicker();
		
		this.setColor(this.options.initialColor);
	},
	
	/**
	 * PRIVATE: builds the colorpicker HTML element
	 */
	_buildColorPicker:function()
	{
		// Build color picker
		this.colorpicker = new Element("div").addClass(this.options.classPrefix + "color-picker");

		// Add to page
		var container = $(this.options.container);
		if(!container) container = document.getElementsByTagName("body")[0];
		this.colorpicker.injectInside(container);
		
		// If in panel mode, add header, make color picker draggable and hide it
		if(this.options.panelMode)
		{
			this.colorpicker.addClass(this.options.classPrefix + "panel-mode");
			
			var header = new Element("div").addClass(this.options.classPrefix + "header-panel").injectInside(this.colorpicker);
			var closeButton = new Element("span").injectInside(header);
			closeButton.addEvent("click", this.hide.bind(this));

			this.colorpicker.makeDraggable({
				handle:header,
				onComplete:this._updatePanelCoords.bind(this)
			});

			this.hide();
		}
		
		// Build panels and cursors
		this.svPanel = new Element("div").addClass(this.options.classPrefix + "sv-panel").injectInside(this.colorpicker);
		if(window.ie6)
		{
			this.svPanel.setStyle("background", "transparent");
			this.ieSvPanel = new Element("div").addClass(this.options.classPrefix + "sv-panel-ie").injectInside(this.colorpicker);
		}
		this.svCursor = new Element("span").injectInside(this.svPanel);
		this.huePanel = new Element("div").addClass(this.options.classPrefix + "hue-panel").injectInside(this.colorpicker);
		this.hueCursor = new Element("span").injectInside(this.huePanel);
		
		// Setup saturation/value panel
		this.draggingSV = false;
		this.svDragOffset = 5;
		this.svPanel.addEvents({
			mousedown:(function() { this.draggingSV = true; }).bind(this),
			mouseup:(function() { this.draggingSV = false; }).bind(this),
			click:this._moveSV.bindWithEvent(this)
		});
		document.addEvent("mousemove", (function(event) { if(this.draggingSV) this._moveSV(event); }).bindWithEvent(this));
		document.addEvent("mouseup", (function() { this.draggingSV = false; }).bind(this));

		// Setup hue panel
		this.draggingH = false;
		this.hDragOffset = 2;
		this.huePanel.addEvents({
			mousedown:(function() { this.draggingH = true; }).bind(this),
			mouseup:(function() { this.draggingH = false; }).bind(this),
			click:this._moveH.bindWithEvent(this)
		});
		document.addEvent("mousemove", (function(event) { if(this.draggingH) this._moveH(event); }).bindWithEvent(this));
		document.addEvent("mouseup", (function() { this.draggingH = false; }).bind(this));

		document.addEvent("mousemove", (function(event) { this._mouse = event.page; }).bindWithEvent(this));

		this._updatePanelCoords();
	},
	
	/**
	 * PRIVATE: Updates the panel coordinates
	 * For performance reasons, we don't get these values everytime
	 * If the panels are hidden, the methos is run periodically
	 * until the coordinates are available
	 */
	_updatePanelCoords:function()
	{
		this.svPanelCoords = this.svPanel.getCoordinates();
		this.huePanelCoords = this.huePanel.getCoordinates();

		$clear(this._timer);

		if(this.svPanelCoords.width == 0) this._timer = this._updatePanelCoords.delay(100, this);
	},
	
	/**
	 * Panel mode only
	 * PUBLIC: shows color picker
	 */
	show:function()
	{
		if(!this.options.panelMode || this.state == "open") return;
		
		var pickerCoords = this.colorpicker.getCoordinates();
		var windowCoords = window.getSize();
		var left = this._mouse.x + 5;
		var top = this._mouse.y + 5;
		if(left + pickerCoords.width > windowCoords.size.x) left -= (pickerCoords.width + 10);
		if(top + pickerCoords.height > (windowCoords.scroll.y + windowCoords.size.y)) top -= (pickerCoords.height + 10);
		
		this.colorpicker.setStyles({
			visibility:"visible",
			top:top + "px",
			left:left + "px"
		});
		
		this.state = "open";

		this._updatePanelCoords();
	},
	
	/**
	 * Panel mode only
	 * PUBLIC: hides color picker
	 */
	hide:function()
	{
		if(!this.options.panelMode || this.state == "closed") return;

		this.colorpicker.setStyles({
			visibility:"hidden",
			top:0,
			left:0
		});
		
		this.state = "closed";
	},

	/**
	 * PUBLIC: sets the color in the color picker
	 * @param color a hexadecimal color code to load into the color picker (e.g. "#336699")
	 */
	setColor:function(color)
	{
		// Update selected color
		this.selectedColor = new Color($pick(color, "#000000"));
		
		// Get HSV values
		var hsv = this.selectedColor.rgbToHsb();
		
		// Update hue panel
		var topH = Math.round((360 - hsv[0]) / 360 * this.huePanelCoords.height);
		this.hueCursor.setStyle("top", topH - this.hDragOffset + "px");

		// Update saturation/value panel background
		$pick(this.ieSvPanel, this.svPanel).setStyle("background-color", new Color([hsv[0], 100, 100], "hsb"));
		
		// Updated saturation/value panel
		var topSV = Math.round((100 - hsv[2]) / 100 * this.svPanelCoords.height);
		var leftSV = Math.round(hsv[1] / 100 * this.svPanelCoords.width);
		this.svCursor.setStyles({
			top:topSV - this.svDragOffset + "px",
			left:leftSV - this.svDragOffset + "px"
		});
	},
	
	/**
	 * PUBLIC: links an element to the color picker
	 * The element can be an text input box or any other HTML element
	 * Attached input boxes are synched both ways with the color picker
	 * Any number of elements can be attached to the color picker (within reason)
	 * @param element id or reference to existing HTML element
	 * @param property (optional) css property to update with color value
	 */
	attach:function(element, property)
	{
		element = $(element);
		
		// If element doesn't exist, do nothing
		if(!element) return;

		// Create context
		var context = {
			colorPicker:this,
			element:element,
			property:property,
			storedValue:""
		};

		var fn, fn2;

		if(element.getTag() == "input" && element.getProperty("type").toLowerCase() == "text")
		{
			// The element is an input box, create update function for its value
			fn = function(color) {
				this.storedValue = this.element.value = color.toUpperCase();
			};
			
			// Also create a function for synching the other way
			fn2 = function() {
				var newValue = this.element.getValue();
				if(this.storedValue == newValue || !newValue.test(/#?[0-9a-f]{6}/i)) return;
				this.colorPicker.setColor(newValue);
				this.storedValue = newValue;
			};
			
			// Run this function every 500ms
			fn2.periodical(500, context);
		}
		else
		{
			// The element is a HTML element, create update function for the given property
			fn = function(color) { this.element.setStyle(this.property, color); };
		}
		
		// Attach event
		this.addEvent("selectColor", fn.bind(context));
	},
	
	/**
	 * PRIVATE: handles the saturation/value panel cursor movements
	 */
	_moveSV:function(event)
	{
		// Get relative mouse position
		var left = event.page.x - this.svPanelCoords.left;
		var top = event.page.y - this.svPanelCoords.top;

		// Constrain cursor within panel
		left = this._constrain(left, 0, this.svPanelCoords.width);
		top = this._constrain(top, 0, this.svPanelCoords.height);

		// Calculate new value and saturation values
		var value = Math.abs(100 - Math.round(top / this.svPanelCoords.height * 100));
		value = this._constrain(value, 0, 100);
		var saturation = Math.round(left / this.svPanelCoords.width * 100);
		saturation = this._constrain(saturation, 0, 100);

		// Adjust cursor position (to center mouse on cursor)
		top -= this.svDragOffset;
		left -= this.svDragOffset;

		// Move cursor
		this.svCursor.setStyles({
			top:top + "px",
			left:left + "px"
		});

		// Update color
		this.selectedColor = this.selectedColor.setBrightness(value);
		this.selectedColor = this.selectedColor.setSaturation(saturation);
		
		this._broadcastColorChange();
	},
	
	/**
	 * PRIVATE: handles the hue panel cursor movements
	 */
	_moveH:function(event)
	{
		// Get relative mouse position
		var left = event.page.x - this.huePanelCoords.left;
		var top = event.page.y - this.huePanelCoords.top;
		
		// Constrain cusor with panel
		top = this._constrain(top, 0, this.huePanelCoords.height-1);

		// Calculate new hue value
		var hue = Math.abs(360 - Math.round(top / (this.huePanelCoords.height-1) * 360));
		hue = this._constrain(hue, 0, 360);

		// Adjust cursor position
		top -= this.hDragOffset;
		
		// Move cursor
		this.hueCursor.setStyle("top", top + "px");
		
		// Update selected color
		this.selectedColor = this.selectedColor.setHue(hue);
		
		this._broadcastColorChange();
		
		// Update saturation/value panel background
		$pick(this.ieSvPanel, this.svPanel).setStyle("background-color", new Color([hue, 100, 100], "hsb"));
	},
	
	/**
	 * PRIVATE: broadcasts the selectColor event
	 */
	_broadcastColorChange:function()
	{
		this.fireEvent("selectColor", [this.selectedColor.rgbToHex().toUpperCase()]);
	},
	
	/**
	 * PRIVATE: helper function to constrain a value between to limits
	 * @param value the value to constrain
	 * @param from lower limit
	 * @param to higher limit
	 */
	_constrain:function(value, from, to)
	{
		if(value < from) return from;
		if(value > to) return to;
		return value;
	}
});

// Implement Events interface
MooColorPicker.implement(new Events);
MooColorPicker.implement(new Options);