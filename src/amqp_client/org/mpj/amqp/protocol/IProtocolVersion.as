package org.mpj.amqp.protocol {    
    public interface IProtocolVersion {        
        // getters
        function get FRAME_METHOD()      :int;
        function get FRAME_HEADER()      :int;
        function get FRAME_BODY()        :int;
        function get FRAME_HEARTBEAT()   :int;
        function get FRAME_END()         :int;
        function get VERSION_MAJOR()     :int;
        function get VERSION_MINOR()     :int;
        function get VERSION_REVISION()  :int;

        // returns the protocol definition in XML format
        function get xml():XML;
    }
}
