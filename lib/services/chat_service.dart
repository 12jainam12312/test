import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatService {
  // Replace with your ngrok URL (get this from your Python console output)
  static const String baseUrl = 'https://2ed69e906929.ngrok-free.app'; // Update this with your ngrok URL
  
  // Language codes mapping
  static const Map<String, String> languageCodes = {
    'English': 'eng_Latn',
    'Hindi': 'hin_Deva',
    'Marathi': 'mar_Deva',
    'Gujarati': 'guj_Gujr',
    'Bengali': 'ben_Beng',
    'Tamil': 'tam_Taml',
    'Telugu': 'tel_Telu',
    'Kannada': 'kan_Knda',
    'Malayalam': 'mal_Mlym',
    'Punjabi': 'pan_Guru',
    'Odia': 'ory_Orya',
    'Assamese': 'asm_Beng',
  };
  
  static Future<ChatMessage> sendMessage(String userMessage, String language) async {
    try {
      final languageCode = languageCodes[language] ?? 'eng_Latn';
      
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': userMessage,
          'language': languageCode,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is String) {
          return ChatMessage.bot(responseData);
        } else {
          final responseText = responseData['response'] ?? 'No response text';
          final severity = responseData['severity'];
          final timeLimit = responseData['time_limit'];
          
          bool isEmergency = _isEmergencyResponse(responseText) || 
                            (severity?.toLowerCase() == 'severe');
          
          return ChatMessage.bot(
            responseText,
            isEmergency: isEmergency,
            severity: severity,
            timeLimit: timeLimit,
          );
        }
      } else {
        return ChatMessage.bot(
          '⚠️ Sorry, the server responded with an error (${response.statusCode}). Please try again later.',
          isEmergency: true,
        );
      }
    } catch (e) {
      return ChatMessage.bot(
        '⚠️ Network error: ${e.toString()}. Please check your connection and try again.',
        isEmergency: true,
      );
    }
  }
  
  static bool _isEmergencyResponse(String response) {
    final emergencyKeywords = ['severe', '🚨', 'immediate', 'emergency', 'urgent', 'serious', '⚠️'];
    return emergencyKeywords.any((keyword) => response.toLowerCase().contains(keyword));
  }
}