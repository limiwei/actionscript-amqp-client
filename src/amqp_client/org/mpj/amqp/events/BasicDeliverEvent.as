/**

Event for processing basic.deliver methods. the event id will be the consumer
tag of the method. use the consumer tag from the basic.consume-ok method

**/

package org.mpj.amqp.events {
    import flash.events.Event;
    import org.mpj.amqp.frame.Frame;
    
    public class BasicDeliverEvent extends Event {
        
        private var _frame:Frame=null;
        
        public function get frame():Frame { return _frame; }
        
        //----------------------------------------------------------
        // BasicDeliverEvent
        //----------------------------------------------------------
        public function BasicDeliverEvent(consumerTag:String, frame:Frame) {
            super(consumerTag);
            this._frame = frame;
        }

    }
    
}
