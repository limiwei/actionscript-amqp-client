package org.mpj.amqp.frame  {
    
    import flash.net.registerClassAlias;
    import flash.utils.ByteArray;
    import org.mpj.amqp.utils.ObjectUtils;

    public class PackedFrame {
        private var _name                       :String       = null;
        private var _responses                  :Array        = null;
        private var _method                     :ByteArray    = null;
        private var _header                     :ByteArray    = null;
        private var _body                       :ByteArray    = null;
    
        
        // will be method "class.method"
        //public function set name(name:String) :String    { _name=name;}
        public function get name()              :String    { return _name;}
    
        public function get responses()          :Array    { return _responses;}
        public function addResponse( response:String ):void { _responses.push(response);}
        public function hasResponses()           :Boolean   { return Boolean(_responses.length>0);}
        public function hasResponse( response:String ):Boolean { 
            for each (var check_response:String in _responses) {                
                // found valid response frame
                if (check_response==response) {
                    return true;
                }
            }
            return false;
        }
        
        public function get method()            :ByteArray    { return _method;}
        public function get header()            :ByteArray    { return _header;}
        public function get hasHeade()          :Boolean      { return Boolean(_header.length>0);}
        public function get body()              :ByteArray    { return _body;}
        public function get hasBody()           :Boolean      { return Boolean(_body.length>0);}
        
        //----------------------------------------------------------
        // PackedFrame
        //----------------------------------------------------------
        public function PackedFrame(methodName:String) {
            _name=methodName;
            _responses = new Array();
            _method = new ByteArray();
            _header = new ByteArray();
            _body = new ByteArray();
        }
        
        //----------------------------------------------------------
        // make a copy of this class
        //----------------------------------------------------------
        public function clone() : PackedFrame
        {
            registerClassAlias( "org.emc.amqp.PackedFrame", PackedFrame );
            var bytes : ByteArray = new ByteArray();
            bytes.writeObject( this );
            bytes.position = 0;
            return bytes.readObject() as PackedFrame;
        }
    }
}
