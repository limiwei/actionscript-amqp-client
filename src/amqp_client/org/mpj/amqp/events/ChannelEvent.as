package org.mpj.amqp.events {
    
    import flash.events.Event;

    public class ChannelEvent extends Event {
        public static const CHANNEL_OPEN        :String = "CHANNEL_OPEN";
        public static const CHANNEL_CLOSE       :String = "CHANNEL_CLOSE";

        //----------------------------------------------------------
        // ChannelEvent
        //----------------------------------------------------------
        public function ChannelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
            super(type, bubbles, cancelable);
        }
    }
}
