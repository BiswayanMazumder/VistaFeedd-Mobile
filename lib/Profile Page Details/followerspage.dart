import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistafeedd/Profile%20Page/otherprofilepage.dart';
import 'package:vistafeedd/Profile%20Page/profilepage.dart';
class FollowerPage extends StatefulWidget {
  final List followerslist;
  final String username;
  FollowerPage(
      {required this.followerslist,required this.username});

  @override
  State<FollowerPage> createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage> {
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
    print('Names $usernames');
    print("PFPS $pfps");
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchfollowersdetails();
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
      ),) :ListView.builder(
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
      },),
    );
  }
}
