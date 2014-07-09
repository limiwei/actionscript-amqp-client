package org.mpj.amqp.promise {
    import org.mpj.amqp.frame.Frame;
    
    public class PromiseFault {
        private var _code           :uint      = 0;
        private var _text           :String    = "";
        private var _frame          :Frame     = null;

        public function get code()  :uint       { return _code; }
        public function get text()  :String     { return _text; }
        public function get hasFrame():Boolean  { return Boolean(_frame!=null); }
        public function get frame() :Frame      { return _frame; }


        //---------------------------------------------------------------------------
        // PromiseFault
        //---------------------------------------------------------------------------
        public function PromiseFault(code:uint, text:String, frame:Frame=null) {
            _code=uint(code);
            _text=String(text);
            if (frame!=null) {
                _frame=frame.clone();        
            }
        }    
    }
}
