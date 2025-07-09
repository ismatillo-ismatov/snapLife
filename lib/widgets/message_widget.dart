import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/message_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/models/messages.dart';
import 'package:ismatov/models/shortUserprofile.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:provider/provider.dart';
import 'package:ismatov/widgets/chat_provider.dart';
import 'package:web_socket_channel/io.dart';

class ChatPage extends StatefulWidget{
  final int sender;
  final int receiver;

  const ChatPage({Key? key, required this.sender, required this.receiver}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage>{
  final MessageService messageService = MessageService();
  List<Message> messages = [];
  String? token;
  PartialMessage? _replyIngTo;
  // Message? _replyIngTo;
  final TextEditingController _messageController = TextEditingController();

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _initializeChat();

  }
  @override
  void dispose() {
    _timer?.cancel();
    messageService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

void _initializeChat() async {
  print('ChatPage initialized with sender:${widget.sender},receiver:${widget.receiver}');
   token = await ApiService().getUserToken();
   if (token == null) {
     print("Token yoqm foydalanuvchi lofin qilmagan");
   }
  messageService.connectToWebSocket(
      widget.sender,
      widget.receiver,
          (newMessage) {
        if (mounted) {
          setState(() {
            messages.add(newMessage);
          });
        }
      }
  );
  messageService.markAllAsRead(
      senderId: widget.receiver,
      receiverId: widget.sender,
      token: token!
  );
  _fetchMessages();

}

  Future<void> _fetchMessages() async {
    try{
      token = await ApiService().getUserToken();
      if(token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Token not found. Please log in again."))
        );
        return;
      }
      print("Fetching messages for sender: ${widget.sender}, receiver: ${widget.receiver}");
      final fetchedMessages = await MessageService().fetchMessages(
          widget.sender,
          widget.receiver,
          token!
      );
      if (mounted) {
        setState(() {
          messages = fetchedMessages;

        });
      }
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch messages: $e"))
      );

    }
  }

@override
void didChangeDependencies(){
    super.didChangeDependencies();
}


Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _sendMediaMessage(pickedFile.path, 'image');
    }
}

Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _sendMediaMessage(pickedFile.path, 'video');
    }
}

Future<void> _recordAudio() async {

}

Future<void> _sendMediaMessage(String filePath, String type) async {
    if (filePath.isNotEmpty) {
      final file = File(filePath);
      if (!file.existsSync()) return;

          try{
            String? token = await ApiService().getUserToken();
            if (token == null) throw Exception("token topilmadi");
            final uri = Uri.parse("${ApiService.baseUrl}/messages/");
            final request = http.MultipartRequest('POST',uri)
              ..headers['Authorization'] = 'Token $token'
              ..fields['receiver'] = widget.receiver.toString()
              ..fields['type'] = type
              ..fields['message'] = ''
              ..files.add(await http.MultipartFile.fromPath('file', filePath));

            final responseStream = await request.send();
            final response = await http.Response.fromStream(responseStream);
            if (response.statusCode == 201 || response.statusCode == 200 ) {
              print("send media file");

              final responseData = jsonDecode(response.body);
              final newMessage = Message.fromJson(responseData);
              setState(() {
                messages.add(newMessage);
              });
            } else {
              print('send error: ${response.statusCode}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("not send media: ${response.statusCode}")),

              );
            }


          } catch (e) {
            print("Error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Send media error: $e")),
            );
          }
    }


}


String _formatTime(String timestamp) {
    final time = DateTime.parse(timestamp).toLocal();
    return "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}";
}

  void _sendMessage() async {
    if(_messageController.text.isNotEmpty) {
      final messageText = _messageController.text;
      _messageController.clear();
      final replyTo = _replyIngTo;

      final newMessage = Message(
        id: 0,
        sender: ShortUserProfile(id: widget.sender, userName: 'You',profileImage: null,),
        receiver: ShortUserProfile(id: widget.receiver, userName: '',profileImage: null),
          message: messageText,
        is_read: false,
        timestamp: DateTime.now().toIso8601String(),
        type: 'text',
        file: null,
        repliedTo: replyTo,
      );
      setState(() {
        messages.add(newMessage);
        _replyIngTo = null;
      });
      try {
        bool success = await messageService.sendMessage(
            widget.sender,
            widget.receiver,
            messageText,
            type: 'text',
            repliedToId: replyTo?.id,

        );
        if(success){
          print('xabar yuborildi');
        }else {
          print('Xotolik yuz berdi');
        }
      } catch (e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xabar yuborilmadi $e")),
        );
      }
    }
  }

  Widget _buildReplyPreveiw() {
    if (_replyIngTo == null) return SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [

            Text(
              "Replying to: ${_replyIngTo!.sender.userName}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
                Text(
                  _replyIngTo!.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
      ]
          ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _replyIngTo = null;
              });
            },
          )
        ],
      ),
    );
  }





  Widget _buildMessageInput() {
    return Row(
      children: [
        IconButton(
            icon: Icon(Icons.image),
          onPressed: _pickImage,
        ),

        IconButton(
          icon: Icon(Icons.videocam),
          onPressed: _pickVideo,
        ),
        IconButton(
          icon: Icon(Icons.mic),
          onPressed: _recordAudio,
        ),



        Expanded(
            child: TextField(
              controller:  _messageController,
              decoration: InputDecoration(
                hintText: 'Write a messege',
                border:OutlineInputBorder(),
              ),
            ),
        ),
        IconButton(
          icon: Icon(Icons.send),
            onPressed: _sendMessage,
        )
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final receiverProfile = messages.isNotEmpty
        ? (messages.first.sender.id == widget.receiver
        ? messages.first.sender
        : messages.first.receiver)
        : null;
    return Scaffold(
        appBar: AppBar(
          title:  receiverProfile != null
          ? InkWell(
              onTap: () async {
                final token = await ApiService().getUserToken();
                if (token != null) {
                  try {
                    final userProfile = await UserService()
                        .fetchUserProfileById(
                        receiverProfile.id, token!
                    );
                    // int senderId =

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage( userProfile: userProfile),
                        )

                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Profile yuklab bolmadi: $e"))
                    );
                  }
                }
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: receiverProfile != null
                    ? NetworkImage(
                        ApiService().formatImageUrl(receiverProfile.profileImage))
                        : null,
                    child: receiverProfile.profileImage == null
                        ? Icon(Icons.person)
                        : null,
                  ),
                  SizedBox(width: 8),
                  Text(receiverProfile.userName),
                ],
              )

          )
              : Text("chat"),
        ),
        body: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(child: Text("No message yet"),)
                  : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context,index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  }
              ),
            ),
            _buildReplyPreveiw(),
            _buildMessageInput(),
          ],
        ),

    );

  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.sender.id == widget.sender;
    final isRead = message.is_read;
    return Slidable(
        key: ValueKey(message.id),
        endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                  onPressed: (context){
                    setState(() {
                      _replyIngTo = PartialMessage(
                          id: message.id,
                          message: message.message,
                          sender: message.sender,
                          timestamp: message.timestamp
                      );
                      // _replyIngTo = message;
                    });
    },
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.reply,
                // label: 'Reply',
        )
            ]
        ),
        child: Align(
            alignment: isMe ? Alignment.centerRight: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                  crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (message.repliedTo != null) ... [
                      Container(
                        padding: EdgeInsets.all(6),
                        margin: EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.repliedTo!.sender.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black12,
                              ),
                            ),
                            Text(
                              message.repliedTo!.message,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                            )

                          ],
                        ),
                      )
                    ],
                    if (message.type == 'text') ... [

                    Text(
                      message.message,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                    ] else if (message.type == 'image' && message.file != null ) ...[
                      Image.network(
                        ApiService().formatImageUrl(message.file!),
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                    ] else if (message.type == 'video' && message.file != null) ...[
                      Icon(Icons.videocam, color: isMe ? Colors.white: Colors.black),
                      Text(
                        "send video",
                        style: TextStyle(color: isMe ? Colors.white : Colors.black),
                      ),
                      SizedBox(height: 8),
                    ],
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                    if (isMe) ...[
                      SizedBox(width: 4),
                      Icon(
                          isRead ? Icons.done_all : Icons.check,
                          size: 14,
                          color: isRead ? Colors.greenAccent : Colors.white70
                      ),
                    ]
                  ]

              ),
            )
        )
    );

  }



  }