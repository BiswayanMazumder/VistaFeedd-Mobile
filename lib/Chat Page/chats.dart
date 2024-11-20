import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:vistafeedd/Chat%20Page/Chat_customise.dart';

class Chats extends StatefulWidget {
  final String ChatID;
  final String username;
  final String PFP;
  final String UID;

  Chats({
    required this.PFP,
    required this.username,
    required this.ChatID,
    required this.UID,
  });

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> messages = [];
  List<DateTime?> messagetimes = [];
  List<dynamic> messagesender = [];
  List<dynamic> audioLinks = [];
  bool _isListening = false;
  Timer? _timer;
  String chatthemeid = '';
  String? _audioFilePath;
  late FlutterSoundRecorder _recorder;
  late FlutterSoundPlayer _player;
  @override
  void initState() {
    super.initState();
    fetchmessages();
    fetchchattheme();
    _initializeRecorder();
    startFetchingMessages();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> fetchmessages() async {
    try {
      final docsnap = await FirebaseFirestore.instance
          .collection('Chats')
          .doc(widget.ChatID)
          .collection('Messages')
          .orderBy('timestamp')
          .get();

      messages.clear();
      messagetimes.clear();
      messagesender.clear();
      audioLinks.clear();

      for (var doc in docsnap.docs) {
        var message = doc['message'] ?? '';
        var sender = doc['senderId'] ?? '';
        var timestamp = doc['timestamp'];
        var audioLink = doc['AudioLink'] ?? '';

        messages.add(message);
        messagesender.add(sender);
        audioLinks.add(audioLink);

        if (timestamp is Timestamp) {
          messagetimes.add(timestamp.toDate());
        } else {
          messagetimes.add(null);
        }
      }

      setState(() {});
      _scrollToBottom();
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> fetchchattheme() async {
    final docsnap = await _firestore.collection('Chat Themes').doc(widget.ChatID).get();
    if (docsnap.exists) {
      setState(() {
        chatthemeid = docsnap['Image URL'];
      });
    }
  }

  Future<void> sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        await _firestore
            .collection('Chats')
            .doc(widget.ChatID)
            .collection('Messages')
            .add({
          'message': message,
          'AudioLink': '',
          'senderId': _auth.currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
        fetchmessages();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    await _recorder.openRecorder();
    await _player.openPlayer();
  }

  Future<String?> _uploadAudioToFirebase(String filePath) async {
    try {
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      final ref = FirebaseStorage.instance.ref().child('audioMessages/$fileName');
      final uploadTask = await ref.putFile(File(filePath));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    try {
      await _recorder.stopRecorder();
      if (_audioFilePath != null) {
        final downloadUrl = await _uploadAudioToFirebase(_audioFilePath!);
        if (downloadUrl != null) {
          await _firestore
              .collection('Chats')
              .doc(widget.ChatID)
              .collection('Messages')
              .add({
            'message': '',
            'AudioLink': downloadUrl,
            'senderId': _auth.currentUser!.uid,
            'timestamp': FieldValue.serverTimestamp(),
          });
          fetchmessages();
        }
      }
    } catch (e) {
      print('Error stopping recording or uploading audio: $e');
    }
  }

  void startFetchingMessages() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchmessages();
      fetchchattheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.PFP)),
            const SizedBox(width: 10),
            InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatsCustomise(PFP: widget.PFP,
                      ChatID: widget.ChatID,
                      username: widget.username,
                      UID: widget.UID),));
                },
                child: Text(widget.username, style: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 18))),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (chatthemeid.isNotEmpty)
            Positioned.fill(
              child: Image.network(chatthemeid, fit: BoxFit.cover),
            ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    bool isSender = messagesender[i] == _auth.currentUser!.uid;
                    return Row(
                      mainAxisAlignment:
                      isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isSender)
                          CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.PFP)),
                        if (messages[i].isNotEmpty)
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: isSender ? Colors.blue : Colors.grey[800],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              messages[i],
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        if (audioLinks[i] != null && audioLinks[i].isNotEmpty)
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              color: isSender ? Colors.blue : Colors.grey[800],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: IconButton(
                              icon: const Icon( CupertinoIcons.play_circle, color: Colors.white),
                              onPressed: () async {
                                await _player.startPlayer(fromURI: audioLinks[i]);
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                color: _isListening ? Colors.purple : Colors.grey[900],
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _isListening
                          ? Text('Listening...', style: GoogleFonts.poppins(color: Colors.white))
                          : TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () async {
                        setState(() => _isListening = true);
                        final tempDir = await getTemporaryDirectory();
                        _audioFilePath = '${tempDir.path}/voice_recording.aac';
                        await _recorder.startRecorder(toFile: _audioFilePath);
                      },
                      onLongPressUp: () async {
                        setState(() => _isListening = false);
                        await _stopRecordingAndUpload();
                      },
                      child: Icon(CupertinoIcons.mic, color: Colors.white),
                    ),
                    if (!_isListening)
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: sendMessage,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
