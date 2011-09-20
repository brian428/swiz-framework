package integration.application.module.event
{
	import flash.events.Event;

	public class SimpleModuleEvent extends Event
	{
		public static const MODULE_EVENT : String = "simpleModuleEvent";
		public static const MODULE_EVENT_COMPLETE : String = "simpleModuleEventComplete";

		public function SimpleModuleEvent( type : String )
		{
			super( type, true, false );
		}
	}
}