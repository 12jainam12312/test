enum UserRole { patient, doctor, admin }

enum DoctorStatus { pending, approved, rejected }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final int credits;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.credits = 1000, // Initial credits
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.patient,
      ),
      credits: map['credits'] ?? 1000,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLogin: map['lastLogin'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.toString().split('.').last,
      'credits': credits,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin?.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    int? credits,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      credits: credits ?? this.credits,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class DoctorModel {
  final String uid;
  final String specialization;
  final String experience;
  final String medicalLicense;
  final List<String> certificates;
  final List<String> documentUrls;
  final DoctorStatus status;
  final String? rejectionReason;
  final DateTime appliedAt;
  final DateTime? approvedAt;
  final int consultationFee; // in credits
  final double rating;
  final int totalConsultations;

  DoctorModel({
    required this.uid,
    required this.specialization,
    required this.experience,
    required this.medicalLicense,
    required this.certificates,
    required this.documentUrls,
    this.status = DoctorStatus.pending,
    this.rejectionReason,
    required this.appliedAt,
    this.approvedAt,
    this.consultationFee = 15, // Default 15 credits
    this.rating = 0.0,
    this.totalConsultations = 0,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      uid: map['uid'] ?? '',
      specialization: map['specialization'] ?? '',
      experience: map['experience'] ?? '',
      medicalLicense: map['medicalLicense'] ?? '',
      certificates: List<String>.from(map['certificates'] ?? []),
      documentUrls: List<String>.from(map['documentUrls'] ?? []),
      status: DoctorStatus.values.firstWhere(
        (e) => e.toString() == 'DoctorStatus.${map['status']}',
        orElse: () => DoctorStatus.pending,
      ),
      rejectionReason: map['rejectionReason'],
      appliedAt: DateTime.fromMillisecondsSinceEpoch(map['appliedAt'] ?? 0),
      approvedAt: map['approvedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['approvedAt'])
          : null,
      consultationFee: map['consultationFee'] ?? 15,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalConsultations: map['totalConsultations'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'specialization': specialization,
      'experience': experience,
      'medicalLicense': medicalLicense,
      'certificates': certificates,
      'documentUrls': documentUrls,
      'status': status.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'appliedAt': appliedAt.millisecondsSinceEpoch,
      'approvedAt': approvedAt?.millisecondsSinceEpoch,
      'consultationFee': consultationFee,
      'rating': rating,
      'totalConsultations': totalConsultations,
    };
  }
}

class AyurvedicSolution {
  final String id;
  final String problem;
  final String solution;
  final String submittedBy;
  final DateTime submittedAt;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;

  AyurvedicSolution({
    required this.id,
    required this.problem,
    required this.solution,
    required this.submittedBy,
    required this.submittedAt,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  factory AyurvedicSolution.fromMap(Map<String, dynamic> map) {
    return AyurvedicSolution(
      id: map['id'] ?? '',
      problem: map['problem'] ?? '',
      solution: map['solution'] ?? '',
      submittedBy: map['submittedBy'] ?? '',
      submittedAt: DateTime.fromMillisecondsSinceEpoch(map['submittedAt'] ?? 0),
      isApproved: map['isApproved'] ?? false,
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['approvedAt'])
          : null,
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'problem': problem,
      'solution': solution,
      'submittedBy': submittedBy,
      'submittedAt': submittedAt.millisecondsSinceEpoch,
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.millisecondsSinceEpoch,
      'rejectionReason': rejectionReason,
    };
  }
}

class Consultation {
  final String id;
  final String patientId;
  final String doctorId;
  final String problem;
  final String? prescription;
  final int creditsCharged;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final double? rating;
  final String? feedback;

  Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.problem,
    this.prescription,
    required this.creditsCharged,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.rating,
    this.feedback,
  });

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      problem: map['problem'] ?? '',
      prescription: map['prescription'],
      creditsCharged: map['creditsCharged'] ?? 0,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
      rating: map['rating']?.toDouble(),
      feedback: map['feedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'problem': problem,
      'prescription': prescription,
      'creditsCharged': creditsCharged,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'rating': rating,
      'feedback': feedback,
    };
  }
}