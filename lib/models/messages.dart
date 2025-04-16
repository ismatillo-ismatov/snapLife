

  class Message {
    final int id;
    final int sender;
    final int receiver;
    final String message;
    final String timestamp;
    bool is_read;

    Message({
      required this.id,
      required this.sender,
      required this.receiver,
      required this.message,
      required this.timestamp,
      required this.is_read,
  });

    factory Message.fromJson(Map<String, dynamic> json) {
      print("Parsing message JSON: $json");
      return Message(
          id: json['id'] ?? 0,
          sender: json['sender'] ?? 0,
          receiver: json['receiver'] ?? -1,
          message: json['message'] ?? '',
          timestamp: json['timestamp'] ?? '',
          is_read: json['is_read'] ?? false,
      );
    }
  }