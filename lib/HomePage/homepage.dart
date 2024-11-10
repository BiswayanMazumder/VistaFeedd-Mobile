import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<dynamic> postimages = [];
  List<dynamic> postusername = [];
  List<dynamic> postuid = [];
  List<dynamic> likedusers = [];
  List<dynamic> postcaption = [];
  List<dynamic> postdate = [];
  List<dynamic> postuserpfps = [];
  final String svgString = '''
<svg aria-label="Verified" class="x1lliihq x1n2onr6" fill="rgb(0, 149, 246)" height="12" role="img" viewBox="0 0 12 12" width="12"><title>Verified</title><path d="M19.998 3.094 14.638 0l-2.972 5.15H5.432v6.354L0 14.64 3.094 20 0 25.359l5.432 3.137v5.905h5.975L14.638 40l5.36-3.094L25.358 40l3.232-5.6h6.162v-6.01L40 25.359 36.905 20 40 14.641l-5.248-3.03v-6.46h-6.419L25.358 0l-5.36 3.094Zm7.415 11.225 2.254 2.287-11.43 11.5-6.835-6.93 2.244-2.258 4.587 4.581 9.18-9.18Z" fill-rule="evenodd"></path></svg>
''' ;

  bool _isLoading = true;
  List<dynamic> following = [];
  List<dynamic> verification=[];
  // Fetch the list of following users
  Future<void> fetchfollowing() async {
    final docsnap = await _firestore.collection('Following').doc(_auth.currentUser!.uid).get();
    if (docsnap.exists) {
      setState(() {
        following = docsnap.data()?['Following ID'] ?? [];
      });
    }
    if (kDebugMode) {
      print('Following: $following');
    }
  }

  // Fetch the posts from the followed users only
  Future<void> fetchposts() async {
    await fetchfollowing();
    List postID = [];

    try {
      final docsnap = await _firestore.collection('Global Post IDs').doc('Posts').get();
      if (docsnap.exists) {
        setState(() {
          postID = docsnap.data()?['Post IDs'] ?? [];
        });
      }

      if (kDebugMode) {
        print('PIDs: $postID');
      }

      List<dynamic> tempPostImages = [];
      List<dynamic> tempPostUid = [];
      List<dynamic> tempPostCaption = [];
      List<dynamic> tempPostDate = [];

      // Only fetch posts from followed users
      for (int i = 0; i < postID.length; i++) {
        final postdata = await _firestore.collection('Global Post').doc(postID[i]).get();
        if (postdata.exists) {
          final postUid = postdata.data()?['Uploaded UID'];
          if (following.contains(postUid)) {  // Filter posts by followed users
            final imageLink = postdata.data()?['Image Link'];
            if (imageLink is List) {
              tempPostImages.addAll(imageLink);
            } else if (imageLink is String) {
              tempPostImages.add(imageLink);
            }

            tempPostUid.add(postUid ?? '');
            tempPostCaption.add(postdata.data()?['Caption'] ?? '');
            tempPostDate.add(postdata.data()?['Upload Date'] ?? '');
          }
        }
      }

      setState(() {
        postimages = tempPostImages;
        postuid = tempPostUid;
        postcaption = tempPostCaption;
        postdate = tempPostDate;
      });

      if (kDebugMode) {
        print('Posts fetched: ${postimages.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Posts error: $e');
      }
    }
  }

  // Fetch user details for the posts (e.g., username, profile picture)
  Future<void> fetchpostuserdetails() async {
    try {
      await fetchposts();
      for (int i = 0; i < postuid.length; i++) {
        final docsnap = await _firestore.collection('User Details').doc(postuid[i]).get();
        if (docsnap.exists) {
          postusername.add(docsnap.data()?['Name']);
          postuserpfps.add(docsnap.data()?['Profile Pic']);
          verification.add(docsnap.data()?['Verified']);
        }
      }
      if (kDebugMode) {
        print('Verified $verification');
      }
    } catch (e) {
      if (kDebugMode) {
        print("User details error: $e");
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (kDebugMode) {
      print('Posts User Details: $postuserpfps $postusername');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchpostuserdetails();
    fetchfollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      )
          : ListView.builder(
        itemCount: postuid.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  SizedBox(width: 10),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        postuserpfps[index],
                        height: 35,
                        width: 35,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      children: [
                        Text(
                          '   ${postusername[index]}  ',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                       verification[index]? SizedBox(
                          width: 12,
                          height: 12,
                          child: SvgPicture.string(svgString),
                        ):Container(),

                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Image(
                    image: NetworkImage(postimages[index]),
                    width: 0.99 * MediaQuery.sizeOf(context).width,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
