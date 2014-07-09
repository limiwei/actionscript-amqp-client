package  {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.emc.amqp.Connection;
	import org.emc.amqp.promise.Promise;
	import org.emc.amqp.promise.PromiseFault;
	import org.emc.amqp.promise.PromiseResult;
	import org.emc.amqp.events.BasicDeliverEvent;
	
	public class TutorialTwo extends BasePanel {

		public function TutorialTwo(connection:Connection, rabbitFlash:RabbitFlash) {
			super(connection, rabbitFlash);
		}
		
		/***********************************************************
		
			Following code block are the tutorials
		
		 **********************************************************/
		 
		//----------------------------------------------------------
		// doNewTask
		//----------------------------------------------------------
		private function doNewTask(e:MouseEvent):void  {		
			// declare the queue
			var p:Promise = _connection.channel.sendMethod(
					"queue.declare", 
					{queue:"task_queue",durable:"true"});
			
			// send basic publish
			p.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				_connection.channel.sendMethod(
					 "basic.publish", 
					 {routing_key:"task_queue", delivery_mode:2}, 
					 "Hello World!");
			});
		}
		
		
		//----------------------------------------------------------
		// doStartWorker
		//----------------------------------------------------------
		private function doStartWorker(e:MouseEvent):void  {				
			// declare the queue
			var p:Promise = _connection.channel.sendMethod(
                            "queue.declare", 
                            {queue:"task_queue",durable:"true"});
			
			// send basic consume
			p.onResult(function(info:PromiseResult) 
			{
				dumpObject(info.frame.fields, info.frame.name);
				
				// set prefetch
				_connection.channel.sendMethod(
				"basic_qos", 
				{prefetch_count:1});
				
				// start conusmer
				var cp:Promise = _connection.channel.sendMethod(
                                 "basic.consume", 
                                 {queue:"task_queue"});
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
			
			// send ack
			var sp:Promise = _connection.channel.sendMethod(
							"basic.ack", 
							{delivery_tag:e.frame.fields.delivery_tag});						
							
			sp.onResult(function(info:PromiseResult) {
					appendLog("ack sent ["+e.frame.fields.delivery_tag+"]");
			});
		}
		
		/***********************************************************
		
			End tutorials
		
		 **********************************************************/
	
	
		//----------------------------------------------------------
		// doInit
		//----------------------------------------------------------
		override protected function doInit():void {		
			
			newTask_btn.addEventListener(MouseEvent.CLICK, doNewTask);
			startWorker_btn.addEventListener(MouseEvent.CLICK, doStartWorker);
			
			source_txt.htmlText=
'//----------------------------------------------------------<br>\
// doNewTask<br>\
//----------------------------------------------------------<br>\
private function doNewTask(e:MouseEvent):void  {<br>\
	// declare the queue<br>\
	var p:Promise = _connection.channel.sendMethod(<br>\
			"queue.declare",<br>\
			{queue:"task_queue",durable:"true"});<br>\
<br>\
	// send basic publish<br>\
	p.onResult(function(info:PromiseResult)<br>\
	{<br>\
		dumpObject(info.frame.fields, info.frame.name);<br>\
		_connection.channel.sendMethod(<br>\
			 "basic.publish", <br>\
			 {routing_key:"task_queue", delivery_mode:2}, <br>\
			 "Hello World!");<br>\
	});<br>\
}<br>\
<br><br>\
//----------------------------------------------------------<br>\
// doStartWorker<br>\
//----------------------------------------------------------<br>\
private function doStartWorker(e:MouseEvent):void  {			<br>\
	// declare the queue<br>\
	var p:Promise = _connection.channel.sendMethod(<br>\
					"queue.declare", <br>\
					{queue:"task_queue",durable:"true"});<br>\
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
		// start conusmer<br>\
		var cp:Promise = _connection.channel.sendMethod(<br>\
						 "basic.consume", <br>\
						 {queue:"task_queue"});<br>\
		cp.onResult(function(info:PromiseResult) <br>\
		{<br>\
			dumpObject(info.frame.fields, info.frame.name);<br>\
			//setup the listener<br>\
			_connection.channel.addEventListener(info.frame.fields.consumer_tag, onReceive);<br>\
		});<br>\
	});<br>\
}<br>\
<br>\
//----------------------------------------------------------<br>\
// onReceive<br>\
//----------------------------------------------------------<br>\
private function onReceive(e:BasicDeliverEvent):void {<br>\
	dumpObject(e.frame.fields, "BasicDeliverEvent");<br>\
	<br>\
	appendConsumer(e.frame.fields.consumer_tag+" ["+ e.frame.body+"]");<br>\
	<br>\
	// send ack<br>\
	var sp:Promise = _connection.channel.sendMethod(<br>\
					"basic.ack", <br>\
					{delivery_tag:e.frame.fields.delivery_tag});<br>\
					<br>\
	sp.onResult(function(info:PromiseResult) {<br>\
			appendLog("ack sent ["+e.frame.fields.delivery_tag+"]");<br>\
	});<br>\
}';
		}


	}
	
}
