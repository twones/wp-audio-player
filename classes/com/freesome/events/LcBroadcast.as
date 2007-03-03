
/**
* Allows simple broadcasting (sending to multiple movies)
* @author	Pete Hobson
* @version	1.0 
*/
class com.freesome.events.LcBroadcast 
{

	/**
	* Will be true if this object is the Master LcBroadcast object.  All others will be clients
	* and route broadcasts through the master.
	*/
	public var isMaster:Boolean;
	
	/**
	* A unique identifier for this object.  Each instance will be different, and only
	* one shall be the value "_MASTER" 
	*/
	public var internalID:String;
	
	/**
	* Version number.  this is broadcast as a field in the onInit setup - the hope is
	* to allow backwards compatability between versions.
	*/	
	public var LCBversion:String = "1.0.1"
	
	private var _toMaster:LocalConnection;
	private var _fromMaster:LocalConnection;
	private var _clientsList:Array;
	private var _LCtimer:Number;
	private var _master:String;
	
	/**
	* Add an event listener to this instance
	*/
	public var addListener:Function;
	
	/**
	* Remove an already registered event listener from this object
	*/
	public var removeEventListener:Function;

	private var broadcastMessage:Function;
	
	/**
	* Constructor
	* @param	var classID - 
	* 
	* <p>
	* a Unique identifier for your group of LcBroadcasts which you want to communicate together.  
	* Specifying a value here will allow other movies who use LcBroadcast in unrelated applications
	* To ignore your calls.
	* 
	* In order to ensure a unique ID it is recommended to use a java style package string such as
	* 
	* LcBroadcast("com.yourwebsite.yourapplication");
	* </p>
	* 
	* 
	*/
	function LcBroadcast(var classID:String)
	{
		//Add underscore to connection name
		_master = "_"+classID;
		//Set up a broadcaster
		AsBroadcaster.initialize(this);	
		//Set up a slight delay to avoid deadlocks
		_LCtimer = setInterval( this, "_pollmaster", random(500)+500, "interval function called" ); 
	
	}	
	
	/**
	* Boradcast a message to all copies of LcBroadcast running on the local machine.
	* Internaly  uses localconnection, so copies may be in differnt browsers or standalone
	* applications.
	* 
	* @param	ob - object to be broadcast 
	* @usage  <pre>
	* my_lcb = new LcBroadcast();
	* my_lcb.broadcast({msg:"hello"});
	*/
	public function broadcast(ob:Object) {
		
		if (isMaster)
			_receiveMessageMaster(ob);
		else {
			var lc:LocalConnection = new LocalConnection();
			if (lc.connect(_master)) {

				this._makeMeMaster();
			}
			_toMaster.send(_master,"receiveMessageMaster",ob);
		}
	}
	
	/**
	* Find out if this instance is the first created instance
	* if so we are "master" a special instance used to relay messages
	*/
	private function _pollmaster() {

		
		//initalise a new local connection
		_toMaster = new LocalConnection();
		_toMaster["LCB"] = this;
		
		//if we can not connect as master, we must be a client
		if (!_toMaster.connect(_master) ) {			
			_registerWithMaster();
		} else {
				//clear polling timer
				clearInterval(_LCtimer);
			_makeMeMaster();
		}
		
	}
	
	/* Master functions */
	
	/**
	* Makes the cyrrent instnce the master
	*/
	private function _makeMeMaster():Void{
		
		this.isMaster = true;
		this.internalID = this._master;
		_clientsList = new Array();
		
		_toMaster.registerClient= function(ob:Object) {this["LCB"]._registerClient(ob)};
		_toMaster.receiveMessageMaster = function (ob:Object) {this["LCB"]._receiveMessageMaster(ob);};
		this.broadcastMessage("onInit",{isMaster:this.isMaster,LCBversion:LCBversion});	
		
	}
	/**
	* Adds the client to the client list
	* @param	ob.id  id of client
	*/
	private function _registerClient(ob:Object) {
		var lc:LocalConnection;
		lc = new LocalConnection();

		_clientsList[ob.id] = true;
		lc.send(ob.id,"recieveClientList",_clientsList);	
		
		//echo to all clients
		for( var i in _clientsList ) {
			
			var id:String = _clientsList[i];
			
			lc.send(id,"newClient",ob);			
		}	
		
	}
	
	/**
	* All clients will broadcast to this method of the master
	* @param	ob - messsage
	*/
	private function _receiveMessageMaster(ob:Object) {
		
		//echo to all clients
		for( var id in _clientsList ) {
			var lc:LocalConnection;
			
			lc = new LocalConnection();
			lc.send(id,"receiveMessageFromMaster",ob);			
		}	
		//echo to master
		this.broadcastMessage("onBroadcast",ob);
		
	}
	
	/* Client functions */
	
	/**
	* inform the master of the existence of a new client
	*/
	
	private function _registerWithMaster():Void {
		this.isMaster = false;
		if (this.internalID == undefined) {
			var id:String
			_fromMaster = new LocalConnection();
			_fromMaster["LCB"]=this;
			_fromMaster.receiveMessageFromMaster= function (ob:Object) {this["LCB"]._receiveMessageFromMaster(ob);}; 
			_fromMaster.newClient= function (ob:Object) {this["LCB"]._newClient(ob);};
			_fromMaster.recieveClientList= function (ob:Object) {this["LCB"]._recieveClientList(ob);};
			_fromMaster.onStatus= function (ob:Object) {this["LCB"]._onStatus(ob);};
			//keep assiging a random id until we have an unused one
			do {
				id =  "_LcBroadcast"+"_"+random(5000000);
			} while (!_fromMaster.connect(id));
			this.internalID = id;
			this.broadcastMessage("onInit",{isMaster:this.isMaster, LCBversion:LCBversion});
		}
	
		
		//register with master
		_toMaster.send(_master,"registerClient",{id:this.internalID});
		
		
	}
	private function _onStatus(infoObject:Object) {
		if (infoObject.level == "error") {
			this.broadcastMessage("onInit",{msg:"error"});
		}
	}
	private function _newClient (ob:Object):Void {
		if (ob.id != this.internalID)
			_clientsList[ob.id] = true;
		this.broadcastMessage("onInit",{msg:"_newClient:"+_clientsList.length});
	}
	private function _recieveClientList(cl:Array) {
		_clientsList = cl;
	}
	
	/**
	* Recives a bradcast from the master
	* @param	ob
	*/
	private  function _receiveMessageFromMaster(ob:Object) {
		this.broadcastMessage("onBroadcast",ob);
	}
	
}
