package org.mpj.amqp.utils {
    import flash.utils.ByteArray;
    
    //----------------------------------------------------------
    // some basic object functions. did this in order to not
    // have to pull in flex
    //----------------------------------------------------------
    
    public class ObjectUtils {

        //----------------------------------------------------------
        // copy
        //----------------------------------------------------------
        public static function copy( value:Object ):Object {
            var buffer:ByteArray = new ByteArray();
            buffer.writeObject(value);
            buffer.position = 0;
            
            var result:Object = buffer.readObject();
            return result;        
        }
        
        //----------------------------------------------------------
        // dumpObject
        //----------------------------------------------------------
        public static function dumpObject(o : Object, s : String="") {
            var i : String;
            
            if (s=="") { trace("-----start-----"); }

            for (i in o)
            {
                trace(s + i + "=" + o[i] + " (" + typeof(o[i]) + ")");
                
                dumpObject(o[i], s + "   ");
            }
            
            if (s=="") { trace("-----end-----"); }
        }
    }
}
