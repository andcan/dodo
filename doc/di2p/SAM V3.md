Updated August 2010 for release 0.8
Specified below is a simple client protocol for interacting with I2P.

SAM version 3 was introduced in I2P release 0.7.3. Alternatives: SAM V1, SAM V2, BOB.

Version 3 Changes SAM v2 provided a way to manage several sockets on the same I2P destination in parallel, i.e. the client does not have to wait for data being successfully sent on one socket before sending data on another socket. But all data transited through the same client<-->SAM socket, which was quite complicated to manage for the client.

SAM v3 manages sockets in a different way: each I2P socket matches a unique client<-->SAM socket, which is much more simple to handle. This is similar to BOB. 
SAM v3 also offers a UDP port for sending datagrams through I2P, and can forward back I2P datagrams to the client's datagram server.

Version 3 Protocol

----------------------------------------------------------------------
Simple Anonymous Messaging (SAM version 3.0) Specification
----------------------------------------------------------------------
Client application talks to SAM bridge, which deals with
all of the I2P functionality (using the streaming 
lib for virtual streams, or I2CP directly for async messages).

All client<-->SAM bridge communication is unencrypted and 
unauthenticated.  Access to the SAM
bridge should be protected through firewalls or other means
(perhaps the bridge may have ACLs on what IPs it accepts 
connections from).

All of these SAM messages are sent on a single line in plain ASCII,
terminated by the newline character (\n).  The formatting shown
below is merely for readability, and while the first two words in
each message must stay in their specific order, the ordering of
the key=value pairs can change (e.g. "ONE TWO A=B C=D" or 
"ONE TWO C=D A=B" are both perfectly valid constructions).  In
addition, the protocol is case-sensitive.
In the following, message examples are preceded by "-> " for
messages sent by the client to the SAM bridge, and by "<- " for
messages sent by the SAM bridge to the client.

I2P communications can take three distinct forms:
* Virtual streams
* Repliable datagrams (messages with a FROM field)
* Anonymous datagrams (raw anonymous messages)

I2P communications are supported by I2P sessions, and each I2P
session is bound to an address (called destination). An I2P session
is associated with one of the three types above, and cannot carry
communications of another type.

  
----------------------------------------------------------------------
SAM connection handshake
----------------------------------------------------------------------
No SAM communication can occur until after the client and bridge have
agreed on a protocol version, which is done by the client sending
a HELLO and the bridge sending a HELLO REPLY: 

->  HELLO VERSION MIN=$min MAX=$max

and

<-  HELLO REPLY RESULT=OK VERSION=3.0

*** In order to force protocol version 3.0, the values of $min and $max
*** must be "3.0".

If the SAM bridge cannot find a suitable version, it replies with :

<- HELLO REPLY RESULT=NOVERSION

If some error occurred, such as a bad request format, it replies with :

<- HELLO REPLY RESULT=I2P_ERROR MESSAGE={$message}


----------------------------------------------------------------------
SAM sessions
----------------------------------------------------------------------
A SAM session is created by a client opening a socket to the SAM 
bridge, operating a handshake, and sending a SESSION CREATE message, 
and the session terminates when the socket is disconnected.

Each registered I2P Destination is uniquely associated with a session ID
(or nickname).

Each session is uniquely associated with :
 * the socket from which the client creates the session
 * its ID (or nickname)

The session creation message can only use one of these forms (messages 
received through other forms are answered with an error message) :

->  SESSION CREATE 
          STYLE={STREAM,DATAGRAM,RAW}
          ID={$nickname}
          DESTINATION={$private_destination_key,TRANSIENT}
          [option=value]*

DESTINATION specifies what destination should be used for 
sending and receiving messages/streams.  It has to be a suitable
private base64 destination key. If the destination is
specified as TRANSIENT, the SAM bridge creates a new destination.

{$nickname} is the choice of the client. No whitespace is allowed.

Additional options given are passed to the I2P session 
configuration if not interpreted by the SAM bridge (e.g. 
outbound.length=0). These options are documented below.

The SAM bridge itself should already be configured with what router 
it should communicate over I2P through (though if need be there may
be a way to provide an override, e.g. i2cp.tcp.host=localhost and 
i2cp.tcp.port=7654).

After receiving the session create message, the SAM bridge will reply
with a session status message, as follows:

If the creation was successful :
<-  SESSION STATUS RESULT=OK DESTINATION={$private_destination_key}

If the nickname is already associated with a session :
<-  SESSION STATUS RESULT=DUPLICATED_ID

If the destination is already in use :
<-  SESSION STATUS RESULT=DUPLICATED_DEST

If the destination is not a valid private destination key :
<-  SESSION STATUS RESULT=INVALID_KEY

If some other error has occurred :
<-  SESSION STATUS RESULT=I2P_ERROR MESSAGE={$message}

If it's not OK, the MESSAGE should contain human-readable information
as to why the session could not be created.


SAM sessions live and die with the socket they are associated with.
When the socket is closed, the session dies, and all communications
using the session die at the same time. And the other way round, when
the session dies for any reason, the SAM bridge closes the socket.


----------------------------------------------------------------------
SAM virtual streams
----------------------------------------------------------------------
Virtual streams are guaranteed to be sent reliably and in order, with
failure and success notification as soon as it is available.

Streams are bidirectional communication sockets between two I2P
destinations, but their opening has to be requested by one of them. 
Hereafter, CONNECT commands are used by the SAM client for such a
request. FORWARD / ACCEPT commands are used by the SAM client when
he wants to listen to requests coming from other I2P destinations.


-----------------------------
SAM virtual streams : CONNECT
-----------------------------
A client asks for a connection by :
 * opening a new socket with the SAM bridge
 * passing the same HELLO handshake as above
 * sending the connection command :  

-> STREAM CONNECT
         ID={$nickname}
         DESTINATION=$peer_public_base64_key
         [SILENT={true,false}]

This establishes a new virtual connection from the local session
whose ID is {$nickname} to the specified peer.

If SILENT=true is passed, the SAM bridge won't issue any other message
on the socket : if the connection fails, the socket will be closed.
If the connection succeeds, all remaining data passing through the
current socket is forwarded from and to the connected I2P destination
peer.

If SILENT=false, which is the default value, the SAM bridge sends a
last message to its client before forwarding or shutting down the
socket :

<-  STREAM STATUS 
         RESULT=$result
         [MESSAGE=...]

The RESULT value may be one of:

    OK
    CANT_REACH_PEER
    I2P_ERROR
    INVALID_KEY
    INVALID_ID
    TIMEOUT

If the RESULT is OK, all remaining data passing through the
current socket is forwarded from and to the connected I2P destination
peer. If the connection was not possible (timeout, etc),
RESULT will contain the appropriate error value (accompanied by an
optional human-readable MESSAGE), and the SAM bridge closes the
socket.

----------------------------
SAM virtual streams : ACCEPT
----------------------------

A client waits for an incoming connection request by :
 * opening a new socket with the SAM bridge
 * passing the same HELLO handshake as above
 * sending the accept command :  

-> STREAM ACCEPT
         ID={$nickname}
         [SILENT={true,false}]

This makes the session ${nickname} listen for one incoming
connection request from the I2P network.

The SAM bridge answers with :

<-  STREAM STATUS 
         RESULT=$result
         [MESSAGE=...]

The RESULT value may be one of:

    OK
    I2P_ERROR
    INVALID_ID

If the result is not OK, the socket is closed immediately by the SAM
bridge. If the result is OK, the SAM bridge starts waiting for an
incoming connection request from another I2P peer. When a request
arrives, the SAM bridge accepts it and :

 * If SILENT=true was passed, the SAM bridge won't issue any other message
on the client socket : all remaining data passing through the
current socket is forwarded from and to the connected I2P destination
peer.
 * If SILENT=false was passed, which is the default value, the SAM bridge
sends the client a ASCII line containing the base64 public destination key
of the requesting peer. After this '\n' terminated line, all remaining data 
passing through the current socket is forwarded from and to the connected
I2P destination peer, until one of the peer closes the socket.

-----------------------------
SAM virtual streams : FORWARD
-----------------------------

A client can use a regular socket server and wait for connection requests
coming from I2P. For that, the client has to :
 * open a new socket with the SAM bridge
 * pass the same HELLO handshake as above
 * send the forward command :

-> STREAM FORWARD
         ID={$nickname}
         PORT={$port}
         [HOST={$host}]
         [SILENT={true,false}]

This makes the session ${nickname} listen for incoming
connection requests from the I2P network.

The SAM bridge answers with :

<-  STREAM STATUS 
         RESULT=$result
         [MESSAGE=...]

The RESULT value may be one of:

    OK
    I2P_ERROR
    INVALID_ID

 * {$host} is the hostname or IP address of the socket server to which
SAM will forward connection requests. If not given, SAM takes the IP
of the socket that issued the forward command.

 * {$port} is the port number of the socket server to which SAM will
forward connection requests. It is mandatory.

When a connection request arrives from I2P, the SAM bridge requests a
socket connection from {$host}:{$port}. If it is accepted after no more
than 3 seconds, SAM will accept the connection from I2P, and then :

 * If SILENT=true was passed, all data passing through the obtained
current socket is forwarded from and to the connected I2P destination
peer.
 * If SILENT=false was passed, which is the default value, the SAM bridge
sends on the obtained socket an ASCII line containing the base64 public
destination key of the requesting peer. After this '\n' terminated line,
all remaining data passing through the socket is forwarded from and to 
the connected I2P destination peer, until one of the sides closes the
socket.



The I2P router will stop listening to incoming connection requests as
soon as the "forwarding" socket is closed.




----------------------------------------------------------------------
SAM repliable datagrams : sending a datagram
----------------------------------------------------------------------
While I2P doesn't inherently contain a FROM address, for ease of use
an additional layer is provided as repliable datagrams - unordered
and unreliable messages of up to 31KB in size that include a FROM 
address (leaving up to 1KB for header material).  This FROM address 
is authenticated internally by SAM (making use of the destination's 
signing key to verify the source) and includes replay prevention.

After establishing a SAM session with STYLE=DATAGRAM, the client can
send datagrams through SAM's UDP port (7655).

The first line of a datagram sent through this port has to be in the
following format :

3.0 {$nickname} {$base64_public_destination_key}

 * 3.0 is the version of SAM
 * {$nickname} is the id of the DGRAM session that will be used
 * {$base64_public_destination_key} is the destination of the
    datagram
 * this line is '\n' terminated.

The first line will be discarded by SAM before sending the remaining
of the message to the specified destination.

----------------------------------------------------------------------
SAM repliable datagrams : receiving a datagram
----------------------------------------------------------------------
Received datagrams are written by SAM on the socket from which the
datagram session was opened, unless specified otherwise by the CREATE
command.

When a datagram arrives, the bridge delivers it to the client via the
message :

<-  DATAGRAM RECEIVED
           DESTINATION=$base64key
           SIZE=$numBytes\n[$numBytes of data]

The SAM bridge never exposes to the client the authentication headers
or other fields, merely the data that the sender provided.  This 
continues until the session is closed (by the client dropping the
connection).

----------------------------------------------------------------------
SAM repliable datagrams : forwarding datagrams
----------------------------------------------------------------------
When creating a datagram session, the client can ask SAM to forward
incoming messages to a specified ip:port. It does so by issuing the
CREATE command with PORT and HOST options :

-> SESSION CREATE 
          STYLE=DATAGRAM
          ID={$nickname}
          DESTINATION={$private_destination_key,TRANSIENT}
          PORT={$port}
          [HOST={$host}]
          [option=value]*

 * {$host} is the hostname or IP address of the datagram server to
     which SAM will forward datagrams. If not given, SAM takes the
     IP of the socket that issued the forward command.

 * {$port} is the port number of the datagram server to which SAM
     will forward datagrams.

When a datagram arrives, the bridge sends to the specified host:port
a message containing the following data :

${sender_base64_destination_key}\n{$datagram_payload}


----------------------------------------------------------------------
SAM anonymous datagrams
----------------------------------------------------------------------
Squeezing the most out of I2P's bandwidth, SAM allows clients to send
and receive anonymous datagrams, leaving authentication and reply 
information up to the client themselves.  These datagrams are 
unreliable and unordered, and may be up to 32KB in size.

After establishing a SAM session with STYLE=RAW, the client can
send anonymous datagrams through the SAM bridge exactly the same way
he sends non anonymous datagrams.

Both ways of receiving datagrams are also available for anonymous
datagrams.

When anonymous datagrams are to be written to the socket that created
the session,the bridge delivers it to the client via:

<- RAW RECEIVED
      SIZE=$numBytes\n[$numBytes of data]

When anonymous datagrams are to be forwarded to some host:port,
the bridge sends to the specified host:port a message containing 
the following data :

{$datagram_payload}


----------------------------------------------------------------------
SAM utility functionality
----------------------------------------------------------------------
The following message can be used by the client to query the SAM
bridge for name resolution:

 NAMING LOOKUP 
        NAME=$name

which is answered by

 NAMING REPLY 
        RESULT=$result
        NAME=$name 
        [VALUE=$base64key]
        [MESSAGE=$message]


The RESULT value may be one of:

    OK
    INVALID_KEY
    KEY_NOT_FOUND

If NAME=ME, then the reply will contain the base64key used by the
current session (useful if you're using a TRANSIENT one).  If $result
is not OK, MESSAGE may convey a descriptive message, such as "bad
format", etc.

Public and private base64 keys can be generated using the following
message:

 DEST GENERATE

which is answered by

 DEST REPLY
      PUB=$pubkey
      PRIV=$privkey

----------------------------------------------------------------------
RESULT values
----------------------------------------------------------------------
These are the values that can be carried by the RESULT field, with
their meaning:

 OK              Operation completed successfully
 CANT_REACH_PEER The peer exists, but cannot be reached
 DUPLICATED_DEST The specified Destination is already in use
 I2P_ERROR       A generic I2P error (e.g. I2CP disconnection, etc.)
 INVALID_KEY     The specified key is not valid (bad format, etc.)
 KEY_NOT_FOUND   The naming system can't resolve the given name
 PEER_NOT_FOUND  The peer cannot be found on the network
 TIMEOUT         Timeout while waiting for an event (e.g. peer answer)


----------------------------------------------------------------------
Tunnel, I2CP, and Streaming Options
----------------------------------------------------------------------

These options may be passed in as name=value pairs at the end of a
SAM SESSION CREATE line.

All sessions may include I2CP options such as tunnel lengths.
STREAM sessions may include Streaming lib options.
See those references for option names and defaults.


----------------------------------------------------------------------
BASE 64 Notes
---------------------------------------------------------------------- 

Base 64 encoding must use the I2P standard Base 64 alphabet "A-Z, a-z, 0-9, -, ~".


----------------------------------------------------------------------
Client library implementations:
---------------------------------------------------------------------- 
Client libraries are available for C, C++, C#, Perl, and Python.
These are in the apps/sam/ directory in the I2P Source Package.
Some may be older and have not been updated for SAMv3 support.


----------------------------------------------------------------------
Default SAM Setup
---------------------------------------------------------------------- 

The default SAM port is 7656. SAM is not enabled by default in the I2P Router;
it must be started manually, or configured to start automatically,
on the configure clients page in the router console, or in the clients.config file.
The default SAM UDP port is 7655, listening on 0.0.0.0.
These may be changed by adding the arguments sam.udp.port=nnnnn and/or
sam.udp.host=w.x.y.z to the invocation.