/// Represents a chat room in BitChat
class ChatRoom {
  /// Unique room identifier
  final String id;
  
  /// Room name
  final String name;
  
  /// Room description
  final String? description;
  
  /// Whether the room is public or private
  final bool isPublic;
  
  /// Maximum number of participants
  final int maxParticipants;
  
  /// Current number of participants
  final int participantCount;
  
  /// Room creation timestamp
  final DateTime createdAt;
  
  /// Last activity timestamp
  final DateTime lastActivity;
  
  /// Room owner ID
  final String? ownerId;
  
  /// Room metadata
  final Map<String, dynamic> metadata;
  
  ChatRoom({
    required this.id,
    required this.name,
    this.description,
    this.isPublic = true,
    this.maxParticipants = 100,
    this.participantCount = 0,
    required this.createdAt,
    required this.lastActivity,
    this.ownerId,
    this.metadata = const {},
  });
  
  /// Create a copy of this room with updated fields
  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    bool? isPublic,
    int? maxParticipants,
    int? participantCount,
    DateTime? createdAt,
    DateTime? lastActivity,
    String? ownerId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantCount: participantCount ?? this.participantCount,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      ownerId: ownerId ?? this.ownerId,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Convert room to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'maxParticipants': maxParticipants,
      'participantCount': participantCount,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'ownerId': ownerId,
      'metadata': metadata,
    };
  }
  
  /// Create room from JSON
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isPublic: json['isPublic'] ?? true,
      maxParticipants: json['maxParticipants'] ?? 100,
      participantCount: json['participantCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      lastActivity: DateTime.parse(json['lastActivity']),
      ownerId: json['ownerId'],
      metadata: json['metadata'] ?? {},
    );
  }
  
  /// Check if room is full
  bool get isFull => participantCount >= maxParticipants;
  
  /// Check if room has available space
  bool get hasSpace => participantCount < maxParticipants;
  
  /// Get available spots
  int get availableSpots => maxParticipants - participantCount;
  
  /// Check if user is the owner
  bool isOwner(String userId) => ownerId == userId;
  
  @override
  String toString() {
    return 'ChatRoom(id: $id, name: $name, participants: $participantCount/$maxParticipants)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoom && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
