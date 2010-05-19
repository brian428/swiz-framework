package org.swizframework.testable.module.control
{
	import flash.events.Event;
	
	import org.swizframework.controller.AbstractController;
	
	public class SimpleModuleController extends AbstractController
	{
		public static const CONTROLLER_CREATED : String = "simpleModuleControllerCreated";
		
		[Bindable]
		public var name : String;
		
		public function SimpleModuleController()
		{
			super();
		}
		
		[PostConstruct]
		public function postConstructHandler() : void
		{
			dispatcher.dispatchEvent( new Event( CONTROLLER_CREATED, true ) );
		}
	}
}