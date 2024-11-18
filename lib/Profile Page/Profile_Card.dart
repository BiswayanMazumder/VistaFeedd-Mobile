import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value, // Rotate the whole container
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
                                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            widget.bio,
                            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
