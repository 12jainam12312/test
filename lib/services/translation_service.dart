import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // Replace with your Python translation server URL
  static const String translationUrl = 'https://your-translation-server.ngrok-free.app'; // Add your translation server URL here
  
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

  static Future<String> translateText({
    required String text,
    required String fromLang,
    required String toLang,
  }) async {
    // If both languages are same, return original text
    if (fromLang == toLang) return text;
    
    // Get language codes
    final fromCode = languageCodes[fromLang];
    final toCode = languageCodes[toLang];
    
    if (fromCode == null || toCode == null) {
      throw Exception('Unsupported language');
    }

    try {
      final response = await http.post(
        Uri.parse('$translationUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'src_lang': fromCode,
          'tgt_lang': toCode,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['translated_text'] ?? text;
      } else {
        throw Exception('Translation server error: ${response.statusCode}');
      }
    } catch (e) {
      // If translation fails, return original text
      print('Translation failed: $e');
      return text;
    }
  }

  // Helper method to translate user input to English before sending to chatbot
  static Future<String> translateToEnglish(String text, String userLanguage) async {
    if (userLanguage == 'English') return text;
    return await translateText(
      text: text,
      fromLang: userLanguage,
      toLang: 'English',
    );
  }

  // Helper method to translate chatbot response to user's language
  static Future<String> translateFromEnglish(String text, String userLanguage) async {
    if (userLanguage == 'English') return text;
    return await translateText(
      text: text,
      fromLang: 'English',
      toLang: userLanguage,
    );
  }
}