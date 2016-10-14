package tools;
import com.smartfoxserver.v2.entities.data.SFSObject;
import haxe.Serializer;
import haxe.Unserializer;
/**
 * Serialization unserialization tools
 * @author vincent blanchet
 */
class SFSObjectTool
{
	public static function instanceToSFSObject(obj:Dynamic):#if html5 Dynamic #else SFSObject#end
	{
		if (obj == null)
			return null;
		
			
		var s = new Serializer();
		s.serialize(obj);
		#if html5 
		var sfsObj = {obj:s.toString()};
		#else
		var sfsObj = new SFSObject();
		sfsObj.putUtfString("obj", s.toString() );
		#end
		return sfsObj;
	}
	
	public static function sfsObjectToInstance(sfsObj:SFSObject):Dynamic
	{
		var res:Dynamic = null;
		if (sfsObj == null)
			return null;
			
		var so = #if html5 sfsObj.obj #else sfsObj.getUtfString("obj")#end;
		if (so == null)
			return null;
		try{
		var s = new Unserializer(so);
		
		res = s.unserialize();
		}catch (e:Dynamic){
			trace(e);
			trace(sfsObj.getDump());
			return null;
		}
		return res;
	}
}