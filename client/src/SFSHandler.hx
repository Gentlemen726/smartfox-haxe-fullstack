package;
import com.smartfoxserver.v2.SmartFox;
import com.smartfoxserver.v2.core.SFSEvent;
import Commands;
import Move;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.requests.ExtensionRequest;
import com.smartfoxserver.v2.requests.LeaveRoomRequest;
import com.smartfoxserver.v2.requests.LoginRequest;
import tools.SFSObjectTool;
/**
 * ...
 * @author vincent blanchet
 */
class SFSHandler
{
	var sfs:SmartFox;
	public var onMove:Move->Void;
	public var onTurn:Int->String->Void;
	public var onReady:StartState->Void;
	//public var onEnd:EndResult->Void;
	public var currentTurn:String;
	public var currentTurnId:Int;
	public var me(get, null):com.smartfoxserver.v2.entities.SFSUser;
	public function new() 
	{

	}
	
	private function onUserExit(e:SFSEvent):Void 
	{
		#if html5
		trace("User disconnected :" + e.user.name);
		#else
		trace("User disconnected :" + e.params.user.name);
		#end
	}
	
	private function run(e:SFSEvent):Void 
	{
		trace("on extension response");
		var extParams:SFSObject = #if html5 e.params #else e.params.params #end;
		#if html5
		switch(e.cmd)
		#else
		switch(e.params.cmd)
		#end
		{
			case Commands.TURN :
				#if html5
				currentTurn = extParams.name;
				currentTurnId = extParams.id;
				#else
				currentTurn = extParams.getUtfString("name");
				currentTurnId = extParams.getInt("id");
				#end
				trace('it is $currentTurn\'s turn');
				if (onTurn != null)
					onTurn(currentTurnId,currentTurn);
					
			case Commands.MOVE :
				var move : Move = SFSObjectTool.sfsObjectToInstance(extParams);

				if (onMove != null)
					onMove(move);
					
			case Commands.READY :
				//server is ready		
				var startState:StartState = SFSObjectTool.sfsObjectToInstance(extParams);

				if (onReady != null)
					onReady(startState);
					
		}
	}
	
	public function move(move:Move):Void{
		sfs.send(new ExtensionRequest(Commands.MOVE, SFSObjectTool.instanceToSFSObject(move)));
	}
	/**
	 * player is ready
	 */
	public function ready():Void{
		sfs.send(new ExtensionRequest(Commands.READY));
	}
	
	public function leaveGame():Void
	{
		sfs.send(new LeaveRoomRequest());
	}
	
	public function play():Void
	{
		sfs.send(new ExtensionRequest(Commands.PLAY));
	}
	
	
	public function connect():Void
	{
		#if !html5 
		var config:com.smartfoxserver.v2.util.ConfigData = new com.smartfoxserver.v2.util.ConfigData();
		config.httpPort = 8080;
		config.useBlueBox = false;
		#else
		var config:com.smartfoxserver.v2.SmartFox.ConfigObj = {host:"",port:0,useSSL:false,zone:"",debug:true};
		#end
		config.debug = true;
		config.host = "127.0.0.1";
		config.port = #if web 8888 #else 9933 #end;
		config.zone = "Haxe";
		#if html5
		sfs = new com.smartfoxserver.v2.SmartFox(config);
		#else
		sfs = new com.smartfoxserver.v2.SmartFox(true);
		#end
		sfs.addEventListener(SFSEvent.CONNECTION, onConnection #if html5 ,this #end);
		sfs.addEventListener(SFSEvent.SOCKET_ERROR, onSocketError #if html5 ,this #end);
		sfs.addEventListener(SFSEvent.LOGIN_ERROR, onSocketError #if html5 ,this #end);
		sfs.addEventListener(SFSEvent.ROOM_CREATION_ERROR, onSocketError #if html5 ,this #end);
		sfs.addEventListener(SFSEvent.ROOM_JOIN_ERROR, onSocketError #if html5 , this #end);
		sfs.addEventListener(SFSEvent.USER_EXIT_ROOM, onUserExit #if html5 , this #end);
		sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, run #if html5 , this #end);
		sfs.addEventListener(SFSEvent.CONNECTION_LOST, onConnectionLost #if html5 , this #end);
		trace("config:" + config);
		try{
		#if html5
		sfs.connect();
		#else
		sfs.connectWithConfig(config);
		#end
		}catch (e:Dynamic){
			trace(e+" " + haxe.CallStack.toString( haxe.CallStack.exceptionStack()));
		}
	}
	
	private function onConnectionLost(e:SFSEvent):Void 
	{
		trace("Connection lost!!!");
	}
	
	private function onLogin(e:SFSEvent):Void 
	{
		play();
	}
	
	private function onConnection(e:SFSEvent):Void 
	{
		#if html5
		if (e.success)
		#else
		if (e.params.success)
		#end
		{
			sfs.addEventListener(SFSEvent.LOGIN, onLogin #if html5 ,this #end);
			sfs.send(new LoginRequest("", "", "Haxe"));
		}else{
			trace("Not connected to internet");
		}
	}
	
	private function onSocketError(e:SFSEvent):Void 
	{
		trace("socket error:" + e.params);
	}
	
	public function isAvailable():Bool
	{
		#if html5
		return sfs.isConnected();
		#else
		return sfs.isConnected;
		#end
	}
	
	public function destroy():Void
	{
		sfs.removeEventListener(SFSEvent.CONNECTION, onConnection);
		sfs.removeEventListener(SFSEvent.SOCKET_ERROR, onSocketError);
		sfs.removeEventListener(SFSEvent.LOGIN_ERROR, onSocketError);
		sfs.removeEventListener(SFSEvent.ROOM_CREATION_ERROR, onSocketError);
		sfs.removeEventListener(SFSEvent.ROOM_JOIN_ERROR, onSocketError);
		sfs.removeEventListener(SFSEvent.USER_EXIT_ROOM, onUserExit);
		sfs.removeEventListener(SFSEvent.EXTENSION_RESPONSE, run);
		sfs.removeEventListener(SFSEvent.CONNECTION_LOST, onConnectionLost);
	}
	
	function get_me():com.smartfoxserver.v2.entities.SFSUser 
	{
		return cast sfs.mySelf;
	}
	
	
}