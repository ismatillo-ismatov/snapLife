import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:ismatov/models/messages.dart';
import 'package:ismatov/models/shortUserprofile.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageService {
  WebSocketChannel? _channel;
  final ApiService _apiService = ApiService();
  void connectToWebSocket(
      int sender, int receiver, Function(Message) onMessageReceived) async {
    String? token = await _apiService.getUserToken();
    if (token == null) {
      print("Token yo'q, login qiling");
      return;
    }
    final url = Uri.parse("ws://176.118.198.70/ws/messages/$sender/$receiver/?token=$token");
    // final url = Uri.parse("ws://192.168.100.8:8000/ws/messages/$sender/$receiver/?token=$token");
    debugPrint("WebSocket ulanmoqda: $url");
    _channel = WebSocketChannel.connect(url);
    _channel!.stream.listen(
  (raw) {
    debugPrint("WS raw: $raw");
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('error')) {
          debugPrint("Serverdan xato: ${decoded['error']}");
          return;
        }
        if (decoded.containsKey('message') && (decoded['message'] == 'ok' || decoded['message'] == 'ko')) {
          debugPrint("Status xabari e'tiborsiz qoldirildi: $decoded");
          return;
        }

        Map<String, dynamic> payload = {};
        if (decoded.containsKey('message') && decoded['message'] is Map<String, dynamic>) {
          payload = Map<String, dynamic>.from(decoded['message']);
        } else if (decoded.containsKey('data') && decoded['data'] is Map<String, dynamic>) {
          payload = Map<String, dynamic>.from(decoded['data']);
        } else if (decoded.containsKey('from_redis') && decoded['from_redis'] is Map<String, dynamic>) {
          payload = Map<String, dynamic>.from(decoded['from_redis']);
        } else {
          payload = decoded.cast<String, dynamic>();
        }

        if (payload['id'] == null || payload['sender_id'] == null || payload['receiver_id'] == null) {
          debugPrint("Xato: JSON ma'lumotlarida 'id', 'sender_id' yoki 'receiver_id' maydoni yo‘q: $payload");
          return;
        }

        final m = Message(
          id: payload['id'] as int,
          sender: ShortUserProfile(
            id: payload['sender_id'] as int,
            userName: payload['sender_name'] ?? 'User',
            profileImage: payload['sender_image'],
          ),
          receiver: ShortUserProfile(
            id: payload['receiver_id'] as int,
            userName: payload['receiver_name'] ?? 'User',
            profileImage: payload['receiver_image'],
          ),
          message: payload['message'] ?? '',
          type: payload['type'] ?? 'text',
          file: payload['file'],
          is_read: (payload['is_read'] ?? false) as bool,
          timestamp: payload['timestamp'] as String,
          repliedTo: payload['replied_to'] != null
              ? PartialMessage(
                  id: payload['replied_to'] as int,
                  message: payload['replied_to_text'] ?? '',
                  sender: ShortUserProfile(
                    id: payload['replied_to_sender_id'] ?? 0,
                    userName: payload['replied_to_sender_name'] ?? '',
                    profileImage: payload['replied_to_sender_image'],
                  ),
                  timestamp: payload['replied_to_ts'] ?? DateTime.now().toIso8601String(),
                )
              : null,
        );
        debugPrint("Yangi xabar qabul qilindi: ${m.message}, ID: ${m.id}");
        onMessageReceived(m);
      } else {
        debugPrint("Noto‘g‘ri JSON formati: $decoded");
      }
    } catch (e) {
      debugPrint("WebSocket xabarini parse qilishda xato: $e");
    }
  },
  onError: (error) {
    debugPrint("WebSocket xatosi: $error");
    Future.delayed(Duration(seconds: 2), () { // 5 dan 2 ga qisqartirildi
      debugPrint("WebSocket qayta ulanmoqda...");
      connectToWebSocket(sender, receiver, onMessageReceived);
    });
  },
  onDone: () {
    debugPrint("WebSocket ulanishi yopildi");
    Future.delayed(Duration(seconds: 2), () { // 5 dan 2 ga qisqartirildi
      debugPrint("WebSocket qayta ulanmoqda...");
      connectToWebSocket(sender, receiver, onMessageReceived);
    });
  },
);
  }
  // void connectToWebSocket(
  //     int sender, int receiver, Function(Message) onMessageReceived) async {
  //   String? token = await _apiService.getUserToken();
  //   if (token == null) {
  //     print("Token yoq login qiling");
  //     return;
  //   }
  //   final url = Uri.parse("ws://192.168.100.8:8000/ws/messages/$sender/$receiver/?token=$token");
  //   // final url = Uri.parse("ws://192.168.100.8:8000/ws/messages/room123/?token=$token");
  //   // final url = Uri.parse("ws://192.168.100.8:8000/ws/messages/?token=$token");
  //   _channel = WebSocketChannel.connect(url);
  //   _channel!.stream.listen((raw) {
  //     print("WS raw: $raw");
  //     final decoded = json.decode(raw);
  //     if (decoded is Map<String, dynamic>) {
  //       // Status xabarlarni o‘tkazib yuboramiz
  //       if (decoded.containsKey('message') && (decoded['message'] == 'ok' || decoded['message'] == 'ko')) {
  //         print("Status xabari e'tiborsiz qoldirildi: $decoded");
  //         return;
  //       }
  //
  //       Map<String, dynamic>? p;
  //       if (decoded['data'] is Map<String, dynamic>) {
  //         p = Map<String, dynamic>.from(decoded['data']);
  //       } else if (decoded['from_redis'] is Map<String, dynamic>) {
  //         p = Map<String, dynamic>.from(decoded['from_redis']);
  //       } else {
  //         p = decoded.cast<String, dynamic>();
  //       }
  //
  //       // ID va boshqa majburiy maydonlarni tekshirish
  //       if (p == null || p['id'] == null || p['sender_id'] == null || p['receiver_id'] == null) {
  //         print("Xato: JSON ma'lumotlarida 'id', 'sender_id' yoki 'receiver_id' maydoni yo‘q: $p");
  //         return;
  //       }
  //
  //       try {
  //         final m = Message.fromJson(p);
  //         onMessageReceived(m);
  //       } catch (e) {
  //         print("fromJson xatosi: $e");
  //         try {
  //           final m = Message(
  //             id: p['id'] as int,
  //             sender: ShortUserProfile(
  //               id: p['sender_id'] as int,
  //               userName: p['sender_name'] ?? 'User',
  //               profileImage: null,
  //             ),
  //             receiver: ShortUserProfile(
  //               id: p['receiver_id'] as int,
  //               userName: p['receiver_name'] ?? 'User',
  //               profileImage: null,
  //             ),
  //             message: p['message'] ?? '',
  //             type: p['type'] ?? 'text',
  //             file: p['file'],
  //             is_read: (p['is_read'] ?? false) as bool,
  //             timestamp: p['timestamp'] as String,
  //             repliedTo: p['replied_to'] != null
  //                 ? PartialMessage(
  //               id: p['replied_to'] as int,
  //               message: p['replied_to_text'] ?? '',
  //               sender: ShortUserProfile(
  //                 id: p['replied_to_sender_id'] ?? 0,
  //                 userName: p['replied_to_sender_name'] ?? '',
  //                 profileImage: null,
  //               ),
  //               timestamp: p['replied_to_ts'] ?? DateTime.now().toIso8601String(),
  //             )
  //                 : null,
  //           );
  //           onMessageReceived(m);
  //         } catch (e) {
  //           print("Qo‘lda parse qilishda xato: $e");
  //         }
  //       }
  //     } else {
  //       print("Noto‘g‘ri JSON formati: $decoded");
  //     }
  //   });

  // pastdagi kerak emas
  // _channel!.stream.listen((raw) {
  //   print("WS raw: $raw");
  //   final decoded = json.decode(raw);
  //
  //   Map<String, dynamic>? p;
  //   if (decoded is Map<String, dynamic>) {
  //     if (decoded['data'] is Map<String, dynamic>) {
  //       p = Map<String, dynamic>.from(decoded['data']);
  //     } else if (decoded['from_redis'] is Map<String, dynamic>) {
  //       p = Map<String, dynamic>.from(decoded['from_redis']);
  //     } else {
  //       p = decoded.cast<String, dynamic>();
  //     }
  //   }
  //   if (p == null) return;
  //   try {
  //     final m = Message.fromJson(p);
  //     onMessageReceived(m);
  //     return;
  //   } catch (e) {
  //     print("fromJson mos emas, qolda quramiz $e");
  //   }
  //   try {
  //     final m = Message(
  //       id: p['id'] as int,
  //       sender: ShortUserProfile(
  //           id: (p['sender_id'] ?? p['sender']) as int,
  //           userName: p['sender_name'] ?? 'User',
  //           profileImage: null),
  //       receiver: ShortUserProfile(
  //         id: (p['receiver_id'] ?? p['receiver']) as int,
  //         userName: p['receiver_name'] ?? 'User',
  //         profileImage: null,
  //       ),
  //       message: p['message'] ?? '',
  //       type: p['type'] ?? 'text',
  //       file: p['file'],
  //       is_read: (p['is_read'] ?? false) as bool,
  //       timestamp: p['timestamp'] as String,
  //       repliedTo: p['replied_to'] != null
  //           ? PartialMessage(
  //               id: p['replied_to'] as int,
  //               message: p['replied_to_text'] ?? '',
  //               sender: ShortUserProfile(
  //                 id: p['replied_to_sender_id'] ?? 0,
  //                 userName: p['replied_to_sender_name'] ?? '',
  //                 profileImage: null,
  //               ),
  //               timestamp:
  //                   p['replied_to_ts'] ?? DateTime.now().toIso8601String(),
  //             )
  //           : null,
  //     );
  //     onMessageReceived(m);
  //   } catch (e) {
  //     print("qolda qurishda xato: $e payload=$e");
  //   }
  // });
  // }
  void disconnect() {
    _channel?.sink.close();
    print("WebSocket uzildi");
  }

  Future<bool> sendMessage(
    int sender,
    int receiver,
    String messageText, {
    String type = 'text',
    String? file,
    int? repliedToId,
  }) async {
    if (_channel != null) {
      final message = {
        "message": messageText,
        'sender': sender,
        "receiver": receiver,
        "type": type,
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

  Future<List<Message>> fetchMessages(
      int sender, int receiver, String token) async {
    final url = Uri.parse(
        "${ApiService.baseUrl}/messages/get_messages/?sender=$sender&receiver=$receiver");

    final response = await http.get(
      url,
      headers: {
        'Authorization': "Token $token",
        // 'Content-type': 'application/json'
      },
    );
    print("response status: ${response.statusCode}");
    print('response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception("Xabarlarni olishda xatolik: ${response.body}");
    }
  }

  Future<List<Message>> fetchInbox(String token) async {
    final url = Uri.parse("${ApiService.baseUrl}/messages/inbox/");

    final response = await http.get(url, headers: {
      'Authorization': 'Token $token',
      'Content-type': 'application/json',
    });
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
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-type': 'application/json'
      },
      body: jsonEncode({
        'sender': senderId,
        'receiver': receiverId,
      }),
    );
    if (response.statusCode != 200) {
      print("Xatolik ${response.body}");
      throw Exception("Xabarni oqilgand deb belgilab bolmadi.");
    }
  }

  Future<void> markAllAsRead({
    required int senderId,
    required int receiverId,
    required String token,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/messages/mark_all_as_read/');
    final response = await http.post(url,
        headers: {
          'Authorization': 'Token $token',
          'Content-type': 'application/json',
        },
        body: jsonEncode({
          'sender': senderId,
          'receiver': receiverId,
        }));
    if (response.statusCode == 200) {
      print("Barcha xabarlar oqildi");
    } else {
      print("Xatolik: ${response.body}");
    }
  }
}
