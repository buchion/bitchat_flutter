import 'dart:typed_data';
import 'dart:math';
import '../utils/logger.dart';

/// Simplified Noise Protocol implementation for BitChat encryption
class NoiseProtocol {
  static const String _tag = 'NoiseProtocol';
  
  final BitChatLogger _logger = BitChatLogger();
  final Random _random = Random.secure();
  
  bool _isHandshakeComplete = false;
  Uint8List? _encryptionKey;
  Uint8List? _decryptionKey;
  
  /// Initialize Noise Protocol
  Future<void> initialize() async {
    try {
      _logger.info(_tag, 'Initializing Noise Protocol...');
      
      // Generate session keys
      _encryptionKey = Uint8List(32);
      _decryptionKey = Uint8List(32);
      
      for (int i = 0; i < 32; i++) {
        _encryptionKey![i] = _random.nextInt(256);
        _decryptionKey![i] = _random.nextInt(256);
      }
      
      _logger.info(_tag, 'Noise Protocol initialized');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to initialize: $e');
      rethrow;
    }
  }
  
  /// Start handshake
  Future<Uint8List> startHandshake() async {
    final ephemeralKey = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      ephemeralKey[i] = _random.nextInt(256);
    }
    
    _isHandshakeComplete = true;
    return ephemeralKey;
  }
  
  /// Encrypt a message
  Uint8List encryptMessage(Uint8List plaintext) {
    if (!_isHandshakeComplete) {
      throw StateError('Handshake must be completed');
    }
    
    final encrypted = Uint8List(plaintext.length);
    for (int i = 0; i < plaintext.length; i++) {
      encrypted[i] = plaintext[i] ^ (_encryptionKey?[i % 32] ?? 0);
    }
    return encrypted;
  }
  
  /// Decrypt a message
  Uint8List decryptMessage(Uint8List ciphertext) {
    if (!_isHandshakeComplete) {
      throw StateError('Handshake must be completed');
    }
    
    final decrypted = Uint8List(ciphertext.length);
    for (int i = 0; i < ciphertext.length; i++) {
      decrypted[i] = ciphertext[i] ^ (_decryptionKey?[i % 32] ?? 0);
    }
    return decrypted;
  }
  
  /// Check if handshake is complete
  bool get isHandshakeComplete => _isHandshakeComplete;
}
