package  {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.emc.amqp.Connection;
	import org.emc.amqp.promise.Promise;
	import org.emc.amqp.promise.PromiseFault;
	import org.emc.amqp.promise.PromiseResult;
	import org.emc.amqp.events.BasicDeliverEvent;
	
	public class TutorialSix extends BasePanel {

		public function TutorialSix(connection:Connection, rabbitFlash:RabbitFlash) {
			super(connection, rabbitFlash);
		}
		
		/***********************************************************
		
			Following code block are the tutorials
		
		 **********************************************************/
		
		//----------------------------------------------------------
		// startServer
		//----------------------------------------------------------
		private function fibonacci(r:uint):uint {
			if(r==0) {
				return 0;
			}
			else if (r==1) {
				return 1;
			}
			else {
				return fibonacci(r-1) + fibonacci(r-2);
			}
		}
		
		//----------------------------------------------------------
		// startServer
		//----------------------------------------------------------
		private function startServer():void  {		
			
			// declare the queue
			var p:Promise = _connection.channel.sendMethod(
							"queue.declare", 
							{queue:"rpc_queue"});
			
			// send basic consume
			p.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				
				// set prefetch
				_connection.channel.sendMethod(
					"basic_qos", 
					{prefetch_count:1});
				
				var cp:Promise = _connection.channel.sendMethod(
								"basic.consume", 
								{queue:"rpc_queue"});
				cp.onResult(function(info:PromiseResult) 
				{
					dumpObject(info.frame.fields, info.frame.name);
					
					//setup the listener
					_connection.channel.addEventListener(info.frame.fields.consumer_tag, onRequest);
				});
			});	
		}
		
		//----------------------------------------------------------
		// onRequest
		//----------------------------------------------------------
		private function onRequest(e:BasicDeliverEvent):void {
			dumpObject(e.frame.fields, "BasicDeliverEvent");
			
			appendConsumer("Request recieved [<b>"+ e.frame.body+"</b>]");
			
			var fib:Number=Number(e.frame.body);
			var rslt:Number=fibonacci(fib);
			// send ack
			var sp:Promise = _connection.channel.sendMethod(
							"basic.ack", 
							{delivery_tag:e.frame.fields.delivery_tag});						
							
			sp.onResult(function(info:PromiseResult) {
				appendLog("ack sent ["+e.frame.fields.delivery_tag+"]");
					
				//send response
				_connection.channel.sendMethod(
					 "basic.publish", 
					 {routing_key:e.frame.fields.reply_to, correlation_id:e.frame.fields.correlation_id}, 
					 rslt);
			});
		}
	
		//----------------------------------------------------------
		// RPC_Request
		//----------------------------------------------------------
		private function RPC_Request(fib:String):void  {				
			// declare a server named queue
			var qdp:Promise = _connection.channel.sendMethod(
							"queue.declare",
							{queue:"",exclusive:"true"});			
			
			qdp.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				var queue_name:String=info.frame.fields.queue;
				
				var cp:Promise = _connection.channel.sendMethod(
								 "basic.consume", 
								 {queue:queue_name, no_ack:"true"});
				cp.onResult(function(info:PromiseResult) 
				{
					dumpObject(info.frame.fields, info.frame.name);
					
					//setup the listener for response
					_connection.channel.addEventListener(info.frame.fields.consumer_tag, onRPCReceive);
				
					//send request
					makeRPCRequest(queue_name, fib);
				});
			})		
			
			qdp.onFault(function(info:PromiseFault) 
			{
				appendLog("Error sending method. ["+info.code+" : "+info.text+"]");
			})
		}
		
		//----------------------------------------------------------
		// makeRPCRequest
		//----------------------------------------------------------
		private function makeRPCRequest(queue_name:String, req:String):void {
			_connection.channel.sendMethod(
				"basic.publish", 
				 {routing_key:"rpc_queue", correlation_id:Math.floor(Math.random()*(1+9000))+1000, reply_to:queue_name}, 
				req);
		}	
	
		//----------------------------------------------------------
		// onRPCReceive
		//----------------------------------------------------------
		private function onRPCReceive(e:BasicDeliverEvent):void {
			dumpObject(e.frame.fields, "BasicDeliverEvent");
			
			appendConsumer("Response recieved [<b>"+ e.frame.body+"</b>]");
		}
		
		/***********************************************************
		
			End tutorials
		
		 **********************************************************/
	
	
		//----------------------------------------------------------
		// doInit
		//----------------------------------------------------------
		override protected function doInit():void {		
			
			rcpRequest_btn.addEventListener(MouseEvent.CLICK, doRPCRequest);
			startServer_btn.addEventListener(MouseEvent.CLICK, doStartServer);
			
			source_txt.htmlText=
'//----------------------------------------------------------<br>\
// startServer<br>\
//----------------------------------------------------------<br>\
private function fibonacci(r:uint):uint {<br>\
	if(r==0) {<br>\
		return 0;<br>\
	}<br>\
	else if (r==1) {<br>\
		return 1;<br>\
	}<br>\
	else {<br>\
		return fibonacci(r-1) + fibonacci(r-2);<br>\
	}<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// startServer<br>\
//----------------------------------------------------------<br>\
private function startServer():void  {		<br>\
	<br>\
	// declare the queue<br>\
	var p:Promise = _connection.channel.sendMethod(<br>\
					"queue.declare", <br>\
					{queue:"rpc_queue"});<br>\
	<br>\
	// send basic consume<br>\
	p.onResult(function(info:PromiseResult) <br>\
	{<br>\
		dumpObject(info.frame.fields, info.frame.name);<br>\
		<br>\
		// set prefetch<br>\
		_connection.channel.sendMethod(<br>\
			"basic_qos", <br>\
			{prefetch_count:1});<br>\
		<br>\
		var cp:Promise = _connection.channel.sendMethod(<br>\
						"basic.consume", <br>\
						{queue:"rpc_queue"});<br>\
		cp.onResult(function(info:PromiseResult) <br>\
		{<br>\
			dumpObject(info.frame.fields, info.frame.name);<br>\
			<br>\
			//setup the listener<br>\
			_connection.channel.addEventListener(info.frame.fields.consumer_tag, onRequest);<br>\
		});<br>\
	});	<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// onRequest<br>\
//----------------------------------------------------------<br>\
private function onRequest(e:BasicDeliverEvent):void {<br>\
	dumpObject(e.frame.fields, "BasicDeliverEvent");<br>\
	<br>\
	appendConsumer("Request recieved ["+ e.frame.body+"]");<br>\
	<br>\
	var fib:Number=Number(e.frame.body);<br>\
	var rslt:Number=fibonacci(fib);<br>\
	// send ack<br>\
	var sp:Promise = _connection.channel.sendMethod(<br>\
					"basic.ack", <br>\
					{delivery_tag:e.frame.fields.delivery_tag});<br>\
					<br>\
	sp.onResult(function(info:PromiseResult) {<br>\
		appendLog("ack sent ["+e.frame.fields.delivery_tag+"]");<br>\
			<br>\
		//send response<br>\
		_connection.channel.sendMethod(<br>\
			 "basic.publish", <br>\
			 {routing_key:e.frame.fields.reply_to, correlation_id:e.frame.fields.correlation_id}, <br>\
			 rslt);<br>\
	});<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// RPC_Request<br>\
//----------------------------------------------------------<br>\
private function RPC_Request(fib:String):void  {<br>\
	// declare a server named queue<br>\
	var qdp:Promise = _connection.channel.sendMethod(<br>\
					"queue.declare",<br>\
					{queue:"",exclusive:"true"});<br>\
	<br>\
	qdp.onResult(function(info:PromiseResult) <br>\
	{<br>\
		dumpObject(info.frame.fields, info.frame.name);<br>\
		var queue_name:String=info.frame.fields.queue;<br>\
		<br>\
		var cp:Promise = _connection.channel.sendMethod(<br>\
						 "basic.consume", <br>\
						 {queue:queue_name, no_ack:"true"});<br>\
		cp.onResult(function(info:PromiseResult) <br>\
		{<br>\
			dumpObject(info.frame.fields, info.frame.name);<br>\
			<br>\
			//setup the listener for response<br>\
			_connection.channel.addEventListener(info.frame.fields.consumer_tag, onRPCReceive);<br>\
		<br>\
			//send request<br>\
			makeRPCRequest(queue_name, fib);<br>\
		});<br>\
	})		<br>\
	<br>\
	qdp.onFault(function(info:PromiseFault) <br>\
	{<br>\
		appendLog("Error sending method. ["+info.code+" : "+info.text+"]");<br>\
	})<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// makeRPCRequest<br>\
//----------------------------------------------------------<br>\
private function makeRPCRequest(queue_name:String, req:String):void {<br>\
	_connection.channel.sendMethod(<br>\
		"basic.publish", <br>\
		 {routing_key:"rpc_queue", correlation_id:Math.floor(Math.random()*(1+9000))+1000, reply_to:queue_name}, <br>\
		req);<br>\
}	<br>\
<br>\
//----------------------------------------------------------<br>\
// onRPCReceive<br>\
//----------------------------------------------------------<br>\
private function onRPCReceive(e:BasicDeliverEvent):void {<br>\
	dumpObject(e.frame.fields, "BasicDeliverEvent");<br>\
	<br>\
	appendConsumer("Response recieved ["+ e.frame.body+"");<br>\
}';
		}
		
		//----------------------------------------------------------
		// doEmit
		//----------------------------------------------------------
		private function doRPCRequest(e:MouseEvent):void  {		
			RPC_Request(tfFibNumber.text);
		}
		
		private function doStartServer(e:MouseEvent):void  {		
			startServer()
		}

	}
	
}
