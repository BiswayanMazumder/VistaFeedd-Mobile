import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';

class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
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
                onTap: (){},
                child: const Text(
                  'Proceed',
                  style: TextStyle(
                    color: Colors.white,
                    // color: Color.fromRGBO(0, 149, 246, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          )
        ],
        title: const Text(
          'New Post',
          style: TextStyle(
            color: Colors.white,
            // color: Color.fromRGBO(0, 149, 246, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Fixed container for the selected image
          Container(
            height: MediaQuery.sizeOf(context).height/2,
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
