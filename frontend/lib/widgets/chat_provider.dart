// import 'package:flutter/material.dart';
// import 'package:ismatov/models/message_model.dart';
// import 'message_widget.dart';
//
// class ChatProvider extends ChangeNotifier{
//   List<Message>  _message = [];
//   List<Message> get messages => _message;
//
//   void sendMessage(String text) {
//     final newMessage = Message(
//         id: DateTime.now().toString(),
//         text: text,
//         isMe: true
//     );
//     _message.add(newMessage);
//     notifyListeners();
//
//   }
//
// }