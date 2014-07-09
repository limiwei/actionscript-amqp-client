package org.mpj.amqp {
    import flash.events.EventDispatcher;
    
    import org.mpj.amqp.transport.AMQPSocket;
    import org.mpj.amqp.protocol.AMQPParser;
    import org.mpj.amqp.frame.Frame;
    import org.mpj.amqp.frame.PackedFrame;    
    import org.mpj.amqp.queue.ChannelQueue;
    import org.mpj.amqp.queue.ChannelQueueItem;    
    import org.mpj.amqp.events.QueueEvent;
    import org.mpj.amqp.events.ChannelEvent;
    import org.mpj.amqp.events.BasicDeliverEvent;
    import org.mpj.amqp.events.ConnectionEvent;
    import org.mpj.amqp.promise.Promise;
    import org.mpj.amqp.promise.PromiseResult;
    import org.mpj.amqp.promise.PromiseFault;
    import org.mpj.amqp.error.AMQPError;
    import org.mpj.amqp.utils.ObjectUtils;
        
    public class Channel extends EventDispatcher {
        private const STATE_CLOSED    :int = 0;
        private const STATE_CLOSING   :int = 1;
        private const STATE_OPENING   :int = 2;
        private const STATE_OPENED    :int = 3;
        
        private var _connection       :Connection;
        private var _number           :uint;
        private var _queue            :ChannelQueue;    
        private var _frame            :Frame = null;
        private var _state            :int = STATE_CLOSED;
        private var _responseExpected :Boolean  = false;
        
        //----------------------------------------------------------
        // Channel
        //----------------------------------------------------------
        public function Channel(n:uint, connection:Connection, autoOpen:Boolean=true) {
            
            _number=n;
            _connection=connection;
            
            // create queue
            _queue=new ChannelQueue();
            
            // queue events
            _queue.addEventListener(QueueEvent.ITEM_READY, onSendQueuedItem);                
            
            reset();
            
            if(autoOpen) {
                open();
            }
        }
        
        //----------------------------------------------------------
        // reset
        // this will loop through the queue and call the fault handler
        // for any promises. then clear the queue
        // We may not need to do this. The queue could stay filled, and start
        // again after connection open
        //----------------------------------------------------------
        public function reset(frame:Frame=null):void {
            if (_number) {
                _state=STATE_CLOSED;
            } else {
                _state=STATE_OPENED;
            }
            
            _queue.reset(frame);
        }
        
        //----------------------------------------------------------
        // onConnectionReady
        //----------------------------------------------------------
        public function onConnectionReady(event:ConnectionEvent):void {
            
            // process anything that was in the queue
            _queue.process();
        }
        
        //----------------------------------------------------------
        // onConnectionReady
        //----------------------------------------------------------
        public function onConnectionClosed(event:ConnectionEvent):void {
            reset(event.frame);
        }
        
        //----------------------------------------------------------
        // open
        //----------------------------------------------------------
        public function open():void {
            _state=STATE_OPENING;
            var p:Promise = sendMethod("channel.open");
            p.onResult(function(data:Object) {  
                dispatchEvent(new ChannelEvent(ChannelEvent.CHANNEL_OPEN));
                _state=STATE_OPENED;
            });
            
            p.onFault(function(data:Object) {  
                _state=STATE_CLOSED;
            });
        }

        //----------------------------------------------------------
        // close
        // need to send this back up to connection and get rid of channel
        //----------------------------------------------------------
        public function close():void {
            _state=STATE_CLOSING;
            
            var p:Promise = sendMethod("channel.close");
            p.onResult(function(data:Object) {
                _state=STATE_CLOSED;
            });        
            
            p.onFault(function(data:Object) {  
                _state=STATE_CLOSED;
            });
        }
        
        //----------------------------------------------------------
        // sendMethod
        // method can be by name of index, ie "connection.start-ok", or "10.11"
        // fields is an object with keys being the name of the field
        // returned promise will be null if method has no reply
        //----------------------------------------------------------
        public function sendMethod(method:String, fields:Object=null, body:*=null):Promise {        

            var queueItem:ChannelQueueItem= new ChannelQueueItem(method, fields, body);
            
            _queue.addItem(queueItem);
            
            return queueItem.promise;
        }
        
        //----------------------------------------------------------
        // onSendQueuedItem
        // send any frames in the queue
        //----------------------------------------------------------
        private function onSendQueuedItem(e:QueueEvent):void {
            
            if (_number&&!_connection.isReady()) {
                return;
            }
            
            _responseExpected=false;
            
            if (_state==STATE_CLOSED) {
                open();
                return;
            }
            
            var queuedItem:ChannelQueueItem=e.item;
            var packedFrame:PackedFrame;

            try {
                packedFrame=_connection.parser.buildMethodFrame(queuedItem.methodName, queuedItem.fields, queuedItem.body);
            } catch (e:Error) {
                queuedItem.promise.fault(new PromiseFault(e.errorID, e.message));    
                
                //shift the queue.
                _queue.shift();
                
                return;
            }
            
            _connection.socket.sendFrame(_connection.parser.FRAME_METHOD, packedFrame.method, _connection.parser.FRAME_END, _number);
            
            //send the header
            if (packedFrame.hasHeader) {
                _connection.socket.sendFrame(_connection.parser.FRAME_HEADER, packedFrame.header, _connection.parser.FRAME_END, _number);                
            }
            
            //send the body
            if (packedFrame.hasBody) {
                _connection.socket.sendFrame(_connection.parser.FRAME_BODY, packedFrame.body, _connection.parser.FRAME_END, _number);                
            }
            
            // if we just sent the close_ok 
            if (queuedItem.methodName=="channel.close-ok" ||
                queuedItem.methodName=="20.41") {
                _state=STATE_CLOSED;
                dispatchEvent(new ChannelEvent(ChannelEvent.CHANNEL_CLOSE));
            }
            
            // check to see if we need to set up a response
            if (packedFrame.hasResponses() && _number>0) {
                // save responses
                queuedItem.setResponses(packedFrame.responses);
                
                // this callis expecting a response
                _responseExpected=true;
            } else    {
                // send a success result promise 
                queuedItem.promise.result(new PromiseResult(true));
                
                //shift the queue
                _queue.shift();
            }
        }
        
        //----------------------------------------------------------
        // processFrame
        // will be called from connection class when a frame comes
        // in for this channel
        //----------------------------------------------------------
        public function processFrame(frame:Frame) {
            
            if (frame.type==_connection.parser.FRAME_METHOD && frame.hasContent) {
                
                _frame=frame.clone();
                
                // do not sesnd response yet, wait for header and body
                return;
            } else if (frame.type==_connection.parser.FRAME_HEADER) {    // add header fields
                
                for(var k:* in frame.fields) {
                    _frame.setField(k, frame.fields[k]);
                }
                
                // check to see if there is a body following header.
                if (frame.bodySize>0) {
                    return;
                }
            } else if (frame.type==_connection.parser.FRAME_BODY) {    // add body                
                _frame.body=frame.body;
            } else {
                _frame=frame.clone();
            }
            
            var clonedFrame:Frame = _frame.clone(); // return frame. free up _frame
        
            if (_responseExpected) {
                var queueItem:ChannelQueueItem=_queue.shift();
                var handled:Boolean = false;        
                _responseExpected=false;
                
                // check to see if it is a close method
                // this will happen if the previous call had an error
                // we could compare the class and method index of the message
                // in the queue with the ones in the frame to ensure this error
                // is for the frame that was just sent
                if (clonedFrame.name == "channel.close") {
                    handled=true;
                                    
                    // need to reply with the "close-ok" method 
                    sendMethod("channel.close-ok");    
                    
                    // send fault response with the frame
                    queueItem.promise.fault(new PromiseFault(clonedFrame.fields.reply_code,
                                                    clonedFrame.fields.reply_text,
                                                    clonedFrame));
                    return;
                }

                // check for valid response frame
                if (queueItem.hasResponse(clonedFrame.methodName)) {
                    handled=true;
                    
                    // send result response
                    queueItem.promise.result(new PromiseResult(true,clonedFrame));                    
                }
                
                // frame came back that we where not expecting and was not the close method
                if (!handled) {                    
                    // unknown frame at this point
                    
                    // send fault response with the frame
                    queueItem.promise.fault(new PromiseFault(AMQPError.UNKNOWN_FRAME,
                                                    AMQPError.toString(AMQPError.UNKNOWN_FRAME),
                                                    clonedFrame));                                            
                }
            } else if (clonedFrame.name == "basic.deliver") {
                // recieved a basic.deliver. fire an event with 
                // the consumer tag as the event id
                
                dispatchEvent(new BasicDeliverEvent(_frame.fields.consumer_tag, clonedFrame));
                
            } else {
                // not sure what to do here. this is technically an unknown frame
                // but not sure who to send the response to. so just move on to 
                // next item in queue
                trace("unknown frame :"+clonedFrame.name);
                
                // need to reply with the "close-ok" method
                if (clonedFrame.name == "channel.close") {
                    sendMethod("channel.close-ok");    
                }
            }
            
            // process the next item in teh queue if there is one
            _queue.process();
        }
    }
}
