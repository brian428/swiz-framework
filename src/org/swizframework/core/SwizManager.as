/*
 * Copyright 2010 Swiz Framework Contributors
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License. You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package org.swizframework.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import mx.utils.UIDUtil;
	
	import org.swizframework.processors.IMetadataProcessor;
	import org.swizframework.processors.IProcessor;
	
	public class SwizManager
	{
		public static var swizzes:Array = [];
		public static var wiredViews:Array = [];
		public static var metadataTagNames:Array = [];
		
		public static function addSwiz( swiz:ISwiz ):void
		{
			swizzes.push( swiz );
			
			// Build a unique set of Swiz-specific and user-defined custom metadata tags.
			// This way, other code, such as TypeDescriptor, can use it to only process Swiz metadata and ignore all the unnecessary Flex/Flash metadata.
			for each( var p:IProcessor in swiz.processors )
			{
				if( p is IMetadataProcessor )
				{
					metadataTagNames = arrayConcatUnique( metadataTagNames, IMetadataProcessor( p ).metadataNames );
				}	
			}
			
		}
		
		public static function removeSwiz( swiz:ISwiz ):void
		{
			swizzes.splice( swizzes.indexOf( swiz ), 1 );
		}
		
		public static function setUp( dObj:DisplayObject ):void
		{
			var uid:String = UIDUtil.getUID( dObj );
			
			// already wired
			if( wiredViews.indexOf( uid ) > -1 )
				return;
			
			for( var i:int = swizzes.length - 1; i > -1; i-- )
			{
				var swiz:ISwiz = ISwiz( swizzes[ i ] );
				
				if( DisplayObjectContainer( swiz.dispatcher ).contains( dObj ) )
				{
					wiredViews.push( uid );
					swiz.beanFactory.setUpBean( BeanFactory.constructBean( dObj, null, swiz.domain ) );
					return;
				}
			}
			
			// this is stupid, if we got here, no swiz had a dispatcher 
			// containing the view (like, it's a freaking popup). make the first swiz do it
			var rootSwiz:ISwiz = swizzes[ 0 ];
			wiredViews.push( uid );
			rootSwiz.beanFactory.setUpBean( BeanFactory.constructBean( dObj, null, swiz.domain ) );
			
		}
		
		public static function tearDown( dObj:DisplayObject ):void
		{
			var uid:String = UIDUtil.getUID( dObj );
			
			// wasn't wired
			if( wiredViews.indexOf( uid ) == -1 )
				return;
			
			for( var i:int = swizzes.length - 1; i > -1; i-- )
			{
				var swiz:ISwiz = ISwiz( swizzes[ i ] );
				
				if( DisplayObjectContainer( swiz.dispatcher ).contains( dObj ) )
				{
					wiredViews.splice( wiredViews.indexOf( uid ), 1 );
					swiz.beanFactory.tearDownBean( BeanFactory.constructBean( dObj, null, swiz.domain ) );
					return;
				}
			}
			
			
			
			// this is stupid, if we got here, no swiz had a dispatcher 
			// containing the view (like, it's a freaking popup). make the first swiz do it
			var rootSwiz:ISwiz = swizzes[ 0 ];
			wiredViews.splice( wiredViews.indexOf( uid ), 1 );
			rootSwiz.beanFactory.tearDownBean( BeanFactory.constructBean( dObj, null, swiz.domain ) );
		}
		
		/**
		 * Returns an array of unique values contained in all of the passed arrays.
		 */ 
		private static function arrayConcatUnique( ...args ) : Array
		{
			var result : Array = new Array();
			for each ( var arg:* in args )
			{
				if ( arg is Array )
				{
					for each ( var value:* in arg )
					{
						if ( result.indexOf( value ) == -1 )
							result.push( value );
					}
				}
			}
			return result;
		}
	
	}

}