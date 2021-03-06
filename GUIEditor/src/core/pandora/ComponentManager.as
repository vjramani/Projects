package core.pandora 
{
	import core.XMLScriptInterpreter;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Vijay Venkatramani
	 */
	public class ComponentManager 
	{
		private static var rootElemIdCount:int = 0;
		
		private var ready:Boolean = false;
		private var classDefinitions:Dictionary = null;
		private var rootElements:Dictionary = null;
		
		public function ComponentManager() 
		{
			//if (!_s) throw("Attempting to instatiate Singleton class ComponentManager");
			
			PrimitiveOperations.InitOperations();
			classDefinitions = new Dictionary();
			rootElements = new Dictionary();
		}
		
		public function Load(_xml:XML):void
		{
			ready = false;
			
			var _rootDefinitions:Dictionary = new Dictionary();
			
			// run through all children and check for defines and calls
			var _nodes:Array = XMLScriptInterpreter.GetChildNodes(_xml);
			for each(var _node:XML in _nodes)
			{
				if (XMLScriptInterpreter.GetChildCount(_node) > 0)
				{
					classDefinitions[XMLScriptInterpreter.GetNodeName(_node)] = new ComponentClass(_node, this);
				}
				else
				{
					var _idName:String = XMLScriptInterpreter.GetNodeName(_node) + "_" + (++rootElemIdCount);
					//_rootDefinitions[XMLScriptInterpreter.GetNodeName(_node)] = new ComponentDefinition(_node, this);
					_rootDefinitions[_idName] = new ComponentDefinition(_node, this);
				}
			}
			
			ResolveClassDefinitions();
			CreateRootElements(_rootDefinitions);
			
			ready = true;
		}
		
		public function GetComponentClass(className:String):ComponentClass
		{
			if (className == null || classDefinitions[className] == null) return null;
			return classDefinitions[className];
		}
		
		public function GetObject(_id:String):ComponentObject
		{
			if (rootElements[_id] == undefined || rootElements[_id] == null) return null;
			return rootElements[_id];
		}
		public function GetElementList():Array
		{
			var _list:Array = new Array();
			for (var _k:String in rootElements)
			{
				_list.push(_k);
			}
			
			return _list;
		}
		
		private function CreateRootElements(_definitions:Dictionary):void 
		{
			// Loop through all the keys in rootElements and create all the Objects
			var _obj:ComponentObject = null;
			for each(var _def:ComponentDefinition in _definitions)
			{
				_obj = _def.GetClass().CreateComponent(_def.GetAttributes());
				rootElements[_obj.GetName()] = _obj;
			}
		}
		
		private function ResolveClassDefinitions():void 
		{
			// Loop through all class definitions and Resolve them
			for each(var _obj:ComponentClass in classDefinitions)
			{
				if(!_obj.IsResolved()) _obj.Resolve();
 			}
		}
		
		public function IsReady():Boolean
		{
			return ready;
		}
		
		public function CleanUp():void
		{
			
		}
	}
}
/*
class CompManagerSingletonBlocker
{
	
}
*/