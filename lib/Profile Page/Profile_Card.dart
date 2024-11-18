import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:vistafeedd/Profile%20Page/profilepage.dart';

class ProfileCard extends StatefulWidget {
  final String name;
  final String pfp;
  final String bio;

  ProfileCard({required this.name, required this.pfp, required this.bio});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isDetailsVisible = false;
  GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Create the rotation animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward(); // Start rotating the container immediately

    // Rotation angle (360 degrees)
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159) // 2*pi radians (360 degrees)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // After rotation completes, show the details
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isDetailsVisible = true; // Show the details after rotation
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  final FirebaseAuth _auth=FirebaseAuth.instance;
  // Function to capture the container as PNG and share it
  Future<void> _captureAndShareImage() async {
    try {
      RenderRepaintBoundary boundary =
      _containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();

      // Get the temporary directory to store the image
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/profile_card.png';
      final file = File(filePath);
      await file.writeAsBytes(uint8List);

      // Share the image using the Share package
      await Share.shareFiles([filePath], text: 'https://vistafeedd.vercel.app/others/${_auth.currentUser!.uid}');
    } catch (e) {
      print("Error capturing and sharing image: $e");
    }
  }
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isuploading=false;
  Future<void> captureAndUploadImageToFirestore() async {
    try {
      setState(() {
        _isuploading=true;
      });
      // Capture the image from the widget
      RenderRepaintBoundary boundary =
      _containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();

      // Get the temporary directory to store the image
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/profile_card.png';
      final file = File(filePath);
      await file.writeAsBytes(uint8List);

      // Upload the image to Firebase Storage
      File storageFile = File(filePath);
      String fileName = 'profile_card_${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageReference = _storage.ref().child('Story_Images/${_auth.currentUser!.uid}/$fileName');

      // Upload the image to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(storageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      if (kDebugMode) {
        print("Image uploaded successfully. Download URL: $downloadUrl");
      }

      // Optionally: Save the URL to Firestore
      // Example: Assuming you have a `users` collection and a user document
      await _firestore.collection('Stories').doc(_auth.currentUser!.uid).set(
          {
            'Likes':[],
            'Story Link':downloadUrl,
            'Upload Date':FieldValue.serverTimestamp(),
            'Uploader UID':_auth.currentUser!.uid,
            'Viewers':[]
          });

      // Optionally: Share the image URL
      // await Share.share('Check out my profile: $downloadUrl');
      setState(() {
        _isuploading=false;
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage(userid: _auth.currentUser!.uid),));
    } catch (e) {
      setState(() {
        _isuploading=false;
      });
      print("Error capturing and uploading image: $e");
    }
  }
  List SvgTexts=[
    '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" id="upload">
  <path d="M8.71,7.71,11,5.41V15a1,1,0,0,0,2,0V5.41l2.29,2.3a1,1,0,0,0,1.42,0,1,1,0,0,0,0-1.42l-4-4a1,1,0,0,0-.33-.21,1,1,0,0,0-.76,0,1,1,0,0,0-.33.21l-4,4A1,1,0,1,0,8.71,7.71ZM21,12a1,1,0,0,0-1,1v6a1,1,0,0,1-1,1H5a1,1,0,0,1-1-1V13a1,1,0,0,0-2,0v6a3,3,0,0,0,3,3H19a3,3,0,0,0,3-3V13A1,1,0,0,0,21,12Z"/>
</svg>''',
    '<svg aria-label="Share" class="x1lliihq x1n2onr6 xyb1xck" fill="black" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Share</title><line fill="none" stroke="black" stroke-linejoin="round" stroke-width="2" x1="22" x2="9.218" y1="3" y2="10.083"></line><polygon fill="none" points="11.698 20.334 22 3.001 2 3.001 9.218 10.084 11.698 20.334" stroke="black" stroke-linejoin="round" stroke-width="2"></polygon></svg>',
    // '<svg aria-label="Share" class="x1lliihq x1n2onr6 xyb1xck" fill="black" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Share</title><line fill="none" stroke="black" stroke-linejoin="round" stroke-width="2" x1="22" x2="9.218" y1="3" y2="10.083"></line><polygon fill="none" points="11.698 20.334 22 3.001 2 3.001 9.218 10.084 11.698 20.334" stroke="black" stroke-linejoin="round" stroke-width="2"></polygon></svg>',
    '<svg aria-label="Copy link" class="x1lliihq x1n2onr6 x5n08af" fill="black" height="20" role="img" viewBox="0 0 24 24" width="20"><title>Copy link</title><path d="m9.726 5.123 1.228-1.228a6.47 6.47 0 0 1 9.15 9.152l-1.227 1.227m-4.603 4.603-1.228 1.228a6.47 6.47 0 0 1-9.15-9.152l1.227-1.227" fill="none" stroke="black" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path><line fill="none" stroke="black" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="8.471" x2="15.529" y1="15.529" y2="8.471"></line></svg>',
    '<svg aria-label="Facebook" class="x1lliihq x1n2onr6 x5n08af" fill="black" height="20" role="img" viewBox="0 0 24 24" width="20"><title>Facebook</title><circle cx="12" cy="12" fill="none" r="11.25" stroke="black" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"></circle><path d="M16.671 15.469 17.203 12h-3.328V9.749a1.734 1.734 0 0 1 1.956-1.874h1.513V4.922a18.452 18.452 0 0 0-2.686-.234c-2.741 0-4.533 1.66-4.533 4.668V12H7.078v3.469h3.047v7.885a12.125 12.125 0 0 0 3.75 0V15.47Z" fill-rule="evenodd"></path></svg>',
    '<svg aria-label="Messenger" class="x1lliihq x1n2onr6 x5n08af" fill="black" height="20" role="img" viewBox="0 0 24 24" width="20"><title>Messenger</title><path d="M12.003 2.001a9.705 9.705 0 1 1 0 19.4 10.876 10.876 0 0 1-2.895-.384.798.798 0 0 0-.533.04l-1.984.876a.801.801 0 0 1-1.123-.708l-.054-1.78a.806.806 0 0 0-.27-.569 9.49 9.49 0 0 1-3.14-7.175 9.65 9.65 0 0 1 10-9.7Z" fill="none" stroke="black" stroke-miterlimit="10" stroke-width="1.739"></path><path d="M17.79 10.132a.659.659 0 0 0-.962-.873l-2.556 2.05a.63.63 0 0 1-.758.002L11.06 9.47a1.576 1.576 0 0 0-2.277.42l-2.567 3.98a.659.659 0 0 0 .961.875l2.556-2.049a.63.63 0 0 1 .759-.002l2.452 1.84a1.576 1.576 0 0 0 2.278-.42Z" fill-rule="evenodd"></path></svg>',
    '<svg aria-label="WhatsApp" class="x1lliihq x1n2onr6 x5n08af" fill="black" height="20" role="img" viewBox="0 0 31 31" width="20"><title>WhatsApp</title><path clip-rule="evenodd" d="M15.662.263A15.166 15.166 0 0 1 26.06 4.48a15.048 15.048 0 0 1 4.653 10.381 15.164 15.164 0 0 1-3.77 10.568 15.063 15.063 0 0 1-11.37 5.138c-2.273 0-4.526-.513-6.567-1.495l-7.93 1.764a.116.116 0 0 1-.138-.13l1.34-8.019a15.181 15.181 0 0 1-1.85-6.837A15.052 15.052 0 0 1 4.555 5.012 15.061 15.061 0 0 1 15.586.263h.075Zm-.085 2.629c-.12 0-.242.002-.364.005-6.902.198-12.356 5.975-12.158 12.877.06 2.107.654 4.176 1.717 5.982l.231.392-.993 5.441 5.385-1.271.407.212a12.527 12.527 0 0 0 6.13 1.402c6.901-.198 12.356-5.974 12.158-12.876-.195-6.78-5.773-12.164-12.513-12.164ZM10.34 8.095c.253.008.507.015.728.032.271.019.57.04.836.683.315.763.996 2.668 1.085 2.86.09.194.146.418.011.668-.134.25-.203.407-.4.623-.196.216-.414.484-.59.649-.197.184-.4.384-.19.771.21.388.934 1.657 2.033 2.7 1.413 1.34 2.546 1.783 2.996 1.993a.998.998 0 0 0 .415.112c.162 0 .292-.068.415-.193.237-.24.95-1.071 1.25-1.454.156-.2.299-.271.453-.271.123 0 .255.045.408.107.345.137 2.185 1.115 2.56 1.317.374.202.625.305.715.466.09.162.066.924-.278 1.803-.344.878-1.922 1.688-2.621 1.73-.205.012-.406.04-.668.04-.634 0-1.621-.166-3.865-1.133-3.817-1.643-6.136-5.683-6.318-5.942-.182-.26-1.489-2.111-1.432-3.983C7.94 9.8 8.951 8.91 9.311 8.54c.345-.355.74-.445.996-.445h.032Z" fill="black" fill-rule="evenodd"></path></svg>',
    '<svg aria-label="Email" class="x1lliihq x1n2onr6 x5n08af" fill="black" height="20" role="img" viewBox="0 0 24 24" width="20"><title>Email</title><rect fill="none" height="17.273" stroke="black" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" width="20" x="2" y="3.364"></rect><polyline fill="none" points="2 7.155 12.002 13.81 22 7.157" stroke="black" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></polyline></svg>',
    '<svg data-name="Icons" viewBox="0 0 24 24" width="1em" height="1em" fill="black" class="x1qx5ct2 xw4jnvo" color="rgb(var(--ig-primary-text))"><path d="m21.8 20.4-7.28-9.706 6.323-7.025a1 1 0 0 0-1.487-1.338l-6.058 6.733L8.3 2.4a.999.999 0 0 0-.8-.4H3a1 1 0 0 0-.8 1.6l7.28 9.706-6.323 7.025a1 1 0 0 0 1.487 1.338l6.058-6.733L15.7 21.6c.189.252.486.4.8.4H21a1 1 0 0 0 .8-1.6zM17 20 5 4h2l12 16h-2z"></path></svg>',
    // '<svg data-name="Icons" viewBox="0 0 24 24" width="1em" height="1em" fill="black" class="x1qx5ct2 xw4jnvo" color="rgb(var(--ig-primary-text))"><path d="m21.8 20.4-7.28-9.706 6.323-7.025a1 1 0 0 0-1.487-1.338l-6.058 6.733L8.3 2.4a.999.999 0 0 0-.8-.4H3a1 1 0 0 0-.8 1.6l7.28 9.706-6.323 7.025a1 1 0 0 0 1.487 1.338l6.058-6.733L15.7 21.6c.189.252.486.4.8.4H21a1 1 0 0 0 .8-1.6zM17 20 5 4h2l12 16h-2z"></path></svg>'
  ];
  List SVGName=[
    'Upload',
    'Share to story',
    'Copy Link',
    'Facebook',
    'Messenger',
    'WhatsApp',
    'Email',
    'X'
  ];
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
            Icons.close,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar:Container(
        width: MediaQuery.of(context).size.width,
        height: 120,
        color: Colors.black,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Specify horizontal scrolling
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(SvgTexts.length-1, (index) {  // You can generate the circle avatars dynamically
                return  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0), // Add space between items
                  child: Column(
                    children: [
                      InkWell(
                        onTap: (){
                          if(index==0){
                          _isuploading?null: _captureAndShareImage();
                          }
                          if(index==1){
                           _isuploading?null: captureAndUploadImageToFirestore();
                          }
                          if(index==2){
                            Clipboard.setData(ClipboardData(text: 'https://vistafeedd.vercel.app/others/${_auth.currentUser!.uid}')).then((_) {
                              // Show a message after copying
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile URL copied!')),
                              );
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: SvgPicture.string(SvgTexts[index]),
                        ),
                      ),
                      Text(SVGName[index],style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                      ),)
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.5),
      body:Center(
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value, // Rotate the whole container
              child: RepaintBoundary(
                key: _containerKey, // Key for capturing the widget
                child: Container(
                  height: MediaQuery.sizeOf(context).height / 1.5,
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.blue,
                        Colors.purple,
                        Colors.orange,
                        Colors.yellow,
                        Colors.orangeAccent,
                        Colors.purpleAccent,
                        Colors.blueAccent,
                        Colors.blueGrey,
                      ],
                      tileMode: TileMode.clamp,
                      begin: Alignment.topLeft, // Starting point of the gradient
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // CircleAvatar with the profile image
                            CircleAvatar(
                              radius: 100,
                              backgroundImage: NetworkImage(widget.pfp),
                            ),

                            // Rotated container with name, positioned at the bottom of the avatar
                            Positioned(
                              bottom: 0,
                              child: Transform.rotate(
                                angle: -0.15, // Adjust the angle to tilt it
                                child: Container(
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                      child: Text(
                                        widget.name,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // Show name and bio after rotation
                      if (_isDetailsVisible)
                        Column(
                          children: [
                            Text(
                              widget.name,
                              style: GoogleFonts.alegreya(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.bio,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
