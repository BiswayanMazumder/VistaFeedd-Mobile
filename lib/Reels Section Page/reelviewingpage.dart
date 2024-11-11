import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class ReelViewing extends StatefulWidget {
  final String ReelVideoID;
  final String thumbnail;
  ReelViewing({required this.ReelVideoID, required this.thumbnail});

  @override
  State<ReelViewing> createState() => _ReelViewingState();
}

class _ReelViewingState extends State<ReelViewing> {
  late VideoPlayerController _controller1;

  @override
  void initState() {
    super.initState();
    _controller1 = VideoPlayerController.networkUrl(Uri.parse(widget.ReelVideoID))
      ..initialize().then((_) {
        setState(() {
          _controller1.setLooping(true); // Enable looping
          _controller1.play(); // Start playing
        });
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
          child: Icon(CupertinoIcons.back, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: _controller1.value.isInitialized
              ? Stack(
            children: [
              // Video player
              Container(
                width: MediaQuery.sizeOf(context).width,
                child: AspectRatio(
                  aspectRatio: _controller1.value.aspectRatio,
                  child: VideoPlayer(_controller1),
                ),
              ),
              // Text Overlay (centered on the right-most side)
              Positioned(
                right: 16.0, // Distance from the right edge
                top: MediaQuery.sizeOf(context).height / 2 - 24, // Center vertically
                child: Column(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: SvgPicture.string(
                        '<svg aria-label="Like" fill="white" height="24" viewBox="0 0 24 24" width="24"><path d="M16.792 3.904A4.989 4.989 0 0 1 21.5 9.122c0 3.072-2.652 4.959-5.197 7.222-2.512 2.243-3.865 3.469-4.303 3.752-.477-.309-2.143-1.823-4.303-3.752C5.141 14.072 2.5 12.167 2.5 9.122a4.989 4.989 0 0 1 4.708-5.218 4.21 4.21 0 0 1 3.675 1.941c.84 1.175.98 1.763 1.12 1.763s.278-.588 1.11-1.766a4.17 4.17 0 0 1 3.679-1.938m0-2a6.04 6.04 0 0 0-4.797 2.127 6.052 6.052 0 0 0-4.787-2.127A6.985 6.985 0 0 0 .5 9.122c0 3.61 2.55 5.827 5.015 7.97.283.246.569.494.853.747l1.027.918a44.998 44.998 0 0 0 3.518 3.018 2 2 0 0 0 2.174 0 45.263 45.263 0 0 0 3.626-3.115l.922-.824c.293-.26.59-.519.885-.774 2.334-2.025 4.98-4.32 4.98-7.94a6.985 6.985 0 0 0-6.708-7.218Z"></path></svg>',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              : const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
