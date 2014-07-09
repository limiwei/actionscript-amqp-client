--------------------------------------------------------------
Folder Structure
--------------------------------------------------------------
RabbitFlash.html    html file for amqp client tester application
RabbitFlash.swf     swf file for the amqp client tester application
src                 source code. client library is in "amqp_client" folder "org.mpj.amqp"
libraries           contains the swc libraries. currently just one, "amqp_client.swc"
Flash Professional  contains project files/sources for flash profession projects
Flash Professional\swc    contains the flash professional project for creating "amqp_client.swc"
Flash Professional\amqp tester  contains the flash professional project for ceating the amqp tester flash movie

--------------------------------------------------------------
First Steps
--------------------------------------------------------------

Launch the RabbitFlash.html. This tester application contains all of the tutorials on the
rabbitmq website. It also contains a full protocol tester, where you can send any amqp method
to a server.

The tutorial code is contained in each dialog of the tester application. You can also look at
the tutorial actions cript files located in "Flash Professional\amqp tester\user_interface\tutorials"

--------------------------------------------------------------
How to use the client library
--------------------------------------------------------------
The two main interaces to the library are;

org.mpj.amqp.Connection
org.mpj.amqp.Channel

The library is desgined so that all calls are sent through a sendMethod function off of
the channel class. The library uses the concept of promises, which all calls will return.

1. create the connection;

    connection:Connection = new Connection({}, false);
    
    The empty object is the set of paramters, these are the current parameters that you can override;
        
    protocol      : AMQPParser.v0_9_1
    host          : "127.0.0.1"
    port          : 5672
    virtual_host  : "/"
    user          : "guest"
    password      : "guest"
    heartbeat     : false

2. add a listener for when the connection is ready

    connection.addEventListener(ConnectionEvent.CONNECTION_READY, onConnectionReady);

3. connect to the rabbitmq server

    connection.connect(hostName, user, password);
    
    Any paramters not passed will default. the following will default to "127.0.0.1" for host;
    
    connection.connect(null, user, password);
     
    when the connection is ready the onConnectionREady will be called;
    
    private function onConnectionReady(event:ConnectionEvent):void {
    
    }

4. after the connection ready event is made, you can make calls to the server via a channel. If you
make calls to the channel before the connection is ready, the messages will be queued until the connection
is ready. If an error happens during connection the queued messages will be lost. Therfor you should wait
until the connection is ready before sending methods via the channel.

// declare the queue
var p:Promise = connection.channel.sendMethod("queue.declare", {queue:"hello"});
            
// send basic publish
p.onResult(function(info:PromiseResult) 
{
    connection.channel.sendMethod(
    "basic.publish", 
    {routing_key:"hello"}, 
    "Hello World!");
});

The sendMethod takes three parameters, the first is the name of the method you want to
send. It can be in "class name.method name" or "class index.method index" format. The second
parameter is an object that contains any fields/properites for the method you want to override
from the defaults. In the above example we are setting the queue field. You can set any field
or property in the same object. The third parameter is the body to be sent with the message.

