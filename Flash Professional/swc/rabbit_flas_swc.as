package  {
	
	import flash.display.MovieClip;
	import org.emc.amqp.*
	import org.emc.amqp.error.*;
	import org.emc.amqp.events.*;
	import org.emc.amqp.frame.*;
	import org.emc.amqp.promise.*;
	import org.emc.amqp.protocol.*;
	import org.emc.amqp.queue.*;
	import org.emc.amqp.transport.*;
	import org.emc.amqp.utils.*;
	
	public class rabbit_flas_swc extends MovieClip {
		
		// reference it so it is in the swc file
		private var _Channel:Channel;
		private var _Connection:Connection;
		private var _AMQPError:AMQPError;
		private var _BasicDeliverEvent:BasicDeliverEvent;
		private var _ChannelEvent:ChannelEvent;
		private var _ConnectionEvent:ConnectionEvent;
		private var _FrameEvent:FrameEvent;
		private var _QueueEvent:QueueEvent;
		private var _Frame:Frame;
		private var _PackedFrame:PackedFrame;
		private var _Promise:Promise;
		private var _PromiseFault:PromiseFault;
		private var _PromiseResult:PromiseResult;
		private var _AMQP_0_8_0:AMQP_0_8_0;
		private var _AMQP_0_9_1:AMQP_0_9_1;
		private var _AMQPParser:AMQPParser;
		private var _BitBuffer:BitBuffer;
		private var _IProtocolVersion:IProtocolVersion;
		private var _ChannelQueueItem:ChannelQueueItem;
		private var _ChannelQueue:ChannelQueue;
		private var _AMQPSocket:AMQPSocket;
		private var _ObjectUtils:ObjectUtils;
		
		public function rabbit_flas_swc() {
			// constructor code
		}
	}
	
}
