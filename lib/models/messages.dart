
import "package:flutter/material.dart";

import "shortUserprofile.dart";

class Message {

  final int id;
  final ShortUserProfile sender;
  final ShortUserProfile receiver;
  final String message;
  final String? file;
  final String type;
  final String timestamp;
  final bool is_read;
  final PartialMessage? repliedTo;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    this.file,
    required this.type,
    required this.timestamp,
    required this.is_read,
    this.repliedTo,
  });
factory Message.fromJson(Map<String, dynamic> json) {
  print("Parsing message JSON: $json");
  return Message(
    id: json['id'] ?? 0,
    sender: ShortUserProfile.fromJson(json['sender']),
    receiver: ShortUserProfile.fromJson(json['receiver']),
    message: json['message'] ?? '',
    file: json['file'],
    type: json['type'],
    timestamp: json['timestamp'] ?? '',
    is_read: json['is_read'] ?? false,
    repliedTo: json['replied_to'] != null
        ? PartialMessage.fromJson(json['replied_to'])
        : null,
  );
}
}


class PartialMessage {
  final int id;
  final String message;
  final ShortUserProfile sender;
  final String timestamp;

  PartialMessage({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
});
  factory PartialMessage.fromJson(Map<String,dynamic> json) {
    return PartialMessage(
        id: json['id'],
        message: json['message'],
        sender: ShortUserProfile.fromJson(json['sender']),
        timestamp: json['timestamp']
    );
  }
}



