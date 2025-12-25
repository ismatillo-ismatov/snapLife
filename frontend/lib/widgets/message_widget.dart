import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/message_service.dart';
import 'package:ismatov/models/messages.dart';
import 'package:ismatov/models/shortUserprofile.dart';

class ChatPage extends StatefulWidget {
  final int sender; // Profile ID (jo'natuvchi)
  final int receiver; // Profile ID (qabul qiluvchi)

  const ChatPage({Key? key, required this.sender, required this.receiver})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  List<Message> messages = [];
  String? _token;
  PartialMessage? _replyIngTo;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }


  @override
  void dispose() {
    _timer?.cancel();
    _messageService.disconnect();
    _messageController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
  void handlePushNotification(Map<String, dynamic> data) {
  if (data['notification_type'] == 'message' && data['receiver_id'] == widget.receiver.toString()) {
    _messageService.connectToWebSocket(widget.sender, widget.receiver, (newMessage) {
      if (!mounted) return;
      setState(() {
        messages = [...messages, newMessage];
      });
      _scrollToBottom();
    });
  }
}

  Future<void> _initializeChat() async {
  debugPrint('ChatPage init: sender=${widget.sender}, receiver=${widget.receiver}');
  _token = await ApiService().getUserToken();
  if (_token == null) {
    debugPrint("Token yo'q: login qiling");
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Token topilmadi. Iltimos, qayta login qiling")),
    );
    return;
  }

  // WebSocket ulanadi
  _messageService.connectToWebSocket(
    widget.sender,
    widget.receiver,
    (newMessage) {
      if (!mounted) return;
      debugPrint("onMessageReceived: ${newMessage.message}, ID: ${newMessage.id}");
      setState(() {
  debugPrint("setState chaqirildi, messages oldin: ${messages.map((m) => m.id).toList()}");
  final idx = messages.indexWhere((m) => m.id == 0 && m.message == newMessage.message && m.sender.id == newMessage.sender.id);
  if (idx >= 0) {
    debugPrint("Optimistik xabar almashtirildi: index=$idx");
    messages[idx] = newMessage;
  } else {
    debugPrint("Yangi xabar qo'shildi: ${newMessage.message}");
    messages = [...messages, newMessage];
  }
  debugPrint("setState chaqirildi, messages keyin: ${messages.map((m) => m.id).toList()}");
});
      _scrollToBottom();
    },
  );

  if (_token != null) {
    unawaited(_messageService.markAllAsRead(
      senderId: widget.receiver,
      receiverId: widget.sender,
      token: _token!,
    ));
  }

  await _fetchMessages();
}

  Future<void> _fetchMessages() async {
    try {
      _token ??= await ApiService().getUserToken();
      if (_token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token topilmadi. Iltimos, qayta login qiling")),
        );
        return;
      }
      final fetched = await _messageService.fetchMessages(
        widget.sender,
        widget.receiver,
        _token!,
      );
      if (!mounted) return;
      setState(() {
        debugPrint("fetchMessages: ${fetched.length} ta xabar yuklandi");
        messages = [...fetched]; // Yangi instans
      });
      _jumpToBottom();
    } catch (e) {
      debugPrint("Fetch messages error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xabarlarni olishda xato: $e")),
      );
    }
  }

  void _appendAndScroll(Message m) {
    setState(() {
      debugPrint("appendAndScroll: ${m.message}");
      messages = [...messages, m]; // Yangi instans
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) {
      debugPrint("scrollCtrl hasClients=false");
      return;
    }
    debugPrint("scrollToBottom chaqirildi, maxScrollExtent: ${_scrollCtrl.position.maxScrollExtent}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 50, // Qo‘shimcha bufer
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _jumpToBottom() {
    if (!_scrollCtrl.hasClients) {
      debugPrint("jumpToBottom hasClients=false");
      return;
    }
    debugPrint("jumpToBottom chaqirildi, maxScrollExtent: ${_scrollCtrl.position.maxScrollExtent}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent + 50); // Qo‘shimcha bufer
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final replyTo = _replyIngTo;
    _messageController.clear();
    setState(() => _replyIngTo = null);

    // Optimistik xabar
    final optimistic = Message(
      id: 0,
      sender: ShortUserProfile(id: widget.sender, userName: 'You', profileImage: null),
      receiver: ShortUserProfile(id: widget.receiver, userName: '', profileImage: null),
      message: text,
      is_read: false,
      timestamp: DateTime.now().toIso8601String(),
      type: 'text',
      file: null,
      repliedTo: replyTo,
    );
    _appendAndScroll(optimistic);

    try {
      final ok = await _messageService.sendMessage(
        widget.sender,
        widget.receiver,
        text,
        type: 'text',
        repliedToId: replyTo?.id,
      );
      if (!ok) {
        debugPrint('WS yuborish muvaffaqiyatsiz');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xabar yuborishda xato")),
        );
        setState(() {
          debugPrint("Optimistik xabar o'chirildi: $text");
          messages = messages.where((m) => m.id != 0 || m.message != text).toList(); // Yangi instans
        });
      }
    } catch (e) {
      debugPrint("Xabar yuborishda xato: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xabar yuborilmadi: $e")),
      );
      setState(() {
        debugPrint("Optimistik xabar o'chirildi: $text");
        messages = messages.where((m) => m.id != 0 || m.message != text).toList(); // Yangi instans
      });
    }
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
    if (filePath.isEmpty) return;

    final file = File(filePath);
    if (!file.existsSync()) return;

    try {
      final token = await ApiService().getUserToken();
      if (token == null) throw Exception("token topilmadi");

      final uri = Uri.parse("${ApiService.baseUrl}/messages/");
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Token $token'
        ..fields['receiver'] = widget.receiver.toString()
        ..fields['type'] = type
        ..fields['message'] = ''
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final responseStream = await request.send();
      final response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newMessage = Message.fromJson(responseData);
        _appendAndScroll(newMessage);
      } else {
        debugPrint('media send error: ${response.statusCode}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Media yuborilmadi: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("Media yuborishda xato: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Media yuborilmadi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              key: ValueKey(messages.length),
              controller: _scrollCtrl,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                debugPrint("Rendering message at index: $index, ID: ${messages[index].id}");
                final message = messages[index];
                final isMe = message.sender.id == widget.sender;
                final isRead = message.is_read;
                return KeyedSubtree(
                  key: ValueKey("${message.id}_${message.timestamp}"),
                  // key: ValueKey(message.id),
                  child: _buildMessageTile(message, isMe, isRead),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Message message, bool isMe, bool isRead) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) {
              setState(() {
                _replyIngTo = PartialMessage(
                  id: message.id,
                  message: message.message,
                  sender: message.sender,
                  timestamp: message.timestamp,
                );
              });
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.reply,
          ),
        ],
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.repliedTo != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.repliedTo!.sender.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        message.repliedTo!.message,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              if (message.type == 'text') ...[
                Text(
                  message.message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              ] else if (message.type == 'image' && message.file != null) ...[
                Image.network(
                  ApiService().formatImageUrl(message.file!),
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
              ] else if (message.type == 'video' && message.file != null) ...[
                Icon(
                  Icons.videocam,
                  color: isMe ? Colors.white : Colors.black,
                ),
                Text(
                  "send video",
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      isRead ? Icons.done_all : Icons.check,
                      size: 14,
                      color: isRead ? Colors.greenAccent : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.grey[200],
      child: Column(
        children: [
          if (_replyIngTo != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyIngTo!.sender.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _replyIngTo!.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => _replyIngTo = null);
                    },
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _pickImage,
              ),
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: _pickVideo,
              ),
              IconButton(
                icon: const Icon(Icons.mic),
                onPressed: _recordAudio,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: "Xabar yozing...",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
