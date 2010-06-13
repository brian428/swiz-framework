package org.swizframework.testable.module.control
{
	import flash.events.Event;
	
	import org.swizframework.controller.AbstractController;
	
	public class SimpleModuleController extends AbstractController
	{
		public static const MODULE_SETUP_COMPLETE : String = "simpleModuleSetUpComplete";
		public static const CONTROLLER_EVENT : String = "simpleModuleControllerEvent";
		
		[Bindable]
		public var name : String;
		
		public function SimpleModuleController()
		{
			super();
		}
		
	}
}