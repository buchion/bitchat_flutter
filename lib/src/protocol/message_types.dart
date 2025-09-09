/// Message types supported by the BitChat protocol
enum MessageType {
  /// Text message
  text(0x01),
  
  /// Private message
  private(0x02),
  
  /// Room join/leave notification
  room(0x03),
  
  /// Peer discovery
  discovery(0x04),
  
  /// Keep-alive ping
  ping(0x05),
  
  /// Keep-alive pong
  pong(0x06),
  
  /// File transfer
  file(0x07),
  
  /// Voice message
  voice(0x08),
  
  /// Image message
  image(0x09),
  
  /// System message
  system(0x0A);
  
  const MessageType(this.value);
  final int value;
  
  static MessageType fromValue(int value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.text,
    );
  }
}
