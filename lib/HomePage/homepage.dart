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
<svg width="100" height="30" xmlns="http://www.w3.org/2000/svg"><rect width="100" height="30" fill="black" rx="5"></rect><text x="50%" y="50%" font-family="'Lobster', cursive" font-size="21" fill="white" text-anchor="middle" alignment-baseline="middle" dominant-baseline="middle">VistaFeedd</text></svg>
''';

  bool _isLoading = true;

  Future<void> fetchposts() async {
    List postID = [];
    try {
      final docsnap = await _firestore.collection('Global Post IDs').doc('Posts').get();
      if (docsnap.exists) {
        setState(() {
          postID = docsnap.data()?['Post IDs'] ?? [];
        });
      }

      if (kDebugMode) {
        print('PIDs $postID');
      }

      List<dynamic> tempPostImages = [];
      List<dynamic> tempPostUid = [];
      List<dynamic> tempPostCaption = [];
      List<dynamic> tempPostDate = [];

      for (int i = 0; i < postID.length; i++) {
        final postdata = await _firestore.collection('Global Post').doc(postID[i]).get();
        if (postdata.exists) {
          final imageLink = postdata.data()?['Image Link'];
          if (imageLink is List) {
            tempPostImages.addAll(imageLink);
          } else if (imageLink is String) {
            tempPostImages.add(imageLink);
          }

          tempPostUid.add(postdata.data()?['Uploaded UID'] ?? '');
          tempPostCaption.add(postdata.data()?['Caption'] ?? '');
          tempPostDate.add(postdata.data()?['Upload Date'] ?? '');
        }
      }

      setState(() {
        postimages = tempPostImages;
        postuid = tempPostUid;
        postcaption = tempPostCaption;
        postdate = tempPostDate;
      });

      if (kDebugMode) {
        print('Posts ${postimages.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Posts error $e');
      }
    }
  }

  Future<void> fetchpostuserdetails() async {
    try {
      await fetchposts();
      for (int i = 0; i < postuid.length; i++) {
        final docsnap = await _firestore.collection('User Details').doc(postuid[i]).get();
        if (docsnap.exists) {
          postusername.add(docsnap.data()?['Name']);
          postuserpfps.add(docsnap.data()?['Profile Pic']);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("User details error $e");
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (kDebugMode) {
      print('Posts $postuserpfps $postusername');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchpostuserdetails();
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
                    child: Text(
                      '   ${postusername[index]}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
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
              )
            ],
          );
        },
      ),
    );
  }
}

