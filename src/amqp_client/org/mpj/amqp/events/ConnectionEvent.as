package org.mpj.amqp.events {
    
    import flash.events.Event;
    
    import org.mpj.amqp.frame.Frame;

    public class ConnectionEvent extends Event {
        // connection
        public static const CONNECTION_READY:String         = "CONNECTION_READY";
        public static const CONNECTION_CLOSED:String        = "CONNECTION_CLOSED";
        public static const CONNECTION_SECURE:String        = "CONNECTION_SECURE";
        
        public static const CONNECTION_STATE_READY:String   = "CONNECTION_STATE_READY";
        public static const CONNECTION_STATE_CLOSED:String  = "CONNECTION_STATE_CLOSED";
    
        // socket specific
        public static const CONNECTION_SOCKET_CLOSED:String = "CONNECTION_SOCKET_CLOSED";
        public static const CONNECTION_SOCKET_ERROR:String  = "CONNECTION_SOCKET_ERROR";
        public static const CONNECTION_SECURITY_EVENT:String = "CONNECTION_SECURITY_EVENT";

        private var _frame:Frame = null;
        private var _event:Event = null;
        
        public function get hasFrame()      :Boolean        { return Boolean(_frame!=null); }
        public function get frame()         :Frame          { return _frame; }
        
        public function get hasEvent()      :Boolean        { return Boolean(_frame!=null); }
        public function get event()         :Event          { return _event; }
    
        //----------------------------------------------------------
        // ConnectionEvent
        //----------------------------------------------------------
        public function ConnectionEvent(type:String, frame:Frame=null, event:Event=null) {
            super(type, false, false);
            if (frame!=null) {
                _frame=frame.clone();        
            }
            if (event!=null) {
                _event=event.clone();        
            }
        }
    }
}
