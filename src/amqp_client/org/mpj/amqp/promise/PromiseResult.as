package org.emc.amqp.promise {
    import org.mpj.amqp.frame.Frame;
    
    public class PromiseResult {
        private var _success            :Boolean    = false;
        private var _frame              :Frame      = null;
        
        public function get success()   :Boolean    { return _success; }
        public function get hasFrame()  :Boolean    { return Boolean(_frame!=null); }
        public function get frame()     :Frame      { return _frame; }

        //---------------------------------------------------------------------------
        // PromiseResult
        //---------------------------------------------------------------------------
        public function PromiseResult(success:Boolean, frame:Frame=null) {
            _success=success;
            if (frame!=null) {
                _frame=frame.clone();        
            }
        }
    }
}
