import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/lost_item.dart';

/// Service handling all CRUD operations for lost/found items:
/// - Firebase Storage for uploading and removing item photos.
/// - Firebase Realtime Database for saving, listening to, updating, and deleting item records.
class ItemService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference get _itemsRef => _database.ref('items');

  /// Upload an image to Firebase Storage and return the download URL and storage path.
  Future<({String imageUrl, String storagePath})> _uploadImage({
    required XFile imageFile,
    required String itemId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'lost_items/${itemId}_$timestamp.jpg';
    final storageRef = _storage.ref().child(storagePath);

    final bytes = await imageFile.readAsBytes();
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'itemId': itemId},
    );

    final uploadTask = storageRef.putData(bytes, metadata);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return (imageUrl: downloadUrl, storagePath: storagePath);
  }

  /// Delete an image from Firebase Storage if it exists.
  Future<void> _deleteStorageFile(String storagePath) async {
    if (storagePath.trim().isEmpty) return;
    try {
      await _storage.ref(storagePath).delete();
    } catch (e) {
      debugPrint('Warning: Could not delete storage file at $storagePath: $e');
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

    // Generate a unique ID from Realtime Database
    final newRef = _itemsRef.push();
    final itemId = newRef.key;
    if (itemId == null) {
      throw Exception('Could not generate unique item ID from database.');
    }

    // 1. Upload photo to Firebase Storage
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

    // 3. Save JSON in Firebase Realtime Database at /items/{itemId}
    await newRef.set(newItem.toMap());

    return newItem;
  }

  /// READ: Real-time stream of all items from Realtime Database, newest first.
  Stream<List<LostItem>> getItemsStream() {
    return _itemsRef.onValue.map((event) {
      final snapshotValue = event.snapshot.value;
      if (snapshotValue == null) return <LostItem>[];

      try {
        final dataMap = Map<dynamic, dynamic>.from(snapshotValue as Map);
        final items = <LostItem>[];

        dataMap.forEach((key, value) {
          if (value is Map) {
            items.add(LostItem.fromMap(key.toString(), value));
          }
        });

        // Sort descending by creation timestamp (newest items first)
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      } catch (e) {
        debugPrint('Error parsing items stream: $e');
        return <LostItem>[];
      }
    });
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
    String imageUrl = originalItem.imageUrl;
    String storagePath = originalItem.storagePath;

    // If the student selected a replacement photo, upload new and delete old
    if (newImageFile != null) {
      final uploadResult = await _uploadImage(
        imageFile: newImageFile,
        itemId: originalItem.id,
      );

      // Delete old photo in background
      await _deleteStorageFile(originalItem.storagePath);

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

    await _itemsRef.child(originalItem.id).update(updatedData);
  }

  /// UPDATE: Toggle claimed / returned status
  Future<void> toggleClaimedStatus({
    required String itemId,
    required bool isClaimed,
  }) async {
    await _itemsRef.child(itemId).update({'isClaimed': !isClaimed});
  }

  /// DELETE: Delete item record from Realtime Database and photo from Firebase Storage.
  Future<void> deleteItem(LostItem item) async {
    // 1. Delete image file from Firebase Storage
    await _deleteStorageFile(item.storagePath);

    // 2. Remove record from Firebase Realtime Database
    await _itemsRef.child(item.id).remove();
  }
}
