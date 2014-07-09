package  org.mpj.amqp {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.utils.Dictionary;
    import flash.events.EventDispatcher;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    
    import org.mpj.amqp.transport.AMQPSocket;
    import org.mpj.amqp.protocol.AMQPParser;
    import org.mpj.amqp.frame.Frame
    import org.mpj.amqp.error.AMQPError;
    import org.mpj.amqp.utils.ObjectUtils;
    import org.mpj.amqp.events.FrameEvent;
    import org.mpj.amqp.events.ConnectionEvent;
    import org.mpj.amqp.events.ChannelEvent;
    
    public class Connection extends EventDispatcher {    
        private const STATE_CLOSED         :int = 0;
        private const STATE_OPENED         :int = 1;
            
        // constants for the library
        private static const _product      :String = "AS-AMQP";
        private static const _version      :String = "1.0.0";
   
        private var _socket                :AMQPSocket;
        private var _parser                :AMQPParser;
        private var _controlChannel        :Channel;
        private var _controlHandlers       :Dictionary = new Dictionary();
        private var _reconnectTimer        :Timer = null;
        private var _reconnectTime         :Number = 100;
        private var _secondaryReconnectTime:Number = 1000;
        private var _state                 :int = STATE_CLOSED;
        
        // need to store this as an object. if channels close need a way
        // to get rid of them
        private var _channels               :Array = [];
        
        public function get socket()        :AMQPSocket    { return _socket; }
        public function get parser()        :AMQPParser    { return _parser; }
        
        public function isReady():Boolean    { return Boolean(_state==STATE_OPENED); }
        
        private var parameters:*    = {
            protocol    : AMQPParser.v0_9_1,
            host        : "127.0.0.1",
            port        : 5672,
            virtual_host: "/",
            user        : "guest",
            password    : "guest",
            heartbeat    : false
        };    
        
        //----------------------------------------------------------
        // Connection
        //----------------------------------------------------------
        public function Connection(connectionParameters:*, autoConnect:Boolean=true) {
            
            for(var k:* in connectionParameters) {
                parameters[k] = connectionParameters[k];
            }
            
            try {                            
                // create the AMQP parser. This is used to parse the AMQP frame
                _parser=new AMQPParser(parameters.protocol);
                
                // create a new AMQP socket. This will open a socket connection to the server
                // and read frames off the sockets. When a full frame is read it will emit
                // a FrameEvent.FRAME_READY event.
                _socket= new AMQPSocket();
                
                // socket events
                _socket.addEventListener(Event.CONNECT, onSocketConnect);
                _socket.addEventListener(Event.CLOSE, onSocketClose);
                _socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
                _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketSecurityError);
                
                // frame events
                _socket.addEventListener(FrameEvent.FRAME_READY, onFrameReady);

                _controlChannel=new Channel(0, this, false);
                
                // setup control handler functions
                _controlHandlers[10]=onConnectionStart;
                _controlHandlers[20]=onConnectionSecure;
                _controlHandlers[30]=onConnectionTune;
                _controlHandlers[41]=onConnectionOpenOk;
                _controlHandlers[50]=onConnectionClose;
                _controlHandlers[51]=onConnectionCloseOk;
                
                _reconnectTimer = new Timer(_reconnectTime);
                _reconnectTimer.addEventListener(TimerEvent.TIMER, doReconnect);

                // auto connect if set
                if (autoConnect) {
                    reconnect();
                }    
            } catch (error:Error) {
                throw error;
            }
        }
        
        //----------------------------------------------------------
        // connect
        //----------------------------------------------------------
        public function connect(host:String=null, user:String=null, pass:String=null) {
            if (user!=null) {
                parameters.user=user;
            }
            if (pass!=null) {
                parameters.pass=pass;
            }
            
            if (host!=null) {
                parameters.host=host;
            }            
            
            reconnect();
        }
        
        //----------------------------------------------------------
        // disconnect
        //----------------------------------------------------------
        public function disconnect() {
            _controlChannel.sendMethod("connection.close");
        }
    
        //----------------------------------------------------------
        // getMethods
        //  passthrough - returns a list of all method names
        //----------------------------------------------------------
        public function getMethods():Array {
            return _parser.getMethods();
        }    
        
        //----------------------------------------------------------
        // getFields
        //  passthrough - returns a list of all fields for the given method
        //----------------------------------------------------------
        public function getFields(methodName:String):Array {
            return _parser.getFields(methodName);
        }
        
        //----------------------------------------------------------
        // setState
        //----------------------------------------------------------
        public function setState(state:int, frame:Frame=null):void {
            _state=state;
            
            switch (_state) {
                case STATE_CLOSED:
                    dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_STATE_CLOSED, frame));
                break;
                
                case STATE_OPENED:
                    dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_STATE_READY, frame));
                break;
            }
        }        
        
        /*
        * Channel functions
        *
        */    
        
        //----------------------------------------------------------
        // channel gets the last channel
        //----------------------------------------------------------
        public function get channel():Channel {
            return _channels[_channels.length - 1] == null ? createChannel() : _channels[_channels.length - 1];
        }
        
        //----------------------------------------------------------
        // creates a new channel
        //----------------------------------------------------------
        public function createChannel():Channel {
            
            var c=new Channel(_channels.length + 1,this, true);
            
            this.addEventListener(ConnectionEvent.CONNECTION_STATE_READY, c.onConnectionReady);
            this.addEventListener(ConnectionEvent.CONNECTION_STATE_CLOSED, c.onConnectionClosed);
            
            _channels.push(c);
            
            return channel;
        }
        
        //----------------------------------------------------------
        // doReconnect
        // attempt to reconnect
        //----------------------------------------------------------
        private function doReconnect(e:TimerEvent):void {    
        
            // attempt to open the socket
            _socket.connect(parameters.host, parameters.port);
            
            // set delay to a second for all future reconnects
            _reconnectTimer.delay=_secondaryReconnectTime;
        }
        
        //----------------------------------------------------------
        // reconnect
        //----------------------------------------------------------
        public function reconnect() {
            _reconnectTimer.start();
        }
        
        //----------------------------------------------------------
        // onSocketConnect 
        // start negotiating when socket is connected
        //----------------------------------------------------------
        private function onSocketConnect(e:Event):void {
            
            // socket is opened. stop the timer
            _reconnectTimer.stop();
                        
            // start the seven step authentication process
            startNegotiating();
        }
                
        //----------------------------------------------------------
        // onSocketClose
        //----------------------------------------------------------
        private function onSocketClose(e:Event):void {
            
            // this should happen in the onclose event or oncloseok event
            // added here in case rabbitmq server goes down.
            setState(STATE_CLOSED);
            
            dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_CLOSED));
            
            //set timer back
            _reconnectTimer.delay=_reconnectTime;
        }
        
        //----------------------------------------------------------
        // onSocketError
        // need to hanldle this. if the socket went down need to
        // clean everything up
        //----------------------------------------------------------
        private function onSocketError(e:IOErrorEvent):void {
            dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_SOCKET_ERROR, null, e));
        }
            
        //----------------------------------------------------------
        // onSocketSecurityError
        // need to hanldle this. if the socket went down need to
        // clean everything up
        //----------------------------------------------------------
        private function onSocketSecurityError(e:SecurityErrorEvent):void {
            dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_SECURITY_EVENT, null, e));
        }    
        
        //----------------------------------------------------------
        // onFrameReady
        // need to do somethign with these traces?
        //----------------------------------------------------------
        private function onFrameReady(event:FrameEvent):void {

            //parse the frame into an object
            var frame:Frame=_parser.parseFrame(event.frame);
        
            //trace("recieved "+frame.name);
            //ObjectUtils.dumpObject(frame.fields);
            
            // handle the frame. channel 0 is control channel
            if(frame.channel == 0 ) {        
                if (frame.classIndex==10) {
                    var f:Function;
                    try {
                        f=_controlHandlers[frame.methodIndex];
                    }
                    catch(e:TypeError) {
                        trace("unkown method id for control frame "+frame.methodIndex);
                    }

                    if (f==null) {
                        trace("unkown method id for control frame "+frame.methodIndex);
                    } else {
                        f(frame);    
                    }
                } else {
                    trace("unhandled class id for control frame "+frame.methodIndex);
                }
            } else {
                if(_channels[frame.channel - 1] is Channel) {
                    (_channels[frame.channel - 1] as Channel).processFrame(frame);
                } else {
                    trace("unknown channel id "+frame.channel);
                }
            }
        }
        
        /*
        * Handlers for the seven step negotiation process
        *
        */
        
        //----------------------------------------------------------
        // startNegotiating
        // STEP ONE
        //----------------------------------------------------------
        private function startNegotiating():void {
            _socket.writeUTFBytes("AMQP");
            _socket.writeByte(1);
            _socket.writeByte(1);
            _socket.writeByte(_parser.VERSION_MAJOR);
            _socket.writeByte(_parser.VERSION_MINOR);
            _socket.flush();    
        }
        
        //----------------------------------------------------------
        // onConnectionStart
        // STEP TWO
        //----------------------------------------------------------
        private function onConnectionStart(frame:Frame):void {
            
            //check version
            // should handle this better, could try a different protocol version
            if (frame.fields.version_major != _parser.VERSION_MAJOR ||
                frame.fields.version_minor != _parser.VERSION_MINOR) {
                
                _socket.close();
                
                AMQPError.throwError(AMQPError.VERSION_MISMATCH, 
                                  " ["+frame.fields.version_major+
                                  ":"+_parser.VERSION_MAJOR+
                                  "]"+
                                  " ["+frame.fields.version_minor+
                                  ":"+_parser.VERSION_MINOR+"]");    
            }
            
            // STEP THREE  reply with StartOK
            _controlChannel.sendMethod("connection.start-ok", {client_properties:{product:_product,version:_version},
                                                                  response:{LOGIN:parameters.user, PASSWORD:parameters.password}});
        }
        
        //----------------------------------------------------------
        // onConnectionSecure
        // fire a ConnectionSecure event with the frame. the secure-ok method
        // will need to be sent in the event handler
        //----------------------------------------------------------
        private function onConnectionSecure(frame:Frame):void {
            dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_SECURE, frame));
        }
        
        //----------------------------------------------------------
        // sendSecureOk
        // pass in the an object with the response field set
        // ex { response:OBJECT }, where object is the buffe that needs
        // to be sent back to server
        //----------------------------------------------------------
        public function sendSecureOk(obj:Object):void {    
            _controlChannel.sendMethod("connection.secure-ok", obj);
        }        
        
        //----------------------------------------------------------
        // onConnectionStart
        // STEP FOUR
        //----------------------------------------------------------
        private function onConnectionTune(frame:Frame):void {
            
            // STEP FIVE  send tune.ok
            _controlChannel.sendMethod("connection.tune-ok", {channel_max:frame.fields.channel_max,
                                                                 frame_max:frame.fields.frame_max,
                                                              heartbeat:frame.fields.heartbeat});
            
            // STEP SIX send connection open        
            _controlChannel.sendMethod("connection.open", {virtual_host:parameters.virtual_host});
        }
        
        //----------------------------------------------------------
        // onConnectionOpenOk
        //----------------------------------------------------------
        private function onConnectionOpenOk(frame:Frame):void {
            
            setState(STATE_OPENED);
            
            dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_READY));
        }
        
        //----------------------------------------------------------
        // onConnectionClose
        // this will come in if there was a major error
        //----------------------------------------------------------
        private function onConnectionClose(frame:Frame):void {
            
            setState(STATE_CLOSED, frame);
            
            // reply back with close_ok
            _controlChannel.sendMethod("connection.close-ok");
            reconnect();
        }
        
        //----------------------------------------------------------
        // onConnectionCloseOK
        // 
        //----------------------------------------------------------
        private function onConnectionCloseOk(frame:Frame):void {
            
            setState(STATE_CLOSED, frame);
            
            // reply back with close_ok
            _controlChannel.sendMethod("connection.close-ok");
        }
    }
}
