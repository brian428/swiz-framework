package integration.tests
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import integration.application.RootContainer;
	import mx.core.Container;
	import org.flexunit.async.Async;
	import org.fluint.uiImpersonation.IVisualTestEnvironment;
	import org.fluint.uiImpersonation.UIImpersonator;
	import org.fluint.uiImpersonation.VisualTestEnvironmentBuilder;
	import org.swizframework.core.Bean;
	import org.swizframework.core.mxml.Swiz;
	import org.swizframework.reflection.TypeCache;

	public class BaseSwizIntegrationTest
	{
		
		protected static var LONG_TIME : int = 5000;
		
		[Dispatcher]
		public var dispatcher : IEventDispatcher;
		
		protected var rootContainer : RootContainer;
		protected var testBean : Bean;
		
		[Before( async,ui )]
		public function createRootContainer() : void
		{
			// Stop the UI Impersonator from removing and re-adding the children, which causes the Swiz dispatcher to get torn down before the test can run.
			var env : IVisualTestEnvironment = VisualTestEnvironmentBuilder.getInstance().buildVisualTestEnvironment();
			Container( env ).clipContent = false;
			
			rootContainer = new RootContainer();
			Async.proceedOnEvent( this, rootContainer, Event.ADDED_TO_STAGE, LONG_TIME );
			UIImpersonator.addChild( rootContainer );
			createBeanForTest();
		}
		
		[After( async,ui )]
		public function destroyRootContainer() : void
		{
			Async.proceedOnEvent( this, rootContainer, Event.REMOVED_FROM_STAGE, LONG_TIME );
			UIImpersonator.removeAllChildren();
			Async.proceedOnEvent( this, rootContainer, Event.ENTER_FRAME, LONG_TIME );
			rootContainer = null;
		}
		
		protected function createBeanForTest() : void
		{
			var swiz : org.swizframework.core.mxml.Swiz = rootContainer.mySwiz;
			
			// Wrap this unit test in a Bean definition.
			testBean = new Bean();
			testBean.source = this;
			testBean.typeDescriptor = TypeCache.getTypeDescriptor( testBean.type, swiz.domain );
			
			// Process this test case bean.
			swiz.beanFactory.setUpBean( testBean );
		}
		
	}
}