import 'dart:async';
import 'package:bitchat_flutter/bitchat_flutter.dart';
import 'package:flutter/foundation.dart';
import 'bitchat_message.dart';
import 'bitchat_peer.dart';
import 'bluetooth/mesh_network.dart';
import 'bluetooth/peer_discovery.dart';
import 'security/identity_manager.dart';
import 'utils/logger.dart';

/// Main BitChat client that manages the entire BitChat functionality
class BitChatClient extends ChangeNotifier {
  static const String _tag = 'BitChatClient';
  
  final BitChatLogger _logger = BitChatLogger();
  late final MeshNetwork _meshNetwork;
  late final PeerDiscovery _peerDiscovery;
  late final IdentityManager _identityManager;
  
  final StreamController<BitChatMessage> _messageController = 
      StreamController<BitChatMessage>.broadcast();
  final StreamController<BitChatPeer> _peerController = 
      StreamController<BitChatPeer>.broadcast();
  
  bool _isInitialized = false;
  bool _isConnected = false;
  List<BitChatPeer> _peers = [];
  List<BitChatMessage> _messageHistory = [];
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  List<BitChatPeer> get peers => List.unmodifiable(_peers);
  List<BitChatMessage> get messageHistory => List.unmodifiable(_messageHistory);
  Stream<BitChatMessage> get messageStream => _messageController.stream;
  Stream<BitChatPeer> get peerStream => _peerController.stream;
  
  /// Initialize the BitChat client
  Future<void> initialize() async {
    try {
      _logger.info(_tag, 'Initializing BitChat client...');
      
      _identityManager = IdentityManager();
      await _identityManager.initialize();
      
      _meshNetwork = MeshNetwork();
      await _meshNetwork.initialize();
      
      _peerDiscovery = PeerDiscovery();
      await _peerDiscovery.initialize();
      
      _setupEventListeners();
      
      _isInitialized = true;
      _logger.info(_tag, 'BitChat client initialized successfully');
      notifyListeners();
      
    } catch (e) {
      _logger.error(_tag, 'Failed to initialize BitChat client: $e');
      rethrow;
    }
  }
  
  /// Connect to the BitChat network
  Future<void> connect() async {
    if (!_isInitialized) {
      throw StateError('BitChat client must be initialized before connecting');
    }
    
    try {
      await _meshNetwork.connect();
      await _peerDiscovery.startDiscovery();
      
      _isConnected = true;
      notifyListeners();
      
    } catch (e) {
      _logger.error(_tag, 'Failed to connect: $e');
      rethrow;
    }
  }
  
  /// Send a message to the network
  Future<void> sendMessage(String content, {String? roomId}) async {
    if (!_isConnected) {
      throw StateError('Must be connected to send messages');
    }
    
    final message = BitChatMessage(
      id: _generateMessageId(),
      content: content,
      senderId: _identityManager.currentIdentity?.id ?? '',
      roomId: roomId ?? 'public',
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    
    await _meshNetwork.broadcastMessage(message);
    _messageHistory.add(message);
    notifyListeners();
  }
  
  /// Emergency wipe - clear all data
  Future<void> emergencyWipe() async {
    await _meshNetwork.disconnect();
    await _identityManager.clearAllData();
    _messageHistory.clear();
    _peers.clear();
    _isInitialized = false;
    _isConnected = false;
    notifyListeners();
  }
  
  void _setupEventListeners() {
    _meshNetwork.messageStream.listen((message) {
      _messageHistory.add(message);
      _messageController.add(message);
      notifyListeners();
    });
    
    _peerDiscovery.peerStream.listen((peer) {
      final existingIndex = _peers.indexWhere((p) => p.id == peer.id);
      if (existingIndex >= 0) {
        _peers[existingIndex] = peer;
      } else {
        _peers.add(peer);
      }
      _peerController.add(peer);
      notifyListeners();
    });
  }
  
  String _generateMessageId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  @override
  void dispose() {
    _messageController.close();
    _peerController.close();
    super.dispose();
  }
}
