import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../providers/theme_provider.dart';
import '../services/consultation_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';

class PatientConsultationScreen extends StatefulWidget {
  final UserModel doctor;

  const PatientConsultationScreen({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  State<PatientConsultationScreen> createState() => _PatientConsultationScreenState();
}

class _PatientConsultationScreenState extends State<PatientConsultationScreen> {
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late RtcEngine _engine;
  bool _isVideoCallActive = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  String? _consultationId;
  List<Map<String, dynamic>> _messages = [];
  bool _isConsultationStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
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
          // Doctor joined the call
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          // Doctor left the call
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.enableAudio();
  }

  Future<void> _startConsultation() async {
    if (_problemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your problem')),
      );
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) return;

    try {
      final consultationId = await ConsultationService.startConsultation(
        patientId: user.uid,
        doctorId: widget.doctor.uid,
        problem: _problemController.text.trim(),
        creditsToCharge: 15, // Default consultation fee
      );

      if (consultationId != null) {
        setState(() {
          _consultationId = consultationId;
          _isConsultationStarted = true;
        });

        // Create chat room
        await ConsultationService.createConsultationChatRoom(
          consultationId,
          user.uid,
          widget.doctor.uid,
        );

        _loadMessages();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultation started! 15 credits deducted.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting consultation: $e')),
      );
    }
  }

  Future<void> _loadMessages() async {
    if (_consultationId == null) return;

    ConsultationService.getConsultationMessages(_consultationId!).listen((snapshot) {
      setState(() {
        _messages = snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList();
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _consultationId == null) return;

    final user = AuthService().currentUser;
    if (user == null) return;

    await ConsultationService.sendConsultationMessage(
      consultationId: _consultationId!,
      senderId: user.uid,
      message: _messageController.text.trim(),
      isDoctor: false,
    );

    _messageController.clear();
  }

  Future<void> _joinVideoCall() async {
    if (_consultationId == null) return;

    await _engine.joinChannel(
      token: null,
      channelId: _consultationId!,
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

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    _problemController.dispose();
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
          'Consult Dr. ${widget.doctor.displayName}',
          style: TextStyle(color: themeProvider.primaryColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Doctor Info Card
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
                        'Dr. ${widget.doctor.displayName}',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Consultation Fee: 15 credits',
                        style: TextStyle(
                          color: themeProvider.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isConsultationStarted)
                  Text(
                    'Credits: ${widget.doctor.credits}',
                    style: TextStyle(
                      color: themeProvider.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // Problem Description (if consultation not started)
          if (!_isConsultationStarted)
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Describe Your Problem',
                    style: TextStyle(
                      color: themeProvider.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _problemController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Please describe your health concern in detail...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedButton(
                    text: 'Start Consultation (15 Credits)',
                    icon: Icons.medical_services,
                    onPressed: _startConsultation,
                  ),
                ],
              ),
            ),

          // Video Call Section (if consultation started)
          if (_isConsultationStarted && _isVideoCallActive)
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
                    Center(
                      child: Text(
                        'Video Call with Doctor',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    
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

          // Chat Section (if consultation started)
          if (_isConsultationStarted)
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
                                  ? MainAxisAlignment.start 
                                  : MainAxisAlignment.end,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDoctor 
                                        ? themeProvider.cardColor 
                                        : themeProvider.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    message['message'] ?? '',
                                    style: TextStyle(
                                      color: isDoctor 
                                          ? themeProvider.textColor 
                                          : themeProvider.backgroundColor,
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
                              onPressed: _joinVideoCall,
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
        ],
      ),
    );
  }
}