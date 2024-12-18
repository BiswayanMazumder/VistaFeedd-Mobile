import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistafeedd/Calling%20Page/voice_call.dart';
import 'package:vistafeedd/Chat%20Page/chats.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> ChatIDS = [];
  List<dynamic> ChatUIDS = [];
  List<dynamic> ChatNames = [];
  List<dynamic> ChatPFPS = [];
  Future<void> fetchpreviouschattedusers() async {
    final docsnap = await _firestore
        .collection('Chat UIDs')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      ChatIDS = docsnap.data()?['IDs'];
      ChatUIDS = docsnap.data()?['UIDs'];
    }
    if (ChatUIDS.contains(_auth.currentUser!.uid)) {
      int num = ChatUIDS.indexOf(_auth.currentUser!.uid);
      print(num);
      ChatUIDS.remove(_auth.currentUser!.uid);
      ChatIDS.removeAt(num);
    }
    if (kDebugMode) {
      print('UIDS $ChatUIDS');
      print('IDS $ChatIDS');
    }
    for (int i = 0; i < ChatUIDS.length; i++) {
      final UserSnap =
          await _firestore.collection('User Details').doc(ChatUIDS[i]).get();
      if (UserSnap.exists) {
        setState(() {
          ChatNames.add(UserSnap.data()?['Name']);
          ChatPFPS.add(UserSnap.data()?['Profile Pic']);
        });
      }
    }
    if (kDebugMode) {
      print('Name $ChatIDS');
    }
  }

  String username = '';
  Future<void> fetchusername() async {
    final docsnap = await _firestore
        .collection('User Details')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        username = docsnap.data()?['Name'];
      });
    }
  }

  bool _isLoading = true;
  Future<void> fetchdata() async {
    await fetchpreviouschattedusers();
    await fetchusername();
    setState(() {
      _isLoading = false;
    });
  }

  List<dynamic> messages = [];
  List<DateTime?> messagetimes = [];
  Future<void> fetchmessages(String chatID) async {
    try {
      // Get the snapshot of the messages collection
      final docsnap = await FirebaseFirestore.instance
          .collection('Chats')
          .doc(chatID)
          .collection('Messages')
          .get();

      if (kDebugMode) {
        print('Docsnap: $docsnap');
      }

      // Clear previous messages and timestamps before adding new ones
      messages.clear();
      messagetimes.clear();

      // Iterate through all the documents and add them to the messages and messagetimes lists
      for (var doc in docsnap.docs) {
        // Get message and timestamp from the document data
        var message = doc.data()?['message'];
        var timestamp = doc.data()?['timestamp'];

        // Convert Firestore Timestamp to DateTime
        if (timestamp is Timestamp) {
          messagetimes.add(timestamp.toDate());
        } else {
          messagetimes.add(null); // Handle missing or invalid timestamp
        }

        messages.add(message);
      }

      if (kDebugMode) {
        print('Fetched Messages: $messages');
        print('Fetched Timestamps: $messagetimes');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching messages: $e');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            username,
            style: GoogleFonts.poppins(color: CupertinoColors.white),
          ),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: CupertinoColors.white,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Messages',
                          style: GoogleFonts.poppins(
                              color: CupertinoColors.white, fontSize: 18),
                        ),
                        const Spacer(),
                        Text(
                          'Requests',
                          style: GoogleFonts.poppins(
                              color: const Color.fromRGBO(0, 149, 246, 7),
                              fontSize: 18),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: ListView.builder(
                        shrinkWrap:
                            true, // Ensures the ListView takes up only as much space as needed
                        itemCount: ChatUIDS.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          NetworkImage(ChatPFPS[index]),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Chats(
                                                  UID: ChatUIDS[index],
                                                    PFP: ChatPFPS[index],
                                                    username: ChatNames[index],
                                                    ChatID: ChatIDS[index].toString())));
                                      },
                                      child: Text(
                                        ChatNames[index],
                                        style: GoogleFonts.poppins(
                                            color: CupertinoColors.white),
                                      ),
                                    ),

                                  ],
                                ),
                              ) // Your Row widget content
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ));
  }
}
