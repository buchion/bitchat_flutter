import 'dart:async';
import '../bitchat_peer.dart';
import '../utils/logger.dart';

/// Manages peer discovery for BitChat devices
class PeerDiscovery {
  static const String _tag = 'PeerDiscovery';
  
  final BitChatLogger _logger = BitChatLogger();
  final StreamController<BitChatPeer> _peerController = 
      StreamController<BitChatPeer>.broadcast();
  
  bool _isInitialized = false;
  bool _isDiscovering = false;
  List<BitChatPeer> _discoveredPeers = [];
  
  /// Get peer stream
  Stream<BitChatPeer> get peerStream => _peerController.stream;
  
  /// Get discovered peers
  List<BitChatPeer> get discoveredPeers => List.unmodifiable(_discoveredPeers);
  
  /// Initialize peer discovery
  Future<void> initialize() async {
    try {
      _logger.info(_tag, 'Initializing peer discovery...');
      
      // Set up discovery parameters
      _isInitialized = true;
      _logger.info(_tag, 'Peer discovery initialized successfully');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to initialize peer discovery: $e');
      rethrow;
    }
  }
  
  /// Start discovering peers
  Future<void> startDiscovery() async {
    if (!_isInitialized) {
      throw StateError('Peer discovery must be initialized before starting');
    }
    
    try {
      _logger.info(_tag, 'Starting peer discovery...');
      
      _isDiscovering = true;
      
      // In a real implementation, this would start Bluetooth scanning
      // and process discovered devices to find BitChat peers
      
      _logger.info(_tag, 'Peer discovery started');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to start peer discovery: $e');
      rethrow;
    }
  }
  
  /// Stop discovering peers
  Future<void> stopDiscovery() async {
    try {
      _logger.info(_tag, 'Stopping peer discovery...');
      
      _isDiscovering = false;
      
      // In a real implementation, this would stop Bluetooth scanning
      
      _logger.info(_tag, 'Peer discovery stopped');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to stop peer discovery: $e');
      rethrow;
    }
  }
  
  /// Add a discovered peer
  void addPeer(BitChatPeer peer) {
    final existingIndex = _discoveredPeers.indexWhere((p) => p.id == peer.id);
    
    if (existingIndex >= 0) {
      // Update existing peer
      _discoveredPeers[existingIndex] = peer;
    } else {
      // Add new peer
      _discoveredPeers.add(peer);
    }
    
    _peerController.add(peer);
    _logger.info(_tag, 'Peer added/updated: ${peer.displayNameOrId}');
  }
  
  /// Remove a peer
  void removePeer(String peerId) {
    final index = _discoveredPeers.indexWhere((p) => p.id == peerId);
    if (index >= 0) {
      final peer = _discoveredPeers.removeAt(index);
      _logger.info(_tag, 'Peer removed: ${peer.displayNameOrId}');
    }
  }
  
  /// Clear all discovered peers
  void clearPeers() {
    _discoveredPeers.clear();
    _logger.info(_tag, 'All peers cleared');
  }
  
  /// Get peer by ID
  BitChatPeer? getPeerById(String peerId) {
    try {
      return _discoveredPeers.firstWhere((p) => p.id == peerId);
    } catch (e) {
      return null;
    }
  }
  
  /// Get peers in a specific room
  List<BitChatPeer> getPeersInRoom(String roomId) {
    return _discoveredPeers.where((p) => p.currentRoom == roomId).toList();
  }
  
  /// Get connected peers
  List<BitChatPeer> getConnectedPeers() {
    return _discoveredPeers.where((p) => p.isConnected).toList();
  }
  
  /// Check if discovery is active
  bool get isDiscovering => _isDiscovering;
  
  /// Dispose resources
  void dispose() {
    _peerController.close();
    stopDiscovery();
  }
}
