import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../providers/theme_provider.dart';
import '../services/consultation_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';

class DoctorConsultationScreen extends StatefulWidget {
  final String consultationId;
  final Consultation consultation;

  const DoctorConsultationScreen({
    Key? key,
    required this.consultationId,
    required this.consultation,
  }) : super(key: key);

  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late RtcEngine _engine;
  bool _isVideoCallActive = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeAgora();
    _loadMessages();
  }

  Future<void> _initializeAgora() async {
    // Initialize Agora RTC Engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: 'YOUR_AGORA_APP_ID', // Replace with your Agora App ID
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isVideoCallActive = true;
          });
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          // Patient joined the call
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          // Patient left the call
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.enableAudio();
  }

  Future<void> _loadMessages() async {
    // Load consultation messages
    ConsultationService.getConsultationMessages(widget.consultationId).listen((snapshot) {
      setState(() {
        _messages = snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList();
      });
    });
  }

  Future<void> _startVideoCall() async {
    await _engine.joinChannel(
      token: null, // Use null for testing, implement token server for production
      channelId: widget.consultationId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _endVideoCall() async {
    await _engine.leaveChannel();
    setState(() {
      _isVideoCallActive = false;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = AuthService().currentUser;
    if (user == null) return;

    await ConsultationService.sendConsultationMessage(
      consultationId: widget.consultationId,
      senderId: user.uid,
      message: _messageController.text.trim(),
      isDoctor: true,
    );

    _messageController.clear();
  }

  Future<void> _completeConsultation() async {
    if (_prescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a prescription')),
      );
      return;
    }

    try {
      await ConsultationService.completeConsultation(
        consultationId: widget.consultationId,
        prescription: _prescriptionController.text.trim(),
        doctorId: widget.consultation.doctorId,
        creditsEarned: widget.consultation.creditsCharged,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation completed successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing consultation: $e')),
      );
    }
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    _prescriptionController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        title: Text(
          'Consultation',
          style: TextStyle(color: themeProvider.primaryColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Patient Info Card
          AnimatedCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: themeProvider.primaryColor,
                  child: Icon(Icons.person, color: themeProvider.backgroundColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Consultation',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Problem: ${widget.consultation.problem}',
                        style: TextStyle(
                          color: themeProvider.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${widget.consultation.creditsCharged} credits',
                  style: TextStyle(
                    color: themeProvider.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Video Call Section
          if (_isVideoCallActive)
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Video view will be implemented here
                    Center(
                      child: Text(
                        'Video Call Active',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    
                    // Call controls
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                _isMuted = !_isMuted;
                              });
                              _engine.muteLocalAudioStream(_isMuted);
                            },
                            backgroundColor: _isMuted ? Colors.red : Colors.grey,
                            child: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                          ),
                          FloatingActionButton(
                            onPressed: _endVideoCall,
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.call_end),
                          ),
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                _isVideoEnabled = !_isVideoEnabled;
                              });
                              _engine.muteLocalVideoStream(!_isVideoEnabled);
                            },
                            backgroundColor: _isVideoEnabled ? Colors.grey : Colors.red,
                            child: Icon(_isVideoEnabled ? Icons.videocam : Icons.videocam_off),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Chat Section
          Expanded(
            flex: _isVideoCallActive ? 1 : 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Messages
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isDoctor = message['isDoctor'] ?? false;
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: isDoctor 
                                ? MainAxisAlignment.end 
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDoctor 
                                      ? themeProvider.primaryColor 
                                      : themeProvider.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message['message'] ?? '',
                                  style: TextStyle(
                                    color: isDoctor 
                                        ? themeProvider.backgroundColor 
                                        : themeProvider.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Message input
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        if (!_isVideoCallActive)
                          IconButton(
                            onPressed: _startVideoCall,
                            icon: Icon(
                              Icons.video_call,
                              color: themeProvider.primaryColor,
                            ),
                          ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          onPressed: _sendMessage,
                          icon: Icon(
                            Icons.send,
                            color: themeProvider.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prescription Section
          AnimatedCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prescription',
                  style: TextStyle(
                    color: themeProvider.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _prescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter prescription and recommendations...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedButton(
                  text: 'Complete Consultation',
                  icon: Icons.check,
                  onPressed: _completeConsultation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}