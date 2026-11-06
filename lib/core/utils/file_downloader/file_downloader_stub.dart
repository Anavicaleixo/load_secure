
Future<String?> downloadFileBytes({
  required List<int> bytes,
  required String filename,
  required String mimeType,
}) async {
  throw UnsupportedError('Download nao suportado nesta plataforma.');
}

Future<String?> downloadFileText({
  required String text,
  required String filename,
  required String mimeType,
}) async {
  throw UnsupportedError('Download nao suportado nesta plataforma.');
}
