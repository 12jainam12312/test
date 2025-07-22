import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AyurvedicService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit Ayurvedic solution for review
  static Future<void> submitSolution({
    required String problem,
    required String solution,
    required String submittedBy,
  }) async {
    try {
      final solutionId = _firestore.collection('ayurvedic_solutions').doc().id;
      
      final ayurvedicSolution = AyurvedicSolution(
        id: solutionId,
        problem: problem,
        solution: solution,
        submittedBy: submittedBy,
        submittedAt: DateTime.now(),
      );

      await _firestore
          .collection('ayurvedic_solutions')
          .doc(solutionId)
          .set(ayurvedicSolution.toMap());
    } catch (e) {
      throw Exception('Failed to submit solution: $e');
    }
  }

  // Get pending solutions (for admin)
  static Future<List<AyurvedicSolution>> getPendingSolutions() async {
    try {
      final querySnapshot = await _firestore
          .collection('ayurvedic_solutions')
          .where('isApproved', isEqualTo: false)
          .where('rejectionReason', isNull: true)
          .orderBy('submittedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AyurvedicSolution.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting pending solutions: $e');
      return [];
    }
  }

  // Get approved solutions
  static Future<List<AyurvedicSolution>> getApprovedSolutions() async {
    try {
      final querySnapshot = await _firestore
          .collection('ayurvedic_solutions')
          .where('isApproved', isEqualTo: true)
          .orderBy('approvedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AyurvedicSolution.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting approved solutions: $e');
      return [];
    }
  }

  // Approve solution (admin function)
  static Future<void> approveSolution(String solutionId, String approvedBy) async {
    await _firestore.collection('ayurvedic_solutions').doc(solutionId).update({
      'isApproved': true,
      'approvedBy': approvedBy,
      'approvedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Reject solution (admin function)
  static Future<void> rejectSolution(String solutionId, String reason) async {
    await _firestore.collection('ayurvedic_solutions').doc(solutionId).update({
      'rejectionReason': reason,
    });
  }

  // Search approved solutions
  static Future<List<AyurvedicSolution>> searchSolutions(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('ayurvedic_solutions')
          .where('isApproved', isEqualTo: true)
          .get();

      // Filter results based on problem or solution content
      final results = querySnapshot.docs
          .map((doc) => AyurvedicSolution.fromMap(doc.data()))
          .where((solution) =>
              solution.problem.toLowerCase().contains(query.toLowerCase()) ||
              solution.solution.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return results;
    } catch (e) {
      print('Error searching solutions: $e');
      return [];
    }
  }

  // Get user's submitted solutions
  static Future<List<AyurvedicSolution>> getUserSolutions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('ayurvedic_solutions')
          .where('submittedBy', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AyurvedicSolution.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user solutions: $e');
      return [];
    }
  }

  // Get solution by ID
  static Future<AyurvedicSolution?> getSolution(String solutionId) async {
    try {
      final doc = await _firestore.collection('ayurvedic_solutions').doc(solutionId).get();
      if (doc.exists) {
        return AyurvedicSolution.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting solution: $e');
      return null;
    }
  }
}