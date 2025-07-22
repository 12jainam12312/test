class AppConstants {
  // App Information
  static const String appName = 'Ayurvedic First Aid';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Natural remedies for wellness';
  
  // API Configuration
  static const String baseApiUrl = 'YOUR_GRADIO_ENDPOINT_HERE';
  static const int apiTimeoutSeconds = 30;
  
  // UI Constants
  static const double borderRadius = 16.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 36.0;
  
  // Animation Durations
  static const int typingAnimationDuration = 1500;
  static const int messageAnimationDuration = 300;
  static const int loadingDelay = 1500;
  
  // Text Constants
  static const String welcomeMessage = '🙏 Namaste! I\'m your Ayurvedic First-Aid assistant. How can I help you today?';
  static const String errorMessage = '⚠️ Sorry, I encountered an error. Please try again or consult a healthcare professional if it\'s urgent.';
  static const String inputHint = 'Describe your health concern...';
  static const String typingIndicator = 'Analyzing your query...';
  
  // Emergency Keywords
  static const List<String> emergencyKeywords = [
    'severe',
    'emergency',
    'urgent',
    'serious',
    'immediate',
    'critical',
    'danger',
    'help'
  ];
  
  // Common Health Issues (for quick actions)
  static const List<Map<String, dynamic>> commonIssues = [
    {
      'title': 'Headache',
      'icon': 'psychology',
      'query': 'I have a headache',
      'keywords': ['headache', 'migraine', 'head pain']
    },
    {
      'title': 'Burn',
      'icon': 'local_fire_department',
      'query': 'What to do for a burn?',
      'keywords': ['burn', 'burning', 'scalded']
    },
    {
      'title': 'Indigestion',
      'icon': 'dining',
      'query': 'Help with indigestion',
      'keywords': ['indigestion', 'stomach', 'acidity', 'gas']
    },
    {
      'title': 'Insect Bite',
      'icon': 'pest_control',
      'query': 'Remedy for insect bite',
      'keywords': ['insect', 'bite', 'sting', 'mosquito']
    },
    {
      'title': 'Cold & Cough',
      'icon': 'sick',
      'query': 'Help with cold and cough',
      'keywords': ['cold', 'cough', 'fever', 'sore throat']
    },
    {
      'title': 'Skin Issues',
      'icon': 'face',
      'query': 'Help with skin problems',
      'keywords': ['skin', 'rash', 'eczema', 'itching']
    }
  ];
  
  // Disclaimer Text
  static const String disclaimerText = 
      'This app provides traditional Ayurvedic remedies for common health issues. '
      'Always consult a qualified healthcare professional for serious conditions.\n\n'
      '⚠️ This is not a substitute for professional medical advice.';
}