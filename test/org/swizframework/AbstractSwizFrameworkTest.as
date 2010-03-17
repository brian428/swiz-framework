package org.swizframework
{
	import flash.events.Event;
	
	import mx.core.Container;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.fluint.uiImpersonation.*;
	import org.swizframework.core.Bean;
	import org.swizframework.core.BeanProvider;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.core.mxml.Swiz;
	import org.swizframework.events.SwizEvent;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.testable.control.SimpleController;
	import org.swizframework.testable.event.SimpleTestEvent;
	
	public class AbstractSwizFrameworkTest
	{
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
			bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.type );
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