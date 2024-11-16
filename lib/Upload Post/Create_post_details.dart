import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:vistafeedd/HomePage/homepage.dart';

class Post_Details_Create extends StatefulWidget {
  final File imageFile;

  const Post_Details_Create({Key? key, required this.imageFile})
      : super(key: key);

  @override
  State<Post_Details_Create> createState() => _Post_Details_CreateState();
}

class _Post_Details_CreateState extends State<Post_Details_Create> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> followers = [];
  bool _isfollower = false; // Track the follower-only state

  // Fetch the followers data from Firestore
  Future<void> fetchfollower() async {
    final docsnap = await _firestore
        .collection('Followers')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        followers = docsnap.data()?['Followers ID'] ?? [];
      });
    }
    if (kDebugMode) {
      print('Follower: $followers');
    }
  }

  final TextEditingController _CaptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchfollower();
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      // Create a unique filename for the image
      String fileName =
          '${_auth.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload image to Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('post_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        imageLink = downloadUrl; // Store the URL in a variable
      });

      if (kDebugMode) {
        print('Image uploaded successfully: $imageLink');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
    }
  }

  int randomFiveDigitNumber = 0;
  Future<void> generatePostID() async {
    final random = Random();
    randomFiveDigitNumber =
        10000 + random.nextInt(90000); // Generates 5-digit number
    if (kDebugMode) {
      print('Random 5-digit number: $randomFiveDigitNumber');
    }
  }

  String imageLink = '';
  bool _isloading = false;
  Future<void> uploadpost() async {
    setState(() {
      _isloading = true;
    });

    // Upload image to Storage and get its link
    await uploadImage(widget.imageFile);

    if (imageLink.isNotEmpty) {
      await generatePostID();
      int numbers = randomFiveDigitNumber;

      // Update Firestore with image link and other details
      await _firestore.collection('Global Post IDs').doc('Posts').set({
        'Post IDs': FieldValue.arrayUnion([numbers.toString()]),
      },SetOptions(merge: true));

      await _firestore.collection('Global Post').doc(numbers.toString()).set({
        'Caption': _CaptionController.text,
        'Image Link': imageLink,
        'Upload Date': FieldValue.serverTimestamp(),
        'Uploaded UID': _auth.currentUser!.uid,
        'postid': numbers,
        'Followers Only': _isfollower,
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
      if (kDebugMode) {
        print('Post uploaded successfully with post ID: $numbers');
      }
    }

    setState(() {
      _isloading = false;
    });
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
        title: Text(
          'New Post',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: MediaQuery.sizeOf(context).height / 3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: widget.imageFile != null
                              ? DecorationImage(
                                  image: FileImage(widget.imageFile),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextField(
                        controller: _CaptionController,
                        style: GoogleFonts.poppins(
                          color: CupertinoColors.white,
                        ),
                        maxLength: 150,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintText: 'Add a caption...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          // Show the modal bottom sheet
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            backgroundColor: Colors.black,
                            builder: (context) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  color: Colors.black,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Audience',
                                        style: GoogleFonts.poppins(
                                          color: CupertinoColors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Who would you like to share your post with?',
                                            style: GoogleFonts.poppins(
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Followers Only',
                                                style: GoogleFonts.poppins(
                                                  color: CupertinoColors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                '${followers.length} followers',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),

                                          // Use StatefulBuilder to manage local state in the modal
                                          StatefulBuilder(
                                            builder: (BuildContext context,
                                                setState) {
                                              return Switch(
                                                value:
                                                    _isfollower, // Bind to the parent state
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    _isfollower =
                                                        value; // Update the parent state
                                                    print(
                                                        'Follower $_isfollower');
                                                  });
                                                },
                                                activeColor: Colors.green,
                                                inactiveThumbColor: Colors.grey,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.people,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Everyone',
                                            style: GoogleFonts.poppins(
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Audience',
                              style: GoogleFonts.poppins(
                                  color: CupertinoColors.white),
                            ),
                            const Spacer(),
                            Text(
                              _isfollower ? 'Followers Only' : 'Everyone',
                              style: GoogleFonts.poppins(
                                  color: CupertinoColors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (_CaptionController.text != '') {
                        //post photo
                        // if (!_isloading) {
                          uploadpost();
                        // }
                      }
                    },
                    child: Container(
                      height: 80,
                      color: Colors.black,
                      child: Center(
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: 60,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Color.fromRGBO(0, 149, 246, 1),
                          ),
                          child: Center(
                            child: _isloading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: CupertinoColors.white,
                                    ),
                                  )
                                : Text(
                                    'Share',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
