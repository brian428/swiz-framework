package org.swizframework.core
{
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	import mx.core.Container;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.fluint.sequence.*;
	import org.fluint.uiImpersonation.*;
	import org.swizframework.core.*;
	import org.swizframework.events.SwizEvent;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.testable.control.SimpleController;
	import org.swizframework.testable.event.SimpleTestEvent;
	import org.swizframework.testable.view.SimpleCanvas;
	
	public class SwizTest
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
		
		protected static var LONG_TIME:int = 500;
		
		protected var swiz : Swiz;
		protected var ui : Container;
		
		[Before(async)]
		public function setUp() : void 
		{
			createUI();
			Async.proceedOnEvent( this, ui, SwizEvent.CREATED, LONG_TIME );
			createSwiz();
		}
		
		[After(async,ui)]
		public function tearDown() : void 
		{
			destroySwiz();	
		}
		
		/**
		 * Create the UI container that will hold display objects and act as the Swiz dispatcher
		 */
		protected function createUI() : void
		{
			var envBuilder : VisualTestEnvironmentBuilder = VisualTestEnvironmentBuilder.getInstance();
			ui = envBuilder.buildVisualTestEnvironment() as Container;
		}
		
		protected function createSwiz() : void
		{
			swiz  = new Swiz();
			swiz.beanProviders = [];
			setSwizDispatcher();
			createSwizConfig();
			createBeansForTest();
			swiz.init();
		}
		
		/**
		 * Assign a dispatcher to the Swiz instance for this test. Override if necessary in child test cases.
		 */ 
		protected function setSwizDispatcher() : void
		{
			swiz.dispatcher = ui;	
		}
		
		/**
		 * Create the SwizConfig for this test. Override if necessary in child test cases.
		 */
		protected function createSwizConfig() : void
		{
			swiz.config = new SwizConfig();
			swiz.config.eventPackages = ['org.swizframework.testable.event.*'];
			swiz.config.viewPackages = ['org.swizframework.testable.view.*'];	
		}
		
		/**
		 * Create Beans and BeanProviders for this test. Override if necessary in child test cases.
		 */
		protected function createBeansForTest() : void
		{
			createSwizBean( this, 'currentTest' );
			createSwizBean( SimpleController, 'simpleController' );
		}
		
		
		/**
		 * Create a Swiz Bean, initialize it, and add it to Swiz through a new BeanProvider. 
		 * @param source Object to use as the source for the Bean. If this is a Class reference, a new instance of that class will be created and used as the Bean source.
		 * @param name The name for the new Bean.
		 * @return Returns the newly-created Bean instance.
		 * 
		 */
		protected function createSwizBean( source : Object, name : String ) : Bean
		{
			var sourceInstance : Object = source;
			
			// if the source is a class reference, create a new instance of the class.
			if( sourceInstance is Class )
			{
				var sourceClass : Class = sourceInstance as Class;
				sourceInstance = new sourceClass();
			}
			
			// wrap the source in a Bean definition
			var bean:Bean = new Bean();
			bean.source = sourceInstance;
			bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.type, ApplicationDomain.currentDomain );
			bean.name = name;
			
			// initialize bean to trigger inject, register mediators, etc.
			if( swiz.beanFactory )
			{
				swiz.beanFactory.setUpBean( bean );
			}
			
			// add a new BeanProvider
			var beanProvider : BeanProvider = new BeanProvider();
			beanProvider.addBean( bean );
			swiz.beanProviders.push( beanProvider );
			
			return bean;
		}
		
		/**
		 * Remove all children from the UI container and set the Swiz instance to null.
		 */ 
		protected function destroySwiz() : void
		{
			ui.removeAllChildren();			
			swiz = null;
		}
		
	}
}