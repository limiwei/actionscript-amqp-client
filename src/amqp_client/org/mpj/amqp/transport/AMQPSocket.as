package org.mpj.amqp.transport  {
    import flash.net.Socket;
    import flash.events.ProgressEvent;
    import flash.utils.ByteArray;
    import org.mpj.amqp.events.FrameEvent;

    public class AMQPSocket extends Socket {
        
        private var STATE_HEADER    :Number = 0;
        private var STATE_FRAME     :Number = 1;        
        private var HEADER_LENGTH   :Number = 7;    // size of the AMQP header
        
        private var _buffer         :ByteArray = null;
        private var _required       :Number = HEADER_LENGTH;
        private var _state          :Number = STATE_HEADER;
    
        //----------------------------------------------------------
        // AMQPSocket
        //----------------------------------------------------------
        public function AMQPSocket() {            
            addEventListener(ProgressEvent.SOCKET_DATA, onDataReceived);
        }
        
        //----------------------------------------------------------
        // sendFrame
        //----------------------------------------------------------
        public function sendFrame(type:int, frame:ByteArray, end:int, channel:uint=0):void {
            
            frame.position=0;
            
            writeByte(type);
            writeShort(channel);
            writeUnsignedInt(frame.length);
            writeBytes(frame);
            writeByte(end);
            
            flush();
        }
        
        //----------------------------------------------------------
        // onDataReceived
        //----------------------------------------------------------
        protected function onDataReceived(e:ProgressEvent):void {
            
            // create the buffer as required
            if(_buffer == null) {
                _buffer = new ByteArray();
            }
            
            // read any bytes available on the socket
            readBytes(_buffer);
            _buffer.position=0;
            
            while (_buffer.position < _buffer.length) {
                
                // reset to read header
                _state=STATE_HEADER;
                
                //reset the required buffer before processing
                _required=HEADER_LENGTH;

                //parse out frame from the buffer
                parseFrame();    
                
            }
            
            _buffer = null;
        }
        
        //----------------------------------------------------------
        // parseFrame,  
        // read a frame from the buffer
        //----------------------------------------------------------
        protected function parseFrame():void {
            if (_state==STATE_HEADER) {                
                var type:uint= _buffer.readUnsignedByte();
                var channel:uint= _buffer.readUnsignedShort();
                var frameSize:uint= _buffer.readUnsignedInt();
                
                _required+=frameSize+1; // 1 for frame end
                
                _state=STATE_FRAME;        
            }        
            
            // we have a header, check if all the frame is there
            // we should always get the whole frame
            if (_state==STATE_FRAME && _buffer.length>=_required) {
                var frame :ByteArray = new ByteArray();
                _buffer.position-=HEADER_LENGTH;
                _buffer.readBytes(frame, 0, _required);
                
                // dispatch the frame
                dispatchEvent(new FrameEvent(FrameEvent.FRAME_READY, frame));
            }
        }
    }
}
