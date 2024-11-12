import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistafeedd/HomePage/homepage.dart';
import 'package:vistafeedd/Login%20And%20Signup%20Page/loginpage.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    // Add a delay of 5 seconds before navigating to the next page
    Future.delayed(const Duration(seconds: 5), () {
      // Navigate to the next page (replace 'NextPage()' with your actual next page)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>_auth.currentUser!=null? HomePage():const LoginPage()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           SizedBox(
            height: MediaQuery.sizeOf(context).height/3,
          ),
         const Center(
            child: Image(image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/vistafeedd'
                '.appspot.com/o/Assets%2Fpngtree-meta-ball-icon-vector-design-template-png-image_53567'
                '33.png?alt=media&token=d09b9c69-11b4-4538-8066-bd4b53d37019'),height: 150,width: 150,),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height/2.8,
          ),
           Center(
            child: Column(
              children: [
                Text('VistaFeedd',style: GoogleFonts.poppins(color: Colors.white,
                fontSize: 22
                ),),
                const SizedBox(
                  height: 10,
                ),
                Text('A Biswayan Mazumder venture',style: GoogleFonts.poppins(color: Colors.white,
                    fontSize: 12,
                  fontWeight: FontWeight.w300
                ),),
              ],
            )
          )
        ],
      ),
    );
  }
}
