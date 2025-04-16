import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:ismatov/models/messages.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
class MessageService {
  WebSocketChannel? _channel;
  final ApiService _apiService = ApiService();

  void connectToWebSocket(int sender, int receiver, Function(Message) onMessageReceived) {
    _channel  = WebSocketChannel.connect(
      Uri.parse('ws://192.168.100.8:8000/ws/messages/$sender/$receiver/')
    );
    _channel!.stream.listen((data){
      print("WebSocket orqali keldan data: $data");
      final Map<String,dynamic> messageData = json.decode(data);
      final message = Message.fromJson(messageData);
      print("WebSocket orqali yangi xabar keldi");
      onMessageReceived(message);
    });

  }

  Future<void>checkConnection() async {
    try{
      final result = await InternetAddress.lookup('google.com');
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
        print('internet bor');
      }
    } catch(e){
      print("Internet mavjud emas $e");
    }
  }

  Future<bool> sendMessage(int sender, int receiver, String message) async {
  try {
    final token = await ApiService().getUserToken();
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/messages/"),
      headers: {
        'Authorization': "Token $token",
        'Content-type': 'application/json'
      },
      body: jsonEncode({
        'sender': sender,
        'receiver': receiver,
        'message': message,
      }),
    );
    return response.statusCode == 201;
  } catch (e) {
    print("Error sending message: $e");
    return false;
  }

  }

  void disconnect(){
    _channel?.sink.close();
  }
  Stream get messages => _channel!.stream;


  Future<List<Message>> fetchMessages(int senderId,int receiverId,String token) async {
    final response = await http.get(
      // Uri.parse("${ApiService.baseUrl}/messages/"),
      Uri.parse("${ApiService.baseUrl}/messages/?sender=$senderId&receiver=$receiverId"),
      headers: {
        'Authorization': "Token $token",
        'Content-type': 'application/json'
      },
    );
    print("response status: ${response.statusCode}");
    print('response body: ${response.body}');
    if(response.statusCode == 200) {

      final Map<String,dynamic>jsonData =  json.decode(response.body);
      final List<dynamic> results = jsonData['results'];
      return results.map((data) => Message.fromJson(data)).toList();
    } else{
      throw Exception("Failed to load messages");
    }
  }


  static Future<bool>sendMessageToAPI(int senderId,int receiverId,String messageText,String token) async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/messages/"),
          headers: {
        'Authorization':"Token $token",
        'Content-type': 'application/json'
    },
      body: json.encode({
        'sender': senderId,
        'receiver': receiverId,
        'message': messageText,
        'is_read':false,
      })
    );
    print("Request body: ${json.encode({
      'sender':senderId,
      'receiver': receiverId,
      'message': messageText,
      'is_read':false,
    })}");
    print('response body: ${response.body}');

    if(response.statusCode == 201){
      print("Message send successfully");
      return true;
    } else{
      print('Failed to send message: ${response.body}');
      return false;
    }

    }

    Future<List<dynamic>>getMessages(int senderId, int receiverId) async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/messages/get_messages/sender=$senderId&receiver=$receiverId"),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load message');
    }
    }
}
