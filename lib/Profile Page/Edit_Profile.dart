import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class Edit_Profile extends StatefulWidget {
  const Edit_Profile({super.key});

  @override
  State<Edit_Profile> createState() => _Edit_ProfileState();
}

class _Edit_ProfileState extends State<Edit_Profile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String pfp = '';
  // late VideoPlayerController _controller1;
  String usernames = '';
  String bio = '';
  bool isprivate = false;
  bool isverified = false;
   final TextEditingController _NameController=TextEditingController();
   final TextEditingController _BioController=TextEditingController();
  Future<void> fetchpfp() async {
    final docsnap = await _firestore
        .collection('User Details')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        pfp = docsnap.data()?['Profile Pic'];
        usernames = docsnap.data()?['Name'];
        bio = docsnap.data()?['Bio'];
        isprivate = docsnap.data()?['Private Account'];
        isverified = docsnap.data()?['Verified'];
      });
    }
    if (kDebugMode) {
      print('Verified $isverified');
    }
    setState(() {
      _NameController.text=usernames;
      _BioController.text=bio;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchpfp();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
    );
  }
}
