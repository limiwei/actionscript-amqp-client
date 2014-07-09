package org.mpj.amqp.protocol {
    import flash.utils.ByteArray;
    import flash.utils.getDefinitionByName;
    
    import org.mpj.amqp.error.AMQPError;
    import org.mpj.amqp.frame.Frame;
    import org.mpj.amqp.frame.PackedFrame;
    
    public class AMQPParser {
            
        // class path to the version classes
        private static const versionClassPath   :String="org.emc.amqp.protocol.";

        // version strings for the supported protocols
        public static const v0_8_0              :String="AMQP_0_8_0";
        public static const v0_9_1              :String="AMQP_0_9_1";
                
        // pass through getters from protocol version
        public function get FRAME_METHOD()      :int    { return _amqp.FRAME_METHOD; }
        public function get FRAME_HEADER()      :int    { return _amqp.FRAME_HEADER; }
        public function get FRAME_BODY()        :int    { return _amqp.FRAME_BODY; }
        public function get FRAME_HEARTBEAT()   :int    { return _amqp.FRAME_HEARTBEAT; }
        public function get FRAME_END()         :int    { return _amqp.FRAME_END; }
        public function get VERSION_MAJOR()     :int    { return _amqp.VERSION_MAJOR; }
        public function get VERSION_MINOR()     :int    { return _amqp.VERSION_MINOR; }
        public function get VERSION_REVISION()  :int    { return _amqp.VERSION_REVISION; }
            
        //xml definition file for protocol version
        private var _amqp        :IProtocolVersion;        
        
        // bit buffer for handling booleans
        private var _bit        :BitBuffer = new BitBuffer();
        
        //----------------------------------------------------------
        // AMQPSocket
        // pass in one of the above version srings defined above
        //     throws 
        //   AMQPError.INVALID_PROTOCOL_VERSION if the version string is not a class
        //   AMQPError.INVALID_PROTOCOL_DEFINITION if the definition file is invalid
        //----------------------------------------------------------
        public function AMQPParser(version:String) {
            
            // need to declare the version classes so they are included in the swf
            AMQP_0_9_1
            AMQP_0_8_0
            
            var classReference:Class;    
            var classPath:String = versionClassPath+version;
            
            try {
                classReference = getDefinitionByName(classPath) as Class;
                _amqp =  new classReference() as IProtocolVersion;
            } catch (e:ReferenceError) {
                AMQPError.throwError(AMQPError.INVALID_PROTOCOL_VERSION, " "+version);
            }
        }
        
        //----------------------------------------------------------
        // getMethods
        //  returns a list of all method names
        //----------------------------------------------------------
        public function getMethods():Array {
            var methods:Array=new Array();
            
            // loop through the field tags in the method parsing out the values
            for each(var methodXML:XML in _amqp.xml.descendants("method")) {    
                var addMethod:Boolean=false;
                for each(var chassisXML:XML in methodXML[0].elements("chassis")) {    
                    if (String(chassisXML.@name)=="server") {
                        addMethod=true;
                        break
                    }
                }
                
                if (addMethod) {
                    if (String(methodXML.parent().@name)!="connection" &&
                        String(methodXML.parent().@name)!="tx") {
                        var n:String=methodXML.parent().@name+"."+methodXML.@name;            
                        methods.push({method:n});
                    }
                }
            }    
            
            return methods;
        }
        
        //----------------------------------------------------------
        // getFields
        //  returns a list of all fields for the given method
        //----------------------------------------------------------
        public function getFields(methodName:String):Array {
            var fields:Array=new Array();
            
            // get method
            var indexes:Array = methodName.split(".");
            
            // search by name
              var methodXML:XMLList=_amqp.xml.elements("class").(@name==indexes[0]).method.(@name==indexes[1]);
            
            // search by id
            if (methodXML == null || methodXML.length()!=1) {
                  methodXML=_amqp.xml.elements("class").(@index==indexes[0]).method.(@index==indexes[1]);
            }
            
            // loop through the field tags in the method parsing out the values
            for each(var fieldXML:XML in methodXML[0].elements("field")) {
                var f:Object = {field:String(fieldXML.@name), value:String(fieldXML.@value)};
                fields.push(f);
            }
            
            if (String(methodXML[0].@content)=="1") {
                for each(var classFieldXML:XML in methodXML[0].parent().elements("field")) {
                    var cf:Object = {field:String(classFieldXML.@name), value:String(classFieldXML.@value)};
                    fields.push(cf);
                }            
            }
            
            return fields;
        }        
        //----------------------------------------------------------
        // parseFrame  parses an amqp frame and returns an object representing the frame. 
        // The returned object will have the following fields in it
        //     "type" - type of frame one of FRAME_METHOD, FRAME_HEADER, FRAME_BODY
        //     "channel" - the channel the frame is designated for, 0 is control channel
        //     "frameSize" - size of frame in bytes
        // Method frames will have the following additional fields
        //    "class_id" - id of the class
        //     "method_id" - id of the method
        //   all fields related to the method
        // throws
        //        AMQPError.UNKNOWN_FRAME
        //----------------------------------------------------------
        public function parseFrame(data:ByteArray):Frame {
            var frame:Frame=new Frame();

            // reset position to zero
            data.position=0;
            
            // parse header
            frame.type=data.readUnsignedByte();
            frame.channel=data.readUnsignedShort();
            frame.frameSize=data.readUnsignedInt();    

            switch (frame.type) {
                case FRAME_METHOD:
                    parseMethodFrame(data, frame);
                break;
                case FRAME_HEADER:
                    parseHeaderFrame(data, frame);
                break;
                case FRAME_BODY:
                    parseBodyFrame(data, frame);
                break;
                case FRAME_HEARTBEAT:
                    trace("parse FRAME_HEARTBEAT");
                break;                        
                default:
                    AMQPError.throwError(AMQPError.UNKNOWN_FRAME);            
                break;
            }
            
            return frame;
        }
        
        //----------------------------------------------------------
        // parseMethodFrame
        // parses a method frame and returns an object that contains
        // all fields within the frame
        //
        // throws
        //        AMQPError.INVALID_FRAME
        //        AMQPError.UNKNOWN_METHOD_FRAME
        //
        // [classid][methodid][fields][frame_end]
        //----------------------------------------------------------
        public function parseMethodFrame(data:ByteArray, frame:Frame) {
            var valid :Boolean    = false;
            
            // read the class id and method id
            frame.classIndex = uint(parseValue("class_id", data));
            frame.methodIndex = uint(parseValue("method_id", data));
            
            // debug
            //trace("parseMethodFrame "+frame.classIndex+" "+frame.methodIndex+" "+frame.frameSize);
            
            // retrieve the xml representation of the method
              var methodXML:XMLList=_amqp.xml.elements("class").(@index==frame.classIndex).method.(@index==frame.methodIndex);

            // make sure we found a valid method and only one version of it
            AMQPError.throwIf(Boolean(methodXML == null || methodXML.length()!=1), AMQPError.UNKNOWN_METHOD_FRAME);
            
            frame.className = String(methodXML.parent().@name);
            frame.methodName = String(methodXML.@name);
            frame.hasContent = Boolean(String(methodXML.@content)=="1");
            
            // loop through the field tags in the method parsing out the values
            for each(var fieldXML:XML in methodXML[0].elements("field")) {        
                frame.setField(fieldXML.@name, parseValue(getDomain(fieldXML), data));
            }
            
            //should have frame _end left
            if(data.bytesAvailable > 0) {
                valid = data.readUnsignedByte() == FRAME_END;
            }
                
            AMQPError.throwIf(!valid, AMQPError.INVALID_FRAME);            
        }
        
        //----------------------------------------------------------
        // parseHeaderFrame
        // parses a heder frame and returns an object that contains
        // all properties within the frame
        //
        // throws
        //        AMQPError.UNKNOWN_HEADER_FRAME
        //        AMQPError.INVALID_FRAME
        //
        // [classid][properties]
        //----------------------------------------------------------
        public function parseHeaderFrame(data:ByteArray, frame:Frame) {
            var valid :Boolean    = false;
            
            // read the class id and method id
            var classIndex:uint = parseValue("class_id", data);
                        
            // retrieve the xml representation of the class
              var classXML:XMLList=_amqp.xml.elements("class").(@index==classIndex);

            // make sure we found a valid method and only one version of it
            AMQPError.throwIf(Boolean(classXML == null || classXML.length()!=1), AMQPError.UNKNOWN_HEADER_FRAME);
        
            var wieght=data.readShort(); //weight
            
            //body size
            var lower = data.readUnsignedInt(); 
            frame.bodySize = data.readUnsignedInt();        
            var propFlags = data.readUnsignedShort();
            
            var bit:int = 15;

            // loop through the field tags in the header reading any properties that where set
            for each(var propXML:XML in classXML[0].elements("field")) {
                if (propFlags & (1 << bit)) {
                    // set the value of the field into the return object
                    frame.setField(propXML.@name, parseValue(getDomain(propXML), data));
                }
                bit--;
            }            
            
            //should have frame _end left
            if(data.bytesAvailable > 0) {
                valid = data.readUnsignedByte() == FRAME_END;
            }
                        
            AMQPError.throwIf(!valid, AMQPError.INVALID_FRAME);        
        }
        
        //----------------------------------------------------------
        // getDomain - helper function
        //----------------------------------------------------------
        public function getDomain(xml:XML):String {
            var type:String=null;
            type=xml.@domain;
            // types are in as domains
            if (type=="") {
                type=xml.@type;
            }
    
            return type;
        }
        
        //----------------------------------------------------------
        // parseBodyFrame
        // parses a heder frame and returns an object that contains
        // all properties within the frame
        //
        // throws
        //        AMQPError.INVALID_FRAME
        //
        // [classid][properties]
        //----------------------------------------------------------
        public function parseBodyFrame(data:ByteArray, frame:Frame) {
            var valid:Boolean=false;
                        
            // parse out the body
            frame.body=String(data.readUTFBytes(frame.frameSize));
            
            //should have frame _end left
            if(data.bytesAvailable > 0) {
                valid = data.readUnsignedByte() == FRAME_END;
            }
                        
            AMQPError.throwIf(!valid, AMQPError.INVALID_FRAME);    
        }
        
        //----------------------------------------------------------
        // parseValue  t can be a domain or a type
        // Need to fix this. should not have these hard coded keys
        //----------------------------------------------------------
        public function parseValue(t:String, data:ByteArray):* {
            var type:String="";
            
            // retrieve type from domain. this should work becuase all of the
            // table types where added as domains. and all types are also 
            // declared asdomains
              var xmlNodeList:XMLList=_amqp.xml.domain.(@name==t);
            if (xmlNodeList.length()==1) {            
                type=String(xmlNodeList[0].@type);
            }
            
            switch (type) {
                case "bit":
                    return _bit.readBit(data);
                break;
                case "octet":
                    _bit.reset();
                    return data.readUnsignedByte();
                break;
                case "short":
                    _bit.reset();
                    return data.readUnsignedShort();
                break;
                case "long":
                    _bit.reset();
                    return data.readUnsignedInt();
                break;
                case "longlong":
                    var ll_u=data.readUnsignedInt();                    
                    return data.readUnsignedInt();
                break;
                case "shortstr":
                    _bit.reset();
                    //read length of string
                    var ss_l:uint = data.readUnsignedByte();
                    return data.readUTFBytes(ss_l);
                break;
                case "longstr":            
                    _bit.reset();
                    //read length of string
                    var ls_l:uint = data.readUnsignedInt();
                    
                    //read buffer
                    var bytes:ByteArray = new ByteArray();
                    if (ls_l) {
                        data.readBytes(bytes, 0, ls_l);
                        bytes.position = 0;
                    }
                    
                    return bytes;
                break;
                case "timestamp":
                    _bit.reset();
                    var ts_u:uint = data.readUnsignedInt();
                    var ts_l:uint = data.readUnsignedInt();
                    return ts_l;
                break;
                case "table":            
                    _bit.reset();
                    // create an object to hold the table fields
                    var table:Object=new Object()
                    // read the table length
                    var t_l:uint = parseValue("long", data);
                    
                    if(t_l != 0) {    
                        //get current position in buffer
                        var start:uint = data.position; 
                        //loop through buffer reading each field
                        while(data.position < (start + t_l)) {                            
                            // read name of field
                            var n:String = parseValue("shortstr", data);
                            
                            // read table type and value                
                            table[n]=parseValue(String.fromCharCode(int(parseValue("octet", data))), data)
                        }
                    }
                    
                    return table;
                break;
                default:
                    AMQPError.throwError(AMQPError.UNKNOWN_TYPE, " ["+type+"]");        
                break;
            }        
        }    
        
        //--------------------------------------------------------------------------- 
        // writeValue   t can be a domain or a type
        //--------------------------------------------------------------------------- 
        private function writeValue(t:String, value:*, b:ByteArray) {    
            var type:String="";
            
            // retrieve type from domain. this should work becuase all of the
            // table types where added as domains. and all types are also 
            // declared asdomains
              var xmlNodeList:XMLList=_amqp.xml.domain.(@name==t);
            if (xmlNodeList.length()==1) {            
                type=String(xmlNodeList[0].@type);
            }        
        
            switch (type) {
                case "bit":
                    // not sure how the boolean came in. so make a stab at it.
                    // looks for "true" or "1" or a number greater then 0;
                    var val:Boolean =false;
                    if (value is Number && value>0) {
                        val=true;
                    } else if (value is String) {
                        if (value=="1" || value.toLowerCase()=="true") {
                            val=true
                        }
                    } else if (value is Boolean) {
                        val=value;
                    }
                    
                    _bit.writeBit(val, b);
                break;
                case "octet":
                    _bit.flush(b);
                    b.writeByte(int(value));
                break;
                case "short":
                    _bit.flush(b);
                    b.writeShort(int(value));
                break;
                case "long":
                    _bit.flush(b);
                    b.writeUnsignedInt(uint(value));
                break;
                case "longlong":
                    _bit.flush(b);
                    b.writeUnsignedInt(uint(0));
                    b.writeUnsignedInt(uint(value));
                break;
                case "shortstr":
                    _bit.flush(b);
                    var shortstr=String(value);
                    //if (shortstr.length) {
                        b.writeByte(shortstr.length);
                        b.writeUTFBytes(shortstr);
                    //}
                break;
                case "longstr":        
                    _bit.flush(b);
                    var longstr=String(value)
                    //if (longstr.length) {
                        b.writeUnsignedInt(longstr.length);
                        b.writeUTFBytes(longstr);
                    //}
                break;
                case "timestamp":
                    _bit.flush(b);
                    b.writeUnsignedInt(0);
                    b.writeUnsignedInt(value);
                break;
                case "table":            
                    _bit.flush(b);
                    
                    var tb:ByteArray=new ByteArray();
                    
                    for (var k:* in value) {                    
                        // write key name
                        writeValue("shortstr", String(k), tb);    
                        
                        //get the class name of the object
                        //these are in the version xml as domains
                        var className:String = flash.utils.getQualifiedClassName( value[k] );

                        var tableType:String="";
                        var xmlType:XMLList=_amqp.xml.domain.(@name==className);
                        
                        if (xmlType.length()==1) {            
                            tableType=String(xmlType[0].@type);
                        }    
                        
                        //write value type
                        writeValue("octet", tableType.charCodeAt(0), tb);        
                        
                        //write value
                        writeValue(tableType, value[k], tb);                            
                    }
                    
                    tb.position=0;
                    writeValue("long", tb.length, b);
                    b.writeBytes(tb);
                break;
                default:
                    AMQPError.throwError(AMQPError.UNKNOWN_TYPE, " ["+type+"]");            
                break;
            }
        }
        
        //----------------------------------------------------------
        // buildMethodFrame builds a method frame
        // The returned object will have the following fields in it
        //     "method" - contains a method frame
        //  "responses" an array of possible response names for the method
        //  if it has content it will also have the following two field
        //     "header" - contains the header frame
        //     "body" - contains the content/body to be sent

        //----------------------------------------------------------
        public function buildMethodFrame(method:String, fields:Object, body:*=null):PackedFrame {
            
            var frame:Object = new Object();
            
            // get method
            var indexes:Array = method.split(".");
            
            AMQPError.throwIf(Boolean(indexes.length!=2), AMQPError.UNKNOWN_METHOD, " ["+method+"]");
            
            // search by name
              var methodXML:XMLList=_amqp.xml.elements("class").(@name==indexes[0]).method.(@name==indexes[1]);
            
            // search by id
            if (methodXML == null || methodXML.length()!=1) {
                  methodXML=_amqp.xml.elements("class").(@index==indexes[0]).method.(@index==indexes[1]);
            }
            
            // make sure we found a valid method and only one version of it
            AMQPError.throwIf(Boolean(methodXML == null || methodXML.length()!=1), AMQPError.UNKNOWN_METHOD, " ["+method+"]");
            
            var packedFrame=new PackedFrame(methodXML[0].parent().@name+"."+methodXML[0].@name);
            
            // build the response array    
            for each(var responseXML:XML in methodXML[0].elements("response")) {
                packedFrame.addResponse(String(responseXML.@name));
            }

            // build the method frame
            //frame["method"]=new ByteArray();
            
            //write the class and method ids
            writeValue("short", int(methodXML[0].parent().@index), packedFrame.method);
            writeValue("short", int(methodXML[0].@index), packedFrame.method);
            
            // pack up fields            
            for each(var fieldXML:XML in methodXML[0].elements("field")) {
                // check if the field was passed in
                var f:*=fields[fieldXML.@name];
                
                if (f==undefined) { // should check if value field is not there
                        writeValue(getDomain(fieldXML), fieldXML.@value, packedFrame.method);
                } else {
                    writeValue(getDomain(fieldXML), f, packedFrame.method);
                }
            }
            
            // flush _bit if single boolean was last one in
            _bit.flush(packedFrame.method);

            // check if we need to send header and body
            if (int(methodXML[0].@content)==1) {
                
                // build body first so we know the size
                //frame["body"]=new ByteArray();
                if (body!=null) {
                    packedFrame.body.writeUTFBytes(body);
                }
                
                // build header
                //frame["header"]=new ByteArray();
                buildHeaderFrame(methodXML[0].parent(), packedFrame.header, packedFrame.body.length, fields);
            }
            
            return packedFrame;
        }
        
        //----------------------------------------------------------
        // buildHeaderFrame
        //----------------------------------------------------------
        public function buildHeaderFrame(classXML:XML, header:ByteArray, bodySize:uint, fields:Object) {
            
            //write the class id
            writeValue("short", int(classXML.@index), header);
            
            //write wieght
            writeValue("short", 0, header);
        
            //write size of body
            writeValue("longlong", bodySize, header);
                        
            // pack up property fields and set property flag    .    
            // protocol only supports 15 properties. bit is set per property in 
            // the order of the properties
            var propFlag:uint=0;
            var bit:int = 15;
            var propBuffer:ByteArray=new ByteArray();
            
            for each(var fieldXML:XML in classXML.elements("field")) {
            
                // check if over 15 properties
                AMQPError.throwIf(Boolean(bit<1), AMQPError.UNKNOWN_METHOD, " ["+classXML.@name+"]");
                
                // check if the field was passed in
                var f:*=fields[fieldXML.@name];
                if (f==undefined) {
                    if (fieldXML.@value != undefined) {
                        writeValue(getDomain(fieldXML), fieldXML.@value, propBuffer);
                        propFlag |= (1 << bit);
                    }
                } else {
                    writeValue(getDomain(fieldXML), f, propBuffer);
                    propFlag |= (1 << bit);
                }
                bit--;
            }
            
            // flush _bit if single boolean was last one in
            _bit.flush(header);
            
            // write the property flag
            writeValue("short", propFlag, header);
            
            // reset position
            propBuffer.position=0;
        
            // add in the prop buffer
            header.writeBytes(propBuffer);
        }
    }
}
