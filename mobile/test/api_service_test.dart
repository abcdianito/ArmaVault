import 'package:flutter_test/flutter_test.dart';
import 'package:firearms_catalog/services/api_service.dart';

void main() {
  test('detects and decodes data-uri images', () {
    const dataUri = 'data:image/png;base64,AAAA';

    expect(ApiService.isDataUri(dataUri), isTrue);
    expect(ApiService.decodeImageBytes(dataUri), isNotNull);
    expect(ApiService.decodeImageBytes(dataUri)!.length, greaterThan(0));
  });
}
