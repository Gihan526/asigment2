import 'dart:convert';
import 'dart:typed_data';

import 'package:asigment2/services/cloudinary_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadClient extends http.BaseClient {
  UploadClient(this.handle);
  final Future<http.StreamedResponse> Function(http.BaseRequest) handle;
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      handle(request);

  @override
  void close() => closed = true;
}

http.StreamedResponse response(String body, [int status = 200]) =>
    http.StreamedResponse(Stream.value(utf8.encode(body)), status);

XFile photo([int size = 4]) =>
    XFile.fromData(Uint8List(size), path: 'campus-photo.png');

void main() {
  test(
    'uploads multipart bytes using the unsigned preset and saves its ID',
    () async {
      final client = UploadClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://api.cloudinary.com/v1_1/lkualbj6/image/upload',
        );
        final upload = request as http.MultipartRequest;
        expect(upload.fields, {
          'upload_preset': 'foundly_images',
          'context': 'itemId=item1',
        });
        expect(upload.files.single.field, 'file');
        expect(upload.files.single.filename, 'campus-photo.png');
        expect(await upload.files.single.finalize().toBytes(), Uint8List(4));
        return response(
          jsonEncode({
            'secure_url':
                'https://res.cloudinary.com/lkualbj6/image/upload/v123/random_id.png',
            'public_id': 'random_id',
          }),
        );
      });
      final result = await CloudinaryService(
        clientFactory: () => client,
      ).uploadImage(imageFile: photo(), itemId: 'item1');
      expect(result.storagePath, 'cloudinary:random_id');
      expect(result.imageUrl, endsWith('/random_id.png'));
      expect(client.closed, isTrue);
    },
  );

  test('reports rejected formats and closes the connection', () async {
    final client = UploadClient(
      (_) async =>
          response('{"error":{"message":"Image format not allowed"}}', 400),
    );
    await expectLater(
      CloudinaryService(
        clientFactory: () => client,
      ).uploadImage(imageFile: photo(), itemId: 'item1'),
      throwsA(
        predicate((e) => e.toString().contains('Image format not allowed')),
      ),
    );
    expect(client.closed, isTrue);
  });

  test(
    'rejects missing fields, wrong cloud, mismatched IDs and non-JSON',
    () async {
      for (final body in [
        '<html>Service unavailable</html>',
        '[]',
        '{}',
        '{"secure_url":"http://example.com/x.png","public_id":"x"}',
        '{"secure_url":"https://res.cloudinary.com/other/image/upload/v123/x.png","public_id":"x"}',
        '{"secure_url":"https://res.cloudinary.com/lkualbj6/image/upload/v123/y.png","public_id":"x"}',
      ]) {
        final client = UploadClient((_) async => response(body));
        await expectLater(
          CloudinaryService(
            clientFactory: () => client,
          ).uploadImage(imageFile: photo(), itemId: 'item1'),
          throwsException,
        );
        expect(client.closed, isTrue);
      }
    },
  );

  test('rejects empty and oversized images before making a request', () async {
    final service = CloudinaryService(
      clientFactory: () {
        fail('Invalid files must not start an upload');
      },
    );
    for (final size in [0, CloudinaryService.maxImageBytes + 1]) {
      await expectLater(
        service.uploadImage(imageFile: photo(size), itemId: 'item1'),
        throwsException,
      );
    }
  });

  test('reports connection errors and closes the client', () async {
    final client = UploadClient(
      (_) async => throw http.ClientException('offline'),
    );
    await expectLater(
      CloudinaryService(
        clientFactory: () => client,
      ).uploadImage(imageFile: photo(), itemId: 'item1'),
      throwsA(predicate((e) => e.toString().contains('Check your connection'))),
    );
    expect(client.closed, isTrue);
  });

  test(
    'live preset accepts a synthetic PNG',
    () async {
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aZ1cAAAAASUVORK5CYII=',
      );
      final result = await CloudinaryService().uploadImage(
        imageFile: XFile.fromData(png, path: 'foundly-upload-check.png'),
        itemId: 'integration-check',
      );
      expect(result.storagePath, startsWith('cloudinary:'));
      // This tiny test asset remains in Cloudinary; deletion needs a backend.
      // ignore: avoid_print
      print('Verified live upload: ${result.imageUrl}');
    },
    skip: !const bool.fromEnvironment('CLOUDINARY_LIVE_TEST'),
  );
}
