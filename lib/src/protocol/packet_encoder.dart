import 'dart:typed_data';
import 'message_types.dart';
import '../bitchat_message.dart';
import '../utils/compression.dart';
import '../utils/logger.dart';

/// Encodes and decodes BitChat protocol packets
class PacketEncoder {
  static const String _tag = 'PacketEncoder';
  
  final BitChatLogger _logger = BitChatLogger();
  
  /// Packet header size in bytes
  static const int _headerSize = 16;
  
  /// Maximum packet size
  static const int _maxPacketSize = 1024;
  
  /// Packet magic number
  static const int _magicNumber = 0xBCBC;
  
  /// Protocol version
  static const int _protocolVersion = 1;
  
  /// Encode a message into a packet
  Uint8List encodePacket(BitChatMessage message) {
    try {
      // Compress message content if beneficial
      final compressedContent = CompressionUtil.isCompressionBeneficial(message.content)
          ? CompressionUtil.compress(message.content)
          : Uint8List.fromList(message.content.codeUnits);
      
      // Calculate packet size
      final contentSize = compressedContent.length;
      final packetSize = _headerSize + contentSize;
      
      if (packetSize > _maxPacketSize) {
        throw Exception('Packet too large: $packetSize bytes');
      }
      
      // Create packet buffer
      final packet = ByteData(packetSize);
      int offset = 0;
      
      // Magic number (2 bytes)
      packet.setUint16(offset, _magicNumber, Endian.big);
      offset += 2;
      
      // Protocol version (1 byte)
      packet.setUint8(offset, _protocolVersion);
      offset += 1;
      
      // Message type (1 byte)
      packet.setUint8(offset, message.type.value);
      offset += 1;
      
      // TTL (1 byte)
      packet.setUint8(offset, message.ttl.clamp(0, 7));
      offset += 1;
      
      // Content size (2 bytes)
      packet.setUint16(offset, contentSize, Endian.big);
      offset += 2;
      
      // Timestamp (8 bytes)
      final timestamp = message.timestamp.millisecondsSinceEpoch;
      packet.setUint64(offset, timestamp, Endian.big);
      offset += 8;
      
      // Reserved (1 byte)
      packet.setUint8(offset, 0);
      offset += 1;
      
      // Copy compressed content
      packet.buffer.asUint8List(offset, contentSize).setAll(0, compressedContent);
      
      _logger.debug(_tag, 'Encoded packet: ${packetSize} bytes, content: ${contentSize} bytes');
      
      return packet.buffer.asUint8List(0, packetSize);
      
    } catch (e) {
      _logger.error(_tag, 'Failed to encode packet: $e');
      rethrow;
    }
  }
  
  /// Decode a packet into a message
  BitChatMessage decodePacket(Uint8List packet) {
    try {
      if (packet.length < _headerSize) {
        throw Exception('Packet too small: ${packet.length} bytes');
      }
      
      final buffer = ByteData.sublistView(packet);
      int offset = 0;
      
      // Verify magic number
      final magic = buffer.getUint16(offset, Endian.big);
      if (magic != _magicNumber) {
        throw Exception('Invalid magic number: 0x${magic.toRadixString(16)}');
      }
      offset += 2;
      
      // Check protocol version
      final version = buffer.getUint8(offset);
      if (version != _protocolVersion) {
        throw Exception('Unsupported protocol version: $version');
      }
      offset += 1;
      
      // Get message type
      final typeValue = buffer.getUint8(offset);
      final type = MessageType.fromValue(typeValue);
      offset += 1;
      
      // Get TTL
      final ttl = buffer.getUint8(offset);
      offset += 1;
      
      // Get content size
      final contentSize = buffer.getUint16(offset, Endian.big);
      offset += 2;
      
      // Get timestamp
      final timestamp = buffer.getUint64(offset, Endian.big);
      offset += 8;
      
      // Skip reserved byte
      offset += 1;
      
      // Extract content
      if (offset + contentSize > packet.length) {
        throw Exception('Packet content truncated');
      }
      
      final compressedContent = packet.sublist(offset, offset + contentSize);
      
      // Decompress content
      final content = CompressionUtil.decompress(compressedContent);
      
      // Create message (we'll need to reconstruct some fields)
      final message = BitChatMessage(
        id: _generateMessageId(timestamp),
        content: content,
        senderId: 'unknown', // Will be set by the network layer
        roomId: 'public',
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        type: type,
        ttl: ttl,
      );
      
      _logger.debug(_tag, 'Decoded packet: ${packet.length} bytes, content: ${content.length} bytes');
      
      return message;
      
    } catch (e) {
      _logger.error(_tag, 'Failed to decode packet: $e');
      rethrow;
    }
  }
  
  /// Validate packet structure
  bool validatePacket(Uint8List packet) {
    try {
      if (packet.length < _headerSize) return false;
      
      final buffer = ByteData.sublistView(packet);
      
      // Check magic number
      final magic = buffer.getUint16(0, Endian.big);
      if (magic != _magicNumber) return false;
      
      // Check protocol version
      final version = buffer.getUint8(2);
      if (version != _protocolVersion) return false;
      
      // Check packet size
      final contentSize = buffer.getUint16(5, Endian.big);
      final expectedSize = _headerSize + contentSize;
      
      return packet.length == expectedSize;
      
    } catch (e) {
      return false;
    }
  }
  
  /// Get packet header information
  Map<String, dynamic> getPacketInfo(Uint8List packet) {
    try {
      if (packet.length < _headerSize) {
        return {'error': 'Packet too small'};
      }
      
      final buffer = ByteData.sublistView(packet);
      
      return {
        'magicNumber': '0x${buffer.getUint16(0, Endian.big).toRadixString(16)}',
        'protocolVersion': buffer.getUint8(2),
        'messageType': MessageType.fromValue(buffer.getUint8(3)).name,
        'ttl': buffer.getUint8(4),
        'contentSize': buffer.getUint16(5, Endian.big),
        'timestamp': DateTime.fromMillisecondsSinceEpoch(buffer.getUint64(7, Endian.big)),
        'totalSize': packet.length,
      };
      
    } catch (e) {
      return {'error': 'Failed to parse packet: $e'};
    }
  }
  
  /// Generate a message ID from timestamp
  String _generateMessageId(int timestamp) {
    return 'msg_${timestamp}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }
  
  /// Get header size
  int get headerSize => _headerSize;
  
  /// Get maximum packet size
  int get maxPacketSize => _maxPacketSize;
  
  /// Get magic number
  int get magicNumber => _magicNumber;
  
  /// Get protocol version
  int get protocolVersion => _protocolVersion;
}
