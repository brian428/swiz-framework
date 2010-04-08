package org.swizframework.core
{
	import org.swizframework.reflection.TypeDescriptor;
	
	[DefaultProperty( "source" )]
	
	public class Bean
	{
		// ========================================
		// protected properties
		// ========================================
		
		protected var _source:*;
		
		// ========================================
		// public properties
		// ========================================
		
		/**
		 * Source
		 */
		public function get source():*
		{
			return _source;
		}
		
		public function set source( value:* ):void
		{
			_source = value;
		}
		
		/**
		 * Name
		 */
		public var name:String;
		
		/**
		 * Type Descriptor
		 */
		public var typeDescriptor:TypeDescriptor;
		
		/**
		 * BeanFactory
		 */
		public var beanFactory:IBeanFactory;
		
		/**
		 * Initialzed
		 */
		public var initialized:Boolean = false;
		
		public function get type():*
		{
			return source;
		}
		
		// ========================================
		// constructor
		// ========================================
		
		public function Bean( source:* = null, name:String = null, typeDescriptor:TypeDescriptor = null )
		{
			this.source = source;
			this.name = name;
			this.typeDescriptor = typeDescriptor;
		}
		
		// ========================================
		// public methods
		// ========================================
		
		/**
		 *
		 */
		public function toString():String
		{
			return "Bean{ source: " + source + ", name: " + name + " }";
		}
	}
}