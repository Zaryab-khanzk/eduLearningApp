// lib/services/file_service_mobile.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

// This version is specifically for mobile (Android/iOS).
class FileService {
  static Future<void> openFile(Uint8List bytes, String fileName) async {
    // 1. Get a temporary directory to save the file
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';

    // 2. Write the bytes to a temporary file
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // 3. Use open_filex to open the file with the default app
    await OpenFilex.open(filePath);
  }
}
