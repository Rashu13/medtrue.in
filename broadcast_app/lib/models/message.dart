class Message {
  final String id;
  final String senderId;
  final String? receiverId;
  final String content;
  final bool isBroadcast;
  final DateTime createdAt;
  final String? tenantId;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    this.receiverId,
    required this.content,
    required this.isBroadcast,
    required this.createdAt,
    this.tenantId,
    this.isRead = false,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id']?.toString() ?? '',
      senderId: map['sender_id']?.toString() ?? '',
      receiverId: map['receiver_id']?.toString(),
      content: map['content']?.toString() ?? '',
      isBroadcast: map['is_broadcast'] ?? false,
      createdAt: map['created_at'] != null 
          ? (DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      tenantId: map['tenant_id']?.toString(),
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_broadcast': isBroadcast,
      'is_read': isRead,
      if (tenantId != null) 'tenant_id': tenantId,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    bool? isBroadcast,
    DateTime? createdAt,
    String? tenantId,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isBroadcast: isBroadcast ?? this.isBroadcast,
      createdAt: createdAt ?? this.createdAt,
      tenantId: tenantId ?? this.tenantId,
      isRead: isRead ?? this.isRead,
    );
  }
}
