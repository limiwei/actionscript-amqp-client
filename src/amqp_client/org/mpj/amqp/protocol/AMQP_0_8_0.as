package org.mpj.amqp.protocol {
	
	public class AMQP_0_8_0  implements IProtocolVersion {
		
		// getters
		public function get FRAME_METHOD()		:int	{ return 0; }
		public function get FRAME_HEADER()		:int	{ return 0; }
		public function get FRAME_BODY()		:int	{ return 0; }
		public function get FRAME_HEARTBEAT()	:int	{ return 0; }
		public function get FRAME_END()			:int	{ return 0; }
		public function get VERSION_MAJOR()		:int	{ return 0; }
		public function get VERSION_MINOR()		:int	{ return 0; }
		public function get VERSION_REVISION()	:int	{ return 0; }
		
		public function get xml():XML {
			return _protocolXML;
		}
		
		private var _protocolXML:XML;
	}
}
