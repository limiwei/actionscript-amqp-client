/**
added in table types as domains.
added in actionscript types as domains
added value tags to act as default values for fields
changed all "-" to "_" for constant, domain, and field name attributes
changed "start-ok" response from longstr to table (need to fix this)
**/

package org.mpj.amqp.protocol  {
    
    public class AMQP_0_9_1 implements IProtocolVersion {
        
        // getters
        public function get FRAME_METHOD()      :int    { return _protocolXML.constant.(@name=="frame_method").@value; }
        public function get FRAME_HEADER()      :int    { return _protocolXML.constant.(@name=="frame_header").@value; }
        public function get FRAME_BODY()        :int    { return _protocolXML.constant.(@name=="frame_body").@value; }
        public function get FRAME_HEARTBEAT()   :int    { return _protocolXML.constant.(@name=="frame_heartbeat").@value; }
        public function get FRAME_END()         :int    { return _protocolXML.constant.(@name=="frame_end").@value; }
        public function get VERSION_MAJOR()     :int    { return _protocolXML.@major; }
        public function get VERSION_MINOR()     :int    { return _protocolXML.@minor; }
        public function get VERSION_REVISION()  :int    { return _protocolXML.@revision; }
        
        public function get xml():XML {
            return _protocolXML;
        }

        /*
        * protocolXML
        */
        private var _protocolXML:XML=
<amqp major="0" minor="9" revision="1" port="5672">
  <constant name="frame_method" value="1"/>
  <constant name="frame_header" value="2"/>
  <constant name="frame_body" value="3"/>
  <constant name="frame_heartbeat" value="8"/>
  <constant name="frame_min_size" value="4096"/>
  <constant name="frame_end" value="206"/>
  <constant name="reply_success" value="200"/>
  <constant name="content_too_large" value="311" class="soft_error"/>
  <constant name="no_consumers" value="313" class="soft_error"/>
  <constant name="connection_forced" value="320" class="hard_error"/>
  <constant name="invalid_path" value="402" class="hard_error"/>
  <constant name="access_refused" value="403" class="soft_error"/>
  <constant name="not_found" value="404" class="soft_error"/>
  <constant name="resource_locked" value="405" class="soft_error"/>
  <constant name="precondition_failed" value="406" class="soft_error"/>
  <constant name="frame_error" value="501" class="hard_error"/>
  <constant name="syntax_error" value="502" class="hard_error"/>
  <constant name="command_invalid" value="503" class="hard_error"/>
  <constant name="channel_error" value="504" class="hard_error"/>
  <constant name="unexpected_frame" value="505" class="hard_error"/>
  <constant name="resource_error" value="506" class="hard_error"/>
  <constant name="not_allowed" value="530" class="hard_error"/>
  <constant name="not_implemented" value="540" class="hard_error"/>
  <constant name="internal_error" value="541" class="hard_error"/>
  <domain name="class_id" type="short"/>
  <domain name="consumer_tag" type="shortstr"/>
  <domain name="delivery_tag" type="longlong"/>
  <domain name="exchange_name" type="shortstr">
    <assert check="length" value="127"/>
    <assert check="regexp" value="^[a_zA_Z0_9__.:]*$"/>
  </domain>
  <domain name="method_id" type="short"/>
  <domain name="no_ack" type="bit"/>
  <domain name="no_local" type="bit"/>
  <domain name="no_wait" type="bit"/>
  <domain name="path" type="shortstr">
    <assert check="notnull"/>
    <assert check="length" value="127"/>
  </domain>
  <domain name="peer_properties" type="table"/>
  <domain name="queue_name" type="shortstr">
    <assert check="length" value="127"/>
    <assert check="regexp" value="^[a_zA_Z0_9__.:]*$"/>
  </domain>
  <domain name="redelivered" type="bit"/>
  <domain name="message_count" type="long"/>
  <domain name="reply_code" type="short">
    <assert check="notnull"/>
  </domain>
  <domain name="reply_text" type="shortstr">
    <assert check="notnull"/>
  </domain>
  <domain name="bit" type="bit"/>
  <domain name="octet" type="octet"/>
  <domain name="short" type="short"/>
  <domain name="long" type="long"/>
  <domain name="longlong" type="longlong"/>
  <domain name="shortstr" type="shortstr"/>
  <domain name="longstr" type="longstr"/>
  <domain name="timestamp" type="timestamp"/>
  <domain name="table" type="table"/>
  <domain name="t" type="bit"/>
  <domain name="b" type="octet"/>
  <domain name="s" type="short"/>
  <domain name="I" type="long"/>
  <domain name="l" type="longlong"/>
  <domain name="f" type="long"/>
  <domain name="d" type="longlong"/>
  <domain name="D" type="long"/>
  <domain name="S" type="longstr"/>
  <domain name="T" type="timestamp"/>
  <domain name="F" type="table"/>  
  <domain name="Boolean" type="t"/>
  <domain name="String" type="S"/>
  <domain name="ByteArray" type="S"/>
  <domain name="int" type="I"/>
  <domain name="Date" type="T"/>
  <domain name="object" type="table"/> 
  <class name="connection" handler="connection" index="10">
    <chassis name="server" implement="MUST"/>
    <chassis name="client" implement="MUST"/>
    <method name="start" synchronous="1" index="10">
      <chassis name="client" implement="MUST"/>
      <response name="start-ok"/>
      <field name="version_major" domain="octet" value="0"/>
      <field name="version_minor" domain="octet" value="0"/>
      <field name="server_properties" domain="peer_properties"/>
      <field name="mechanisms" domain="longstr">
        <assert check="notnull"/>
      </field>
      <field name="locales" domain="longstr" value="">
        <assert check="notnull"/>
      </field>
    </method>
    <method name="start-ok" synchronous="1" index="11">
      <chassis name="server" implement="MUST"/>
      <field name="client_properties" domain="peer_properties"/>
      <field name="mechanism" domain="shortstr" value="AMQPLAIN">
        <assert check="notnull"/>
      </field>
      <field name="response" domain="table">
        <assert check="notnull"/>
      </field>
      <field name="locale" domain="shortstr" value="en_US">
        <assert check="notnull"/>
      </field>
    </method>
    <method name="secure" synchronous="1" index="20">
      <chassis name="client" implement="MUST"/>
      <response name="secure-ok"/>
      <field name="challenge" domain="longstr"  value=""/>
    </method>
    <method name="secure-ok" synchronous="1" index="21">
      <chassis name="server" implement="MUST"/>
      <field name="response" domain="longstr" value="">
        <assert check="notnull"/>
      </field>
    </method>
    <method name="tune" synchronous="1" index="30">
      <chassis name="client" implement="MUST"/>
      <response name="tune-ok"/>
      <field name="channel_max" domain="short" value="0"/>
      <field name="frame_max" domain="long" value="0"/>
      <field name="heartbeat" domain="short" value="0"/>
    </method>
    <method name="tune-ok" synchronous="1" index="31">
      <chassis name="server" implement="MUST"/>
      <field name="channel_max" domain="short" value="0">
        <assert check="notnull"/>
        <assert check="le" method="tune" field="channel_max"/>
      </field>
      <field name="frame_max" domain="long" value="0"/>
      <field name="heartbeat" domain="short" value="0"/>
    </method>
    <method name="open" synchronous="1" index="40">
      <chassis name="server" implement="MUST"/>
      <response name="open-ok"/>
      <field name="virtual_host" domain="path" value=""/>
      <field name="reserved_1" type="shortstr" reserved="1" value=""/>
      <field name="reserved_2" type="bit" reserved="1" value="false"/>
    </method>
    <method name="open-ok" synchronous="1" index="41">
      <chassis name="client" implement="MUST"/>
      <field name="reserved_1" type="shortstr" reserved="1" value=""/>
    </method>
    <method name="close" synchronous="1" index="50">
      <chassis name="client" implement="MUST"/>
      <chassis name="server" implement="MUST"/>
      <response name="close-ok"/>
      <field name="reply_code" domain="reply_code" value="0"/>
      <field name="reply_text" domain="reply_text" value=""/>
      <field name="class_id" domain="class_id" value="0"/>
      <field name="method_id" domain="method_id" value="0"/>
    </method>
    <method name="close-ok" synchronous="1" index="51">
      <chassis name="client" implement="MUST"/>
      <chassis name="server" implement="MUST"/>
    </method>
  </class>
  <class name="channel" handler="channel" index="20">
    <chassis name="server" implement="MUST"/>
    <chassis name="client" implement="MUST"/>
    <method name="open" synchronous="1" index="10">
      <chassis name="server" implement="MUST"/>
      <response name="open-ok"/>
      <field name="reserved_1" type="shortstr" reserved="1" value=""/>
    </method>
    <method name="open-ok" synchronous="1" index="11">
      <chassis name="client" implement="MUST"/>
      <field name="reserved_1" type="longstr" reserved="1" value=""/>
    </method>
    <method name="flow" synchronous="1" index="20">
      <chassis name="server" implement="MUST"/>
      <chassis name="client" implement="MUST"/>
      <response name="flow-ok"/>
      <field name="active" domain="bit"/>
    </method>
    <method name="flow-ok" index="21">
      <chassis name="server" implement="MUST"/>
      <chassis name="client" implement="MUST"/>
      <field name="active" domain="bit" value="false"/>
    </method>
    <method name="close" synchronous="1" index="40">
      <chassis name="client" implement="MUST"/>
      <chassis name="server" implement="MUST"/>
      <response name="close-ok"/>
      <field name="reply_code" domain="reply_code" value="0"/>
      <field name="reply_text" domain="reply_text" value=""/>
      <field name="class_id" domain="class_id" value="0"/>
      <field name="method_id" domain="method_id" value="0"/>
    </method>
    <method name="close_ok" synchronous="1" index="41">
      <chassis name="client" implement="MUST"/>
      <chassis name="server" implement="MUST"/>
    </method>
  </class>
  <class name="exchange" handler="channel" index="40">
    <chassis name="server" implement="MUST"/>
    <chassis name="client" implement="MUST"/>
    <method name="declare" synchronous="1" index="10">
      <chassis name="server" implement="MUST"/>
      <response name="declare-ok"/>
      <field name="reserved_1" type="short" reserved="1" value="0"/>
      <field name="exchange" type="exchange_name" value="">
        <assert check="notnull"/>
      </field>
      <field name="type" domain="shortstr" value=""/>
      <field name="passive" domain="bit" value="false"/>
      <field name="durable" domain="bit" value="false"/>
      <field name="reserved_2" type="bit" reserved="1" value="false"/>
      <field name="reserved_3" type="bit" reserved="1" value="false"/>
      <field name="no_wait" domain="no_wait" value="false"/>
      <field name="arguments" domain="table"/>
    </method>
    <method name="declare-ok" synchronous="1" index="11">
      <chassis name="client" implement="MUST"/>
    </method>
    <method name="delete" synchronous="1" index="20">
      <chassis name="server" implement="MUST"/>
      <response name="delete-ok"/>
      <field name="reserved_1" type="short" reserved="1" value="0"/>
      <field name="exchange" domain="exchange_name" value="">
        <assert check="notnull"/>
      </field>
      <field name="if_unused" domain="bit" value="false"/>
      <field name="no_wait" domain="no_wait" value="false"/>
    </method>
    <method name="delete-ok" synchronous="1" index="21">
      <chassis name="client" implement="MUST"/>
    </method>
  </class>
  <class name="queue" handler="channel" index="50">
    <chassis name="server" implement="MUST"/>
    <chassis name="client" implement="MUST"/>
    <method name="declare" synchronous="1" index="10">
      <chassis name="server" implement="MUST"/>
      <response name="declare-ok"/>
      <field name="reserved_1" type="short" reserved="1" value="0"/>
      <field name="queue" domain="queue_name" value=""/>
      <field name="passive" domain="bit" value="false"/>
      <field name="durable" domain="bit" value="false"/>
      <field name="exclusive" domain="bit" value="false"/>
      <field name="auto_delete" domain="bit" value="false"/>
      <field name="no_wait" domain="no_wait" value="false"/>
      <field name="arguments" domain="table"/>
    </method>
    <method name="declare-ok" synchronous="1" index="11">
      <chassis name="client" implement="MUST"/>
      <field name="queue" domain="queue_name" value="">
        <assert check="notnull"/>
      </field>
      <field name="message_count" domain="message_count" value="0"/>
      <field name="consumer_count" domain="long" value="0"/>
    </method>
    <method name="bind" synchronous="1" index="20">
      <chassis name="server" implement="MUST"/>
      <response name="bind-ok"/>
      <field name="reserved_1" type="short" reserved="1" value="0"/>
      <field name="queue" domain="queue_name" value=""/>
      <field name="exchange" domain="exchange_name" value=""/>
      <field name="routing_key" domain="shortstr" value=""/>
      <field name="no_wait" domain="no_wait" value="false"/>
      <field name="arguments" domain="table"/>
    </method>
    <method name="bind-ok" synchronous="1" index="21">
      <chassis name="client" implement="MUST"/>
    </method>
    <method name="unbind" synchronous="1" index="50">
      <chassis name="server" implement="MUST"/>
      <response name="unbind-ok"/>
      <field name="reserved_1" type="short" reserved="1" value="0"/>
      <field name="queue" domain="queue_name" value=""/>
      <field name="exchange" domain="exchange_name" value=""/>
      <field name="routing_key" domain="shortstr" value=""/>
      <field name="arguments" domain="table"/>
    </method>
    <method name="unbind-ok" synchronous="1" index="51">
      <chassis name="client" implement="MUST"/>
    </method>
    <method name="purge" synchronous="1" index="30">
      <chassis name="server" implement="MUST"/>
      <response name="purge-ok"/>
      <field name="reserved_1" type="short" reserved="1" value="0"/>
      <field name="queue" domain="queue_name" value=""/>
      <field name="no_wait" domain="no_wait" value="false"/>
    </method>
    <method name="purge-ok" synchronous="1" index="31">
      <chassis name="client" implement="MUST"/>
      <field name="message_count" domain="message_count"  value="0"/>
    </method>
    <method name="delete" synchronous="1" index="40">
      <chassis name="server" implement="MUST"/>
      <response name="delete-ok"/>
      <field name="reserved_1" type="short" reserved="1" value="0"/>
      <field name="queue" domain="queue_name" value=""/>
      <field name="if_unused" domain="bit" value="false"/>
      <field name="if_empty" domain="bit" value="false"/>
      <field name="no_wait" domain="no_wait" value="false"/>
    </method>
    <method name="delete-ok" synchronous="1" index="41">
      <chassis name="client" implement="MUST"/>
      <field name="message_count" domain="message_count" value="0"/>
    </method>
  </class>
  <class name="basic" handler="channel" index="60">
    <chassis name="server" implement="MUST"/>
    <chassis name="client" implement="MAY"/>
    <field name="content_type" domain="shortstr"/>
    <field name="content_encoding" domain="shortstr"/>
    <field name="headers" domain="table"/>
    <field name="delivery_mode" domain="octet" value="1"/>
    <field name="priority" domain="octet" value="0"/>
    <field name="correlation_id" domain="shortstr"/>
    <field name="reply_to" domain="shortstr"/>
    <field name="expiration" domain="shortstr"/>
    <field name="message_id" domain="shortstr"/>
    <field name="timestamp" domain="timestamp"/>
    <field name="type" domain="shortstr"/>
    <field name="user_id" domain="shortstr"/>
    <field name="app_id" domain="shortstr"/>
    <field name="reserved" type="shortstr"/>
    <method name="qos" synchronous="1" index="10">
      <chassis name="server" implement="MUST"/>
      <response name="qos-ok"/>
      <field name="prefetch_size" domain="long" value="0"/>
      <field name="prefetch_count" domain="short" value="0"/>
      <field name="global" domain="bit" value="false"/>
    </method>
    <method name="qos-ok" synchronous="1" index="11">
      <chassis name="client" implement="MUST"/>
    </method>
    <method name="consume" synchronous="1" index="20">
      <chassis name="server" implement="MUST"/>
      <response name="consume-ok"/>
      <field name="reserved_1" type="short" reserved="1"  value="0"/>
      <field name="queue" domain="queue_name" value=""/>
      <field name="consumer_tag" domain="consumer_tag" value=""/>
      <field name="no_local" domain="no_local" value=""/>
      <field name="no_ack" domain="no_ack" value=""/>
      <field name="exclusive" domain="bit" value=""/>
      <field name="no_wait" domain="no_wait" value=""/>
      <field name="arguments" domain="table"/>
    </method>
    <method name="consume-ok" synchronous="1" index="21">
      <chassis name="client" implement="MUST"/>
      <field name="consumer_tag" domain="consumer_tag" value=""/>
    </method>
    <method name="cancel" synchronous="1" index="30">
      <chassis name="server" implement="MUST"/>
      <response name="cancel-ok"/>
      <field name="consumer_tag" domain="consumer_tag" value=""/>
      <field name="no_wait" domain="no_wait" value="false"/>
    </method>
    <method name="cancel-ok" synchronous="1" index="31">
      <chassis name="client" implement="MUST"/>
      <field name="consumer_tag" domain="consumer_tag" value=""/>
    </method>
    <method name="publish" content="1" index="40">
      <chassis name="server" implement="MUST"/>
      <field name="reserved_1" type="short" reserved="1" value="0"/>
      <field name="exchange" domain="exchange_name" value=""/>
      <field name="routing_key" domain="shortstr" value=""/>
      <field name="mandatory" domain="bit" value="false"/>
      <field name="immediate" domain="bit" value="false"/>
    </method>
    <method name="return" content="1" index="50">
      <chassis name="client" implement="MUST"/>
      <field name="reply_code" domain="reply_code" value="0"/>
      <field name="reply_text" domain="reply_text" value=""/>
      <field name="exchange" domain="exchange_name" value=""/>
      <field name="routing_key" domain="shortstr" value=""/>
    </method>
    <method name="deliver" content="1" index="60">
      <chassis name="client" implement="MUST"/>
      <field name="consumer_tag" domain="consumer_tag" value=""/>
      <field name="delivery_tag" domain="delivery_tag" value="0"/>
      <field name="redelivered" domain="redelivered" value="false"/>
      <field name="exchange" domain="exchange_name" value=""/>
      <field name="routing_key" domain="shortstr" value=""/>
    </method>
    <method name="get" synchronous="1" index="70">
      <response name="get-ok"/>
      <response name="get-empty"/>
      <chassis name="server" implement="MUST"/>
      <field name="reserved_1" type="short" reserved="1" value="0"/>
      <field name="queue" domain="queue_name" value=""/>
      <field name="no_ack" domain="no_ack" value="false"/>
    </method>
    <method name="get-ok" synchronous="1" content="1" index="71">
      <chassis name="client" implement="MAY"/>
      <field name="delivery_tag" domain="delivery_tag" value="0"/>
      <field name="redelivered" domain="redelivered" value="false"/>
      <field name="exchange" domain="exchange_name" value=""/>
      <field name="routing_key" domain="shortstr" value=""/>
      <field name="message_count" domain="message_count" value="0"/>
    </method>
    <method name="get-empty" synchronous="1" index="72">
      <chassis name="client" implement="MAY"/>
      <field name="reserved_1" type="shortstr" reserved="1" value=""/>
    </method>
    <method name="ack" index="80">
      <chassis name="server" implement="MUST"/>
      <field name="delivery_tag" domain="delivery_tag" value="0"/>
      <field name="multiple" domain="bit" value="false" />
    </method>
    <method name="reject" index="90">
      <chassis name="server" implement="MUST"/>
      <field name="delivery_tag" domain="delivery_tag" value="0"/>
      <field name="requeue" domain="bit" value="false"/>
    </method>
    <method name="recover-async" index="100" deprecated="1">
      <chassis name="server" implement="MAY"/>
      <field name="requeue" domain="bit"/>
    </method>
    <method name="recover" index="110">
      <chassis name="server" implement="MUST"/>
      <field name="requeue" domain="bit" value="false"/>
    </method>
    <method name="recover-ok" synchronous="1" index="111">
      <chassis name="client" implement="MUST"/>
    </method>
  </class>
  <class name="tx" handler="channel" index="90">
    <chassis name="server" implement="SHOULD"/>
    <chassis name="client" implement="MAY"/>
    <method name="select" synchronous="1" index="10">
      <chassis name="server" implement="MUST"/>
      <response name="select-ok"/>
    </method>
    <method name="select-ok" synchronous="1" index="11">
      <chassis name="client" implement="MUST"/>
    </method>
    <method name="commit" synchronous="1" index="20">
      <chassis name="server" implement="MUST"/>
      <response name="commit-ok"/>
    </method>
    <method name="commit-ok" synchronous="1" index="21">
      <chassis name="client" implement="MUST"/>
    </method>
    <method name="rollback" synchronous="1" index="30">
      <chassis name="server" implement="MUST"/>
      <response name="rollback-ok"/>
    </method>
    <method name="rollback-ok" synchronous="1" index="31">
      <chassis name="client" implement="MUST"/>
    </method>
  </class>
</amqp>
    }
}
