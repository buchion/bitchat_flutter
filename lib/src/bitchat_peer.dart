/// Represents a peer device in the BitChat network
class BitChatPeer {
  /// Unique peer identifier
  final String id;
  
  /// Peer's display name
  final String? displayName;
  
  /// Bluetooth device address
  final String deviceAddress;
  
  /// Signal strength (RSSI)
  final int rssi;
  
  /// Whether peer is currently connected
  final bool isConnected;
  
  /// Current room the peer is in
  final String? currentRoom;
  
  /// Last seen timestamp
  final DateTime lastSeen;
  
  /// Peer's capabilities
  final List<String> capabilities;
  
  /// Whether peer supports encryption
  final bool supportsEncryption;
  
  /// Peer's public key for encryption
  final String? publicKey;
  
  BitChatPeer({
    required this.id,
    this.displayName,
    required this.deviceAddress,
    required this.rssi,
    this.isConnected = false,
    this.currentRoom,
    required this.lastSeen,
    this.capabilities = const [],
    this.supportsEncryption = false,
    this.publicKey,
  });
  
  /// Create a copy of this peer with updated fields
  BitChatPeer copyWith({
    String? id,
    String? displayName,
    String? deviceAddress,
    int? rssi,
    bool? isConnected,
    String? currentRoom,
    DateTime? lastSeen,
    List<String>? capabilities,
    bool? supportsEncryption,
    String? publicKey,
  }) {
    return BitChatPeer(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      deviceAddress: deviceAddress ?? this.deviceAddress,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
      currentRoom: currentRoom ?? this.currentRoom,
      lastSeen: lastSeen ?? this.lastSeen,
      capabilities: capabilities ?? this.capabilities,
      supportsEncryption: supportsEncryption ?? this.supportsEncryption,
      publicKey: publicKey ?? this.publicKey,
    );
  }
  
  /// Convert peer to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'deviceAddress': deviceAddress,
      'rssi': rssi,
      'isConnected': isConnected,
      'currentRoom': currentRoom,
      'lastSeen': lastSeen.toIso8601String(),
      'capabilities': capabilities,
      'supportsEncryption': supportsEncryption,
      'publicKey': publicKey,
    };
  }
  
  /// Create peer from JSON
  factory BitChatPeer.fromJson(Map<String, dynamic> json) {
    return BitChatPeer(
      id: json['id'],
      displayName: json['displayName'],
      deviceAddress: json['deviceAddress'],
      rssi: json['rssi'],
      isConnected: json['isConnected'] ?? false,
      currentRoom: json['currentRoom'],
      lastSeen: DateTime.parse(json['lastSeen']),
      capabilities: List<String>.from(json['capabilities'] ?? []),
      supportsEncryption: json['supportsEncryption'] ?? false,
      publicKey: json['publicKey'],
    );
  }
  
  /// Check if peer has a specific capability
  bool hasCapability(String capability) {
    return capabilities.contains(capability);
  }
  
  /// Get peer's display name or fallback to ID
  String get displayNameOrId => displayName ?? id;
  
  @override
  String toString() {
    return 'BitChatPeer(id: $id, name: $displayNameOrId, room: $currentRoom, connected: $isConnected)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BitChatPeer && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
