import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistafeedd/Profile%20Page/otherprofilepage.dart';
import 'package:vistafeedd/Profile%20Page/profilepage.dart';

class ChatsCustomise extends StatefulWidget {
  final String UID;
  final String username;
  final String ChatID;
  final String PFP;

  ChatsCustomise({
    required this.PFP,
    required this.ChatID,
    required this.username,
    required this.UID,
  });

  @override
  State<ChatsCustomise> createState() => _ChatsCustomiseState();
}

class _ChatsCustomiseState extends State<ChatsCustomise> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List themelinks = [
    'https://i.pinimg.com/736x/67/9d/68/679d68ab60b0fd4ff1634e09567a9fd8.jpg',
    'https://i.pinimg.com/736x/a7/1c/f6/a71cf656b26ea8cdb5100cac535b0313.jpg',
    'https://i.pinimg.com/736x/c1/64/ad/c164adf837cfc1e5304c821dacc6106f.jpg',
    'https://i.pinimg.com/736x/42/46/9c/42469c31a6e84395e3c9717e26eb48c1.jpg',
    'https://i.pinimg.com/736x/31/74/1f/31741f945bc28ebdfcd8c7957b3fe325.jpg',
    'https://i.pinimg.com/736x/7a/88/a3/7a88a37abbac41485b5aad17691f0c19.jpg',
    'https://i.pinimg.com/736x/72/e2/f7/72e2f7b816570213865d91e6ac76a52a.jpg',
    'https://i.pinimg.com/736x/47/df/70/47df7011c42db722fa74b05272e373fc.jpg',
    'https://i.pinimg.com/736x/9a/c9/20/9ac9207a9bfe17c95c21c030ae953577.jpg',
    'https://iphoneswallpapers.com/wp-content/uploads/2024/11/Crystal-Stones-Wallpaper-169x300.jpg',
    'https://i.pinimg.com/736x/6c/2b/7e/6c2b7e96b8a5a71e47cad1df27050f90.jpg',
    'https://i.pinimg.com/736x/99/59/e4/9959e43d530dbe348b6722ad6c9e0954.jpg',
    'https://i.pinimg.com/736x/a9/d0/3d/a9d03d957aaacb9bf4f103246b6b4428.jpg',
    'https://i.pinimg.com/736x/cf/ab/0f/cfab0f49779fd7df1e80b3a950ceed9c.jpg',
    'https://i.pinimg.com/736x/6a/95/d9/6a95d9b5cd282395cbfc33c2b3107377.jpg',
    'https://i.pinimg.com/736x/04/a4/ed/04a4ed0dde358c275520481c68a660a0.jpg',
    'https://i.pinimg.com/736x/3d/8c/2f/3d8c2f2c82c1c9ef1e27be645cd1aa17.jpg',
    'https://i.pinimg.com/736x/1d/dd/b6/1dddb6039e0c0066a9e5b83f94f96347.jpg',
    'https://i.pinimg.com/736x/73/60/00/736000652e67a6b7aad1ca5b11e042ff.jpg'
  ];

  int? selectedIndex; // To keep track of the selected theme index
  String chatthemeid='';
  Future<void>fetchchattheme()async{
    final docsnap=await _firestore.collection('Chat Themes').doc(widget.ChatID).get();
    if(docsnap.exists){
     if (kDebugMode) {
       setState(() {
         selectedIndex=themelinks.indexOf(docsnap.data()?['Image URL']);
       });
     }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchchattheme();
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
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(widget.PFP),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.username,
                      style: GoogleFonts.poppins(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => widget.UID == _auth.currentUser!.uid
                              ? ProfilePage(userid: widget.PFP)
                              : OtherProfilePage(userid: widget.UID),
                        ),
                      );
                    },
                    child: const Icon(Icons.person, color: CupertinoColors.white)),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Text(
                  'Themes',
                  style: GoogleFonts.poppins(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 18),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // Display theme images in a 3x3 grid
            GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columns
                crossAxisSpacing: 10, // Space between columns
                mainAxisSpacing: 10, // Space between rows
              ),
              shrinkWrap: true, // Allow the GridView to fit within available space
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling
              itemCount: themelinks.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedIndex == index; // Check if this theme is selected
                return GestureDetector(
                  onTap: () async{
                    await _firestore.collection('Chat Themes').doc(widget.ChatID).set(
                        {
                          'Image URL':themelinks[index]
                        });
                    setState(() {
                      selectedIndex = isSelected ? null : index; // Toggle selection
                    });
                  },
                  child: Container(
                    width: 100, // Set fixed width
                    height: 100, // Set fixed height
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            themelinks[index],
                            fit: BoxFit.cover,
                            width: 500, // Keep the same width
                            height: 500, // Keep the same height
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 50, // Tick mark size
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
