package org.mpj.amqp.promise {
    import flash.net.registerClassAlias;
    import flash.utils.ByteArray;

    public class Promise {
        private var onResultFunction    :Function = null;
        private var onFaultFunction     :Function = null;
        
        //----------------------------------------------------------
        // Promise
        //----------------------------------------------------------
        public function Promise() {
        }
        
        //----------------------------------------------------------
        // fault
        // returns a PromiseFault class
        //----------------------------------------------------------
        public function fault(info:PromiseFault):void {
            if (onFaultFunction!=null && onFaultFunction is Function) {
                onFaultFunction(info);
            }
        }
        
        //----------------------------------------------------------
        // result
        // returns a PromiseResult class
         //----------------------------------------------------------
        public function result(data:PromiseResult):void {
            if (onResultFunction!=null && onResultFunction is Function) {
                onResultFunction(data);
            }
        }
        
        //----------------------------------------------------------
        // onResult
        // the function passed in must be in the form of;
        // f(data:PromiseResult)
        // (do not have to use "data", but the type needs to PromiseResult
        //----------------------------------------------------------
        public function onResult(f:Function) {
            onResultFunction=f;
        }
        
        //----------------------------------------------------------
        // onFault
        // the function passed in must be in the form of;
        // f(info:PromiseFault) 
        // (do not have to use "info", but the type needs to PromiseFault
        //----------------------------------------------------------
        public function onFault(f:Function) {
            onFaultFunction=f;
        }
        
        //----------------------------------------------------------
        // make a copy of this class
        //----------------------------------------------------------
        public function clone() : Promise
        {
            registerClassAlias( "org.emc.amqp.promise.Promise", Promise );
            var bytes : ByteArray = new ByteArray();
            bytes.writeObject( this );
            bytes.position = 0;
            return bytes.readObject() as Promise;
        }
    }
}
