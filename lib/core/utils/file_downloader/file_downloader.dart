import 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart'
    if (dart.library.io) 'file_downloader_io.dart';

class FileDownloader {
  static Future<String?> downloadBytes({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) {
    return downloadFileBytes(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }

  static Future<String?> downloadText({
    required String text,
    required String filename,
    String mimeType = 'text/plain;charset=utf-8',
  }) {
    return downloadFileText(
      text: text,
      filename: filename,
      mimeType: mimeType,
    );
  }
}
