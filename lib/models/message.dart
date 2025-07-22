enum MessageType { user, bot, emergency, welcome }

class ChatMessage {
  final String id;
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final bool isEmergency;
  final List<String>? steps; // For step-by-step remedies
  final String? severity;    // Severity level (e.g., Mild, Moderate, Severe)
  final String? timeLimit;   // Recommended time limit for action

  ChatMessage({
    required this.id,
    required this.text,
    required this.type,
    DateTime? timestamp,
    this.isEmergency = false,
    this.steps,
    this.severity,
    this.timeLimit,
  }) : timestamp = timestamp ?? DateTime.now();

  // Factory constructor for welcome message
  factory ChatMessage.welcome() {
    return ChatMessage(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      text: '🙏 Namaste! I\'m your Ayurvedic First-Aid assistant. How can I help you today?',
      type: MessageType.welcome,
    );
  }

  // Factory constructor for user message
  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      type: MessageType.user,
    );
  }

  // Factory constructor for bot message
  factory ChatMessage.bot(
    String text, {
    bool isEmergency = false,
    List<String>? steps,
    String? severity,
    String? timeLimit,
  }) {
    return ChatMessage(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      type: isEmergency ? MessageType.emergency : MessageType.bot,
      isEmergency: isEmergency,
      steps: steps,
      severity: severity,
      timeLimit: timeLimit,
    );
  }

  // Factory constructor for emergency message
  factory ChatMessage.emergency(
    String text, {
    String? severity,
    String? timeLimit,
  }) {
    return ChatMessage(
      id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      type: MessageType.emergency,
      isEmergency: true,
      severity: severity,
      timeLimit: timeLimit,
    );
  }

  // Helper method to check if message has severity info
  bool get hasSeverity => severity != null && severity!.isNotEmpty;

  // Helper method to check if message has time limit info
  bool get hasTimeLimit => timeLimit != null && timeLimit!.isNotEmpty;
}