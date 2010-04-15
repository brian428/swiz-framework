package testSuites
{
	import org.swizframework.metadata.*;
	
	[RunWith("org.flexunit.runners.Suite")]
	[Suite]
	public class MetadataTestSuite
	{
		public var injectionTests:InjectionTests;
		public var injectMetadataTagTests:InjectMetadataTagTests;
	}
}