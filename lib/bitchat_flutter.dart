library bitchat_flutter;

// Core BitChat functionality
export 'src/bitchat_client.dart';
export 'src/bitchat_message.dart';
export 'src/bitchat_peer.dart';
export 'src/bitchat_network.dart';

// Bluetooth mesh networking
export 'src/bluetooth/mesh_network.dart';
export 'src/bluetooth/peer_discovery.dart';
export 'src/bluetooth/connection_manager.dart';

// Protocol implementation
export 'src/protocol/bitchat_protocol.dart';
export 'src/protocol/message_types.dart';
export 'src/protocol/packet_encoder.dart';

// Security and encryption
export 'src/security/noise_protocol.dart';
export 'src/security/identity_manager.dart';

// Utilities
export 'src/utils/compression.dart';
export 'src/utils/logger.dart';

// Models
export 'src/models/chat_room.dart';
export 'src/models/user_profile.dart';
