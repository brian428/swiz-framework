package org.swizframework.testable.module.control
{
	import flash.events.Event;
	
	import org.swizframework.controller.AbstractController;
	
	public class SimpleModuleController extends AbstractController
	{
		
		[Bindable]
		public var name : String;
		
		public function SimpleModuleController()
		{
			super();
		}
		
	}
}