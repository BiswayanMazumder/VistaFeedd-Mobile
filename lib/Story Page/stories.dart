import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:vistafeedd/Profile%20Page/profilepage.dart';

class StoryPage extends StatefulWidget {
  final String PFP;
  final String username;
  final String storylink;
  final DateTime? UploadDate;
  final String UID;

  StoryPage({
    required this.PFP,
    required this.username,
    required this.storylink,
    required this.UploadDate,
    required this.UID
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with SingleTickerProviderStateMixin {
  Color _backgroundColor = Colors.black; // Default background color
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _getDominantColor();

    // Initialize the animation controller to run for 7 seconds
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..forward();  // Start the animation immediately

    // Automatically pop the page after 7 seconds
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // Function to extract the dominant color from the image
  void _getDominantColor() async {
    final PaletteGenerator paletteGenerator =
    await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.storylink),
    );

    setState(() {
      // Use the dominant color or fallback to black
      _backgroundColor = paletteGenerator.dominantColor?.color ?? Colors.black;
    });
  }

  String time(DateTime? uploadDate) {
    final now = DateTime.now();
    final difference = now.difference(uploadDate!);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} sec ';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day ';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} week ';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} month ';
    } else {
      return '${(difference.inDays / 365).floor()} year ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Image on the screen
          Positioned(
            top: 50, // 20px from the top
            left: 0,
            right: 0,
            child: Image.network(widget.storylink),
          ),

          // Top progress bar
          Positioned(
            top: 60, // Position the bar near the top
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _controller.value, // Link the animation value to progress
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                );
              },
            ),
          ),

          // Story user details
          Positioned(
            top: 70,
            left: 10,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(userid: widget.UID),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    backgroundImage: NetworkImage(widget.PFP),
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(userid: widget.UID),
                      ),
                    );
                  },
                  child: Text(
                    widget.username,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  time(widget.UploadDate),
                  style: GoogleFonts.poppins(
                      color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }
}
