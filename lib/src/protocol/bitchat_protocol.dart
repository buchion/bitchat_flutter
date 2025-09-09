import 'dart:typed_data';
import 'message_types.dart';
import '../bitchat_message.dart';
import '../utils/logger.dart';

/// Implements the BitChat binary protocol
class BitChatProtocol {
  static const String _tag = 'BitChatProtocol';
  
  final BitChatLogger _logger = BitChatLogger();
  
  /// Protocol version
  static const int _protocolVersion = 1;
  
  /// Maximum message size
  static const int _maxMessageSize = 1024;
  
  /// Maximum TTL value
  static const int _maxTtl = 7;
  
  /// Encode a message to binary format
  Uint8List encodeMessage(BitChatMessage message) {
    try {
      final buffer = ByteData(1024);
      int offset = 0;
      
      // Protocol version (1 byte)
      buffer.setUint8(offset++, _protocolVersion);
      
      // Message type (1 byte)
      buffer.setUint8(offset++, message.type.value);
      
      // TTL (1 byte)
      buffer.setUint8(offset++, message.ttl.clamp(0, _maxTtl));
      
      // Message ID length and data
      final messageIdBytes = Uint8List.fromList(message.id.codeUnits);
      buffer.setUint8(offset++, messageIdBytes.length);
      buffer.setUint8(offset++, messageIdBytes.length >> 8);
      buffer.setUint8(offset++, messageIdBytes.length >> 16);
      buffer.setUint8(offset++, messageIdBytes.length >> 24);
      buffer.setUint8(offset++, messageIdBytes.length >> 32);
      buffer.setUint8(offset++, messageIdBytes.length >> 40);
      buffer.setUint8(offset++, messageIdBytes.length >> 48);
      buffer.setUint8(offset++, messageIdBytes.length >> 56);
      
      // Copy message ID
      for (int i = 0; i < messageIdBytes.length; i++) {
        buffer.setUint8(offset++, messageIdBytes[i]);
      }
      
      // Sender ID length and data
      final senderIdBytes = Uint8List.fromList(message.senderId.codeUnits);
      buffer.setUint8(offset++, senderIdBytes.length);
      buffer.setUint8(offset++, senderIdBytes.length >> 8);
      buffer.setUint8(offset++, senderIdBytes.length >> 16);
      buffer.setUint8(offset++, senderIdBytes.length >> 24);
      buffer.setUint8(offset++, senderIdBytes.length >> 32);
      buffer.setUint8(offset++, senderIdBytes.length >> 40);
      buffer.setUint8(offset++, senderIdBytes.length >> 48);
      buffer.setUint8(offset++, senderIdBytes.length >> 56);
      
      // Copy sender ID
      for (int i = 0; i < senderIdBytes.length; i++) {
        buffer.setUint8(offset++, senderIdBytes[i]);
      }
      
      // Content length and data
      final contentBytes = Uint8List.fromList(message.content.codeUnits);
      buffer.setUint8(offset++, contentBytes.length);
      buffer.setUint8(offset++, contentBytes.length >> 8);
      buffer.setUint8(offset++, contentBytes.length >> 16);
      buffer.setUint8(offset++, contentBytes.length >> 24);
      buffer.setUint8(offset++, contentBytes.length >> 32);
      buffer.setUint8(offset++, contentBytes.length >> 40);
      buffer.setUint8(offset++, contentBytes.length >> 48);
      buffer.setUint8(offset++, contentBytes.length >> 56);
      
      // Copy content
      for (int i = 0; i < contentBytes.length; i++) {
        buffer.setUint8(offset++, contentBytes[i]);
      }
      
      // Timestamp (8 bytes)
      final timestamp = message.timestamp.millisecondsSinceEpoch;
      buffer.setUint8(offset++, timestamp);
      buffer.setUint8(offset++, timestamp >> 8);
      buffer.setUint8(offset++, timestamp >> 16);
      buffer.setUint8(offset++, timestamp >> 24);
      buffer.setUint8(offset++, timestamp >> 32);
      buffer.setUint8(offset++, timestamp >> 40);
      buffer.setUint8(offset++, timestamp >> 48);
      buffer.setUint8(offset++, timestamp >> 56);
      
      // Return the encoded data
      return buffer.buffer.asUint8List(0, offset);
      
    } catch (e) {
      _logger.error(_tag, 'Failed to encode message: $e');
      rethrow;
    }
  }
  
  /// Decode a binary message
  BitChatMessage decodeMessage(Uint8List data) {
    try {
      final buffer = ByteData.sublistView(data);
      int offset = 0;
      
      // Protocol version
      final version = buffer.getUint8(offset++);
      if (version != _protocolVersion) {
        throw Exception('Unsupported protocol version: $version');
      }
      
      // Message type
      final typeValue = buffer.getUint8(offset++);
      final type = MessageType.fromValue(typeValue);
      
      // TTL
      final ttl = buffer.getUint8(offset++);
      
      // Message ID
      final messageIdLength = buffer.getUint64(offset);
      offset += 8;
      final messageId = String.fromCharCodes(
        data.sublist(offset, offset + messageIdLength),
      );
      offset += messageIdLength;
      
      // Sender ID
      final senderIdLength = buffer.getUint64(offset);
      offset += 8;
      final senderId = String.fromCharCodes(
        data.sublist(offset, offset + senderIdLength),
      );
      offset += senderIdLength;
      
      // Content
      final contentLength = buffer.getUint64(offset);
      offset += 8;
      final content = String.fromCharCodes(
        data.sublist(offset, offset + contentLength),
      );
      offset += contentLength;
      
      // Timestamp
      final timestamp = buffer.getUint64(offset);
      offset += 8;
      
      // Create message
      return BitChatMessage(
        id: messageId,
        content: content,
        senderId: senderId,
        roomId: 'public', // Default room for now
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        type: type,
        ttl: ttl,
      );
      
    } catch (e) {
      _logger.error(_tag, 'Failed to decode message: $e');
      rethrow;
    }
  }
  
  /// Validate a message
  bool validateMessage(BitChatMessage message) {
    try {
      // Check message size
      if (message.content.length > _maxMessageSize) {
        _logger.warning(_tag, 'Message too large: ${message.content.length} bytes');
        return false;
      }
      
      // Check TTL
      if (message.ttl < 0 || message.ttl > _maxTtl) {
        _logger.warning(_tag, 'Invalid TTL: ${message.ttl}');
        return false;
      }
      
      // Check required fields
      if (message.id.isEmpty || message.content.isEmpty || message.senderId.isEmpty) {
        _logger.warning(_tag, 'Missing required message fields');
        return false;
      }
      
      return true;
      
    } catch (e) {
      _logger.error(_tag, 'Message validation failed: $e');
      return false;
    }
  }
  
  /// Get protocol version
  int get protocolVersion => _protocolVersion;
  
  /// Get maximum message size
  int get maxMessageSize => _maxMessageSize;
  
  /// Get maximum TTL
  int get maxTtl => _maxTtl;
}
