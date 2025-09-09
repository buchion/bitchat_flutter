/// Represents a user profile in BitChat
class UserProfile {
  /// Unique user identifier
  final String id;
  
  /// Display name
  final String displayName;
  
  /// User avatar (base64 encoded image or URL)
  final String? avatar;
  
  /// User status message
  final String? statusMessage;
  
  /// Whether the user is online
  final bool isOnline;
  
  /// Last seen timestamp
  final DateTime lastSeen;
  
  /// User capabilities
  final List<String> capabilities;
  
  /// Whether the user supports encryption
  final bool supportsEncryption;
  
  /// User's public key for encryption
  final String? publicKey;
  
  /// User's current room
  final String? currentRoom;
  
  /// User metadata
  final Map<String, dynamic> metadata;
  
  UserProfile({
    required this.id,
    required this.displayName,
    this.avatar,
    this.statusMessage,
    this.isOnline = false,
    required this.lastSeen,
    this.capabilities = const [],
    this.supportsEncryption = false,
    this.publicKey,
    this.currentRoom,
    this.metadata = const {},
  });
  
  /// Create a copy of this profile with updated fields
  UserProfile copyWith({
    String? id,
    String? displayName,
    String? avatar,
    String? statusMessage,
    bool? isOnline,
    DateTime? lastSeen,
    List<String>? capabilities,
    bool? supportsEncryption,
    String? publicKey,
    String? currentRoom,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      statusMessage: statusMessage ?? this.statusMessage,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      capabilities: capabilities ?? this.capabilities,
      supportsEncryption: supportsEncryption ?? this.supportsEncryption,
      publicKey: publicKey ?? this.publicKey,
      currentRoom: currentRoom ?? this.currentRoom,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Convert profile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatar': avatar,
      'statusMessage': statusMessage,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'capabilities': capabilities,
      'supportsEncryption': supportsEncryption,
      'publicKey': publicKey,
      'currentRoom': currentRoom,
      'metadata': metadata,
    };
  }
  
  /// Create profile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      displayName: json['displayName'],
      avatar: json['avatar'],
      statusMessage: json['statusMessage'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: DateTime.parse(json['lastSeen']),
      capabilities: List<String>.from(json['capabilities'] ?? []),
      supportsEncryption: json['supportsEncryption'] ?? false,
      publicKey: json['publicKey'],
      currentRoom: json['currentRoom'],
      metadata: json['metadata'] ?? {},
    );
  }
  
  /// Check if user has a specific capability
  bool hasCapability(String capability) {
    return capabilities.contains(capability);
  }
  
  /// Get user's display name or fallback to ID
  String get displayNameOrId => displayName.isNotEmpty ? displayName : id;
  
  /// Check if user is in a specific room
  bool isInRoom(String roomId) => currentRoom == roomId;
  
  /// Get user's status display text
  String get statusDisplay {
    if (isOnline) {
      return statusMessage ?? 'Online';
    } else {
      final timeAgo = _getTimeAgo(lastSeen);
      return 'Last seen $timeAgo';
    }
  }
  
  /// Get time ago string
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
  
  @override
  String toString() {
    return 'UserProfile(id: $id, name: $displayName, online: $isOnline, room: $currentRoom)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
