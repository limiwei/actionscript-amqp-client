package org.mpj.amqp.error  {
    import flash.utils.Dictionary;
    
    public class AMQPError {
        
        private static var _errorStrings                :Dictionary=new Dictionary();
        
        /*    
        Standard AMQP errors, this is as of version 0-9-1
        */    
        public static var     CONTENT_TOO_LARGE               :Number=311;
        public static var     NO_CONSUMERS                    :Number=313;
        public static var     CONNECTION_FORCED               :Number=320;
        public static var     INVALID_PATH                    :Number=402;
        public static var     ACCESS_REFUSED                  :Number=403;
        public static var     NOT_FOUND                       :Number=404;
        public static var     RESOURCE_LOCKED                 :Number=405;
        public static var     PRECONDITION_FAILED             :Number=406;
        public static var     FRAME_ERROR                     :Number=501;
        public static var     SYNTAX_ERROR                    :Number=502;
        public static var     COMMAND_INVALID                 :Number=503;
        public static var     CHANNEL_ERROR                   :Number=504;
        public static var     UNEXPECTED_FRAME                :Number=505;
        public static var     RESOURCE_ERROR                  :Number=506;
        public static var     NOT_ALLOWED                     :Number=530;
        public static var     NOT_IMPLENTED                   :Number=540;
        public static var     INTERNAL_ERROR                  :Number=541;

        /*    
        Errors for the library
        */    
        public static var     INVALID_PROTOCOL_VERSION        :Number=1000;
        _errorStrings        [INVALID_PROTOCOL_VERSION]       = "Invalid protocol version.";
        public static var     INVALID_PROTOCOL_DEFINITION     :Number=1001;
        _errorStrings        [INVALID_PROTOCOL_DEFINITION]    = "Invalid protocol definition.";
        public static var     UNKNOWN_FRAME                   :Number=1002;
        _errorStrings        [UNKNOWN_FRAME]                  = "Received unknown frame.";
        public static var     INVALID_FRAME                   :Number=1003;
        _errorStrings        [INVALID_FRAME]                  = "Received invalid frame.";
        public static var     UNKNOWN_METHOD_FRAME            :Number=1004;
        _errorStrings        [UNKNOWN_METHOD_FRAME]           = "Received unknown method frame.";
        public static var     UNKNOWN_DOMAIN                  :Number=1005;
        _errorStrings        [UNKNOWN_DOMAIN]                 = "Unknown domain.";
        public static var     UNKNOWN_TYPE                    :Number=1006;
        _errorStrings        [UNKNOWN_TYPE]                   = "Unknown type.";
        public static var     UNKNOWN_TABLE_TYPE              :Number=1007;
        _errorStrings        [UNKNOWN_TABLE_TYPE]             = "Unknown table type.";
        public static var     VERSION_MISMATCH                :Number=1008;
        _errorStrings        [VERSION_MISMATCH]               = "Version mismatch.";
        public static var     UNKNOWN_METHOD                  :Number=1009;
        _errorStrings        [UNKNOWN_METHOD]                 = "Attempting to send and unknown method.";
        public static var     INVALID_PROPERTIES              :Number=1010;
        _errorStrings        [INVALID_PROPERTIES]             = "Invalid number of properties for header.";
        public static var     UNKNOWN_HEADER_FRAME            :Number=1011;
        _errorStrings        [UNKNOWN_HEADER_FRAME]           = "Received unknown header frame.";
        
        
        //----------------------------------------------------------
        // toString
        //----------------------------------------------------------
        public static function toString(code:Number):String{
            var errorString=_errorStrings[code];
            
            if (errorString==null) {
                errorString="unknown"
            }
            
            return errorString;            
        }
        
        /*    
         *
         *     Utility functions to throw errors
         *
         */    
        
        //----------------------------------------------------------
        // throwError
        //----------------------------------------------------------
        public static function throwError(code:Number, addtionalString:String=""):void {
                throw new Error(toString(code)+addtionalString, code);
        }
        
        //----------------------------------------------------------
        // throwIf
        //----------------------------------------------------------
        public static function throwIf(condition:Boolean, code:Number, addtionalString:String=""):void {
            if (condition) {
                throw new Error(toString(code)+addtionalString, code);
            }
        }       
    }
}
