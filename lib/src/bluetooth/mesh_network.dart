import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../bitchat_message.dart';
import '../utils/logger.dart';

/// Manages Bluetooth mesh networking for BitChat
class MeshNetwork {
  static const String _tag = 'MeshNetwork';
  static const String _serviceUuid = '12345678-1234-1234-1234-123456789abc';
  static const String _characteristicUuid = '87654321-4321-4321-4321-cba987654321';
  
  final BitChatLogger _logger = BitChatLogger();
  final StreamController<BitChatMessage> _messageController = 
      StreamController<BitChatMessage>.broadcast();
  
  
  BluetoothCharacteristic? _messageCharacteristic;
  
  bool _isInitialized = false;
  bool _isConnected = false;
  List<BluetoothDevice> _connectedPeers = [];
  
  /// Get message stream
  Stream<BitChatMessage> get messageStream => _messageController.stream;
  
  /// Get connection status
  bool get isConnected => _isConnected;
  
  /// Initialize the mesh network
  Future<void> initialize() async {
    try {
      _logger.info(_tag, 'Initializing mesh network...');
      
      // Check if Bluetooth is available
      if (!await FlutterBluePlus.isAvailable) {
        throw Exception('Bluetooth is not available on this device');
      }
      
      // Check if Bluetooth is on
      if (!await FlutterBluePlus.isOn) {
        throw Exception('Bluetooth is not turned on');
      }
      
      _isInitialized = true;
      _logger.info(_tag, 'Mesh network initialized successfully');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to initialize mesh network: $e');
      rethrow;
    }
  }
  
  /// Connect to the mesh network
  Future<void> connect() async {
    if (!_isInitialized) {
      throw StateError('Mesh network must be initialized before connecting');
    }
    
    try {
      _logger.info(_tag, 'Connecting to mesh network...');
      
      // Start scanning for other BitChat devices
      await _startScanning();
      
      // Set up as a peripheral to accept connections
      await _setupPeripheral();
      
      _isConnected = true;
      _logger.info(_tag, 'Connected to mesh network');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to connect: $e');
      rethrow;
    }
  }
  
  /// Disconnect from the mesh network
  Future<void> disconnect() async {
    try {
      _logger.info(_tag, 'Disconnecting from mesh network...');
      
      await _stopScanning();
      await _stopPeripheral();
      
      // Disconnect from all peers
      for (final peer in _connectedPeers) {
        await peer.disconnect();
      }
      _connectedPeers.clear();
      
      _isConnected = false;
      _logger.info(_tag, 'Disconnected from mesh network');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to disconnect: $e');
      rethrow;
    }
  }
  
  /// Broadcast a message to all connected peers
  Future<void> broadcastMessage(BitChatMessage message) async {
    if (!_isConnected) {
      throw StateError('Must be connected to broadcast messages');
    }
    
    try {
      final data = _encodeMessage(message);
      
      // Send to all connected peers
      for (final peer in _connectedPeers) {
        try {
          await _sendMessageToPeer(peer, data);
        } catch (e) {
          _logger.warning(_tag, 'Failed to send to peer ${peer.id}: $e');
        }
      }
      
      _logger.info(_tag, 'Message broadcasted to ${_connectedPeers.length} peers');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to broadcast message: $e');
      rethrow;
    }
  }
  
  /// Send a private message to a specific peer
  Future<void> sendPrivateMessage(BitChatMessage message, String peerId) async {
    if (!_isConnected) {
      throw StateError('Must be connected to send messages');
    }
    
    try {
      final peer = _connectedPeers.firstWhere(
        (p) => p.id.toString() == peerId,
        orElse: () => throw Exception('Peer not found: $peerId'),
      );
      
      final data = _encodeMessage(message);
      await _sendMessageToPeer(peer, data);
      
      _logger.info(_tag, 'Private message sent to $peerId');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to send private message: $e');
      rethrow;
    }
  }
  
  /// Join a chat room
  Future<void> joinRoom(String roomId) async {
    // In a real implementation, this would notify peers about room membership
    _logger.info(_tag, 'Joined room: $roomId');
  }
  
  /// Leave a chat room
  Future<void> leaveRoom(String roomId) async {
    // In a real implementation, this would notify peers about leaving the room
    _logger.info(_tag, 'Left room: $roomId');
  }
  
  /// Start scanning for other BitChat devices
  Future<void> _startScanning() async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      androidUsesFineLocation: false,
    );

    FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        if (_isBitChatDevice(result)) {
          _handleDiscoveredDevice(result.device);
        }
      }
    });
  }
  
  /// Stop scanning for devices
  Future<void> _stopScanning() async {
    await FlutterBluePlus.stopScan();
  }
  
  /// Check if a device is a BitChat device
  bool _isBitChatDevice(ScanResult result) {
    // Check if device advertises BitChat service
    return result.advertisementData.serviceUuids.contains(_serviceUuid);
  }
  
  /// Handle a discovered BitChat device
  void _handleDiscoveredDevice(BluetoothDevice device) {
    _logger.info(_tag, 'Discovered BitChat device: ${device.id}');
    
    // Connect to the device
    _connectToPeer(device);
  }
  
  /// Connect to a peer device
  Future<void> _connectToPeer(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedPeers.add(device);
      
      // Discover services and characteristics
      final services = await device.discoverServices();
      for (final service in services) {
        if (service.uuid.toString() == _serviceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == _characteristicUuid) {
              _messageCharacteristic = characteristic;
              
              // Listen for incoming messages
              characteristic.value.listen((value) {
                _handleIncomingMessage(Uint8List.fromList(value));
              });
              
              break;
            }
          }
        }
      }
      
      _logger.info(_tag, 'Connected to peer: ${device.id}');
      
    } catch (e) {
      _logger.error(_tag, 'Failed to connect to peer ${device.id}: $e');
    }
  }
  
  /// Set up this device as a peripheral
  Future<void> _setupPeripheral() async {
    // In a real implementation, this would set up the device as a peripheral
    // to accept connections from other BitChat devices
    _logger.info(_tag, 'Set up as peripheral');
  }
  
  /// Stop being a peripheral
  Future<void> _stopPeripheral() async {
    // In a real implementation, this would stop being a peripheral
    _logger.info(_tag, 'Stopped being peripheral');
  }
  
  /// Send a message to a specific peer
  Future<void> _sendMessageToPeer(BluetoothDevice peer, Uint8List data) async {
    if (_messageCharacteristic == null) {
      throw StateError('Message characteristic not available');
    }
    
    await _messageCharacteristic!.write(data);
  }
  
  /// Handle incoming message from a peer
  void _handleIncomingMessage(Uint8List data) {
    try {
      final message = _decodeMessage(data);
      _messageController.add(message);
      _logger.info(_tag, 'Received message: ${message.id}');
    } catch (e) {
      _logger.error(_tag, 'Failed to decode incoming message: $e');
    }
  }
  
  /// Encode a message for transmission
  Uint8List _encodeMessage(BitChatMessage message) {
    final json = message.toJson();
    final jsonString = json.toString();
    return Uint8List.fromList(jsonString.codeUnits);
  }
  
  /// Decode a received message
  BitChatMessage _decodeMessage(Uint8List data) {
    final jsonString = String.fromCharCodes(data);
    final json = Map<String, dynamic>.from(
      jsonString as Map<String, dynamic>,
    );
    return BitChatMessage.fromJson(json);
  }
  
  /// Dispose resources
  void dispose() {
    _messageController.close();
    disconnect();
  }
}
