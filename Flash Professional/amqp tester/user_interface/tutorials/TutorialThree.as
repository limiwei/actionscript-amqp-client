package  {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.emc.amqp.Connection;
	import org.emc.amqp.promise.Promise;
	import org.emc.amqp.promise.PromiseFault;
	import org.emc.amqp.promise.PromiseResult;
	import org.emc.amqp.events.BasicDeliverEvent;
	
	public class TutorialThree extends BasePanel {

		public function TutorialThree(connection:Connection, rabbitFlash:RabbitFlash) {
			super(connection, rabbitFlash);
		}
		
		/***********************************************************
		
			Following code block are the tutorials
		
		 **********************************************************/
		 
		//----------------------------------------------------------
		// doEmit
		//----------------------------------------------------------
		private function doEmit(e:MouseEvent):void  {		
			
			// declare the exchange
			var p:Promise = _connection.channel.sendMethod(
					"exchange.declare", 
					{exchange:"logs",type:"fanout"});
			
			// send basic publish
			p.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				_connection.channel.sendMethod(
					 "basic.publish", 
					 {exchange:"logs"}, 
					 "info: Hello World!");
			});
		}
		
		
		//----------------------------------------------------------
		// doStartReciever
		//----------------------------------------------------------
		private function doStartReciever(e:MouseEvent):void  {				
			// declare the exchange
			var p:Promise = _connection.channel.sendMethod(
					"exchange.declare", 
					{exchange:"logs",type:"fanout"});
						
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
					bindQueue(info.frame.fields.queue);
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
		private function bindQueue(queue_name:String):void {
			
			// bind the queue to the exchange
			var qbp:Promise = _connection.channel.sendMethod(
					"queue.bind", 
					{exchange:"logs",queue:queue_name});
						
			qbp.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				
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
			});
			
			qbp.onFault(function(info:PromiseFault) 
			{
				appendLog("Error sending method. ["+info.code+" : "+info.text+"]");
			})
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
// doEmit<br>\
//----------------------------------------------------------<br>\
private function doEmit(e:MouseEvent):void  {		<br>\
	<br>\
	// declare the exchange<br>\
	var p:Promise = _connection.channel.sendMethod(<br>\
			"exchange.declare", <br>\
			{exchange:"logs",type:"fanout"});<br>\
	<br>\
	// send basic publish<br>\
	p.onResult(function(info:PromiseResult) <br>\
	{<br>\
		dumpObject(info.frame.fields, info.frame.name);<br>\
		_connection.channel.sendMethod(<br>\
			 "basic.publish", <br>\
			 {exchange:"logs"}, <br>\
			 "info: Hello World!");<br>\
	});<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// doStartReciever<br>\
//----------------------------------------------------------<br>\
private function doStartReciever(e:MouseEvent):void  {				<br>\
	// declare the exchange<br>\
	var p:Promise = _connection.channel.sendMethod(<br>\
			"exchange.declare", <br>\
			{exchange:"logs",type:"fanout"});<br>\
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
			bindQueue(info.frame.fields.queue);<br>\
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
private function bindQueue(queue_name:String):void {<br>\
	<br>\
	// bind the queue to the exchange<br>\
	var qbp:Promise = _connection.channel.sendMethod(<br>\
			"queue.bind", <br>\
			{exchange:"logs",queue:queue_name});<br>\
				<br>\
	qbp.onResult(function(info:PromiseResult) <br>\
	{<br>\
		dumpObject(info.frame.fields, info.frame.name);<br>\
		<br>\
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
	});<br>\
	<br>\
	qbp.onFault(function(info:PromiseFault) <br>\
	{<br>\
		appendLog("Error sending method. ["+info.code+" : "+info.text+"]");<br>\
	})<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// onReceive<br>\
//----------------------------------------------------------<br>\
private function onReceive(e:BasicDeliverEvent):void {<br>\
	dumpObject(e.frame.fields, "BasicDeliverEvent");<br>\
	<br>\
	appendConsumer(e.frame.fields.consumer_tag+" ["+ e.frame.body+"]");<br>\
}';
		}
	}
	
}
