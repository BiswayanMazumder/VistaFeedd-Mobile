import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  List<dynamic> ChatIDS=[];
  List<dynamic> ChatUIDS=[];
  List<dynamic> ChatNames=[];
  List<dynamic> ChatPFPS=[];
  Future<void>fetchpreviouschattedusers()async{
    final docsnap=await _firestore.collection('Chat UIDs').doc(_auth.currentUser!.uid).get();
    if(docsnap.exists){
      ChatIDS=docsnap.data()?['IDs'];
      ChatUIDS=docsnap.data()?['UIDs'];
    }
    // if(ChatUIDS.contains(_auth.currentUser!.uid)){
    //   ChatUIDS.remove(_auth.currentUser!.uid);
    // }
    if (kDebugMode) {
      print('UIDS $ChatUIDS');
    }
    for(int i=0;i<ChatUIDS.length;i++){
      final UserSnap=await _firestore.collection('User Details').doc(ChatUIDS[i]).get();
      if(UserSnap.exists){
        setState(() {
          ChatNames.add(UserSnap.data()?['Name']);
          ChatPFPS.add(UserSnap.data()?['Profile Pic']);
        });
      }
    }
    if (kDebugMode) {
      print('Name $ChatNames');
    }
  }
  String username='';
  Future<void>fetchusername()async{
    final docsnap=await _firestore.collection('User Details').doc(_auth.currentUser!.uid).get();
    if(docsnap.exists){
      setState(() {
        username=docsnap.data()?['Name'];
      });
    }
  }
  bool _isLoading=true;
  Future<void> fetchdata()async{
    await fetchpreviouschattedusers();
    await fetchusername();
    setState(() {
      _isLoading=false;
    });
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
        title: Text(username,style: GoogleFonts.poppins(
          color: CupertinoColors.white
        ),),
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(CupertinoIcons.back,color: Colors.white,),
        ),
      ),
      body:_isLoading?Center(child: CircularProgressIndicator(
        color: CupertinoColors.white,
      ),) : SingleChildScrollView(
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
                Text('Messages',style: GoogleFonts.poppins(
                  color: CupertinoColors.white,
                  fontSize: 18
                ),),
                const Spacer(),
                Text('Requests',style: GoogleFonts.poppins(
                    color: const Color.fromRGBO(0, 149, 246, 7),
                    fontSize: 18
                ),),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(padding: const EdgeInsets.only(left: 20,right: 20),
            child: ListView.builder(
              shrinkWrap: true, // Ensures the ListView takes up only as much space as needed
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
                              backgroundImage: NetworkImage(ChatPFPS[index]),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(ChatNames[index],style: GoogleFonts.poppins(
                            color: CupertinoColors.white
                          ),)
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
      )
    );
  }
}
