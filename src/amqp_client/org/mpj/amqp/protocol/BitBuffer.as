package org.mpj.amqp.protocol {
    
    import flash.utils.ByteArray;
    
    public class BitBuffer {
        private var bits        :uint        = 0;
        private var mask        :uint        = 1;

        //----------------------------------------------------------
        // BitBuffer
        //----------------------------------------------------------
        public function BitBuffer() {
        }
        
        //----------------------------------------------------------
        // flush
        //----------------------------------------------------------
        public function flush(b:ByteArray):void {
            if(mask > 1) {
                b.writeByte(bits);
                reset();
            }
        }
        
        //----------------------------------------------------------
        // writeBit
        //----------------------------------------------------------
        public function writeBit(bit:Boolean, b:ByteArray):void {

            if(mask > 128) {
                flush(b);
            }
            
            if(bit) {
                bits |= mask;
            }
            
            mask <<= 1;
        }

        //----------------------------------------------------------
        // readBit
        //----------------------------------------------------------
        public function readBit(b:ByteArray):Boolean {
            
            if(mask > 128 || mask == 1) {
                bits = b.readUnsignedByte();
                mask = 1;
            }
            
            var bit:Boolean = (bits & mask) != 0;
            mask <<= 1;
            
            return bit;
        }
        
        //----------------------------------------------------------
        // reset
        //----------------------------------------------------------
        public function reset():void {
            bits = 0;
            mask = 1;
        }
    }
}
