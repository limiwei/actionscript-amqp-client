package  {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.data.DataProvider;
	
	import org.emc.amqp.Connection;
	import org.emc.amqp.promise.Promise;
	import org.emc.amqp.promise.PromiseFault;
	import org.emc.amqp.promise.PromiseResult;
	import org.emc.amqp.events.BasicDeliverEvent;
	
	public class ProtocolTester extends BasePanel {

		//----------------------------------------------------------
		// ProtocolTester
		//----------------------------------------------------------
		public function ProtocolTester(connection:Connection, rabbitFlash:RabbitFlash) {
			super(connection, rabbitFlash);
		}
		
		//----------------------------------------------------------
		// doInit
		//----------------------------------------------------------
		override protected function doInit():void {
			dgMethods.addEventListener(MouseEvent.CLICK, doSelectMethod);
			
			// setup datagrid
			dgFields.columns = ["field","value"];
			dgFields.editable = true;
			dgFields.columns[1].editable=true;
			
			dgMethods.columns = ["method"];
			
			send_btn.addEventListener(MouseEvent.CLICK, doSend);
		}
		
		//----------------------------------------------------------
		// connectionReady
		//----------------------------------------------------------
		override public function connectionReady():void {
			var methods:Array=_connection.getMethods();
			dgMethods.dataProvider = new DataProvider(methods);
			send_btn.enabled=true;
					
		}
		
		//----------------------------------------------------------
		// connectionClosed
		//----------------------------------------------------------
		override public function connectionClosed():void {
			dgFields.dataProvider = new DataProvider();
			dgMethods.dataProvider = new DataProvider();
			send_btn.enabled=false;			
		}	
		
		//----------------------------------------------------------
		// doSelectMethod
		//----------------------------------------------------------
		private function doSelectMethod(e:MouseEvent):void  {
			var fields:Array=_connection.getFields(dgMethods.selectedItem.method);
		
			dgFields.dataProvider = new DataProvider(fields);
		}
		
		//----------------------------------------------------------
		// doSend
		//----------------------------------------------------------
		private function doSend(e:MouseEvent):void  {			
		
			// build fields
			var method=dgMethods.selectedItem.method;
			var fields:Object=new Object;
			for each(var item in dgFields.dataProvider.toArray()){
				if (item.value!=""&&item.field!="arguments"&&typeof(item.value)=="string") {
					fields[item.field]=item.value;
				}
			}
			dumpObject(fields, method);
			var p:Promise = _connection.channel.sendMethod(method, fields, tfContent.text);
			p.onResult(function(info:PromiseResult) {
					   if (info.hasFrame) {
						   dumpObject(info.frame.fields, info.frame.name);
						   
					   		// check for some basic commands
					    	if (info.frame.name=="basic.consume-ok") {
						   		_connection.channel.addEventListener(info.frame.fields.consumer_tag, onReceive);
					   		}
							
				   			// check for some basic commands
					    	if (info.frame.name=="basic.get-empty") {
								appendConsumer("[<b>empty</b>]");
							}
							
					   		// check for some basic commands
					    	if (info.frame.name=="basic.get-ok") {
								appendConsumer(info.frame.fields.routing_key+" [<b>"+ info.frame.body+"</b>]");
								
								var sp:Promise = _connection.channel.sendMethod("basic.ack", {delivery_tag:info.frame.fields.delivery_tag});
								sp.onResult(function(info2:PromiseResult) {
									appendLog("ack sent ["+info.frame.fields.delivery_tag+"]");
								});
					   		}}
					   });		 
			p.onFault(function(info:PromiseFault) {
					   appendLog("Error sending method. ["+info.code+" : "+info.text+"]");
					   });		 
		
		}

		//----------------------------------------------------------
		// onReceive
		//----------------------------------------------------------
		private function onReceive(e:BasicDeliverEvent):void {
			appendConsumer(e.frame.fields.consumer_tag+" [<b>"+ e.frame.body+"</b>]");
			
			// send ack
			var sp:Promise = _connection.channel.sendMethod("basic.ack", {delivery_tag:e.frame.fields.delivery_tag});
			sp.onResult(function(info:PromiseResult) {
					appendLog("ack sent ["+e.frame.fields.delivery_tag+"]");
			});
		}
	
	}
}
