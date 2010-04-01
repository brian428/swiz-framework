package org.swizframework.core
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.fluint.sequence.*;
	import org.fluint.uiImpersonation.*;
	import org.swizframework.AbstractSwizFrameworkTest;
	import org.swizframework.core.*;
	import org.swizframework.testable.control.SimpleController;
	import org.swizframework.testable.event.SimpleTestEvent;
	import org.swizframework.testable.view.SimpleCanvas;
	
	public class SwizTest extends AbstractSwizFrameworkTest
	{
		
		[Test(async)]
		public function testSwizDispatcherSet() : void 
		{
			Assert.assertTrue( "Swiz does not have correct dispatcher instance", swiz.dispatcher == ui );	
		}
		
		[Test(async)]
		public function testSwizMediatesViewEvent() : void 
		{
			Async.handleEvent( this, ui, SimpleTestEvent.GENERIC_RESULT_EVENT, compareEventDataToPassThroughEventName, LONG_TIME, {eventName:SimpleTestEvent.GENERIC_EVENT} ); 
			ui.dispatchEvent( createSimpleTestEvent( SimpleTestEvent.GENERIC_EVENT, SimpleTestEvent.GENERIC_EVENT ) );
		}
		
		[Test(async,ui)]
		public function testSwizMediatesChildViewEvent() : void
		{
			var simpleCanvas : SimpleCanvas = new SimpleCanvas();
			Async.handleEvent( this, ui, SimpleTestEvent.GENERIC_RESULT_EVENT, compareEventDataToPassThroughEventName, LONG_TIME, {eventName:SimpleTestEvent.GENERIC_EVENT} ); 
			UIImpersonator.addChild( simpleCanvas );		
			simpleCanvas.dispatchSimpleEvent();
		}
		
		[Test(async,ui)]
		public function testSwizInjectIntoView() : void
		{
			var simpleCanvas : SimpleCanvas = new SimpleCanvas();
			Async.handleEvent( this, simpleCanvas, Event.ADDED_TO_STAGE, checkInject, LONG_TIME, {component:simpleCanvas} ); 
			UIImpersonator.addChild( simpleCanvas );		
		}
		
		[Test(async)]
		public function testSwizIDispatcherAware() : void 
		{
			Assert.assertTrue( "Controller implementing IDispatcherAware does not have correct dispatcher instance", SimpleController( Bean( swiz.beanFactory.getBeanByName( "simpleController" ) ).source ).dispatcher == ui );	
		}
		
		[Test(async)]
		public function testSwizISwizAware() : void 
		{
			Assert.assertTrue( "Controller implementing ISwizAware does not have correct Swiz instance", SimpleController( Bean( swiz.beanFactory.getBeanByName( "simpleController" ) ).source )._swiz == swiz );	
		}
		
		protected function checkInject( event : Event, passThroughData : Object ) : void
		{
			Assert.assertTrue( "View component did not have controller injected by type", SimpleCanvas( passThroughData.component ).controller is SimpleController );
			Assert.assertTrue( "View component did not have controller injected by name", SimpleCanvas( passThroughData.component ).namedController is SimpleController );
			Assert.assertTrue( "Controller name property was not correctly set during [PostConstruct]", SimpleCanvas( passThroughData.component ).controller.name == SimpleController.CONTROLLER_NAME );
			Assert.assertTrue( "View component did not have outjected controller property injected", SimpleCanvas( passThroughData.component ).controllerName == SimpleController.CONTROLLER_NAME );
			Assert.assertTrue( "View component did not have controller property injected into Canvas label property", SimpleCanvas( passThroughData.component ).label == SimpleController.CONTROLLER_NAME );
		}
		
		protected function compareEventDataToPassThroughEventName( event : SimpleTestEvent, passThroughData : Object ) : void
		{
			Assert.assertTrue( "Event's data property does not match the passThroughData.eventName", event.data == passThroughData.eventName );
		}
		
		[Mediate( event="SimpleTestEvent.GENERIC_EVENT", properties="data" )]
		public function genericMediatorWithData( data : Object ) : void 
		{
			ui.dispatchEvent( createSimpleTestEvent( SimpleTestEvent.GENERIC_RESULT_EVENT, data ) );
		}
		
		protected function createSimpleTestEvent( eventName : String, data : Object = null ) : SimpleTestEvent
		{
			var newEvent : SimpleTestEvent = new SimpleTestEvent( eventName );
			newEvent.data = data;
			return newEvent;
		}
		
	}
}