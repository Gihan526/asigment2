import 'package:flutter_test/flutter_test.dart';
import 'package:asigment2/models/lost_item.dart';

void main() {
  group('LostItem Model Tests', () {
    test('serializes to Map correctly for Firebase Realtime Database', () {
      final item = LostItem(
        id: 'item_123',
        title: 'Earbud',
        location: 'Lecture Room 5',
        description: 'Black Sony earbud left on desk 4',
        contactInfo: 'Left with Security Desk',
        imageUrl: 'https://firebasestorage.googleapis.com/test.jpg',
        storagePath: 'lost_items/item_123.jpg',
        userId: 'user_456',
        userName: 'Gihan',
        userEmail: 'gihan@campus.edu',
        createdAt: 1726485000000,
        isClaimed: false,
      );

      final map = item.toMap();

      expect(map['id'], 'item_123');
      expect(map['title'], 'Earbud');
      expect(map['location'], 'Lecture Room 5');
      expect(map['description'], 'Black Sony earbud left on desk 4');
      expect(map['contactInfo'], 'Left with Security Desk');
      expect(map['imageUrl'], 'https://firebasestorage.googleapis.com/test.jpg');
      expect(map['storagePath'], 'lost_items/item_123.jpg');
      expect(map['userId'], 'user_456');
      expect(map['userName'], 'Gihan');
      expect(map['userEmail'], 'gihan@campus.edu');
      expect(map['createdAt'], 1726485000000);
      expect(map['isClaimed'], false);
    });

    test('deserializes from Realtime Database Map correctly', () {
      final map = {
        'title': 'Earbud',
        'location': 'Lecture Room 5',
        'description': 'White wireless earbud',
        'contactInfo': 'Email me',
        'imageUrl': 'https://firebasestorage.googleapis.com/photo.jpg',
        'storagePath': 'lost_items/photo.jpg',
        'userId': 'user_789',
        'userName': 'Jane Doe',
        'userEmail': 'jane@campus.edu',
        'createdAt': 1726486000000,
        'isClaimed': true,
      };

      final item = LostItem.fromMap('item_999', map);

      expect(item.id, 'item_999');
      expect(item.title, 'Earbud');
      expect(item.location, 'Lecture Room 5');
      expect(item.description, 'White wireless earbud');
      expect(item.contactInfo, 'Email me');
      expect(item.imageUrl, 'https://firebasestorage.googleapis.com/photo.jpg');
      expect(item.storagePath, 'lost_items/photo.jpg');
      expect(item.userId, 'user_789');
      expect(item.userName, 'Jane Doe');
      expect(item.userEmail, 'jane@campus.edu');
      expect(item.createdAt, 1726486000000);
      expect(item.isClaimed, true);
    });

    test('copyWith updates specified fields only', () {
      final original = LostItem(
        id: 'item_1',
        title: 'Earbud',
        location: 'Lecture Room 5',
        imageUrl: 'https://example.com/img1.jpg',
        userId: 'u1',
        userName: 'User 1',
        userEmail: 'u1@test.com',
        createdAt: 1000,
      );

      final updated = original.copyWith(
        location: 'Lecture Room 6',
        isClaimed: true,
      );

      expect(updated.id, 'item_1');
      expect(updated.title, 'Earbud');
      expect(updated.location, 'Lecture Room 6');
      expect(updated.isClaimed, true);
      expect(updated.imageUrl, 'https://example.com/img1.jpg');
    });
  });
}
