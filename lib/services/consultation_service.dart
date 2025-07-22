import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class ConsultationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Start a consultation
  static Future<String?> startConsultation({
    required String patientId,
    required String doctorId,
    required String problem,
    required int creditsToCharge,
  }) async {
    try {
      // Check if patient has enough credits
      final hasCredits = await UserService.hasCredits(patientId, creditsToCharge);
      if (!hasCredits) {
        throw Exception('Insufficient credits');
      }

      // Deduct credits from patient
      final success = await UserService.deductCredits(patientId, creditsToCharge);
      if (!success) {
        throw Exception('Failed to deduct credits');
      }

      // Create consultation
      final consultationId = _firestore.collection('consultations').doc().id;
      final consultation = Consultation(
        id: consultationId,
        patientId: patientId,
        doctorId: doctorId,
        problem: problem,
        creditsCharged: creditsToCharge,
        startTime: DateTime.now(),
      );

      await _firestore.collection('consultations').doc(consultationId).set(consultation.toMap());

      return consultationId;
    } catch (e) {
      print('Error starting consultation: $e');
      return null;
    }
  }

  // Complete consultation with prescription
  static Future<void> completeConsultation({
    required String consultationId,
    required String prescription,
    required String doctorId,
    required int creditsEarned,
  }) async {
    try {
      // Update consultation
      await _firestore.collection('consultations').doc(consultationId).update({
        'prescription': prescription,
        'endTime': DateTime.now().millisecondsSinceEpoch,
        'isCompleted': true,
      });

      // Add credits to doctor
      await UserService.addCredits(doctorId, creditsEarned);
    } catch (e) {
      print('Error completing consultation: $e');
      throw Exception('Failed to complete consultation');
    }
  }

  // Get consultation details
  static Future<Consultation?> getConsultation(String consultationId) async {
    try {
      final doc = await _firestore.collection('consultations').doc(consultationId).get();
      if (doc.exists) {
        return Consultation.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting consultation: $e');
      return null;
    }
  }

  // Get patient's consultation history
  static Future<List<Consultation>> getPatientConsultations(String patientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('consultations')
          .where('patientId', isEqualTo: patientId)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Consultation.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting patient consultations: $e');
      return [];
    }
  }

  // Rate consultation
  static Future<void> rateConsultation({
    required String consultationId,
    required String doctorId,
    required double rating,
    String? feedback,
  }) async {
    try {
      // Update consultation with rating
      await _firestore.collection('consultations').doc(consultationId).update({
        'rating': rating,
        'feedback': feedback,
      });

      // Update doctor's overall rating
      await DoctorService.updateDoctorRating(doctorId, rating);
    } catch (e) {
      print('Error rating consultation: $e');
      throw Exception('Failed to rate consultation');
    }
  }

  // Get active consultations for doctor
  static Future<List<Consultation>> getActiveDoctorConsultations(String doctorId) async {
    try {
      final querySnapshot = await _firestore
          .collection('consultations')
          .where('doctorId', isEqualTo: doctorId)
          .where('isCompleted', isEqualTo: false)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Consultation.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting active consultations: $e');
      return [];
    }
  }

  // Create consultation chat room
  static Future<void> createConsultationChatRoom(String consultationId, String patientId, String doctorId) async {
    try {
      await _firestore.collection('consultation_chats').doc(consultationId).set({
        'consultationId': consultationId,
        'patientId': patientId,
        'doctorId': doctorId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'isActive': true,
      });
    } catch (e) {
      print('Error creating chat room: $e');
    }
  }

  // Send message in consultation chat
  static Future<void> sendConsultationMessage({
    required String consultationId,
    required String senderId,
    required String message,
    required bool isDoctor,
  }) async {
    try {
      await _firestore
          .collection('consultation_chats')
          .doc(consultationId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'message': message,
        'isDoctor': isDoctor,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Get consultation messages
  static Stream<QuerySnapshot> getConsultationMessages(String consultationId) {
    return _firestore
        .collection('consultation_chats')
        .doc(consultationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}