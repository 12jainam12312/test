import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';

class DoctorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Submit doctor application
  static Future<void> submitDoctorApplication({
    required String uid,
    required String specialization,
    required String experience,
    required String medicalLicense,
    required List<String> certificates,
    required List<File> documents,
  }) async {
    try {
      // Upload documents to Firebase Storage
      List<String> documentUrls = [];
      
      for (int i = 0; i < documents.length; i++) {
        final file = documents[i];
        final ref = _storage.ref().child('doctor_documents/$uid/document_$i.jpg');
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        documentUrls.add(downloadUrl);
      }

      // Create doctor profile
      final doctor = DoctorModel(
        uid: uid,
        specialization: specialization,
        experience: experience,
        medicalLicense: medicalLicense,
        certificates: certificates,
        documentUrls: documentUrls,
        appliedAt: DateTime.now(),
      );

      await _firestore.collection('doctors').doc(uid).set(doctor.toMap());
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  // Get doctor profile
  static Future<DoctorModel?> getDoctorProfile(String uid) async {
    try {
      final doc = await _firestore.collection('doctors').doc(uid).get();
      if (doc.exists) {
        return DoctorModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting doctor profile: $e');
      return null;
    }
  }

  // Check if doctor is approved
  static Future<bool> isDoctorApproved(String uid) async {
    try {
      final doctor = await getDoctorProfile(uid);
      return doctor?.status == DoctorStatus.approved;
    } catch (e) {
      return false;
    }
  }

  // Get pending doctors (for admin)
  static Future<List<DoctorModel>> getPendingDoctors() async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('status', isEqualTo: 'pending')
          .orderBy('appliedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting pending doctors: $e');
      return [];
    }
  }

  // Approve doctor (admin function)
  static Future<void> approveDoctor(String uid) async {
    await _firestore.collection('doctors').doc(uid).update({
      'status': 'approved',
      'approvedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Reject doctor (admin function)
  static Future<void> rejectDoctor(String uid, String reason) async {
    await _firestore.collection('doctors').doc(uid).update({
      'status': 'rejected',
      'rejectionReason': reason,
    });
  }

  // Update doctor rating after consultation
  static Future<void> updateDoctorRating(String doctorId, double newRating) async {
    await _firestore.runTransaction((transaction) async {
      final doctorDoc = await transaction.get(_firestore.collection('doctors').doc(doctorId));
      
      if (doctorDoc.exists) {
        final data = doctorDoc.data()!;
        final currentRating = (data['rating'] ?? 0.0).toDouble();
        final totalConsultations = (data['totalConsultations'] ?? 0) + 1;
        
        // Calculate new average rating
        final updatedRating = ((currentRating * (totalConsultations - 1)) + newRating) / totalConsultations;
        
        transaction.update(doctorDoc.reference, {
          'rating': updatedRating,
          'totalConsultations': totalConsultations,
        });
      }
    });
  }

  // Get doctor's earnings
  static Future<int> getDoctorEarnings(String doctorId) async {
    try {
      final consultationsSnapshot = await _firestore
          .collection('consultations')
          .where('doctorId', isEqualTo: doctorId)
          .where('isCompleted', isEqualTo: true)
          .get();

      int totalEarnings = 0;
      for (var doc in consultationsSnapshot.docs) {
        totalEarnings += (doc.data()['creditsCharged'] as int? ?? 0);
      }

      return totalEarnings;
    } catch (e) {
      print('Error calculating earnings: $e');
      return 0;
    }
  }

  // Get doctor's consultation history
  static Future<List<Consultation>> getDoctorConsultations(String doctorId) async {
    try {
      final querySnapshot = await _firestore
          .collection('consultations')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Consultation.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting doctor consultations: $e');
      return [];
    }
  }
}