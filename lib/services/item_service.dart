import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/lost_item.dart';
import 'cloudinary_service.dart';

/// Service handling all CRUD operations for lost/found items:
/// - Cloudinary for new photos; Firebase Storage cleanup for legacy photos.
/// - Cloud Firestore for saving, listening to, updating, and deleting item records.
class ItemService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinary = CloudinaryService();

  CollectionReference<Map<String, dynamic>> get _itemsRef =>
      _database.collection('items');

  /// Upload a photo and return its HTTPS URL and provider-prefixed identifier.
  Future<({String imageUrl, String storagePath})> _uploadImage({
    required XFile imageFile,
    required String itemId,
  }) => _cloudinary.uploadImage(imageFile: imageFile, itemId: itemId);

  /// Clean up legacy photos. Cloudinary deletion requires a trusted backend.
  Future<void> _deleteStorageFile(String storagePath) async {
    if (storagePath.trim().isEmpty) return;
    if (storagePath.startsWith('cloudinary:')) {
      // Never embed a Cloudinary API secret in a mobile app for deletion.
      debugPrint('Cloudinary photo retained in Media Library: $storagePath');
      return;
    }
    try {
      await _storage.ref(storagePath).delete();
    } catch (e) {
      debugPrint('Warning: Could not delete storage file at $storagePath: $e');
    }
  }

  void _validateDetails(
    String title,
    String location,
    String description,
    String contactInfo,
  ) {
    if (title.trim().isEmpty ||
        title.trim().length > 200 ||
        location.trim().isEmpty ||
        location.trim().length > 200) {
      throw ArgumentError(
        'Title and location must contain 1 to 200 characters.',
      );
    }
    if (description.trim().length > 5000 || contactInfo.trim().length > 2000) {
      throw ArgumentError(
        'Details must be at most 5000 characters and contact instructions at most 2000.',
      );
    }
  }

  /// CREATE: Post a newly found item with picture, place, title, and contact details.
  Future<LostItem> createItem({
    required String title,
    required String location,
    required String description,
    required String contactInfo,
    required XFile imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to post an item.');
    }

    _validateDetails(title, location, description, contactInfo);

    // Allocate the document ID before uploading its photo.
    final newRef = _itemsRef.doc();
    final itemId = newRef.id;

    // 1. Upload photo to Cloudinary
    final uploadResult = await _uploadImage(
      imageFile: imageFile,
      itemId: itemId,
    );

    // 2. Prepare item object
    final newItem = LostItem(
      id: itemId,
      title: title.trim(),
      location: location.trim(),
      description: description.trim(),
      contactInfo: contactInfo.trim(),
      imageUrl: uploadResult.imageUrl,
      storagePath: uploadResult.storagePath,
      userId: user.uid,
      userName: user.displayName ?? (user.email?.split('@').first ?? 'Student'),
      userEmail: user.email ?? '',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      isClaimed: false,
    );

    // 3. Save JSON in Cloud Firestore at /items/{itemId}
    try {
      await newRef.set({
        ...newItem.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await _deleteStorageFile(uploadResult.storagePath);
      rethrow;
    }

    return newItem;
  }

  /// READ: Real-time stream of all items from Firestore, newest first.
  Stream<List<LostItem>> getItemsStream() {
    return _itemsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LostItem.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// UPDATE: Modify details of an existing item, with optional new photo upload.
  Future<void> updateItem({
    required LostItem originalItem,
    required String title,
    required String location,
    required String description,
    required String contactInfo,
    XFile? newImageFile,
  }) async {
    _validateDetails(title, location, description, contactInfo);
    String imageUrl = originalItem.imageUrl;
    String storagePath = originalItem.storagePath;

    // If the student selected a replacement photo, upload new and delete old
    if (newImageFile != null) {
      final uploadResult = await _uploadImage(
        imageFile: newImageFile,
        itemId: originalItem.id,
      );

      imageUrl = uploadResult.imageUrl;
      storagePath = uploadResult.storagePath;
    }

    final updatedData = {
      'title': title.trim(),
      'location': location.trim(),
      'description': description.trim(),
      'contactInfo': contactInfo.trim(),
      'imageUrl': imageUrl,
      'storagePath': storagePath,
    };

    try {
      await _itemsRef.doc(originalItem.id).update(updatedData);
    } catch (_) {
      if (newImageFile != null) await _deleteStorageFile(storagePath);
      rethrow;
    }

    // Keep the previous photo until Firestore accepts the replacement.
    if (newImageFile != null) {
      await _deleteStorageFile(originalItem.storagePath);
    }
  }

  /// UPDATE: Toggle claimed / returned status
  Future<void> toggleClaimedStatus({
    required String itemId,
    required bool isClaimed,
  }) async {
    await _itemsRef.doc(itemId).update({'isClaimed': !isClaimed});
  }

  /// DELETE: Remove the post and clean up its photo when the provider allows it.
  Future<void> deleteItem(LostItem item) async {
    // Delete the document first so a denied write cannot remove its photo.
    await _itemsRef.doc(item.id).delete();
    await _deleteStorageFile(item.storagePath);
  }
}
