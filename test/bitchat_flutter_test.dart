import 'package:flutter_test/flutter_test.dart';
import 'package:bitchat_flutter/bitchat_flutter.dart';

void main() {
  group('BitChat Flutter Tests', () {
    test('Message creation and serialization', () {
      final message = BitChatMessage(
        id: 'test-123',
        content: 'Hello, BitChat!',
        senderId: 'user-456',
        roomId: 'public',
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      
      expect(message.id, 'test-123');
      expect(message.content, 'Hello, BitChat!');
      expect(message.senderId, 'user-456');
      expect(message.type, MessageType.text);
      
      // Test JSON serialization
      final json = message.toJson();
      expect(json['id'], 'test-123');
      expect(json['content'], 'Hello, BitChat!');
      
      // Test JSON deserialization
      final deserialized = BitChatMessage.fromJson(json);
      expect(deserialized.id, message.id);
      expect(deserialized.content, message.content);
    });
    
    test('Peer creation and capabilities', () {
      final peer = BitChatPeer(
        id: 'peer-789',
        displayName: 'TestPeer',
        deviceAddress: 'AA:BB:CC:DD:EE:FF',
        rssi: -50,
        lastSeen: DateTime.now(),
        capabilities: ['encryption', 'compression'],
        supportsEncryption: true,
      );
      
      expect(peer.id, 'peer-789');
      expect(peer.displayName, 'TestPeer');
      expect(peer.hasCapability('encryption'), true);
      expect(peer.hasCapability('compression'), true);
      expect(peer.hasCapability('nonexistent'), false);
      expect(peer.displayNameOrId, 'TestPeer');
    });
    
    test('Message types', () {
      expect(MessageType.text.value, 0x01);
      expect(MessageType.private.value, 0x02);
      expect(MessageType.room.value, 0x03);
      
      expect(MessageType.fromValue(0x01), MessageType.text);
      expect(MessageType.fromValue(0x02), MessageType.private);
      expect(MessageType.fromValue(0x99), MessageType.text); // Default fallback
    });
    
    test('Chat room functionality', () {
      final room = ChatRoom(
        id: 'room-123',
        name: 'Test Room',
        description: 'A test chat room',
        maxParticipants: 50,
        participantCount: 25,
        createdAt: DateTime.now(),
        lastActivity: DateTime.now(),
      );
      
      expect(room.id, 'room-123');
      expect(room.name, 'Test Room');
      expect(room.isFull, false);
      expect(room.hasSpace, true);
      expect(room.availableSpots, 25);
    });
    
    test('User profile functionality', () {
      final profile = UserProfile(
        id: 'user-123',
        displayName: 'TestUser',
        isOnline: true,
        lastSeen: DateTime.now(),
        capabilities: ['messaging', 'file-sharing'],
        supportsEncryption: true,
      );
      
      expect(profile.id, 'user-123');
      expect(profile.displayName, 'TestUser');
      expect(profile.isOnline, true);
      expect(profile.hasCapability('messaging'), true);
      expect(profile.displayNameOrId, 'TestUser');
    });
    
    test('Compression utility', () {
      final original = 'Hello, this is a test message that should be compressed!';
      final compressed = CompressionUtil.compress(original);
      final decompressed = CompressionUtil.decompress(compressed);
      
      expect(decompressed, original);
      
      final ratio = CompressionUtil.getCompressionRatio(original, compressed);
      expect(ratio >= 0.0, true);
    });
    
    test('Packet encoder', () {
      final message = BitChatMessage(
        id: 'test-123',
        content: 'Test message',
        senderId: 'user-456',
        roomId: 'public',
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      
      final encoder = PacketEncoder();
      final packet = encoder.encodePacket(message);
      
      expect(packet.length > 0, true);
      expect(encoder.validatePacket(packet), true);
      
      final packetInfo = encoder.getPacketInfo(packet);
      expect(packetInfo['messageType'], 'text');
      expect(packetInfo['totalSize'], packet.length);
    });
  });
}
