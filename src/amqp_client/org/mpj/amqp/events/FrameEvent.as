package org.mpj.amqp.events {
    
    import flash.events.Event;
    import flash.utils.ByteArray;
    
    public class FrameEvent extends Event {
        public static const FRAME_READY:String = "FRAME_READY";

        private var _frame:ByteArray;
        
        public function get frame():ByteArray {
            return _frame;
        }
        
        //----------------------------------------------------------
        // FrameEvent
        //----------------------------------------------------------
        public function FrameEvent(type:String, frame:ByteArray, bubbles:Boolean=false, cancelable:Boolean=false) {
            super(type, bubbles, cancelable);
            _frame=new ByteArray();
            frame.position=0;
            frame.readBytes(_frame);
        }
    }
}
