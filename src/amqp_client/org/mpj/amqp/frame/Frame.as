package org.mpj.amqp.frame {
    
    import flash.net.registerClassAlias;
    import flash.utils.ByteArray;
    import org.mpj.amqp.utils.ObjectUtils;
    
    public class Frame {
        // all frames
        private var _type            :uint        = 0;
        private var _channel        :uint        = 0;
        private var _frameSize        :uint        = 0;

        // header frames
        private var _classIndex        :uint        = 0;    // method also
        private var _className        :String        = "";    // method also        
        private var _properties        :Object        = null;    // method if content is true
        private var _bodySize        :uint        = 0;
        
        // method frame
        private var _methodIndex    :uint        = 0;
        private var _methodName        :String        = "";
        private var _hasContent        :Boolean    = false;
        private var _fields            :Object        = null;
        
        // body frame
        private var _body            :String        = "";    // method if content is true
        
        // header will be "class", method "class.method", body ""    
        public function get name        ():String                { 
            var name = "";
            if (className.length) {
                name+=className;
            }
            if (methodName.length) {
                name+="."+methodName;
            }
            
            return name; 
        }
        
        public function get type()          :uint        { return _type; }
        public function set type(type:uint) :void        { _type=type; }
        public function get channel()       :uint        { return _channel; }
        public function set channel(channel:uint):void   { _channel=channel; }
        public function get frameSize()     :uint        { return _frameSize; }
        public function set frameSize(frameSize:uint):void { _frameSize=frameSize; }
        public function get bodySize()      :uint        { return _bodySize; }
        public function set bodySize(bodySize:uint):void { _bodySize=bodySize; }
        public function get classIndex()    :uint        { return _classIndex; }
        public function set classIndex(classIndex:uint):void { _classIndex=classIndex; }
        public function get className()     :String      { return _className; }
        public function set className(className:String):void { _className=className; }
        public function get methodIndex()   :uint        { return _methodIndex; }
        public function set methodIndex (methodIndex:uint):void { _methodIndex=methodIndex; }
        public function get methodName()    :String      { return _methodName; }
        public function set methodName(methodName:String):void { _methodName=methodName; }
        public function get hasContent()    :Boolean     { return _hasContent; }
        public function set hasContent(hasContent:Boolean):void{ _hasContent=hasContent; }    
        public function get fields()        :Object      { return _fields; }
        
        public function set fields(fields:Object):void { 
            _fields=ObjectUtils.copy(fields);
        }
        
        public function setField(fieldName:String, field:*):void { 
            if (_fields==null) {
                _fields=new Object();
            }
            _fields[fieldName]=ObjectUtils.copy(field);
        }
        
        public function get body()              :String     { return _body; }
        public function set body(body:String)   :void       { _body=body; }

        public function Frame() {
            
        }
        
        //----------------------------------------------------------
        // make a copy of this class
        //----------------------------------------------------------
        public function clone() : Frame
        {
            registerClassAlias( "org.emc.amqp.Frame", Frame );
            var bytes : ByteArray = new ByteArray();
            bytes.writeObject( this );
            bytes.position = 0;
            return bytes.readObject() as Frame;
        }
    }
}
