import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Direct unsigned uploads. Only public configuration belongs in the app.
class CloudinaryService {
  CloudinaryService({http.Client Function()? clientFactory})
    : _clientFactory = clientFactory ?? http.Client.new;

  static const cloudName = 'lkualbj6';
  static const uploadPreset = 'foundly_images';
  static const maxImageBytes = 10 * 1024 * 1024;
  final http.Client Function() _clientFactory;

  Future<({String imageUrl, String storagePath})> uploadImage({
    required XFile imageFile,
    required String itemId,
  }) async {
    final size = await imageFile.length();
    if (size == 0) {
      throw Exception('This photo is empty. Please choose another image.');
    }
    if (size > maxImageBytes) {
      throw Exception('Please choose a photo of 10 MB or smaller.');
    }

    final request =
        http.MultipartRequest(
            'POST',
            Uri.https('api.cloudinary.com', '/v1_1/$cloudName/image/upload'),
          )
          ..fields['upload_preset'] = uploadPreset
          ..fields['context'] = 'itemId=$itemId'
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              await imageFile.readAsBytes(),
              filename: imageFile.name.isEmpty ? 'item-photo' : imageFile.name,
            ),
          );

    final client = _clientFactory();
    try {
      // Include reading the response body in the timeout, and close the client
      // even on timeout so an upload cannot keep running in the background.
      final response = await (() async {
        final stream = await client.send(request);
        return http.Response.fromStream(stream);
      })().timeout(const Duration(seconds: 60));

      Map<String, dynamic> data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) throw const FormatException();
        data = decoded;
      } on FormatException {
        throw Exception('Photo upload failed. Please try again.');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = data['error'];
        final message = error is Map ? error['message'] : null;
        throw Exception(
          message is String
              ? 'Photo upload failed: $message'
              : 'Photo upload failed. Please try again.',
        );
      }

      final imageUrl = data['secure_url'];
      final publicId = data['public_id'];
      // Match the preset's random public IDs and the Firestore validator.
      if (imageUrl is! String ||
          publicId is! String ||
          publicId.length > 289 ||
          !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(publicId) ||
          !RegExp(
            '^https://res[.]cloudinary[.]com/$cloudName/image/upload/'
            'v[0-9]+/$publicId[.](jpg|jpeg|png|webp)\$',
          ).hasMatch(imageUrl)) {
        throw Exception('Photo upload returned an invalid image. Try again.');
      }

      return (imageUrl: imageUrl, storagePath: 'cloudinary:$publicId');
    } on TimeoutException {
      throw Exception('Photo upload timed out. Please try again.');
    } on http.ClientException {
      throw Exception('Could not upload the photo. Check your connection.');
    } finally {
      client.close();
    }
  }
}
