import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auth_service/models/user_model.dart';

class UsersManagementModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();

      // Note: Deletion of Firebase Auth user would require Firebase Admin SDK
      // or a Cloud Function. This implementation only deletes the user document.
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<UserModel> getUserByUid(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (!docSnapshot.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromMap(docSnapshot.data()!);
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }
}
