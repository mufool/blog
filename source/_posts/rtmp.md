---
title: RTMP协议
date: 2017-11-30 17:33:22
tags: [RTMP]
---

## 概念

实时消息传输协议(RTMP)最初是由 Macromedia 为互联网上 Flash player 和服务器之间传输音频、视频以及数据流而开发的一个私有协议。RTMP协议是一个互联网TCP/IP五层体系结构中应用层的协议。RTMP协议中基本的数据单元称为消息（Message）。当RTMP协议在互联网中传输数据的时候，消息会被拆分成更小的单元，称为消息块（Chunk）。（本文内容多来自文档翻译）

<!-- more -->

## 相关术语

- AMF(Action Message Format)是在flash和flex中与远程服务端交换数据的一种格式。它是二进制格式，Flash应用与服务端或数据库通过RPC交换数据时，通常都采用这种格式。AMF 1 诞生于Flash Player6，发展到现在已经变成了了AMF3。
- RTMP(Real-Time Messaging Protocol实时消息传送协议)的缩写，它是Adobe Systems公司为Flash播放器和服务器之间音频、视频和数据传输开发的协议。这是一个标准的，未加密的实时消息传递协议，默认端口是1935，如果未指定连接端口，那么flash客户端会尝试连接其他端口，其尝试连接顺序按照下列顺序依次连接：1935、443、80(RTMP), 80(RTMPT)。
- RTMPT，RTMP的变种，此协建立在HTTP协议之上，是通过HTTP封装后的RTMP协议，默认端口80。
- RTMPS，RTMP的另一个变种，此协议是通过SSL(Secure Sockets Layer 安全套接层)加密的RTMP协议，为数据通讯提供安全支持。SSL在传输层对网络连接进行加密，默认端口443。
- RTMPE，RTMP的变种，RTMPE是一个加密版本的RTMP，和RTMPS不同的是RTMPE不采用SSL加密，RTMPE加密快于SSL,并且不需要认证管理。如果没有指定RTMPE端口，Flash播放器将像RTMP协议一样依次扫描下列端口，1935(RTMPE)，443(RTMPE) ，80(RTMPE)，80(RTMPTE)。
- RTMPTE，RTMPTE 这个协议是一个通过加密通道连接的RTMPE，默认端口80。
- RTMFP，RTMFP是Adobe公司开发的一套新的通信协议，该协议可以让使用Adobe Flash Player的终端用户之间进行直接通信。

## RTMP协议格式

### 握手

1、 基本命令
C0 和S0：分别是1 个byte 的数据块，它主要是为了指明RTMP 的版本。对于Client 来说代表了客户端请求使用的版本，而对Server 来说，表明了服务端选择使用的版本。现在所使用的版本号都是0x03,0-2是早期产品所用的，已被丢弃；4-31保留在未来使用 ；32-255不允许使用。如果Client 请求了一个非法的版本号，那么Server 应该返回版本号0x03。Client 要么同意Server 的选择，要么放弃握手。
![image](http://pic-blog.bfvyun.com/rtmp/c0s0.jpg)

C1 和S1 ：分别是一个1536 bytes 长的数据块。这个数据块的前4 个bytes 指明了这个数据块创建的当前时间戳，也可以是0。后面4 个bytes 通常是0，也可以是版本号，对于Client来说是FP 的版本号，对于Server 来说是FMS 的版本号。随后的1528 个bytes 的值是任意填写的。
![image](http://pic-blog.bfvyun.com/rtmp/c1s1.jpg)

C2 和S2 ：也分别是一个1536 bytes 长的数据块。所不同的是，对于C2 来说，time 和time2的值必须是从S1 中读取的；反过来对S2 也一样，是从C1 中读取的。另一方面剩下的1528个bytes 也不再是随机值了，对于C2 来说这些bytes 必须来自S1，反过来对S2 也一样，这些bytes 必须来自C1。总结下来就是说，C2 要把之前S1 的1536 bytes 内容完完整整的发回给Server，S2 也做类似的动作，把之前收到的C1 的内容完整的发回给Client。
![image](http://pic-blog.bfvyun.com/rtmp/c2s2.jpg)

2、握手流程
- 首先由Client 发送C0、C1 给Server，并且等待S1 的到来。
- 当Server 收到C0 之后，发送S0 和S1 给Client，在收到C1 之后，发送S2 给Client，并等待C2 的到来。
- 当Client 收到S1 之后，发送C2 给Server，在收到S2 之后，就可以发送后续的数据了。
- 当Server 收到C2 之后，就可以发送后续的数据了。

3、握手优化
由于C0、S0 只有1 个bytes，出于优化考虑，通常C0 和C1 是一起发送的，也就是握手开始发送1537 个bytes。由于Server 收到C1 就可以发送S2 了，所以通常Server 会一次性返回S0、S1 和S2 给Client。由于Client 发送完C2 之后就可以发送后续数据包了，因此通通常C2 之后有可能会跟随其他的数据块。

### 消息流（message stream）
message stream是逻辑意义上的流，包含command stream和media stream两种。command stream表示命令数据流，media stream表示媒体流。Command stream是指专门用来在Client 和Server 间传递命令控制消息的数据流。media stream是指包括音频、视频和元数据(metadata)在内的媒体流。

### Chunk
RTMP协议中消息在网络上传输时被拆分成消息块（chunk）。Message Stream 只是逻辑上的概念，因此每个Chunk 也都会包含一个Msg Stream ID。Chunk 的大小是人为指定的，客户端可以与服务器采用不同的chunk 大小。在没有指定之前，chunk 大小采用默认值128 字节。
每个Chunk 都会分配一个Chunk Stream ID。

1、Chunk格式
![image](http://pic-blog.bfvyun.com/rtmp/chunk.jpg)

2、Chunk Basic Header
Basic Header 包含fmt 和cs id 两个字段，fmt 表示协议头格式（Chunk Message HeaderFormat），cs id 表示流id（Chunk Stream ID）。Basic Header 长度为1-3 个字节，由cs id 字段来决定。
Fmt，决定了Chunk Message Header 的格式，取值为0-3，共四种格式。
Cs id，取值范围是0 – 65599，0-2 为保留值。0 表示basic header 长度为2 个字节，1 表示长度为3 个字节，2 表示该chunk 为控制消息（同时Message Stream ID必须是0）。
* 当Basic Header 长度为1 时，cs id 取值2-63。
![image](http://pic-blog.bfvyun.com/rtmp/bh1.jpg)

* 当Basic Header 长度为2时，cs id = 64 + the second byte。
![image](http://pic-blog.bfvyun.com/rtmp/bh2.jpg)

* 当Basic Header 长度为3 时，cs id = 64 + the second byte + the third byte × 256。
![image](http://pic-blog.bfvyun.com/rtmp/bh3.jpg)

解析csid示例代码：
```cpp
int nChannel = ((unsigned char)*m_recvBuf & 0x3f);
if(nChannel == 0)
{
    nChannel = (unsigned char)m_recvBuf[1] + 64;
}
else if(nChannel == 1)
{
    nChannel = (unsigned char)m_recvBuf[2] * 256 + (unsigned char)m_recvBuf[1] + 64;
}
```

3、Chunk Message Header
Fmt 取值从0-3，决定了四种长度的chunk msg header，可取值为11B、7B、3B、0B。
- type0（fmt=0）
![image](http://pic-blog.bfvyun.com/rtmp/cmh0.jpg)

* Timestamp，时间戳，最大值为0xffffff，当超过这个值时启用时间戳扩展字段（最大4 个字节）。当时间戳扩展启用时，这个值必须填0xffffff。
* Message length，并非trunk 的长度，而是指一条音视频帧或者控制消息的长度。
* Message type id，消息类型，0x01-0x07 为控制消息(Chunk Stream ID 必须为2)，0x08 为音频，0x09 为视频，0x12 为元数据，0x14 为命令消息，0x16 为组合消息。
* Msg streamid，Chunk 中的message stream id 为小端字节序，这是adobe 特别强调的。
每个Chunk Stream 开始的第一个Chunk 必须是Type 0 格式的，即使整个Chunk Stream只有一个Chunk。timestamp 表示Chunk 中的msg 的绝对时间值，每条Chunk Stream 的第一个Chunk 的timestamp 都是0。实战中我们发现type0 格式的chunk 非常少。
- type1（fmt=1）
![image](http://pic-blog.bfvyun.com/rtmp/cmh1.jpg)
type1的trunk 和上一个trunk 拥有相同的message stream id。且Timestamp delta 表示相对上一个trunk 的时间差，实战中大多数音视频数据都采用相对时间戳。

- type2（fmt=2）
![image](http://pic-blog.bfvyun.com/rtmp/cmh2.jpg)
type 2 的trunk 和上一个trunk 拥有相同的长度、消息类型、消息流id。

- type3（fmt=3）
Type 3 的trunk msg header 长度为0，表示和上一个trunk 所有参数都相同。如果type3跟在type0 后面，则type3 的相对时间戳也是0。

4、 Extended Timestamp:
这个字段是可选的，长度为4 个字节。只有当正常时间戳超过0xffffff 时，这个字段才存在。Type3 类型的trunk 一定不能有这个字段。

5、Chunk Data:
Chunk Data 可以是音视频数据、元数据、控制消息。

根据FMT的值（nPacketType）获取packet头信息代码如下
```cpp
int CRtmp::ParsePacketHead(const char *pInPacket, int nPacketType, CRtmpPacket *pOutPacket)
{
        if (pInPacket == NULL || pOutPacket == NULL)
{
    return -1;
}

switch (nPacketType)
{
	case 0:
	{
		pOutPacket->m_nTimeStamp = Utils::ReadInt24(pInPacket);
		pOutPacket->m_nMsgLen = Utils::ReadInt24(pInPacket + 3);
		pOutPacket->m_cPacketType = (unsigned char)*(pInPacket + 6);
		pOutPacket->m_nMsgStreamId = Utils::ReadInt32LE(pInPacket + 7);
		if(pOutPacket->m_nTimeStamp == 0xffffff)
		{
			pOutPacket->m_bIfUseExtTS = true;
		}
	}
	break;
	case 1:
	{
		pOutPacket->m_nTimeStamp = Utils::ReadInt24(pInPacket);
		pOutPacket->m_nMsgLen = Utils::ReadInt24(pInPacket + 3);
		pOutPacket->m_cPacketType = (unsigned char)*(pInPacket + 6);
	}
	break;
	case 2:
	{
		pOutPacket->m_nTimeStamp = Utils::ReadInt24(pInPacket);
	}
	break;
	case 3:
		break;
	default:
	break;
	}
	return 0;
}
```

### 实际中message与trunk的关系
在一条TCP 连接中，可以同时包含着几条Message Stream，绝大部分情况下是Control Msg Stream 和Media Msg Stream。而这些Msg Stream 由一段一段的Chunk Stream 组成，每个Chunk Stream 都带有一个Message Stream ID 以标识这个Chunk Stream 是属于哪一个Msg Stream。由于Chunk Stream 所包含的数据比较大，常常又被切分成更小的Chunk，每个Chunk 都带有一个Chunk Stream ID 以标识它属于哪一个Chunk Stream。

## 控制消息
控制消息是作为rtmp trunk stream 的负载存在的。当Message type id 取值为0-7 时，表示控制消息。同时Chunk Basic Header 的Chunk Stream ID 必须为2，Chunk Msg Header 的Message Stream ID 必须为0。其中消息7一般不用。
1、 0x01 – Set Chunk Size
![image](http://pic-blog.bfvyun.com/rtmp/scz.jpg)
这个消息是双向发送的，一方告诉另一方自己的trunk 大小。一旦设置成功则后续所有trunk 大小会一直保持这个值。设置之前是128。

2、 0x02 – About Message
![image](http://pic-blog.bfvyun.com/rtmp/am.jpg)
用来通知正在等待接收指定的Chunk Stream 的对端，放弃等待，并且放弃处理AboutMessage 中所指明的chunk stream id 的Chunk Stream 中的消息。注意这条命令只是撤销一个Chunk Stream 的数据，并不是整条Message Stream。实战中这个消息基本不会发送， 在rtmpdump 中也不会处理这个消息。

3、 0x03 – Acknowledgement
![image](http://pic-blog.bfvyun.com/rtmp/ack.jpg)
用来告知server，到目前为止已经收到了一定量的数据。0x05 消息指定了server 发送的窗口最大值，如果在发送的数据达到了最大值还没有收到客户端发来的报告，则server 会停止发送数据，经过实测fms 超过三倍这个窗口时会停止发送数据。因此客户端必须在收到数据未达到最大值前报告自己接收到的字节数。Sequence num 表示到目前为止客户端收到的字节数，但是要注意这个值会溢出，溢出后server不久便会停止发送数据，rtmpdump 就有这个问题。

4、 0x04 – User Control Message
![image](http://pic-blog.bfvyun.com/rtmp/ucm.jpg)
这条消息是用户控制消息。主要是用来在Client 与Server 之间发送消息通知对方用户控制事件。这个消息的前2 个bytes 是指事件的类型，后面是事件的数据。根据Event Type 的不同，Event Data 的长度是不同的。
* Type0，Stream Begin，服务器端通知客户端message stream 已经可以正常工作了。Event Data 是0，长度为4 个字节。这个事件是当服务器收到客户端的connect 命令后发送给客户端的。
* Type1，Stream EOF，服务器端通知客户端播放已经结束了。Event Data 表示流ID，长度为4 个字节。
* Type2，Stream Dry，服务器端通知客户端message stream 已经没有数据了。EventData 表示流ID，长度为4 个字节。服务器端在一段时间内没有检测到消息则可以给客户端发送这个事件。
* Type3，SetBuffer Length，客户端通知服务器端用来接收数据的buffer 大小（以毫秒为单位）。Event Data 共8 比特，前4 比特表示流ID，后4 比特代表buffer 大小。客户端在服务器端处理流之前发送这个事件。
* Type4，StreamIsRecorded，服务器端通知客户端这个流需要被录像。Event Data 表示流ID，长度为4 个字节。
* Type6，PingRequest，服务器端用于测试客户端是否存活。Event Data 为服务器时间戳，长度为4 个字节。
* Type7，PingResponse，客户端反馈服务器端PingRequest 消息，Event Data 为ping消息中的时间戳，长度为4 个字节。Ping 消息必须回，否则一段时间后server 会停止服务。

5、 0x05 – Window Acknowledgement Size
![image](http://pic-blog.bfvyun.com/rtmp/waz.jpg)
这条消息也叫“Server Bandwidth”，主要是用于告知对方自己希望对方接收多少个字节之后回应一个Ack 确认消息。这个具体的字节数也叫做窗口大小。通常Server 会在成功处理Client 发出的connect 请求后发送这个Msg 更新Client 的Ack 窗口大小。

6、 0x06 – Set Peer Bandwidth
![image](http://pic-blog.bfvyun.com/rtmp/spb.jpg)
这条消息也叫“Client Bandwidth”，和Msg Type 0x05 相对应，这条消息是告诉对方要以怎样的带宽发送数据，带宽值应该与对方的Windows Size 相同。如果收到这条消息的一方发现自己的Windows Size 和这条消息中指定的Bandwidth 不同，应该回应一个Msg Type0x05。另外这条消息还有一个额外的字段Limit type，它的取值分别为：hard(0)、soft(1)、dynamic(2)。
* Hard：对方的发送数据带宽必须严格符合指定带宽。
* Soft：对方发送数据带宽可以自行决定。必要时接收方可以限制对方带宽。
* Dynamic：带宽既可以是hard 也可以是soft。

## 命令消息
当Message type id 取值为14 时，表示命令消息。命令消息对Chunk Stream ID 和MessageStream ID 没有特殊要求，而控制消息是有的。命令消息分为两大类，NetConnection 和NetStream。
- NetConnection 包括：connect、call、close、createStream 命令。
- NetStream 包括：play、play2、deleteStream、closeStream、receiveAudio、receiveVideo、publish、seek、pause 命令。
命令的格式为command name + transaction ID + 其他，所有字段都是用AMF 格式封装的，transaction ID的含义不明确，虽然官方文档有规定，但是实战中不是这么用的。下面我们只介绍最常用的connect、createStream、Play 命令，这三个命令是必须的，其他命令可以不用。
### Connect
Connect 命令是client 发送给server 的第一个命令，而此时chunk 大小还没有设定。因此client 采用默认值128 字节。
Client 到Server 命令格式：
![image](http://pic-blog.bfvyun.com/rtmp/connectc2s.jpg)
其中Command object的取值包括:
![image](http://pic-blog.bfvyun.com/rtmp/connectcmdobj.jpg)
Server 到Client 命令格式:
![image](http://pic-blog.bfvyun.com/rtmp/connects2c.jpg)

### createStream
Createstream 用于与服务器创建一条逻辑链路，传输音频、视频、元数据。
Client 到Server 格式如下：
![image](http://pic-blog.bfvyun.com/rtmp/createc2s.jpg)
Server 到Client 格式如下：
![image](http://pic-blog.bfvyun.com/rtmp/creates2c.jpg)

### Play
开始播放一条stream，streamid为createstream返回的id。
Client 到Server 格式如下：
![image](http://pic-blog.bfvyun.com/rtmp/playc2s.jpg)
Server 到Client 格式如下:
![image](http://pic-blog.bfvyun.com/rtmp/plays2c.jpg)

## 客户端与服务器交互流程
客户端与服务器之间的交互可以划分为三个过程:握手、设置参数、播放。

### 握手
![image](http://pic-blog.bfvyun.com/rtmp/handshake.jpg)

### 设置参数
![image](http://pic-blog.bfvyun.com/rtmp/setconf.jpg)

### 播放
![image](http://pic-blog.bfvyun.com/rtmp/play.jpg)

### 从rtmpdump观察到的交互流程
client ----------------------------------server
1.RTMP_Connect----------------------------------------------------------------------->
2.HandleServerBW<---------------------------------------------------------------------
3.HandleClientBW<----------------------------------------------------------------------
4.HandleChangeChunkSize<------------------------------------------------------------
5.HandleInvoke(_result for connect, NetConnection.Connect.Success)<-----------
6.SendServerBW----------------------------------------------------------------------->
7.SendRecvBuffSize-------------------------------------------------------------------->
8.SendCreateStream------------------------------------------------------------------>
9.HandleInvoke(onBWDone)<----------------------------------------------------------
10.SendCheckBW(_checkbw)--------------------------------------------------------->
11. HandleInvoke(_result for createStream, 得到stream id)<-----------------------
12.SendPlay----------------------------------------------------------------------------->
13.SendClientBufferTime-------------------------------------------------------------->
14.HandleInvoke(_onbwcheck)<-------------------------------------------------------
15.SendCheckBwResult---------------------------------------------------------------->
16.ChangeChunkSize<------------------------------------------------------------------
17.HandleCtrl(stream is recorded)<---------------------------------------------------
18.HandleInvoke(onStatus: NetStream.Play.Reset)<--------------------------------
19.HandleCtrl(Stream Begin)<---------------------------------------------------------
20.HandleInvoke(onStatus: NetStream.Play.Start)<---------------------------------
21.MetaData(RtmpSampleAccess)<---------------------------------------------------
22.MetaData(NetStream.Data.Start)<-------------------------------------------------
23.MetaData(onMetaData)<------------------------------------------------------------
说明:HandleInvoke指的就是命令消息，HandleCtrl指的是控制消息。
1到7为设置参数阶段、8到23为播放阶段、第13步SendClientBufferTime，这个命令是向服务器发送本地接收缓冲区的大小，以时间（毫秒）为单位。实战中发现，FMS流控就是依靠这个参数来做的。如果将这个值设置为5000，则我们会发现FMS快速发送一部分数据（应该是5秒的数据），然后等待大约5秒，然后再发送一部分数据，这种流控其实很不合理。

## 混合消息
混合消息（Aggregate Message）是由多个消息组合而成的消息，Msg type 为0x16。之所以会存在这样的打包消息。是为了减少FMS 因为IO 过于频繁而导致CPU 开销过大的一种优化。
![image](http://pic-blog.bfvyun.com/rtmp/aggregate.jpg)
混合消息中包含很多子消息，实战中发现子消息只有视频、音频、元信息三种。需要说明一点的是，子消息中的head 指的是flv 头而不是rtmp 头。如果非要解析这个数据包的话必须结合flv 头格式进行解析。还有注意一点，flv头中的时间戳都是绝对时间戳，和rtmp 流的时间戳不是一个体系的。如果要计算子消息的时间戳则要结合混合消息头消息中的时间戳。子消息的相对时间可以这样来计算：第一个子消息的时间戳与混合消息的时间戳相同，后续子消息用自己的绝对时间戳减去第一个子消息的绝对时间戳，然后再加上混合消息的时间戳即可。在Aggregate Message body 的打包消息列表中，Back Pointer 的内容是前一个Msg 的尺寸，包括Msg Header，这和FLV File Format 中的PreviousTagSize 非常相似。

## 加流控信息
flv文件头非常小，通常只有几百个字节，好处是元信息很少便于传输，坏处是不便于对数据做索引。下面两个工具可以给flv增加关键帧索引信息，即关键帧的位置和播放时间。
元数据主要有两个数组，times和filepositions,这两个数组是相对应的，比如times[10]=184.4，而filepositions[10]=10000,意思是视频在184.4秒处的文件位置是10000，当向http服务器（例如Nginx）视频信息时
http://localhost/flv/1.flv？start=10000,则视频就会从184.4秒处开始播放，这样就实现了seek到184.4的效果。但是需要注意的是，start的数值必须是关键帧数组里的filepositions的值，否则不会成功。

参考：
[flvtool2](http://rubyforge.org/frs/?group_id=1096)
[yamdi](http://yamdi.sourceforge.net)





















