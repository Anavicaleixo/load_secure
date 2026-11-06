// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';

Future<String?> downloadFileBytes({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) async {
  final u8list = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final blob = html.Blob([u8list], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
  return 'Downloads do navegador';
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
