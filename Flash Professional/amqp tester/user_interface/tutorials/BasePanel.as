package  {
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import org.emc.amqp.Connection;
	
	public class BasePanel extends Sprite {
		protected var _connection	:Connection;
		protected var _rabbitFlash	:RabbitFlash;

		public function BasePanel(connection:Connection, rabbitFlash:RabbitFlash) {

			addEventListener(flash.events.Event.ADDED_TO_STAGE, onInit);		
			_connection=connection;
			_rabbitFlash=rabbitFlash;
		}
		
		//----------------------------------------------------------
		// onInit
		//----------------------------------------------------------
		private function onInit(event:flash.events.Event):void {
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, onInit);
			
			var format:TextFormat = new TextFormat();
            format.size = 22;
			format.bold = true;
			this["header_txt"].setStyle("textFormat", format);

			doInit();
		}
		
		//----------------------------------------------------------
		// doInit
		//----------------------------------------------------------
		protected function doInit():void {
			
		}
		
		//----------------------------------------------------------
		// connectionReady
		//----------------------------------------------------------
		public function connectionReady():void {
			
		}
		
		//----------------------------------------------------------
		// connectionClosed
		//----------------------------------------------------------
		public function connectionClosed():void {
			
		}
		
		//----------------------------------------------------------
		// appendLog
		//----------------------------------------------------------
		public function appendLog(msg:String):void  {
			_rabbitFlash.appendLog(msg);
		}
		
		//----------------------------------------------------------
		// appendConsumer
		//----------------------------------------------------------
		public function appendConsumer(msg:String):void  {
			_rabbitFlash.appendConsumer(msg);
		}		
		
		//----------------------------------------------------------
		// dumpObject
		//----------------------------------------------------------
		public function dumpObject(o : Object, n:String, s : String="") {
			var i : String;
			
			if (s=="") { 
				_rabbitFlash.appendLog("<b>--- "+n+" ---</b>"); 
			}

			for (i in o)
			{
				_rabbitFlash.appendLog(s + i + "=" + o[i] + " (" + typeof(o[i]) + ")");
				
				dumpObject(o[i], n, s + "   ");
			}
			
			if (s=="") { _rabbitFlash.appendLog("<b>--- end ---</b>"); }
		}

	}
}
