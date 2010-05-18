package org.swizframework.core.mxml
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.events.FlexEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.fluint.sequence.*;
	import org.fluint.uiImpersonation.*;
	import org.swizframework.core.*;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.testable.RootContainer;
	import org.swizframework.testable.control.SimpleController;
	import org.swizframework.testable.event.SimpleTestEvent;
	import org.swizframework.testable.view.SimpleCanvas;
	
	public class SwizTest
	{
		protected static var LONG_TIME:int = 500;
		private var rootContainer : RootContainer;
		private var testBean : Bean;
		
		[Before(async,ui)]
		public function createRootContainer() : void
		{
			rootContainer = new RootContainer();
			Async.proceedOnEvent( this, rootContainer, Event.ADDED_TO_STAGE, LONG_TIME );
			UIImpersonator.addChild( rootContainer );
			createBeanForTest();
		}
		
		[After(async,ui)]
		public function destroyRootContainer() : void
		{
			UIImpersonator.removeAllChildren();
			rootContainer.mySwiz.beanFactory.tearDownBean( testBean );
			rootContainer = null;
		}
		
		[Test(async)]
		public function testSwizDispatcherSet() : void 
		{
			Assert.assertTrue( "Swiz does not have correct dispatcher instance", rootContainer.mySwiz.dispatcher == rootContainer );	
		}
		
		[Test(async)]
		public function testSwizMediatesViewEvent() : void 
		{
			Async.handleEvent( this, rootContainer, SimpleTestEvent.GENERIC_RESULT_EVENT, compareEventDataToPassThroughEventName, LONG_TIME, {eventName:SimpleTestEvent.GENERIC_EVENT} ); 
			rootContainer.dispatchEvent( createSimpleTestEvent( SimpleTestEvent.GENERIC_EVENT, SimpleTestEvent.GENERIC_EVENT ) );
		}
		
		[Test(async,ui)]
		public function testSwizMediatesChildViewEvent() : void
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Async.handleEvent( this, rootContainer, SimpleTestEvent.GENERIC_RESULT_EVENT, compareEventDataToPassThroughEventName, LONG_TIME, {eventName:SimpleTestEvent.GENERIC_EVENT} ); 	
			simpleCanvas.dispatchSimpleEvent();
		}
		
		[Test(async,ui)]
		public function testSwizInjectIntoView() : void
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Assert.assertTrue( "View component did not have controller injected by type", simpleCanvas.controller is SimpleController );
			Assert.assertTrue( "View component did not have controller injected by name", simpleCanvas.namedController is SimpleController );
			Assert.assertTrue( "Controller name property was not correctly set during [PostConstruct]", simpleCanvas.controller.name == SimpleController.CONTROLLER_NAME );
			Assert.assertTrue( "View component did not have outjected controller property injected", simpleCanvas.controllerName == SimpleController.CONTROLLER_NAME );
			Assert.assertTrue( "View component did not have controller property injected into Canvas label property", simpleCanvas.label == SimpleController.CONTROLLER_NAME );	
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
		
		protected function compareEventDataToPassThroughEventName( event : SimpleTestEvent, passThroughData : Object ) : void
		{
			Assert.assertTrue( "Event's data property does not match the passThroughData.eventName", event.data == passThroughData.eventName );
		}
		
		[Mediate( event="SimpleTestEvent.GENERIC_EVENT", properties="data" )]
		public function genericMediatorWithData( data : Object ) : void 
		{
			rootContainer.dispatchEvent( createSimpleTestEvent( SimpleTestEvent.GENERIC_RESULT_EVENT, data ) );
		}
		
		protected function createSimpleTestEvent( eventName : String, data : Object = null ) : SimpleTestEvent
		{
			var newEvent : SimpleTestEvent = new SimpleTestEvent( eventName );
			newEvent.data = data;
			return newEvent;
		}
		
		protected function createBeanForTest() : void
		{
			var swiz : org.swizframework.core.mxml.Swiz = rootContainer.mySwiz;
			
			// wrap the unit test in a Bean definition
			testBean = new Bean();
			testBean.source = this;
			testBean.typeDescriptor = TypeCache.getTypeDescriptor( testBean.type, swiz.domain );
			
			// autowire test case with bean factory
			swiz.beanFactory.setUpBean( testBean );
		}
		
	}
}