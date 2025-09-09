import 'protocol/message_types.dart';

/// Represents a message in the BitChat network
class BitChatMessage {
  /// Unique message identifier
  final String id;
  
  /// Message content
  final String content;
  
  /// Sender's identity
  final String senderId;
  
  /// Recipient's identity (for private messages)
  final String? recipientId;
  
  /// Room identifier
  final String roomId;
  
  /// Message timestamp
  final DateTime timestamp;
  
  /// Message type
  final MessageType type;
  
  /// Time-to-live (max hops)
  final int ttl;
  
  /// Message signature for verification
  final String? signature;
  
  /// Whether message is encrypted
  final bool isEncrypted;
  
  /// Message metadata
  final Map<String, dynamic> metadata;
  
  BitChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    this.recipientId,
    required this.roomId,
    required this.timestamp,
    required this.type,
    this.ttl = 7,
    this.signature,
    this.isEncrypted = false,
    this.metadata = const {},
  });
  
  /// Create a copy of this message with updated fields
  BitChatMessage copyWith({
    String? id,
    String? content,
    String? senderId,
    String? recipientId,
    String? roomId,
    DateTime? timestamp,
    MessageType? type,
    int? ttl,
    String? signature,
    bool? isEncrypted,
    Map<String, dynamic>? metadata,
  }) {
    return BitChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      roomId: roomId ?? this.roomId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      ttl: ttl ?? this.ttl,
      signature: signature ?? this.signature,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Convert message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'recipientId': recipientId,
      'roomId': roomId,
      'timestamp': timestamp.toIso8601String(),
      'type': type.value,
      'ttl': ttl,
      'signature': signature,
      'isEncrypted': isEncrypted,
      'metadata': metadata,
    };
  }
  
  /// Create message from JSON
  factory BitChatMessage.fromJson(Map<String, dynamic> json) {
    return BitChatMessage(
      id: json['id'],
      content: json['content'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      roomId: json['roomId'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.fromValue(json['type']),
      ttl: json['ttl'] ?? 7,
      signature: json['signature'],
      isEncrypted: json['isEncrypted'] ?? false,
      metadata: json['metadata'] ?? {},
    );
  }
  
  @override
  String toString() {
    return 'BitChatMessage(id: $id, content: $content, sender: $senderId, room: $roomId, type: $type)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BitChatMessage && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
