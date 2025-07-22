import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user profile after signup
  static Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required UserRole role,
  }) async {
    final user = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());
  }

  // Get user profile
  static Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user credits
  static Future<void> updateCredits(String uid, int newCredits) async {
    await _firestore.collection('users').doc(uid).update({
      'credits': newCredits,
    });
  }

  // Deduct credits (for consultations)
  static Future<bool> deductCredits(String uid, int amount) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(_firestore.collection('users').doc(uid));
        
        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final currentCredits = userDoc.data()!['credits'] as int;
        
        if (currentCredits < amount) {
          return false; // Insufficient credits
        }

        transaction.update(userDoc.reference, {
          'credits': currentCredits - amount,
        });

        return true;
      });
    } catch (e) {
      print('Error deducting credits: $e');
      return false;
    }
  }

  // Add credits (for doctors earning)
  static Future<void> addCredits(String uid, int amount) async {
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(_firestore.collection('users').doc(uid));
      
      if (userDoc.exists) {
        final currentCredits = userDoc.data()!['credits'] as int;
        transaction.update(userDoc.reference, {
          'credits': currentCredits + amount,
        });
      }
    });
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Update last login
  static Future<void> updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get all doctors (for patient to choose)
  static Future<List<UserModel>> getApprovedDoctors() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      List<UserModel> doctors = [];
      
      for (var doc in querySnapshot.docs) {
        final user = UserModel.fromMap(doc.data());
        
        // Check if doctor is approved
        final doctorDoc = await _firestore.collection('doctors').doc(user.uid).get();
        if (doctorDoc.exists) {
          final doctorData = DoctorModel.fromMap(doctorDoc.data()!);
          if (doctorData.status == DoctorStatus.approved) {
            doctors.add(user);
          }
        }
      }

      return doctors;
    } catch (e) {
      print('Error getting approved doctors: $e');
      return [];
    }
  }

  // Check if user has sufficient credits
  static Future<bool> hasCredits(String uid, int requiredAmount) async {
    try {
      final user = await getUserProfile(uid);
      return user != null && user.credits >= requiredAmount;
    } catch (e) {
      return false;
    }
  }
}