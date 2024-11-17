import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:vistafeedd/HomePage/homepage.dart';
import 'dart:io';

import 'package:vistafeedd/Upload%20Post/Create_post_details.dart';

class CreateStory extends StatefulWidget {
  const CreateStory({Key? key}) : super(key: key);

  @override
  State<CreateStory> createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  List<AssetEntity> _mediaList = [];
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchImagesFromDevice();
  }

  // Request permission and fetch images
  Future<void> _fetchImagesFromDevice() async {
    final PermissionState permission =
    await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      // Fetch all images
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isNotEmpty) {
        List<AssetEntity> media =
        await albums[0].getAssetListPaged(page: 0, size: 100); // Fetch images
        setState(() {
          _mediaList = media;
          if (media.isNotEmpty) {
            _selectImage(media[0]); // Set the first image as selected by default
          }
        });
      }
    } else {
      // Handle permission denial
      PhotoManager.openSetting();
    }
  }

  // Function to select an image
  Future<void> _selectImage(AssetEntity asset) async {
    final file = await asset.file;
    setState(() {
      _selectedImage = file;
    });
  }
  String imageLink = '';
  Future<void> uploadImage(File imageFile) async {
    try {
      // Create a unique filename for the image
      String fileName =
          '${_auth.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload image to Firebase Storage
      Reference storageRef =
      FirebaseStorage.instance.ref().child('Story_Images/$fileName');
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
  bool _isloading=false;
  Future<void> uploadstory()async{
    await uploadImage(_selectedImage!);
    setState(() {
      _isloading = true;
    });
    if (imageLink.isNotEmpty) {
      await _firestore.collection('Stories').doc(_auth.currentUser!.uid).set(
          {
            'Likes':[],
            'Story Link':imageLink,
            'Upload Date':FieldValue.serverTimestamp(),
            'Uploader UID':_auth.currentUser!.uid,
            'Viewers':[]
          });
      setState(() {
        _isloading = false;
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));
    }
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
            Icons.close,
            color: Colors.white,
          ),
        ),
        actions: [
          Row(
            children: [
              InkWell(
                onTap: uploadstory,
                child:_isloading?const CircularProgressIndicator(color: Color.fromRGBO(0, 149, 246, 1),)
                    :
                Text(
                  'Next',
                  style: GoogleFonts.poppins(
                    // color: Colors.white,
                      color: const Color.fromRGBO(0, 149, 246, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          )
        ],
        title:  Text(
          'New Story',
          style: GoogleFonts.poppins(
            color: Colors.white,
            // color: Color.fromRGBO(0, 149, 246, 1),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height/1.5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey,
              image: _selectedImage != null
                  ? DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: _selectedImage == null
                ? const Center(
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 50,
              ),
            )
                : null,
          ),
          const SizedBox(height: 10),
          // Grid for displaying thumbnails
          Expanded(
            child: _mediaList.isNotEmpty
                ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, // Number of images per row
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1, // To keep square thumbnails
              ),
              itemCount: _mediaList.length,
              itemBuilder: (context, index) {
                return FutureBuilder<File?>(
                  future: _mediaList[index].file,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null) {
                      final file = snapshot.data!;
                      return GestureDetector(
                        onTap: () => _selectImage(_mediaList[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(file),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _selectedImage?.path == file.path
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
            )
                : const Center(
              child: Text(
                'No images found',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
