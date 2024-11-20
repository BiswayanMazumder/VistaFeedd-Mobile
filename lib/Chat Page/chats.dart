import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vistafeedd/Calling%20Page/voice_call.dart';
import 'package:vistafeedd/Chat%20Page/Chat_customise.dart'; // Importing the async library for Timer
import 'package:audio_waveforms/audio_waveforms.dart';
class Chats extends StatefulWidget {
  final String ChatID;
  final String username;
  final String PFP;
  final String UID;

  Chats({
    required this.PFP,
    required this.username,
    required this.ChatID,
    required this.UID
  });

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController(); // Controller for TextField
  List<dynamic> messages = [];

  List<DateTime?> messagetimes = [];
  List<dynamic> messagesender = [];
  List<dynamic> messagesendercopy = [];
  List<dynamic> messagesendercopyset = [];
  List<dynamic> audioLinks = [];
  bool _isLoading = true;
  String requids='';
  bool _islistening=false;
  Timer? _timer; // Timer to fetch messages every second
  ScrollController _scrollController = ScrollController(); // Controller for scrolling
  late SpeechToText _speech;
  late AudioPlayer _audioPlayer;
  Future<void> fetchmessages() async {
    try {
      final docsnap = await FirebaseFirestore.instance
          .collection('Chats')
          .doc(widget.ChatID)
          .collection('Messages')
          .get();

      // Clear previous data
      messages.clear();
      messagetimes.clear();
      messagesender.clear();
      messagesendercopy.clear();
      audioLinks.clear();  // Initialize the audioLinks list

      for (var doc in docsnap.docs) {
        var message = doc.data()?['message'];
        var sender = doc.data()?['senderId'];
        var timestamp = doc.data()?['timestamp'];
        var audioLink = doc.data()?['AudioLink'];  // Fetch the audio link

        // Add timestamp to list, handling null values
        if (timestamp is Timestamp) {
          messagetimes.add(timestamp.toDate());
        } else {
          messagetimes.add(null);
        }

        // Add sender and message to their respective lists
        messagesender.add(sender);
        messages.add(message);

        // Add audioLink to the list
        audioLinks.add(audioLink); // Add the audio link to the list
      }

      // Generate indices based on messages length and sort by timestamp
      List<int> indices = List.generate(messages.length, (index) => index);
      indices.sort((a, b) => messagetimes[a]?.compareTo(messagetimes[b] ?? DateTime(0)) ?? 0);

      // Create lists for sorted data
      List<dynamic> sortedMessages = [];
      List<DateTime?> sortedTimes = [];
      List<dynamic> sortedSenders = [];
      List<dynamic> sortedAudioLinks = [];  // List for sorted audio links

      // Populate sorted lists
      for (var index in indices) {
        sortedMessages.add(messages[index]);
        sortedTimes.add(messagetimes[index]);
        sortedSenders.add(messagesender[index]);
        sortedAudioLinks.add(audioLinks[index]);  // Add the audio link in the sorted order
      }

      // Update state with the sorted data
      setState(() {
        messages = sortedMessages;
        messagetimes = sortedTimes;
        messagesender = sortedSenders;
        audioLinks = sortedAudioLinks;  // Set the sorted audio links
      });

      print('Audio Links: $audioLinks'); // Optional debug print to check the audio links
      _scrollToBottom();  // Scroll to the bottom when messages are fetched
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching messages: $e');
      }
    }

    setState(() {
      // Filter out the current user's ID from the sender list
      messagesendercopyset = {...messagesendercopy}.toList();
    });

    for (int i = 0; i < messagesendercopyset.length; i++) {
      if (messagesendercopyset[i] == _auth.currentUser!.uid) {
        messagesendercopyset.removeAt(i);
      }
    }

    if (kDebugMode) {
      if (messagesendercopyset.length == 0) {
        print('Messenger ${messagesender}');
      } else {
        print('Messenger ${messagesendercopyset}');
      }
    }
  }

  late FlutterSoundRecorder _recorder;
  late FlutterSoundPlayer _player;
  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
  }
  String? _audioFilePath;
  void startFetchingMessages() {
    _timer = Timer.periodic(const Duration(hours: 2), (Timer t) {
      fetchmessages();
      fetchchattheme();
    });
  }
  Future<void> _startRecording() async {
    try {
      final tempDir = await getTemporaryDirectory();
      _audioFilePath = '${tempDir.path}/voice_recording.aac'; // Temporary file path

      await _recorder.startRecorder(toFile: _audioFilePath);
      print("Recording started...");
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  // Stop recording and play audio
  Future<void> _stopRecording() async {
    try {
      // Stop recording
      await _recorder.stopRecorder();
      if (kDebugMode) {
        print("Recording stopped. File saved to $_audioFilePath");
      }

      if (_audioFilePath != null) {
        // Play the recorded audio file
        await _player.startPlayer(fromURI: _audioFilePath);
        if (kDebugMode) {
          print("Playing recorded audio...");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording or playing audio: $e');
      }
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
          'seen': false,
          // 'recieverID':widget.
          'senderId': _auth.currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear(); // Clear the text field after sending
        fetchmessages(); // Refresh messages
      } catch (e) {
        if (kDebugMode) {
          print('Error sending message: $e');
        }
      }
    }
  }

  // Function to scroll to the bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  String chatthemeid='';
  Future<void>fetchchattheme()async{
    final docsnap=await _firestore.collection('Chat Themes').doc(widget.ChatID).get();
    if(docsnap.exists){
      setState(() {
        chatthemeid=docsnap.data()?['Image URL'];
      });
    }
    if (kDebugMode) {
      print(chatthemeid);
    }
  }
  @override
  void initState() {
    super.initState();
    fetchmessages();
    startFetchingMessages();
    fetchchattheme();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeRecorder();
    // _waveforms = AudioWaveforms;
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (kDebugMode) {
      print('Disposed');
    }
    _messageController.dispose(); // Dispose the controller
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.PFP),
            ),
            const SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatsCustomise(
                      ChatID: widget.ChatID,
                      PFP: widget.PFP,
                      username: widget.username,
                      UID: widget.UID,
                    ),
                  ),
                );
              },
              child: Text(
                widget.username,
                style: GoogleFonts.poppins(
                    color: CupertinoColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Image if chatthemeid is not empty
          if (chatthemeid.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                chatthemeid,
                fit: BoxFit.cover,
              ),
            ),
          // Chat content
          Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController, // Attach the ScrollController here
                  child: Column(
                    children: [
                      for (int i = 0; i < messages.length; i++)
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 50, left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment: messagesender[i] ==
                                    _auth.currentUser!.uid
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  messagesender[i] != _auth.currentUser!.uid
                                      ? CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                    NetworkImage(widget.PFP),
                                  )
                                      : Container(),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50)),
                                      color: messagesender[i] ==
                                          _auth.currentUser!.uid
                                          ? Colors.blue
                                          : const Color.fromRGBO(33, 33, 33, 1),
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.only(left: 10, right: 10),
                                      child: Center(
                                        child: Text(
                                          messages[i],
                                          style: GoogleFonts.poppins(
                                              color: CupertinoColors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color:_islistening?Colors.purple: const Color.fromRGBO(31, 41, 55, 1),
                child: Row(
                  children: [
                    Expanded(
                      child:_islistening?Container(
                        height: 50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Listening...',style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w600
                            ),),
                          ],
                        ),
                        //show waveform here
                      ): TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.poppins(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 15),
                        ),
                        style: GoogleFonts.poppins(color: CupertinoColors.white),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onLongPress: (){
                            setState(() {
                              _islistening=true;
                            });
                            print('Listening $_islistening');
                            _startRecording();
                          },
                          onLongPressEnd: (details) {
                            setState(() {
                              _islistening=false;
                            });
                            print('Listening $_islistening');
                            _stopRecording();
                          },
                          child:const Icon(CupertinoIcons.mic,color: CupertinoColors.white,),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                       _islistening?Container():IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: sendMessage, // Call sendMessage when pressed
                        ),
                      ],
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
