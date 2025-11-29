// lib/services/file_service_stub.dart
import 'dart:typed_data';

// This is a fallback version that does nothing. It will be used on platforms
// that are neither web nor mobile (e.g., desktop, if not configured).
class FileService {
  static Future<void> openFile(Uint8List bytes, String fileName) async {
    throw UnsupportedError('File opening is not supported on this platform.');
  }
}