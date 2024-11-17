import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool isuniqueusername = false;
  List username = [];
  Future<void> checkuniqueusername() async {
    final docsnap =
        await _firestore.collection('User Names').doc('usernames').get();
    if (docsnap.exists) {
      setState(() {
        username = docsnap.data()?['usernames'];
      });
    }
    if (usernames.contains(_NameController.text)) {
      setState(() {
        isuniqueusername = false;
      });
    } else {
      setState(() {
        isuniqueusername = true;
      });
    }
    if (kDebugMode) {
      print(
          'Names ${_NameController.text.trim()} , Bio ${_BioController.text} , Link ${_LinkController.text}');
      print('Unique Name $username ');
    }
  }

  // late VideoPlayerController _controller1;
  String usernames = '';
  String bio = '';
  String Link = '';
  bool isprivate = false;
  bool isverified = false;
  bool _isLoading=true;
  final TextEditingController _NameController = TextEditingController();
  final TextEditingController _BioController = TextEditingController();
  final TextEditingController _LinkController = TextEditingController();
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
        Link = docsnap.data()?['Link'];
      });
    }
    if (kDebugMode) {
      print('Verified $isverified');
    }
    setState(() {
      _NameController.text = usernames;
      _BioController.text = bio;
      _LinkController.text = Link;
    });
  }
  Future<void>fetchdata()async{
    await fetchpfp();
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
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body:_isLoading?const Center(child: CircularProgressIndicator(color: CupertinoColors.white,),): Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(pfp),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Edit Profile Picture',
                            style: GoogleFonts.poppins(
                                color: const Color.fromRGBO(0, 149, 246, 1),
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    TextField(
                      controller: _NameController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          label: Text(
                            'Name',
                            style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300),
                          )),
                      style: GoogleFonts.poppins(
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 80,
                      child: Center(
                        child: InkWell(
                          onTap: () async {
                            await checkuniqueusername();
                            if (!isuniqueusername) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sorry username already exists!',style: GoogleFonts.poppins(
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.w600
                                  ),),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }else{
                              await _firestore.collection('User Details').doc(_auth.currentUser!.uid).update(
                                  {
                                    'Name':_NameController.text
                                  });
                            }
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 60,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Color.fromRGBO(0, 149, 246, 1),
                            ),
                            child: Center(
                              child: Text(
                                'Edit Username',
                                style: GoogleFonts.poppins(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // color: Colors.red,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _BioController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          label: Text(
                            'Bio',
                            style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300),
                          )),
                      style: GoogleFonts.poppins(
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 80,
                      child: Center(
                        child: InkWell(
                          onTap: () async {
                            await _firestore.collection('User Details').doc(_auth.currentUser!.uid).update(
                                {
                                  'Bio':_BioController.text
                                });
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 60,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Color.fromRGBO(0, 149, 246, 1),
                            ),
                            child: Center(
                              child: Text(
                                'Edit Bio',
                                style: GoogleFonts.poppins(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // color: Colors.red,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _LinkController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          label: Text(
                            'Link',
                            style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300),
                          )),
                      style: GoogleFonts.poppins(
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 80,
                      child: Center(
                        child: InkWell(
                          onTap: () async {
                            await _firestore.collection('User Details').doc(_auth.currentUser!.uid).update(
                                {
                                  'Link':_LinkController.text
                                });
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 60,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Color.fromRGBO(0, 149, 246, 1),
                            ),
                            child: Center(
                              child: Text(
                                'Edit Link',
                                style: GoogleFonts.poppins(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // color: Colors.red,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )),

            ],
          )),
    );
  }
}
