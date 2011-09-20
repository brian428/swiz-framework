package testSuites
{
	import integration.tests.*;

	[RunWith( "org.flexunit.runners.Suite" )]
	[Suite]
	public class IntegrationTestSuite
	{
		public var swizMXMLTest : CoreSwizIntegrationTests;
		public var moduleIntegrationTests : ModuleIntegrationTests;
		public var eventHandlerIntegrationTests : EventHandlerIntegrationTests;
		public var injectionIntegrationTests : InjectionIntegrationTests;
	}
}