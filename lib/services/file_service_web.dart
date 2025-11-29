// lib/services/file_service_web.dart
// ignore_for_file: unused_local_variable

import 'dart:typed_data';
import 'dart:html' as html;
// This version is specifically for the web.
class FileService {
static Future<void> openFile(Uint8List bytes, String fileName) async {
final blob = html.Blob([bytes]);
final url = html.Url.createObjectUrlFromBlob(blob);
final anchor = html.AnchorElement(href: url)
..setAttribute("download", fileName)
..click();
html.Url.revokeObjectUrl(url);
}
}