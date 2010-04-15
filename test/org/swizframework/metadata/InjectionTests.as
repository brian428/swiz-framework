package org.swizframework.metadata
{
	import flash.system.ApplicationDomain;
	
	import org.flexunit.asserts.assertTrue;
	import org.swizframework.core.Bean;
	import org.swizframework.reflection.TypeCache;
	
	public class InjectionTests
	{
		
		private var _injection:Injection;
		
		[Before]
		public function setUp():void
		{	
			var bean:Bean = new Bean();
			bean.source = this;
			bean.typeDescriptor = TypeCache.getTypeDescriptor( bean.type, ApplicationDomain.currentDomain );
			
			var tag:InjectMetadataTag = new InjectMetadataTag();
			
			_injection = new Injection( tag, bean );
		}
		
		[Test]
		public function testInjectionConstructor():void
		{
			assertTrue( "Injection constructor did not set the correct bean.", _injection.bean is Bean );
			assertTrue( "Injection constructor did not set the correct injection metadata tag.", _injection.injectTag is InjectMetadataTag );
		}
		
	}
}