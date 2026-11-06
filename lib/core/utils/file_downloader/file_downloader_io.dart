import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

Future<String?> downloadFileBytes({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) async {
  try {
    final userProfile = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '.';
    final downloadsDir = Directory('$userProfile\\Downloads');
    final targetDir = downloadsDir.existsSync() ? downloadsDir : Directory.current;
    final file = File('${targetDir.path}\\$filename');
    final u8list = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    await file.writeAsBytes(u8list);
    return file.path;
  } catch (e) {
    final fallbackFile = File(filename);
    final u8list = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    await fallbackFile.writeAsBytes(u8list);
    return fallbackFile.path;
  }
}

Future<String?> downloadFileText({
  required String text,
  required String filename,
  required String mimeType,
}) async {
  final bytes = utf8.encode(text);
  return downloadFileBytes(
    bytes: bytes,
    filename: filename,
    mimeType: mimeType,
  );
}
