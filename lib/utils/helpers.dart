import 'package:flutter/material.dart';
import 'constants.dart';

class AppHelpers {
  // Format timestamp for messages
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  // Get formatted time (HH:MM)
  static String getFormattedTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  // Check if message contains emergency keywords
  static bool isEmergencyMessage(String message) {
    final lowerMessage = message.toLowerCase();
    return AppConstants.emergencyKeywords.any(
      (keyword) => lowerMessage.contains(keyword)
    );
  }
  
  // Extract steps from response text
  static List<String> extractSteps(String text) {
    final lines = text.split('\n');
    List<String> steps = [];
    
    for (String line in lines) {
      String trimmed = line.trim();
      if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
        steps.add(trimmed);
      }
    }
    
    return steps;
  }
  
  // Clean response text from special tokens
  static String cleanResponseText(String text) {
    return text
        .replaceAll(RegExp(r'<\|.*?\|>'), '')
        .replaceAll(RegExp(r'\[INST\]|\[/INST\]'), '')
        .replaceAll(RegExp(r'<s>|</s>'), '')
        .trim();
  }
  
  // Generate unique message ID
  static String generateMessageId(String prefix) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  // Show snackbar with custom styling
  static void showCustomSnackBar(
    BuildContext context, 
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // Validate user input
  static String? validateUserInput(String input) {
    if (input.trim().isEmpty) {
      return 'Please enter your health concern';
    }
    if (input.trim().length < 3) {
      return 'Please provide more details';
    }
    if (input.length > 500) {
      return 'Message is too long. Please keep it under 500 characters';
    }
    return null; // Valid input
  }
  
  // Get appropriate icon for message type
  static IconData getIconForHealthIssue(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('head') || lowerMessage.contains('migraine')) {
      return Icons.psychology;
    } else if (lowerMessage.contains('burn') || lowerMessage.contains('fire')) {
      return Icons.local_fire_department;
    } else if (lowerMessage.contains('stomach') || lowerMessage.contains('digest')) {
      return Icons.dining;
    } else if (lowerMessage.contains('cold') || lowerMessage.contains('cough')) {
      return Icons.sick;
    } else if (lowerMessage.contains('skin') || lowerMessage.contains('rash')) {
      return Icons.face;
    } else if (lowerMessage.contains('bite') || lowerMessage.contains('insect')) {
      return Icons.pest_control;
    } else {
      return Icons.healing;
    }
  }
  
  // Vibrate device for emergency messages (requires vibration permission)
  static void vibrateForEmergency() {
    // Implementation depends on haptic_feedback package
    // HapticFeedback.heavyImpact();
  }
  
  // Format large numbers (for future analytics)
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}