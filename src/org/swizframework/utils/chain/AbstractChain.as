package org.swizframework.utils.chain
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.swizframework.events.ChainEvent;
	
	[Event( name="chainStart",			type="org.swizframework.events.ChainEvent" )]
	[Event( name="chainStepComplete",	type="org.swizframework.events.ChainEvent" )]
	[Event( name="chainStepError",		type="org.swizframework.events.ChainEvent" )]
	[Event( name="chainComplete",		type="org.swizframework.events.ChainEvent" )]
	[Event( name="chainFail",			type="org.swizframework.events.ChainEvent" )]
	
	public class AbstractChain extends EventDispatcher implements IChainMember
	{
		public var mode:String = ChainType.SEQUENCE;
		
		public var members:Array = [];
		
		/**
		 * Backing variable for <code>dispatcher</code> getter/setter.
		 */
		protected var _dispatcher:IEventDispatcher;
		
		/**
		 *
		 */
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}
		
		public function set dispatcher( value:IEventDispatcher ):void
		{
			_dispatcher = value;
		}
		
		/**
		 * Backing variable for <code>chain</code> getter/setter.
		 */
		protected var _chain:IChain;
		
		/**
		 *
		 */
		public function get chain():IChain
		{
			return _chain;
		}
		
		public function set chain( value:IChain ):void
		{
			_chain = value;
		}
		
		protected var _isComplete:Boolean;
		
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
		/**
		 * Backing variable for <code>position</code> getter/setter.
		 */
		protected var _position:int = -1;
		
		/**
		 *
		 */
		public function get position():int
		{
			return _position;
		}
		
		public function set position( value:int ):void
		{
			_position = value;
		}
		
		/**
		 * Backing variable for <code>stopOnError</code> getter/setter.
		 */
		protected var _stopOnError:Boolean;
		
		/**
		 *
		 */
		public function get stopOnError():Boolean
		{
			return _stopOnError;
		}
		
		public function set stopOnError( value:Boolean ):void
		{
			_stopOnError = value;
		}
		
		public function AbstractChain( dispatcher:IEventDispatcher = null, stopOnError:Boolean = true, mode:String = ChainType.SEQUENCE )
		{
			this.dispatcher = dispatcher;
			this.stopOnError = stopOnError;
			this.mode = mode;
		}
		
		/**
		 *
		 */
		public function addMember( member:IChainMember ):IChain
		{
			member.chain = IChain( this );
			members.push( member );
			return IChain( this );
		}
		
		/**
		 *
		 */
		public function hasNext():Boolean
		{
			return position + 1 < members.length;
		}
		
		/**
		 *
		 */
		public function start():void
		{
			dispatchEvent( new ChainEvent( ChainEvent.CHAIN_START ) );
			position = -1;
			proceed();
		}
		
		public function stepComplete():void
		{
			dispatchEvent( new ChainEvent( ChainEvent.CHAIN_STEP_COMPLETE ) );
			if( mode == ChainType.SEQUENCE )
			{
				proceed();
			}
			else
			{
				for( var i:int = 0; i < members.length; i++ )
				{
					if( !IChainMember( members[ i ] ).isComplete )
						return;
				}
				complete();
			}
		}
		
		/**
		 *
		 */
		public function proceed():void
		{
			if( mode == ChainType.SEQUENCE )
			{
				if( hasNext() )
				{
					position++;
					IChain( this ).doProceed();
				}
				else
				{
					complete();
				}
			}
			else
			{
				for( var i:int = 0; i < members.length; i++ )
				{
					position = i;
					IChain( this ).doProceed();
				}
			}
		}
		
		/**
		 *
		 */
		public function stepError():void
		{
			dispatchEvent( new ChainEvent( ChainEvent.CHAIN_STEP_ERROR ) );
			if( !stopOnError )
				proceed();
			else
				fail();
		}
		
		/**
		 *
		 */
		protected function complete():void
		{
			dispatchEvent( new ChainEvent( ChainEvent.CHAIN_COMPLETE ) );
			_isComplete = true;
			if( chain != null )
				chain.stepComplete();
		}
		
		/**
		 *
		 */
		protected function fail():void
		{
			dispatchEvent( new ChainEvent( ChainEvent.CHAIN_FAIL ) );
			_isComplete = true;
			if( chain != null )
				chain.stepError();
		}
	}
}