class Message {
  final String id;
  final String senderId;
  final String? receiverId;
  final String content;
  final bool isBroadcast;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    this.receiverId,
    required this.content,
    required this.isBroadcast,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['sender_id'] ?? '',
      receiverId: map['receiver_id'],
      content: map['content'] ?? '',
      isBroadcast: map['is_broadcast'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_broadcast': isBroadcast,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    bool? isBroadcast,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isBroadcast: isBroadcast ?? this.isBroadcast,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
