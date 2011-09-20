package integration.application.control
{
	import integration.application.view.SimpleCanvas;
	
	import org.swizframework.controller.AbstractController;
	
	public class SimpleController extends AbstractController
	{
		public static const CONTROLLER_NAME : String = "A Simple Controller";
		
		[Bindable]
		public var name : String;
		
		public function SimpleController()
		{
			super();
		}
		
		[Bindable]
		public var view : SimpleCanvas;
		
		[ViewAdded]
		public function simpleCanvasAdded( view : SimpleCanvas ) : void
		{
			this.view = view;
		}
		
		[ViewRemoved]
		public function simpleCanvasRemoved( view : SimpleCanvas ) : void
		{
			this.view = null;
		}
		
		[PostConstruct]
		public function postConstructHandler() : void
		{
			name = CONTROLLER_NAME;
		}
	}
}