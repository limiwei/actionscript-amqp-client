package  {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.emc.amqp.Connection;
	import org.emc.amqp.promise.Promise;
	import org.emc.amqp.promise.PromiseFault;
	import org.emc.amqp.promise.PromiseResult;
	import org.emc.amqp.events.BasicDeliverEvent;
	
	public class TutorialFive extends BasePanel {

		public function TutorialFive(connection:Connection, rabbitFlash:RabbitFlash) {
			super(connection, rabbitFlash);
		}
		
		/***********************************************************
		
			Following code block are the tutorials
		
		 **********************************************************/
		 
		//----------------------------------------------------------
		// emitMessage
		//----------------------------------------------------------
		private function emitMessage(routingKey:String="kern.info", msg:String="Hello World!"):void  {		
			
			// declare the exchange
			var p:Promise = _connection.channel.sendMethod(
					"exchange.declare", 
					{exchange:"topic_logs",type:"topic"});
			
			// send basic publish
			p.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				_connection.channel.sendMethod(
					 "basic.publish", 
					 {exchange:"topic_logs", routing_key:routingKey}, 
					 msg);
			});
		}
		
		
		//----------------------------------------------------------
		// recieveLogs
		//----------------------------------------------------------
		private function recieveLogs(bindingKeys:Array):void  {				
			// declare the exchange
			var p:Promise = _connection.channel.sendMethod(
					"exchange.declare", 
					{exchange:"topic_logs",type:"topic"});
						
			p.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				
				// declare a server named queue
				var qdp:Promise = _connection.channel.sendMethod(
								"queue.declare",
								{queue:"",exclusive:"true"});			
				
				qdp.onResult(function(info:PromiseResult) 
				{
					dumpObject(info.frame.fields, info.frame.name);
					bindQueue(info.frame.fields.queue, bindingKeys);
				})		
				
				qdp.onFault(function(info:PromiseFault) 
				{
					appendLog("Error sending method. ["+info.code+" : "+info.text+"]");
				})
			});
		}
		
		//----------------------------------------------------------
		// bindQueue
		//----------------------------------------------------------
		private function bindQueue(queue_name:String, bindingKeys:Array):void {
			var consumerSet:Boolean = false;
			
			for each (var binding in bindingKeys) {
				// bind the queue to the exchange
				var qbp:Promise = _connection.channel.sendMethod(
						"queue.bind", 
						{exchange:"topic_logs",queue:queue_name, routing_key:binding});
						
				qbp.onResult(function(info:PromiseResult) 
				{
					dumpObject(info.frame.fields, info.frame.name);
					if (!consumerSet) {
						consumerSet=true;
						// start conusmer
						var cp:Promise = _connection.channel.sendMethod(
										 "basic.consume", 
										 {queue:queue_name, no_ack:"true"});
						cp.onResult(function(info:PromiseResult) 
						{
							dumpObject(info.frame.fields, info.frame.name);
							
							//setup the listener
							_connection.channel.addEventListener(info.frame.fields.consumer_tag, onReceive);
						});
					}
				});
				
				qbp.onFault(function(info:PromiseFault) 
				{
					appendLog("Error sending method. ["+info.code+" : "+info.text+"]");
				})
			}
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
			
			emit_btn.addEventListener(MouseEvent.CLICK, doEmit);
			startReciver_btn.addEventListener(MouseEvent.CLICK, doStartReciever);
			
			source_txt.htmlText=
'//----------------------------------------------------------<br>\
// emitMessage<br>\
//----------------------------------------------------------<br>\
private function emitMessage(routingKey:String="kern.info", msg:String="Hello World!"):void  {<br>\
	<br>\
	// declare the exchange<br>\
	var p:Promise = _connection.channel.sendMethod(<br>\
			"exchange.declare", <br>\
			{exchange:"topic_logs",type:"topic"});<br>\
	<br>\
	// send basic publish<br>\
	p.onResult(function(info:PromiseResult) <br>\
	{<br>\
		dumpObject(info.frame.fields, info.frame.name);<br>\
		_connection.channel.sendMethod(<br>\
			 "basic.publish", <br>\
			 {exchange:"topic_logs", routing_key:routingKey}, <br>\
			 msg);<br>\
	});<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// recieveLogs<br>\
//----------------------------------------------------------<br>\
private function recieveLogs(bindingKeys:Array):void  {	<br>\
	// declare the exchange<br>\
	var p:Promise = _connection.channel.sendMethod(<br>\
			"exchange.declare", <br>\
			{exchange:"topic_logs",type:"topic"});<br>\
				<br>\
	p.onResult(function(info:PromiseResult) <br>\
	{<br>\
		dumpObject(info.frame.fields, info.frame.name);<br>\
		<br>\
		// declare a server named queue<br>\
		var qdp:Promise = _connection.channel.sendMethod(<br>\
						"queue.declare",<br>\
						{queue:"",exclusive:"true"});			<br>\
		<br>\
		qdp.onResult(function(info:PromiseResult) <br>\
		{<br>\
			dumpObject(info.frame.fields, info.frame.name);<br>\
			bindQueue(info.frame.fields.queue, bindingKeys);<br>\
		})		<br>\
		<br>\
		qdp.onFault(function(info:PromiseFault) <br>\
		{<br>\
			appendLog("Error sending method. ["+info.code+" : "+info.text+"]");<br>\
		})<br>\
	});<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// bindQueue<br>\
//----------------------------------------------------------<br>\
private function bindQueue(queue_name:String, bindingKeys:Array):void {<br>\
	var consumerSet:Boolean = false;<br>\
	<br>\
	for each (var binding in bindingKeys) {<br>\
		// bind the queue to the exchange<br>\
		var qbp:Promise = _connection.channel.sendMethod(<br>\
				"queue.bind", <br>\
				{exchange:"topic_logs",queue:queue_name, routing_key:binding});<br>\
				<br>\
		qbp.onResult(function(info:PromiseResult) <br>\
		{<br>\
			dumpObject(info.frame.fields, info.frame.name);<br>\
			if (!consumerSet) {<br>\
				consumerSet=true;<br>\
				// start conusmer<br>\
				var cp:Promise = _connection.channel.sendMethod(<br>\
								 "basic.consume", <br>\
								 {queue:queue_name, no_ack:"true"});<br>\
				cp.onResult(function(info:PromiseResult) <br>\
				{<br>\
					dumpObject(info.frame.fields, info.frame.name);<br>\
					<br>\
					//setup the listener<br>\
					_connection.channel.addEventListener(info.frame.fields.consumer_tag, onReceive);<br>\
				});<br>\
			}<br>\
		});<br>\
		<br>\
		qbp.onFault(function(info:PromiseFault) <br>\
		{<br>\
			appendLog("Error sending method. ["+info.code+" : "+info.text+"]");<br>\
		})<br>\
	}<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// onReceive<br>\
//----------------------------------------------------------<br>\
private function onReceive(e:BasicDeliverEvent):void {<br>\
	dumpObject(e.frame.fields, "BasicDeliverEvent");<br>\
	<br>\
	appendConsumer(e.frame.fields.consumer_tag+" [<b>"+ e.frame.body+"</b>]");<br>\
';
		}
		
		//----------------------------------------------------------
		// doEmit
		//----------------------------------------------------------
		private function doEmit(e:MouseEvent):void  {		
			emitMessage(tfEmitKey.text, tfEmitMessage.text);
		}
		
		//----------------------------------------------------------
		// doStartReciever
		//----------------------------------------------------------
		private function doStartReciever(e:MouseEvent):void  {		
			var bindingKeys:Array=new Array();
			var bindings:Array = String(tfRecieveKey.text).split(",");
			for each (var binding in bindings) {
				bindingKeys.push(binding);
			}
			recieveLogs(bindingKeys);
		}

	}
	
}
