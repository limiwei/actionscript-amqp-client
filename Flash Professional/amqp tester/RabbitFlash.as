package  {
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
 	import fl.transitions.Tween;
 	import fl.transitions.easing.*
 	import flash.filters.BitmapFilterQuality; 
 	import flash.filters.BitmapFilter;
 	import fl.transitions.TweenEvent;
 	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	
 	import org.emc.amqp.Connection;
	import org.emc.amqp.events.ConnectionEvent;
	import org.emc.amqp.events.ChannelEvent;
	import org.emc.amqp.frame.Frame;
	
	public class RabbitFlash extends Sprite {
		var _connection		:Connection;
		var _rotationXUp	:Number = 110;
		var _xShown			:Number = 110;
		var _xHidden		:Number = 642;
		var _panels			:Dictionary = new Dictionary();
		var _buttons		:Dictionary = new Dictionary();
		var _buttonNames	:Array = new Array();
		var _lastPanel		:BasePanel = null;
		
		//----------------------------------------------------------
		// RabbitFlash
		//----------------------------------------------------------
		public function RabbitFlash() {
			addEventListener(flash.events.Event.ADDED_TO_STAGE, onInit);		
			_buttonNames.push("ProtocolTester");
			_buttonNames.push("TutorialOne");
			_buttonNames.push("TutorialTwo");
			_buttonNames.push("TutorialThree");
			_buttonNames.push("TutorialFour");
			_buttonNames.push("TutorialFive");
			_buttonNames.push("TutorialSix");
		}
		
		//----------------------------------------------------------
		// onInit
		//----------------------------------------------------------
		protected function onInit(event:flash.events.Event):void {
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, onInit);
			
			connect_btn.addEventListener(MouseEvent.CLICK, doConnect);
			disconnect_btn.addEventListener(MouseEvent.CLICK, doDisconnect);
			
			// create connection
			try {
				_connection = new Connection({}, false);
				_connection.addEventListener(ConnectionEvent.CONNECTION_READY, onConnectionReady);
				_connection.addEventListener(ConnectionEvent.CONNECTION_CLOSED, onConnectionClosed);
				_connection.addEventListener(ConnectionEvent.CONNECTION_SOCKET_ERROR, onSocketError);
				_connection.addEventListener(ConnectionEvent.CONNECTION_SECURITY_EVENT, onSecurityEvent);
				//_connection.connect("10.12.136.244", "guest", "guest");
				/*_connection.connect("10.12.201.223", "guest", "guest");
				_connection.channel.sendMethod(
				"basic.publish", 
				{routing_key:"hello"}, 
				"Hello World!");*/
			} catch (error:Error) {
				trace (error.message);
			}	
			
			for each (var buttonName in _buttonNames) {
				initPanel(buttonName);
			}
		}
		
		//----------------------------------------------------------
		// doStart
		//----------------------------------------------------------
		private function initPanel(panelName:String):void  {	
			var btn:Button = this[panelName] as Button;
			 
			btn.addEventListener(MouseEvent.CLICK, btnShowPanel);
			_buttons[panelName] = btn;
			
			var classReference:Class;			
				
			try {
				classReference = getDefinitionByName(panelName) as Class;
			} catch (e:ReferenceError) {
			}
			
			var panel:* = new classReference(_connection, this);
			
			_panels[panelName] = panel;
			
			panel.x=_xHidden;
			panel.y=96;
					
			addChild(panel);
		}
		
		//----------------------------------------------------------
		// showPanel
		//----------------------------------------------------------
		private function btnShowPanel(e:MouseEvent):void  {
			var panelName:String=e.currentTarget.name;
			showPanel(panelName);
		}
		
		//----------------------------------------------------------
		// showPanel
		//----------------------------------------------------------
		private function showPanel(panelName:String):void  {
			var panel:BasePanel = _panels[panelName];

			if (_lastPanel != null) {
				var myHoriTween:Tween = new Tween(_lastPanel,"x",Regular.easeOut,_xShown,_xHidden,.6,true);
				myHoriTween.addEventListener(TweenEvent.MOTION_FINISH, function () {
							var myHoriTween3:Tween = new Tween(panel,"x",Regular.easeIn,_xHidden,_xShown,.8,true);			
									   });
			} else {
				var myHoriTween2:Tween = new Tween(panel,"x",Regular.easeIn,_xHidden,_xShown,1,true);			
			}
			_lastPanel=panel;
			
			for (var val in _buttons) {
				if (val==panelName) {
					_buttons[val].enabled=false;
				} else {
					_buttons[val].enabled=true;
				}
			}
		}
		
		//----------------------------------------------------------
		// doDisconnect
		//----------------------------------------------------------
		private function doDisconnect(e:MouseEvent):void  {			
			_connection.disconnect();
		}	
		
		//----------------------------------------------------------
		// doConnect
		//----------------------------------------------------------
		private function doConnect(e:MouseEvent):void  {
			_connection.connect(tfHost.text, tfName.text, tfPassword.text);
		}
		//----------------------------------------------------------
		// onConnectionReady
		//----------------------------------------------------------
		private function onSocketError(event:ConnectionEvent):void {
			appendLog("<b>onSocketError</b> "+event.toString());
		}
		
		//----------------------------------------------------------
		// onConnectionReady
		//----------------------------------------------------------
		private function onSecurityEvent(event:ConnectionEvent):void {
			appendLog("<b>onSecurityEvent</b> "+event.toString());
			
		}
	
		//----------------------------------------------------------
		// onConnectionReady
		//----------------------------------------------------------
		private function onConnectionReady(event:ConnectionEvent):void {	
			tfName.enabled=false;
			tfHost.enabled=false;
			tfPassword.enabled=false;
			connect_btn.enabled=false;
			disconnect_btn.visible=true;
			connect_btn.visible=false;
	
			for each (var panel:BasePanel in _panels) {
				panel.connectionReady();
			}
			
			for each (var btn:Button in _buttons) {
				btn.enabled=true;
			}
			
			appendLog("--- <b>Conection opened</b> ---");	
		}	
		
		//----------------------------------------------------------
		// appendLog
		//----------------------------------------------------------
		public function appendLog(msg:String):void  {
			taLog.htmlText += msg+"<br>";
			taLog.validateNow();
			taLog.verticalScrollPosition = taLog.maxVerticalScrollPosition;
		}
		
		//----------------------------------------------------------
		// appendConsumer
		//----------------------------------------------------------
		public function appendConsumer(msg:String):void  {
			taConsume.htmlText += msg+"<br>";
			taConsume.validateNow();
			taConsume.verticalScrollPosition = taConsume.maxVerticalScrollPosition;
		}		
		
		//----------------------------------------------------------
		// onConnectionClosed
		//----------------------------------------------------------
		private function onConnectionClosed(event:ConnectionEvent):void {
			tfName.enabled=true;
			tfHost.enabled=true;
			tfPassword.enabled=true;
			connect_btn.enabled=true;
			disconnect_btn.visible=false;
			connect_btn.visible=true;
			
			for each (var panel:BasePanel in _panels) {
				panel.connectionClosed();
			}
			
			for each (var btn:Button in _buttons) {
				btn.enabled=false;
			}
			
			if (_lastPanel != null) {
				var myHoriTween:Tween = new Tween(_lastPanel,"x",Regular.easeOut,_xShown,_xHidden,.6,true);
				_lastPanel=null;
			}	
			appendLog("--- <b>Conection closed</b> ---");
		}
	}
}
