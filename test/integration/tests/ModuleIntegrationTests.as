package integration.tests
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import integration.application.RootContainer;
	import integration.application.control.SimpleController;
	import integration.application.module.RootModuleContainer;
	import integration.application.module.event.SimpleModuleEvent;
	import integration.application.module.view.SimpleModuleCanvas;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.fluint.sequence.*;
	import org.fluint.uiImpersonation.*;
	import org.swizframework.core.*;
	
	public class ModuleIntegrationTests extends BaseSwizIntegrationTest
	{
		
		[Test( async,ui )]
		public function testSwizBeanInModule() : void 
		{
			Async.handleEvent( this, rootContainer, RootContainer.MODULE_ADDED, verifyModuleBeans, LONG_TIME, null );
			rootContainer.loadTestModule();
		}
		
		[Test( async,ui )]
		public function testModuleHandlesModuleEventInModuleRoot() : void 
		{
			Async.handleEvent( this, dispatcher, SimpleModuleEvent.MODULE_EVENT_COMPLETE, verifyModuleHandledModuleEvent, LONG_TIME, null ); 
			rootContainer.loadTestModule();
		}
		
		[Test( async,ui )]
		public function testModuleHandlesParentApplicationEvent() : void 
		{
			Async.handleEvent( this, rootContainer, RootContainer.MODULE_ADDED, verifyModuleHandledParentApplicationEvent, LONG_TIME, null ); 
			rootContainer.loadTestModule();
		}
		
		[Test( async,ui )]
		public function testModuleDispatcherMatchesRootDispatcher() : void 
		{
			Async.handleEvent( this, rootContainer, RootContainer.MODULE_ADDED, compareModuleAndRootDispatchers, LONG_TIME, null ); 
			rootContainer.loadTestModule();
		}
		
		[Test( async,ui )]
		public function testModuleSwizIsTornDown() : void 
		{
			Async.handleEvent( this, rootContainer, RootContainer.MODULE_ADDED, destroyModule, LONG_TIME, null ); 
			rootContainer.loadTestModule();
		}
		
		protected function verifyModuleBeans( event : Event, passThroughData : Object ) : void
		{
			var bean : Bean = RootModuleContainer( rootContainer.testModuleLoader.child ).mySwiz.beanFactory.getBeanByType( SimpleController );
			var moduleCanvas : SimpleModuleCanvas = RootModuleContainer( rootContainer.testModuleLoader.child ).simpleModuleCanvas;
			
			Assert.assertTrue( "Bean loaded in module cannot load bean from parent application.", bean.source is SimpleController );
			Assert.assertTrue( "View component in module did not have parent application bean injected by type", moduleCanvas.controller is SimpleController );
			Assert.assertTrue( "View component in module did not have parent application bean injected by name", moduleCanvas.namedController is SimpleController );
			
			rootContainer.removeTestModule();
		}
		
		protected function verifyModuleHandledParentApplicationEvent( event : Event, passThroughData : Object ) : void
		{
			var mediateWorked : Boolean = RootModuleContainer( rootContainer.testModuleLoader.child ).parentAppEventHandlerRan;
			Assert.assertTrue( "Module root container did not handle parent application event.", mediateWorked );
			rootContainer.removeTestModule();
		}
		
		protected function verifyModuleHandledModuleEvent( event : Event, passThroughData : Object ) : void
		{
			var mediateWorked : Boolean = RootModuleContainer( rootContainer.testModuleLoader.child ).moduleEventHandlerRan;
			Assert.assertTrue( "Module root container did not handle module-specific event.", mediateWorked );
			rootContainer.removeTestModule();
		}
		
		protected function compareModuleAndRootDispatchers( event : Event, passThroughData : Object ) : void
		{
			var moduleDispatcher : IEventDispatcher = RootModuleContainer( rootContainer.testModuleLoader.child ).swizDispatcher;
			Assert.assertTrue( "Module dispatcher does not match root dispatcher.", moduleDispatcher == dispatcher );
			rootContainer.removeTestModule();
		}
		
		protected function destroyModule( event : Event, passThroughData : Object ) : void
		{
			Assert.assertTrue( "Module Swiz not set up.", SwizManager.swizzes.length == 2 );
			var module : RootModuleContainer = RootModuleContainer( rootContainer.testModuleLoader.child )
			Async.handleEvent( this, module, Event.REMOVED_FROM_STAGE, waitForEnterFrame, LONG_TIME, {swizCount:SwizManager.swizzes.length} ); 
			rootContainer.removeTestModule();
		}
		
		protected function waitForEnterFrame( event : Event, passThroughData : Object ) : void
		{
			Async.handleEvent( this, rootContainer, Event.ENTER_FRAME, verifyModuleDestroyed, LONG_TIME, {swizCount:passThroughData.swizCount} ); 
		}
		
		protected function verifyModuleDestroyed( event : Event, passThroughData : Object ) : void
		{
			Assert.assertTrue( "Module Swiz not torn down.", SwizManager.swizzes.length == passThroughData.swizCount - 1 );
		}
		
	}
}