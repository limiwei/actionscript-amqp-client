package  {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.emc.amqp.Connection;
	import org.emc.amqp.promise.Promise;
	import org.emc.amqp.promise.PromiseFault;
	import org.emc.amqp.promise.PromiseResult;
	import org.emc.amqp.events.BasicDeliverEvent;
	
	public class TutorialOne extends BasePanel {

		public function TutorialOne(connection:Connection, rabbitFlash:RabbitFlash) {
			super(connection, rabbitFlash);
		}
		
		/***********************************************************
		
			Following code block are the tutorials
		
		 **********************************************************/
		 
		//----------------------------------------------------------
		// Sender
		//----------------------------------------------------------
		private function doSend(e:MouseEvent):void  {		
			// declare the queue
			var p:Promise = _connection.channel.sendMethod(
							"queue.declare", 
							{queue:"hello"});
			
			// send basic publish
			p.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				_connection.channel.sendMethod(
				"basic.publish", 
				{routing_key:"hello"}, 
				"Hello World!");
			});
		}
		
		
		//----------------------------------------------------------
		// Reciever
		//----------------------------------------------------------
		private function doRecieve(e:MouseEvent):void  {				
			// declare the queue
			var p:Promise = _connection.channel.sendMethod(
							"queue.declare", 
							{queue:"hello"});
			
			// send basic consume
			p.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				var cp:Promise = _connection.channel.sendMethod(
								"basic.consume", 
								{queue:"hello", no_ack:"true"});
				cp.onResult(function(info:PromiseResult) 
				{
					dumpObject(info.frame.fields, info.frame.name);
					//setup the listener
					_connection.channel.addEventListener(info.frame.fields.consumer_tag, onReceive);
				});
			});						
		}		
		
		//----------------------------------------------------------
		// onReceive
		//----------------------------------------------------------
		private function onReceive(e:BasicDeliverEvent):void {
			dumpObject(e.frame.fields, "BasicDeliverEvent");
			appendConsumer(e.frame.fields.consumer_tag+" [<b>"+ e.frame.body+"</b>]");
		}
		
		/***********************************************************
		
			End tutorials
		
		 **********************************************************/
	
	
		//----------------------------------------------------------
		// doInit
		//----------------------------------------------------------
		override protected function doInit():void {		
			
			send_btn.addEventListener(MouseEvent.CLICK, doSend);
			recieve_btn.addEventListener(MouseEvent.CLICK, doRecieve);
			
			source_txt.htmlText=
'/*********************************************************************************<br>\
 * Start Reciever<br>\
 *<br>\
 *********************************************************************************/<br>\
<br>\
var p:Promise = _connection.channel.sendMethod(<br>\
                 "queue.declare",<br>\
                 {queue:"hello"});<br>\
<br>\
// send basic consume<br>\
p.onResult(function(info:PromiseResult)<br>\
{<br>\
    var cp:Promise = _connection.channel.sendMethod(<br>\
                    "basic.consume",<br>\
                    {queue:"hello", no_ack:"true"});<br>\
    cp.onResult(function(info:PromiseResult)<br>\
    {<br>\
        //setup the listener<br>\
        _connection.channel.addEventListener(info.frame.fields.consumer_tag, onReceive);<br>\
    });<br>\
});<br><br>\
/*********************************************************************************<br>\
 * Send<br>\
 *<br>\
 *********************************************************************************/<br>\
<br>var p:Promise = _connection.channel.sendMethod(<br>\
                    "queue.declare",<br>\
                    {queue:"hello"});<br>\
<br>\
// send basic publish<br>\
p.onResult(function(info:PromiseResult)<br>\
{<br>\
   _connection.channel.sendMethod(<br>\
   "basic.publish",<br>\
   {routing_key:"hello"},<br>\
   "Hello World!");<br>\
});<br><br>\
';
}
		//----------------------------------------------------------
		// connectionReady
		//----------------------------------------------------------
		override public function connectionReady():void {
			
		}
		
		//----------------------------------------------------------
		// connectionClosed
		//----------------------------------------------------------
		override public function connectionClosed():void {
			
		}

	}
	
}
