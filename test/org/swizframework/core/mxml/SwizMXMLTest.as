package org.swizframework.core.mxml
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.core.Container;
	import mx.events.FlexEvent;
	import mx.events.ModuleEvent;
	import mx.modules.Module;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.fluint.sequence.*;
	import org.fluint.uiImpersonation.*;
	import org.swizframework.core.*;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.testable.RootContainer;
	import org.swizframework.testable.control.SimpleController;
	import org.swizframework.testable.event.SimpleTestEvent;
	import org.swizframework.testable.module.RootModuleContainer;
	import org.swizframework.testable.module.control.SimpleModuleController;
	import org.swizframework.testable.module.event.SimpleModuleEvent;
	import org.swizframework.testable.module.view.SimpleModuleCanvas;
	import org.swizframework.testable.view.SimpleCanvas;
	
	public class SwizMXMLTest
	{
		[Dispatcher]
		public var dispatcher : IEventDispatcher;
		
		protected static var LONG_TIME:int = 5000;
		private var rootContainer : RootContainer;
		private var testBean : Bean;
		
		[Before(async,ui)]
		public function createRootContainer() : void
		{
			// Stop the root container from removing and adding the children, which causes the Swiz dispatcher to get torn down before we can even work with it. x-(
			var env : IVisualTestEnvironment = VisualTestEnvironmentBuilder.getInstance().buildVisualTestEnvironment();
			Container( env ).clipContent = false;
			
			rootContainer = new RootContainer();
			Async.proceedOnEvent( this, rootContainer, Event.ADDED_TO_STAGE, LONG_TIME );
			UIImpersonator.addChild( rootContainer );
			createBeanForTest();
		}
		
		[After(async,ui)]
		public function destroyRootContainer() : void
		{
			Async.proceedOnEvent( this, rootContainer, Event.REMOVED_FROM_STAGE, LONG_TIME );
			UIImpersonator.removeAllChildren();
			rootContainer = null;
		}
		
		[Test(async)]
		public function testSwizDispatcherSet() : void 
		{
			Assert.assertTrue( "Swiz does not have correct dispatcher instance.", dispatcher is IEventDispatcher );	
		}
		
		[Test(async)]
		public function testSwizMediatesViewEvent() : void 
		{
			Async.handleEvent( this, dispatcher, SimpleTestEvent.GENERIC_RESULT_EVENT, compareEventDataToPassThroughEventName, LONG_TIME, {eventName:SimpleTestEvent.GENERIC_EVENT} ); 
			rootContainer.dispatchEvent( createSimpleTestEvent( SimpleTestEvent.GENERIC_EVENT, SimpleTestEvent.GENERIC_EVENT ) );
		}
		
		[Test(async,ui)]
		public function testSwizMediatesChildViewEvent() : void
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Async.handleEvent( this, dispatcher, SimpleTestEvent.GENERIC_RESULT_EVENT, compareEventDataToPassThroughEventName, LONG_TIME, {eventName:SimpleTestEvent.GENERIC_EVENT} ); 	
			simpleCanvas.dispatchSimpleEvent();
		}
		
		[Test(async,ui)]
		public function testSwizInjectIntoView() : void
		{
			var simpleCanvas : SimpleCanvas = rootContainer.simpleCanvas;
			Assert.assertTrue( "View component did not have controller injected by type", simpleCanvas.controller is SimpleController );
			Assert.assertTrue( "View component did not have controller injected by name", simpleCanvas.namedController is SimpleController );
			//Assert.assertTrue( "View component did not have controller property injected into destination Canvas label property", simpleCanvas.label == SimpleController.CONTROLLER_NAME );	
		}
		
		[Test(async,ui)]
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
		
		[Test(async)]
		public function testSwizBeanInModule() : void 
		{
			Async.handleEvent( this, rootContainer, RootContainer.MODULE_ADDED, testModuleBean, LONG_TIME, null );
			rootContainer.loadTestModule();
		}
		
		[Test(async)]
		public function testModuleMediatesModuleEventInModuleRoot() : void 
		{
			Async.handleEvent( this, dispatcher, SimpleModuleEvent.MODULE_EVENT_COMPLETE, testModuleMediatedModuleEvent, LONG_TIME, null ); 
			rootContainer.loadTestModule();
		}
		
		[Test(async)]
		public function testModuleMediatesParentApplicationEvent() : void 
		{
			Async.handleEvent( this, rootContainer, RootContainer.MODULE_ADDED, testModuleMediatedParentApplicationEvent, LONG_TIME, null ); 
			rootContainer.loadTestModule();
		}
		
		protected function testModuleBean( event : Event, passThroughData : Object ) : void
		{
			var bean : Bean = RootModuleContainer( rootContainer.testModuleLoader.child ).mySwiz.beanFactory.getBeanByType( SimpleController );
			var moduleCanvas : SimpleModuleCanvas = RootModuleContainer( rootContainer.testModuleLoader.child ).simpleModuleCanvas;
			
			Assert.assertTrue( "Bean loaded in module cannot load bean from parent application.", bean.source is SimpleController );
			Assert.assertTrue( "View component in module did not have parent application bean injected by type", moduleCanvas.controller is SimpleController );
			Assert.assertTrue( "View component in module did not have parent application bean injected by name", moduleCanvas.namedController is SimpleController );
			
			rootContainer.removeTestModule();
		}
		
		protected function testModuleMediatedParentApplicationEvent( event : Event, passThroughData : Object ) : void
		{
			var mediateWorked : Boolean = RootModuleContainer( rootContainer.testModuleLoader.child ).parentAppEventMediatorRan;
			Assert.assertTrue( "Module root container did not mediate parent application event.", mediateWorked );
			rootContainer.removeTestModule();
		}
		
		protected function testModuleMediatedModuleEvent( event : Event, passThroughData : Object ) : void
		{
			var mediateWorked : Boolean = RootModuleContainer( rootContainer.testModuleLoader.child ).moduleEventMediatorRan;
			Assert.assertTrue( "Module root container did not mediate module-specific event.", mediateWorked );
			rootContainer.removeTestModule();
		}
		
		protected function compareEventDataToPassThroughEventName( event : SimpleTestEvent, passThroughData : Object ) : void
		{
			Assert.assertTrue( "Event's data property does not match the passThroughData.eventName", event.data == passThroughData.eventName );
		}
		
		[Mediate( event="SimpleTestEvent.GENERIC_EVENT", properties="data" )]
		public function genericMediatorWithData( data : Object ) : void 
		{
			dispatcher.dispatchEvent( createSimpleTestEvent( SimpleTestEvent.GENERIC_RESULT_EVENT, data ) );
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