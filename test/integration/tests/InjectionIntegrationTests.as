package integration.tests
{
	import integration.application.control.SimpleController;
	import integration.application.view.SimpleCanvas;
	
	import org.flexunit.Assert;

	public class InjectionIntegrationTests extends BaseSwizIntegrationTest
	{

		[Test( async,ui )]
		public function testSwizInjectIntoView() : void
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Assert.assertTrue( "View component did not have controller injected by type: " + simpleCanvas.controller + " is not SimpleController", simpleCanvas.controller is SimpleController );
			Assert.assertTrue( "View component did not have controller injected by name", simpleCanvas.namedController is SimpleController );
		}
		
		[Test( async,ui )]
		public function testSwizBindingInjectIntoView() : void
		{
			var newName : String = "Some new controller name!";
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			simpleCanvas.controller.name = newName;
			Assert.assertTrue( "Injected property without binding was updated when it should not have been.", simpleCanvas.controllerName != newName );
			Assert.assertTrue( "Injected property with binding was not updated when it should have been.", simpleCanvas.bindingControllerName == newName );
			Assert.assertTrue( "Injected property with two-way binding was not updated when it should have been.", simpleCanvas.twoWayBindingControllerName == newName );
		}
		
		[Test(async,ui)]
		public function testSwizTwoWayBindingInjectIntoView() : void
		{
			var newName : String = "Some new controller name!";
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			
			simpleCanvas.controllerName = newName;
			Assert.assertTrue( "Changing injected property with no binding updated the controller property.", simpleCanvas.controller.name != newName );
			
			simpleCanvas.bindingControllerName = newName;
			Assert.assertTrue( "Changing injected property with one-way binding updated the controller property.", simpleCanvas.controller.name != newName );
			
			simpleCanvas.twoWayBindingControllerName = newName;
			Assert.assertTrue( "Changing injected property with two-way binding did not update the controller property.", simpleCanvas.controller.name == newName );
		}
	
	}
}