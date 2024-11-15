import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(Icons.close,color: Colors.white,),
        ),
        title: Text('New Post',style: GoogleFonts.poppins(
          color: const Color.fromRGBO(0, 149, 246, 7),
          fontWeight: FontWeight.w600
        ),),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
