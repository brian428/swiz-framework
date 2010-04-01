package org.swizframework.testable.control
{
	import org.swizframework.controller.AbstractController;
	
	public class SimpleController extends AbstractController
	{
		public static const CONTROLLER_NAME : String = "A Simple Controller";
		
		[Bindable]
		public var name : String;
		
		public function SimpleController()
		{
			super();
		}
		
		[PostConstruct]
		public function postConstructHandler() : void
		{
			name = CONTROLLER_NAME;
		}
	}
}