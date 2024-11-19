import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:vistafeedd/Calling%20Page/voice_call.dart'; // Importing the async library for Timer

class Chats extends StatefulWidget {
  final String ChatID;
  final String username;
  final String PFP;

  Chats({
    required this.PFP,
    required this.username,
    required this.ChatID,
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
  bool _isLoading = true;
  String requids='';
  Timer? _timer; // Timer to fetch messages every second
  ScrollController _scrollController = ScrollController(); // Controller for scrolling

  Future<void> fetchmessages() async {
    try {
      final docsnap = await FirebaseFirestore.instance
          .collection('Chats')
          .doc(widget.ChatID)
          .collection('Messages')
          .get();

      messages.clear();
      messagetimes.clear();
      messagesender.clear();
      messagesendercopy.clear();

      for (var doc in docsnap.docs) {
        var message = doc.data()?['message'];
        var sender = doc.data()?['senderId'];
        var timestamp = doc.data()?['timestamp'];

        if (timestamp is Timestamp) {
          messagetimes.add(timestamp.toDate());
        } else {
          messagetimes.add(null);
        }
        messagesender.add(sender);
        messages.add(message);
      }

      List<int> indices = List.generate(messages.length, (index) => index);
      indices.sort((a, b) => messagetimes[a]?.compareTo(messagetimes[b] ?? DateTime(0)) ?? 0);

      List<dynamic> sortedMessages = [];
      List<DateTime?> sortedTimes = [];
      List<dynamic> sortedSenders = [];

      for (var index in indices) {
        sortedMessages.add(messages[index]);
        sortedTimes.add(messagetimes[index]);
        sortedSenders.add(messagesender[index]);
      }

      setState(() {
        messages = sortedMessages;
        messagetimes = sortedTimes;
        messagesender = sortedSenders;
        messagesendercopy=messagesender;
      });

      // Scroll to the bottom when messages are fetched
      _scrollToBottom();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching messages: $e');
      }
    }
    setState(() {
      messagesendercopyset={...messagesendercopy}.toList();
    });
    for(int i=0;i<messagesendercopyset.length;i++){
      if(messagesendercopyset[i]==_auth.currentUser!.uid){
        messagesendercopyset.removeAt(i);
      }
    }
    if (kDebugMode) {
      print('Messenger ${messagesender}');
    }
  }

  void startFetchingMessages() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      fetchmessages();
    });
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

  @override
  void initState() {
    super.initState();
    fetchmessages();
    startFetchingMessages();
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
        // actions: [
        //   Row(
        //     children: [
        //       InkWell(
        //         onTap: (){
        //           _timer?.cancel();  // Stop the periodic timer
        //           Navigator.push(context, MaterialPageRoute(builder: (context) => Voice_Call_Interface(PFP: widget.PFP,
        //               username:widget.username,
        //              )));
        //         },
        //         child: const Icon(Icons.call,color: CupertinoColors.white,),
        //       )
        //     ],
        //   )
        // ],
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
            Text(
              widget.username,
              style: GoogleFonts.poppins(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
      body: Container(
        child: Column(
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
                                  backgroundImage: NetworkImage(widget.PFP),
                                )
                                    : Container(),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    color: messagesender[i] == _auth.currentUser!.uid
                                        ? Colors.blue
                                        : const Color.fromRGBO(33, 33, 33, 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: Center(
                                      child: Text(
                                        messages[i],
                                        style: GoogleFonts.poppins(color: CupertinoColors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              color: const Color.fromRGBO(31, 41, 55, 1),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
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
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage, // Call sendMessage when pressed
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
