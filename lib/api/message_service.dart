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


  void connectToWebSocket(int sender, int receiver, Function(Message) onMessageReceived) async {
    String? token = await _apiService.getUserToken();
    if (token == null) {
      print("Token yoq login qiling");
      return;
    }
    final url = Uri.parse("ws://192.168.100.8:8000/ws/messages/?token=$token");
    _channel =WebSocketChannel.connect(url);

    _channel!.stream.listen((data) {
      print("WebSocket orqali keldi: $data");
      final decoded = json.decode(data);
      print("Parsing message JSON: $decoded");
      if (decoded is Map<String,dynamic>  && decoded.containsKey("id")) {
        try {
          final newMessage = Message.fromJson(decoded);
          onMessageReceived(newMessage);


        } catch (e) {
          print('Xabarni perse qilishda xatolik: $e');

        }
      } else {
        print('Oddiy status yoki notorgi fatmatda keldi: $decoded');
      }

    }, onError: (error) {
      print("WebSocket xatosi: $error");
    }, onDone: () {
      print("WebSocket yopildi");

    }
    );
  }
  void disconnect() {
    _channel?.sink.close();
    print("WebSocket uzildi");
  }


  Future<bool> sendMessage(
      int sender,
      int receiver,
      String messageText,{
        String type = 'text',
        String? file,
        int? repliedToId,
      }) async {

    if (_channel != null ) {
      final message = {
        "message": messageText,
        "receiver":receiver,
        "type":type,
        if (file != null) "file": file,
        if (repliedToId != null) "replied_to": repliedToId,
      };
      _channel!.sink.add(json.encode(message));
      print("WebSocket orqali yuborildi $message");
      return true;
    } else {
      print("WebSocket ulanmagan");
      return false;
    }


  }

  // Future<bool> sendMessage(int sender, int receiver, String messageText,{String type = 'text',String? file,int? replyToId}) async {
  //   if (_channel != null ) {
  //     final message = {
  //       "message": messageText,
  //       "receiver":receiver,
  //       "type":type,
  //       if (file != null) "file": file
  //     };
  //     _channel!.sink.add(json.encode(message));
  //     print("WebSocket orqali yuborildi $message");
  //     return true;
  //   } else {
  //     print("WebSocket ulanmagan");
  //     return false;
  //   }
  //
  //
  // }



  Future<List<Message>> fetchMessages(int sender,int receiver,String token) async {
    final url = Uri.parse("${ApiService.baseUrl}/messages/get_messages/?sender=$sender&receiver=$receiver");

    final response = await http.get(url,
      headers: {
        'Authorization': "Token $token",
        // 'Content-type': 'application/json'
      },
    );
    print("response status: ${response.statusCode}");
    print('response body: ${response.body}');
    if (response.statusCode == 200 ) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception("Xabarlarni olishda xatolik: ${response.body}");
    }
  }

  Future<List<Message>> fetchInbox(String token) async {
    final url = Uri.parse("${ApiService.baseUrl}/messages/inbox/");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-type': 'application/json',
      }
    );
    print("Inbox status: ${response.statusCode}");
    print("Inbox body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception("Inbox olishda xatolik");
    }


  }
  Future<List<Message>> fetchInboxMessage() async {
    String? token = await _apiService.getUserToken();
    if (token == null) {
      throw Exception("Token yoq. login qilinmagan");
    }
    return await fetchInbox(token);
  }

  Future<void> markMessageAsRead({
    required int senderId,
    required int receiverId,
    required String token,
}) async {
    final url = Uri.parse('${ApiService.baseUrl}/messages/mark_as_read/');
    final response = await http.post(url,
        headers: {
          'Authorization': 'Token $token',
          'Content-type': 'application/json'
        },
        body: jsonEncode({
          'sender':senderId,
          'receiver':receiverId,
        }),
    );
    if (response.statusCode != 200 ) {
      print("Xatolik ${response.body}");
      throw Exception("Xabarni oqilgand deb belgilab bolmadi.");
    }
  }


  // Future<void> markMessageAsRead(int messageId,String token) async {
  //   final url = Uri.parse('${ApiService.baseUrl}/messages/$messageId/read');
  //   final response = await http.put(url,
  //       headers: {
  //         'Authorization': 'Token $token',
  //         'Content-type': 'application/json'
  //       }
  //   );
  //   if (response.statusCode == 200 ) {
  //     print("Xabar oqilgan deb belgilandi");
  //   } else {
  //     print("Xatolik: ${response.body}");
  //   }
  // }
  //
  Future<void> markAllAsRead({
    required int senderId,
    required int receiverId,
    required String token,
}) async {
    final url = Uri.parse('${ApiService.baseUrl}/messages/mark_all_as_read');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'sender':senderId,
        'receiver':receiverId,
      })
    );
    if (response.statusCode == 200) {
      print("Barcha xabarlar oqildi");
    } else {
      print("Xatolik: ${response.body}");
    }
  }
}