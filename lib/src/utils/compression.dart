import 'dart:typed_data';
import 'dart:convert';

/// Utility for compressing and decompressing BitChat messages
class CompressionUtil {
  /// Compress a string message using simple compression
  static Uint8List compress(String message) {
    try {
      // Convert to UTF-8 bytes
      final bytes = utf8.encode(message);
      
      // Simple compression: find repeated patterns
      final compressed = _compressBytes(bytes);
      
      return compressed;
    } catch (e) {
      // If compression fails, return original bytes
      return Uint8List.fromList(utf8.encode(message));
    }
  }
  
  /// Decompress a compressed message
  static String decompress(Uint8List compressedData) {
    try {
      // Simple decompression
      final decompressed = _decompressBytes(compressedData);
      
      // Convert back to string
      return utf8.decode(decompressed);
    } catch (e) {
      // If decompression fails, try to decode as UTF-8 directly
      return utf8.decode(compressedData);
    }
  }
  
  /// Simple byte compression (find repeated patterns)
  static Uint8List _compressBytes(Uint8List bytes) {
    if (bytes.length < 4) return bytes;
    
    final compressed = <int>[];
    int i = 0;
    
    while (i < bytes.length) {
      // Look for repeated patterns
      int repeatCount = 1;
      int patternLength = 1;
      
      // Find the longest repeated pattern starting at position i
      for (int len = 1; len <= 8 && i + len * 2 <= bytes.length; len++) {
        for (int count = 2; count <= 255 && i + len * count <= bytes.length; count++) {
          bool isRepeated = true;
          for (int k = 0; k < len; k++) {
            if (bytes[i + k] != bytes[i + len + k]) {
              isRepeated = false;
              break;
            }
          }
          
          if (isRepeated && count > repeatCount) {
            repeatCount = count;
            patternLength = len;
          }
        }
      }
      
      if (repeatCount > 1 && patternLength > 1) {
        // Add compression marker
        compressed.add(0xFF); // Special marker
        compressed.add(patternLength);
        compressed.add(repeatCount);
        
        // Add the pattern
        for (int j = 0; j < patternLength; j++) {
          compressed.add(bytes[i + j]);
        }
        
        i += patternLength * repeatCount;
      } else {
        // No compression, add single byte
        compressed.add(bytes[i]);
        i++;
      }
    }
    
    return Uint8List.fromList(compressed);
  }
  
  /// Decompress compressed bytes
  static Uint8List _decompressBytes(Uint8List compressed) {
    final decompressed = <int>[];
    int i = 0;
    
    while (i < compressed.length) {
      if (compressed[i] == 0xFF && i + 2 < compressed.length) {
        // Compression marker found
        final patternLength = compressed[i + 1];
        final repeatCount = compressed[i + 2];
        
        if (i + 2 + patternLength <= compressed.length) {
          // Extract the pattern
          final pattern = compressed.sublist(i + 3, i + 3 + patternLength);
          
          // Repeat the pattern
          for (int j = 0; j < repeatCount; j++) {
            decompressed.addAll(pattern);
          }
          
          i += 3 + patternLength;
        } else {
          // Invalid compression data, add as-is
          decompressed.add(compressed[i]);
          i++;
        }
      } else {
        // Regular byte, add as-is
        decompressed.add(compressed[i]);
        i++;
      }
    }
    
    return Uint8List.fromList(decompressed);
  }
  
  /// Get compression ratio
  static double getCompressionRatio(String original, Uint8List compressed) {
    final originalBytes = utf8.encode(original).length;
    final compressedBytes = compressed.length;
    
    if (originalBytes == 0) return 0.0;
    
    return (1.0 - (compressedBytes / originalBytes)) * 100.0;
  }
  
  /// Check if compression is beneficial
  static bool isCompressionBeneficial(String message) {
    final originalBytes = utf8.encode(message).length;
    final compressed = compress(message);
    
    return compressed.length < originalBytes;
  }
}
