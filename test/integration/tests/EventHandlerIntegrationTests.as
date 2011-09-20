package integration.tests
{
	import integration.application.event.SimpleTestEvent;
	import integration.application.view.SimpleCanvas;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	public class EventHandlerIntegrationTests extends BaseSwizIntegrationTest
	{

		[Test( async )]
		public function testSwizHandlesViewEvent() : void 
		{
			Async.handleEvent( this, dispatcher, SimpleTestEvent.GENERIC_EVENT_PROCESSED, compareEventDataToPassThroughEventName, LONG_TIME, {eventName:SimpleTestEvent.GENERIC_EVENT} ); 
			rootContainer.dispatchEvent( createSimpleTestEvent( SimpleTestEvent.GENERIC_EVENT, SimpleTestEvent.GENERIC_EVENT ) );
		}
		
		[Test( async,ui )]
		public function testSwizHandlesChildViewEvent() : void
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Async.handleEvent( this, dispatcher, SimpleTestEvent.GENERIC_EVENT_PROCESSED, compareEventDataToPassThroughEventName, LONG_TIME, {eventName:SimpleTestEvent.GENERIC_EVENT} ); 	
			simpleCanvas.dispatchSimpleEvent();
		}
		
		protected function compareEventDataToPassThroughEventName( event : SimpleTestEvent, passThroughData : Object ) : void
		{
			Assert.assertTrue( "Event's data property does not match the passThroughData.eventName", event.data == passThroughData.eventName );
		}
		
		[EventHandler( event="SimpleTestEvent.GENERIC_EVENT", properties="data" )]
		public function genericEventHandler( data : Object ) : void 
		{
			dispatcher.dispatchEvent( createSimpleTestEvent( SimpleTestEvent.GENERIC_EVENT_PROCESSED, data ) );
		}
		
		protected function createSimpleTestEvent( eventName : String, data : Object = null ) : SimpleTestEvent
		{
			var newEvent : SimpleTestEvent = new SimpleTestEvent( eventName );
			newEvent.data = data;
			return newEvent;
		}
	
	}
}