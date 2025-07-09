import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/models/messages.dart';
import 'package:ismatov/api/message_service.dart';
import 'package:ismatov/widgets/message_widget.dart';

class InboxMessageWidget extends StatefulWidget {
  final String token;
  const InboxMessageWidget({Key? key, required this.token }) :  super(key: key);

  @override
  State<InboxMessageWidget> createState() => _InboxMessageWidgetState();
}
class _InboxMessageWidgetState extends State<InboxMessageWidget> {
  final MessageService _messageService = MessageService();
  Future<List<Message>>? _inboxMessages;
  // late Future<List<Message>> _inboxMessages;
  final ApiService _apiService = ApiService();
  int? _currentUserId;


  @override
  void initState() {
    super.initState();
    // _inboxMessages = _messageService.fetchInboxMessage();
    _loadData();
  }

  Future<void> _loadData() async {
    var box = await Hive.openBox('authBox');
    int? userId = box.get('user_id');
    if (userId != null) {
      _currentUserId = userId;
      setState(() {
        _inboxMessages = _messageService.fetchInboxMessage();
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: _inboxMessages == null
        ? const Center(child: CircularProgressIndicator())
      : FutureBuilder<List<Message>>(
          future: _inboxMessages,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Xatolik: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty){
              return const Center(child: Text("Xabarlar movjud emas"),);
            }

            final messages =snapshot.data!;
            return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final profile = message.sender!.id == _currentUserId
                      ? message.receiver!
                      : message.sender!;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profile.profileImage != null && profile.profileImage!.isNotEmpty
                          ? NetworkImage(_apiService.formatImageUrl(profile.profileImage!))
                          : const AssetImage('assets/images/nouser.png') as ImageProvider,
                    ),
                    title: Text(
                      profile.userName,
                      style: TextStyle(
                        fontWeight: message.is_read ? FontWeight.normal: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      message.message,
                      style: TextStyle(
                        fontWeight: message.is_read ? FontWeight.normal : FontWeight.bold,
                        color: message.is_read ? Colors.black : Colors.blueAccent,
                      ),
                    ),
                    trailing: Text(
                      _formatTimestamp(message.timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () async {
                      int senderId = message.sender!.id == _currentUserId
                          ? message.receiver!.id
                          : message.sender!.id;
                      int receiverId = _currentUserId!;
                      await _messageService.markMessageAsRead(
                          senderId: senderId,
                          receiverId: receiverId,
                          token: widget.token
                      );


                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatPage(
                            sender: receiverId,
                            receiver: senderId,
                          )
                          )
                      );
                    },
                  );
                }
            );
          }
      ),

    );
  }


  String _formatTimestamp(String timestamp) {
    final time = DateTime.parse(timestamp);
    return "${time.hour}:${time.minute.toString().padLeft(2,'0')}";
  }
}