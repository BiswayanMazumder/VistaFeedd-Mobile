import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistafeedd/HomePage/homepage.dart';

class Voice_Call_Interface extends StatefulWidget {
  final String UID;
  final String username;
  final String PFP;

  Voice_Call_Interface({
    required this.PFP,
    required this.username,
    required this.UID,
  });

  @override
  State<Voice_Call_Interface> createState() => _Voice_Call_InterfaceState();
}

class _Voice_Call_InterfaceState extends State<Voice_Call_Interface> {
  bool _isMuted = false;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initWebRTC();
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _peerConnection?.close();
    _peerConnection?.dispose();
    super.dispose();
  }

  Future<void> _initWebRTC() async {
    // Get local media stream (audio only)
    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});

    // Configure WebRTC connection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    });

    // Add local stream to connection
    _localStream?.getAudioTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // Handle signaling events (SDP, ICE candidates, etc.)
    _peerConnection?.onIceCandidate = (candidate) {
      // Send ICE candidate to the remote peer
    };

    _peerConnection?.onTrack = (event) {
      // Play incoming audio
    };

    // Add other signaling logic here...
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _localStream?.getAudioTracks()[0].enabled = !_isMuted;
    });
  }

  void _endCall() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background blur image
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
            child: Image.network(
              widget.PFP,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Top controls
          Positioned(
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: 80,
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 20),
                    child: InkWell(
                      onTap: _toggleMute,
                      child: Icon(
                        _isMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, right: 20),
                    child: InkWell(
                      onTap: _endCall,
                      child: Container(
                        height: 50,
                        width: 80,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: const Icon(
                          Icons.call_end_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // User info
          Positioned(
            top: MediaQuery.sizeOf(context).height / 4,
            left: (MediaQuery.sizeOf(context).width / 2) - 75,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundImage: NetworkImage(widget.PFP),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.username,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
