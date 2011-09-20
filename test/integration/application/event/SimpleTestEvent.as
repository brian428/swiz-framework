package integration.application.event
{
	import mx.events.DynamicEvent;
	
	public class SimpleTestEvent extends DynamicEvent
	{
		public static const GENERIC_EVENT : String = "genericEvent";
		public static const GENERIC_EVENT_PROCESSED : String = "genericEventProcessed";
		
		public var data : Object;
		
		public function SimpleTestEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super( type, true, cancelable );
		}
	}
}