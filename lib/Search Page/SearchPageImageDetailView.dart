import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class SearchPageImageDetail extends StatefulWidget {
  final String PID;
  final String ImageLink;
  SearchPageImageDetail({required this.PID,required this.ImageLink});

  @override
  State<SearchPageImageDetail> createState() => _SearchPageImageDetailState();
}

class _SearchPageImageDetailState extends State<SearchPageImageDetail> {
  String pfp='';
  String username='';
  String UID='';
  bool isliked=false;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  bool _isloading=false;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  Future<void>fetchpostdetails()async{
    final docsnap=await _firestore.collection('Global Post').doc(widget.PID).get();
    if(docsnap.exists){
      setState(() {
        UID=docsnap.data()?['Uploaded UID'];
      });
    }
    final Docsnap=await _firestore.collection('User Details').doc(UID).get();
    if(Docsnap.exists){
      setState(() {
        pfp=Docsnap.data()?['Profile Pic'];
        username=Docsnap.data()?['Name'];
      });
    }
  }
  Future<void> fetchdata() async {
    await fetchpostdetails();
    setState(() {
      _isloading = false;
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
    return const Placeholder();
  }
}
