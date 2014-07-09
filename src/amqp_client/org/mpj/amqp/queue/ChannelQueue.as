package org.mpj.amqp.queue {
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.events.EventDispatcher;

    import org.mpj.amqp.events.QueueEvent;
    import org.mpj.amqp.frame.Frame;
    import org.mpj.amqp.promise.PromiseFault;
    
    public class ChannelQueue extends EventDispatcher {
        
        private var _queue :Array;
        private var _processTimer :Timer;
        
        // list of methods that will be added to the beggining of te queue
        private static var _priorityMethods :Object = {
                "channel.open":true,
                "20.10":true,
                "channel.close":true,
                "20.40":true,
                "channel.close-ok":true,
                "20.41":true};
    
        //----------------------------------------------------------
        // ChannelQueue
        //----------------------------------------------------------
        public function ChannelQueue() {
            
            // create an array to hold queued items
            _queue=new Array();
            
            // use a timer so the sendmethod channel function can return the promise 
            // before the frame is sent to the socket
            _processTimer = new Timer(100, 0);
            _processTimer.addEventListener(TimerEvent.TIMER, doProcessQueue);    
        }
        
        //----------------------------------------------------------
        // reset
        // sends the promisefault for all items in the queue
        //----------------------------------------------------------
        public function reset(frame:Frame=null) {
            _processTimer.stop();
            
            for each (var item:ChannelQueueItem in _queue) {                
                if (item.promise!=null) {
                    var reply_code=0;
                    var reply_text=0;
                    
                    if (frame!=null && frame.fields!=null) {
                        reply_code=frame.fields.reply_code;
                        reply_text=frame.fields.reply_text;            
                    }
                    
                    item.promise.fault(new PromiseFault(reply_code,reply_text));
                }
            }
            
            _queue=new Array();
        }
        
        //----------------------------------------------------------
        // addItem
        // adds an item to the queue.
        //----------------------------------------------------------
        public function addItem(queueItem:ChannelQueueItem) {
            var f:Function=_queue.push;
            
            // check for priority
            if (_priorityMethods[queueItem.methodName]!=undefined) {
                f=_queue.unshift;
            } 
            
            f(queueItem);

            // process the queue
            process();
        }
        
        //----------------------------------------------------------
        // doProcessQueue
        //----------------------------------------------------------
        private function doProcessQueue(e:TimerEvent):void {
            _processTimer.stop();
            
            if (_queue.length) {
                dispatchEvent(new QueueEvent(QueueEvent.ITEM_READY, _queue[0])); 
            }
        }
        
        //----------------------------------------------------------
        // process
        //----------------------------------------------------------
        public function process():void {
            _processTimer.start();
        }
        
        //----------------------------------------------------------
        // shift
        // remove first item in queue and process again
        //----------------------------------------------------------
        public function shift():ChannelQueueItem {
            _processTimer.start();
            return _queue.shift(); 
        }
    }
}
