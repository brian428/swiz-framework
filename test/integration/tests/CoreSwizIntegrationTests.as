package integration.tests
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import integration.application.control.SimpleController;
	import integration.application.event.SimpleTestEvent;
	import integration.application.view.SimpleCanvas;
	
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.fluint.sequence.*;
	import org.fluint.uiImpersonation.*;
	import org.swizframework.core.*;
	
	public class CoreSwizIntegrationTests extends BaseSwizIntegrationTest
	{

		[Test( async )]
		public function testSwizDispatcherSet() : void 
		{
			Assert.assertTrue( "Swiz does not have correct dispatcher instance.", dispatcher == rootContainer );	
		}
		
		[Test(async)]
		public function testSwizIDispatcherAware() : void 
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Assert.assertTrue( "Controller implementing IDispatcherAware does not have correct dispatcher instance", simpleCanvas.controller.dispatcher is IEventDispatcher );	
		}
		
		[Test(async)]
		public function testSwizISwizAware() : void 
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Assert.assertTrue( "Controller implementing ISwizAware does not have correct Swiz instance", simpleCanvas.controller._swiz is ISwiz );	
		}
		
		[Test( async,ui )]
		public function testViewAddedMetadata() : void
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Assert.assertTrue( "View was not injected into Controller.", simpleCanvas.controller.view == simpleCanvas );
		}
		
		[Test( async,ui )]
		public function testViewRemovedMetadata() : void
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Async.handleEvent( this, simpleCanvas.controller, PropertyChangeEvent.PROPERTY_CHANGE, verifyViewRemoved, LONG_TIME, {controller:simpleCanvas.controller} ); 
			rootContainer.removeElement( simpleCanvas );
		}
		
		protected function verifyViewRemoved( event : Event, passThroughData : Object ) : void
		{
			Assert.assertTrue( "View was not removed from Controller.", passThroughData.controller.view == null );
		}
		
	}
}