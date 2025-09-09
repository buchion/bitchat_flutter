import 'dart:async';
import 'bitchat_message.dart';
import 'bitchat_peer.dart';
import 'bluetooth/mesh_network.dart';
import 'bluetooth/peer_discovery.dart';
import 'utils/logger.dart';

/// Manages the BitChat network operations
class BitChatNetwork {
  static const String _tag = 'BitChatNetwork';
  
  final BitChatLogger _logger = BitChatLogger();
  final MeshNetwork _meshNetwork;
  final PeerDiscovery _peerDiscovery;
  
  final StreamController<BitChatMessage> _messageController = 
      StreamController<BitChatMessage>.broadcast();
  final StreamController<BitChatPeer> _peerController = 
      StreamController<BitChatPeer>.broadcast();
  
  bool _isInitialized = false;
  bool _isConnected = false;
  
  /// Get message stream
  Stream<BitChatMessage> get messageStream => _messageController.stream;
  
  /// Get peer stream
  Stream<BitChatPeer> get peerStream => _peerController.stream;
  
  /// Get connection status
  bool get isConnected => _isConnected;
  
  /// Get mesh network
  MeshNetwork get meshNetwork => _meshNetwork;
  
  /// Get peer discovery
  PeerDiscovery get peerDiscovery => _peerDiscovery;
  
  BitChatNetwork(this._meshNetwork, this._peerDiscovery) {
    _setupEventListeners();
  }
  
  /// Initialize the network
  Future<void> initialize() async {
    try {
      _logger.info(_tag, 'Initializing BitChat network...');
      
      await _meshNetwork.initialize();
      await _peerDiscovery.initialize();
      
      _isInitialized = true;
      _logger.info(_tag, 'BitChat network initialized successfully');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to initialize network: $e');
      rethrow;
    }
  }
  
  /// Connect to the network
  Future<void> connect() async {
    if (!_isInitialized) {
      throw StateError('Network must be initialized before connecting');
    }
    
    try {
      _logger.info(_tag, 'Connecting to BitChat network...');
      
      await _meshNetwork.connect();
      await _peerDiscovery.startDiscovery();
      
      _isConnected = true;
      _logger.info(_tag, 'Connected to BitChat network');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to connect: $e');
      rethrow;
    }
  }
  
  /// Disconnect from the network
  Future<void> disconnect() async {
    try {
      _logger.info(_tag, 'Disconnecting from BitChat network...');
      
      await _peerDiscovery.stopDiscovery();
      await _meshNetwork.disconnect();
      
      _isConnected = false;
      _logger.info(_tag, 'Disconnected from BitChat network');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to disconnect: $e');
      rethrow;
    }
  }
  
  /// Send a message to the network
  Future<void> sendMessage(BitChatMessage message) async {
    if (!_isConnected) {
      throw StateError('Must be connected to send messages');
    }
    
    try {
      await _meshNetwork.broadcastMessage(message);
      _logger.info(_tag, 'Message sent: ${message.id}');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to send message: $e');
      rethrow;
    }
  }
  
  /// Send a private message to a specific peer
  Future<void> sendPrivateMessage(BitChatMessage message, String peerId) async {
    if (!_isConnected) {
      throw StateError('Must be connected to send messages');
    }
    
    try {
      await _meshNetwork.sendPrivateMessage(message, peerId);
      _logger.info(_tag, 'Private message sent to $peerId');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to send private message: $e');
      rethrow;
    }
  }
  
  /// Join a chat room
  Future<void> joinRoom(String roomId) async {
    if (!_isConnected) {
      throw StateError('Must be connected to join rooms');
    }
    
    try {
      await _meshNetwork.joinRoom(roomId);
      _logger.info(_tag, 'Joined room: $roomId');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to join room: $e');
      rethrow;
    }
  }
  
  /// Leave a chat room
  Future<void> leaveRoom(String roomId) async {
    try {
      await _meshNetwork.leaveRoom(roomId);
      _logger.info(_tag, 'Left room: $roomId');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to leave room: $e');
      rethrow;
    }
  }
  
  /// Get all discovered peers
  List<BitChatPeer> getPeers() {
    return _peerDiscovery.discoveredPeers;
  }
  
  /// Get peers in a specific room
  List<BitChatPeer> getPeersInRoom(String roomId) {
    return _peerDiscovery.getPeersInRoom(roomId);
  }
  
  /// Get connected peers
  List<BitChatPeer> getConnectedPeers() {
    return _peerDiscovery.getConnectedPeers();
  }
  
  /// Set up event listeners
  void _setupEventListeners() {
    // Listen for incoming messages from mesh network
    _meshNetwork.messageStream.listen((message) {
      _messageController.add(message);
    });
    
    // Listen for peer updates from discovery
    _peerDiscovery.peerStream.listen((peer) {
      _peerController.add(peer);
    });
  }
  
  /// Dispose resources
  void dispose() {
    _messageController.close();
    _peerController.close();
    disconnect();
  }
}
