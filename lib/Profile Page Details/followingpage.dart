import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistafeedd/Profile%20Page%20Details/followerspage.dart';
import 'package:vistafeedd/Profile%20Page/otherprofilepage.dart';
import 'package:vistafeedd/Profile%20Page/profilepage.dart';
class FollowingPage extends StatefulWidget {
  final List followerslist;
  final String username;
  final String UID;
  FollowingPage(
      {required this.followerslist,required this.username,required this.UID});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  bool _isloading=true;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  List<dynamic>usernames=[];
  List<dynamic> pfps=[];
  Future<void> fetchfollowersdetails()async{
    for(int i=0;i<widget.followerslist.length;i++){
      final docsnap=await _firestore.collection('User Details').doc(widget.followerslist[i]).get();
      if(docsnap.exists){
        setState(() {
          usernames.add(docsnap.data()?['Name']);
          pfps.add(docsnap.data()?['Profile Pic']);
        });
      }
    }
    setState(() {
      _isloading=false;
    });
    if (kDebugMode) {
      print('Names $usernames');
    }
    if (kDebugMode) {
      print("PFPS $pfps");
    }
  }
  List<dynamic> following = [];
  List<dynamic> followers = [];
  Future<void> fetchfollowing() async {
    final docsnap = await _firestore
        .collection('Following')
        .doc(widget.UID)
        .get();
    if (docsnap.exists) {
      setState(() {
        following = docsnap.data()?['Following ID'] ?? [];
      });
    }
    if (kDebugMode) {
      print('Following: $following');
    }
  }
  Future<void> fetchfollower() async {
    final docsnap = await _firestore
        .collection('Followers')
        .doc(widget.UID)
        .get();
    if (docsnap.exists) {
      setState(() {
        followers = docsnap.data()?['Followers ID'] ?? [];
      });
    }
    if (kDebugMode) {
      print('Follower owner: $followers');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchfollowersdetails();
    fetchfollower();
    fetchfollowing();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.username,style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600
            ),)
          ],
        ),
        backgroundColor: Colors.black,
        leading:  InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
      ),
      backgroundColor: Colors.black,
      body:_isloading?const Center(child: CircularProgressIndicator(
        color: Colors.white,
      ),) :Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                  onTap: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FollowerPage(followerslist: followers,
                        username: widget.username,
                        UID: widget.UID),));
                  },
                child: Text(
                  ' ${widget.followerslist.length} Followers',
                  style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15
                  ),
                ),
              ),
              InkWell(
                child: Text(
                  ' ${followers.length} Following',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: ListView.builder(
            itemCount: widget.followerslist.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            pfps[index],
                            height: 35,
                            width: 35,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>widget.followerslist[index]==_auth.currentUser!.uid?
                          ProfilePage(userid: widget.followerslist[index]):
                          OtherProfilePage(userid: widget.followerslist[index]),));
                        },
                        child: Text(usernames[index],style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                        ),),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              );
            },),)
        ],
      )
    );
  }
}
