import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final Map<String, bool> readBy; // New field

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.readBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toUtc(),
      'readBy': readBy,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'],
      text: map['text'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      readBy: Map<String, bool>.from(map['readBy'] ?? {}),
    );
  }
}
