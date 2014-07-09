package org.mpj.amqp.queue {
    import org.mpj.amqp.promise.Promise;
    import org.mpj.amqp.utils.ObjectUtils;
    import org.mpj.amqp.frame.PackedFrame;
        
    public class ChannelQueueItem {
        
        private var _promise            :Promise    = null;    
        private var _methodName         :String     = null;     
        private var _fields             :Object     = null;    
        private var _body               :*          = null;
        private var _responses          :Array      = null;
                
        public function get promise()   :Promise    { return _promise;}
        public function get methodName():String     { return _methodName;}
        public function get fields()    :Object     { return _fields;}
        public function get body()      :*           { return _body;}
        
        public function setResponses( responses:Array ):void { 
            for each(var item:String in responses) {
                _responses.push(item);
            }
        }        
                    
        public function hasResponse( response:String ):Boolean { 
            for each (var check_response:String in _responses) {                
                // found valid response frame
                if (check_response==response) {
                    return true;
                }
            }
            return false;
        }    
        
        //----------------------------------------------------------
        // ChannelQueueItem
        //----------------------------------------------------------
        public function ChannelQueueItem(methodName:String, fields:Object=null, body:*=null) {
            _promise=new Promise();
            _responses=new Array();
            _methodName=methodName;
            if (fields==null) {
                _fields={};
            } else {
                _fields=ObjectUtils.copy(fields);    
            }
            
            // this may be a weak copy. should fix this
            _body=body;        
        }
    }    
}
