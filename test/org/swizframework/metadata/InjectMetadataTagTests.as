package org.swizframework.metadata
{
	import flash.system.ApplicationDomain;
	
	import mx.logging.ILogger;
	import mx.logging.LogEvent;
	import mx.logging.LogEventLevel;
	
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.swizframework.core.Bean;
	import org.swizframework.reflection.MetadataArg;
	import org.swizframework.reflection.MetadataHostProperty;
	import org.swizframework.reflection.TypeCache;
	import org.swizframework.utils.SwizLogger;
	
	public class InjectMetadataTagTests
	{
		protected static var LONG_TIME:int = 500;
		
		[Test]
		public function testInjectTagDefaults():void
		{
			var injectMetadataTag:InjectMetadataTag = new InjectMetadataTag();
			assertTrue( "Inject metadata tag's bind property is not false.", !injectMetadataTag.bind );
			assertTrue( "Inject metadata tag's required property is not true.", injectMetadataTag.required );
			assertTrue( "Inject metadata tag's twoWay property is not true.", !injectMetadataTag.twoWay );
			assertTrue( "Inject metadata tag's source property is not null.", injectMetadataTag.source == null );
			assertTrue( "Inject metadata tag's destination property is not null.", injectMetadataTag.destination == null );
			assertTrue( "Inject metadata tag's args property is not null.", injectMetadataTag.args == null );
			assertTrue( "Inject metadata tag's defaultArgName property is not 'source'.", injectMetadataTag.defaultArgName == "source" );
			assertTrue( "Inject metadata tag's host property is not null.", injectMetadataTag.host == null );
			assertTrue( "Inject metadata tag's name property is not null.", injectMetadataTag.name == null );
			assertTrue( "Inject metadata tag's asTag property is not '[null]'.", injectMetadataTag.asTag == "[null]" );
		}
		
		[Test]
		public function testInjectTagCopyFrom():void
		{	
			var originalMetadataTag:InjectMetadataTag = new InjectMetadataTag();
			originalMetadataTag.name = "Inject";
			
			var host : MetadataHostProperty = new MetadataHostProperty();
			host.metadataTags = [originalMetadataTag];
			originalMetadataTag.host = host;
			
			var injectMetadataTag:InjectMetadataTag = new InjectMetadataTag();
			injectMetadataTag.copyFrom( originalMetadataTag );
			
			assertTrue( "Inject metadata tag's bind property is not false.", !injectMetadataTag.bind );
			assertTrue( "Inject metadata tag's required property is not true.", injectMetadataTag.required );
			assertTrue( "Inject metadata tag's twoWay property is not true.", !injectMetadataTag.twoWay );
			assertTrue( "Inject metadata tag's source property is not null.", injectMetadataTag.source == null );
			assertTrue( "Inject metadata tag's destination property is not null.", injectMetadataTag.destination == null );
			assertTrue( "Inject metadata tag's args property is not null.", injectMetadataTag.args == null );
			assertTrue( "Inject metadata tag's defaultArgName property is not 'source'.", injectMetadataTag.defaultArgName == "source" );
			assertTrue( "Inject metadata tag's host property is not set.", injectMetadataTag.host == host );
			assertTrue( "Inject metadata tag's name property is not 'Inject'.", injectMetadataTag.name == "Inject" );
			assertTrue( "Inject metadata tag's asTag property is not '[Inject]'.", injectMetadataTag.asTag == "[Inject]" );
		}
		
		[Test]
		public function testInjectTagSourceError():void
		{
			var originalMetadataTag:InjectMetadataTag = new InjectMetadataTag();
			originalMetadataTag.name = "Inject";
			originalMetadataTag.args = [new MetadataArg('bean','bean'), new MetadataArg('source','source')];
			
			var host : MetadataHostProperty = new MetadataHostProperty();
			var injectMetadataTag:InjectMetadataTag = new InjectMetadataTag();
			
			var errorString:String;
			try
			{
				injectMetadataTag.copyFrom( originalMetadataTag );	
			}
			catch(e:Error)
			{
				errorString = e.message;	
			}
			
			assertTrue( "Inject metadata tag did not throw error when using bean and source.", errorString != null );
			
		}
		
		[Test(async)]
		public function testInjectTagLogWarningForBean():void
		{
			var originalMetadataTag:InjectMetadataTag = new InjectMetadataTag();
			originalMetadataTag.name = "Inject";
			originalMetadataTag.args = [new MetadataArg('bean','bean')];
			
			var host : MetadataHostProperty = new MetadataHostProperty();
			var injectMetadataTag:InjectMetadataTag = new InjectMetadataTag();
			var logger:ILogger =  SwizLogger.getLogger( injectMetadataTag );
			
			Async.handleEvent( this, logger, LogEvent.LOG, checkLogging, LONG_TIME, {level:LogEventLevel.WARN, substring:"bean attribute"} ); 
			injectMetadataTag.copyFrom( originalMetadataTag );	
		}
		
		[Test(async)]
		public function testInjectTagLogWarningForProperty():void
		{
			var originalMetadataTag:InjectMetadataTag = new InjectMetadataTag();
			originalMetadataTag.name = "Inject";
			originalMetadataTag.args = [new MetadataArg('property','property')];
			
			var host : MetadataHostProperty = new MetadataHostProperty();
			var injectMetadataTag:InjectMetadataTag = new InjectMetadataTag();
			var logger:ILogger =  SwizLogger.getLogger( injectMetadataTag );
			
			Async.handleEvent( this, logger, LogEvent.LOG, checkLogging, LONG_TIME, {level:LogEventLevel.WARN, substring:"property attribute"} ); 
			injectMetadataTag.copyFrom( originalMetadataTag );	
		}
		
		protected function checkLogging( event : LogEvent, passThroughData : Object ) : void
		{
			assertTrue( "Test did not log expected logging level.", event.level == passThroughData.level );
			assertTrue( "Test did not log expected logging message.", event.message.match(".*" + passThroughData.substring + ".*").length > 0 );
		}
		
	}
}