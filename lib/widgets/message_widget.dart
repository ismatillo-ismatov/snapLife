import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/message_service.dart';
import 'package:ismatov/models/messages.dart';
import 'package:provider/provider.dart';
import 'package:ismatov/widgets/chat_provider.dart';
import 'package:web_socket_channel/io.dart';

// class ChatProvider extends ChangeNotifier{
//   List<Message>  _messages = [];
//   String? _token;
//   final MessageService messageService = MessageService();
//   IOWebSocketChannel? _channel;
//
//   List<Message> get messages => _messages;
//   String? get token => _token;
//
//   Future<void> fetchMessages(int sender,int receiver) async {
//     _token = await ApiService().getUserToken();
//     if (_token != null ) {
//       _messages = await messageService.fetchMessages(sender, receiver, _token!);
//       notifyListeners();
//     }
//   }
//
//   void addMessage(Message message) {
//     _messages.add(message);
//     notifyListeners();
//   }
//
// void connectToWebSocket(int sender, int receiver) {
//   _channel = IOWebSocketChannel.connect(
//     'ws://192.168.100.8:8000/ws/messages/$sender/$receiver/'
//   );
//
//   _channel!.stream.listen((message) {
//   final decodedMessage = jsonDecode(message);
//   final newMessage = Message(
//       id: decodedMessage['id'],
//       sender: decodedMessage['sender'],
//       receiver: decodedMessage['receiver'],
//       message: decodedMessage['message'],
//       timestamp: decodedMessage['timestamp'],
//       is_read: decodedMessage['is_read']
//   );
//   addMessage(newMessage);
//   });
// }
//
// @override
//   void dispose(){
//     _channel?.sink.close();
//     super.dispose();
// }
// }
//
//
// class ChatPage extends StatefulWidget{
//   final int sender;
//   final int receiver;
//
//   const ChatPage({Key? key, required this.sender, required this.receiver}) : super(key: key);
//
//   @override
//   _ChatPageState createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   // final MessageService messageService = MessageService();
//   // List<Message> messages = [];
//   // String? token;
//   final TextEditingController _messageController = TextEditingController();
//
//
//   @override
//   void initState() {
//     super.initState();
//     final chatProvider = Provider.of<ChatProvider>(context,listen: false );
//     chatProvider.fetchMessages(widget.sender, widget.receiver);
//     chatProvider.connectToWebSocket(widget.sender, widget.receiver);
//     print('ChatPage initialized with sender:${widget.sender},receiver:${widget.receiver}');
//
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }
//
//
//   void _sendMessage() async {
//     final chatProvider = Provider.of<ChatProvider>(context, listen: false );
//     if(_messageController.text.isNotEmpty){
//       final messageText = _messageController.text;
//       _messageController.clear();
//         final newMessage = Message(
//           id: DateTime.now().millisecondsSinceEpoch,
//           sender: widget.sender,
//           receiver: widget.receiver,
//           message: messageText,
//           timestamp: DateTime.now().toIso8601String(),
//           is_read: false,
//         );
//
//         chatProvider.addMessage(newMessage);
//         await chatProvider.messageService.sendMessage(
//             widget.sender,
//             widget.receiver,
//             messageText
//         );
//       }
//     }
//
//
//   @override
//   Widget build(BuildContext context) {
//   return ChangeNotifierProvider(
//       create:(_) => ChatProvider(),
//     child: Scaffold(
//       appBar: AppBar(title: Text("Message")),
//       body: Consumer<ChatProvider>(
//         builder: (context,chatProvider,child) {
//           return Column(
//             children: [
//               Expanded(
//                   child: chatProvider.messages.isEmpty
//                       ? Center(child: Text("no message yet"),)
//                       : ListView.builder(
//                       itemCount: chatProvider.messages.length,
//                       itemBuilder: (context, index) {
//                         final message = chatProvider.messages[index];
//                         return _buildMessageBubble(message);
//                       }
//                   )
//               ),
//               _buildMessageInput(),
//             ],
//           );
//         }
//       )
//
//     ),
//   );
//   }
// Widget _buildMessageInput() {
//   return Padding(
//     padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
//     child: Row(
//     children: [
//       Expanded(
//         child: TextField(
//           controller:  _messageController,
//           decoration: InputDecoration(
//             hintText: 'Write a messege',
//             border:OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 10)
//           ),
//         ),
//       ),
//       IconButton(
//         icon: Icon(Icons.send,color: Colors.blue),
//         onPressed: _sendMessage,
//       )
//     ],
//     )
//   );
// }
//
//   Widget _buildMessageBubble(Message message) {
//     final isMe = message.sender == widget.sender;
//     return Align(
//       alignment: isMe ? Alignment.centerRight: Alignment.centerLeft,
//       child: Container(
//           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: isMe ? Colors.blue: Colors.grey[300],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             message.message,
//             style: TextStyle(color: isMe ? Colors.white : Colors.black),
//           )
//       ),
//     );
//   }
//
// }

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
  final TextEditingController _messageController = TextEditingController();

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    print('ChatPage initialized with sender:${widget.sender},receiver:${widget
        .receiver}');

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
    _fetchMessages();
    // _timer = Timer.periodic(Duration(seconds: 5), (timer) {
    //   _fetchMessages();
    // });
  }
  @override
  void dispose() {
    _timer?.cancel();
    messageService.disconnect();
    _messageController.dispose();
    super.dispose();
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
          // messages.clear();
          messages = fetchedMessages;
          // messages.addAll(fetchedMessages);
          // messages = [...messages,...fetchedMessages];
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
    _fetchMessages();
}




  void _sendMessage() async {
    if(_messageController.text.isNotEmpty) {
      final messageText = _messageController.text;
      _messageController.clear();

   // bool success = await messageService.sendMessage(
   //      widget.sender,
   //      widget.receiver,
   //      messageText
   //  );
   // if(success){
   //   await _fetchMessages();
   //   print('xabar yuborildi');
   // }else {
   //   print('Xotolik yuz berdi');
   // }
    final newMessage = Message(
      id: -1,
      sender: widget.sender,
      receiver: widget.receiver,
      message: messageText,
      timestamp: DateTime.now().toIso8601String(),
      is_read: false,
    );
    if(mounted) {
      setState(() {
        messages.add(newMessage);
      });
    }
    try {
      bool success = await messageService.sendMessage(
           widget.sender,
           widget.receiver,
           messageText
       );
      if(success){
        await _fetchMessages();
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

  Widget _buildMessageInput() {
    return Row(
      children: [
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
    final filteredMessages = messages.where((message) =>
    (message.sender == widget.sender && message.receiver == widget.receiver) ||
    (message.sender == widget.receiver && message.receiver == widget.sender)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
      ),
      body: Column(
        children: [
          Expanded(
              child: messages.isEmpty
                  ? Center(child: Text("No message yet"),)
                  : ListView.builder(
                itemCount: filteredMessages.length,
                // itemCount: messages.length,
                  itemBuilder: (context,index) {
                  final message = filteredMessages[index];
                  // final message = messages[index];
                  return _buildMessageBubble(message);
                  }
              ),
          ),
          _buildMessageInput(),
        ],
      )
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.sender == widget.sender;
    return Align(
      alignment: isMe ? Alignment.centerRight: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.message,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        )
      ),
    );
  }

}