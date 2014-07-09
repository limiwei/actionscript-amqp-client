package org.mpj.amqp.events {
    
    import flash.events.Event;
    import org.mpj.amqp.queue.ChannelQueueItem;
 
    public class QueueEvent extends Event {
        public static const ITEM_READY:String = "ITEM_READY";

        private var _item:ChannelQueueItem;
        
        public function get item():ChannelQueueItem {
            return _item;
        }
        
        //----------------------------------------------------------
        // FrameEvent
        // use a weak copy so the pomise does not get overridden
        //----------------------------------------------------------
        public function QueueEvent(type:String, item:ChannelQueueItem, bubbles:Boolean=false, cancelable:Boolean=false) {
            super(type, bubbles, cancelable);
            _item=item;
        }
    }   
}
