import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:vistafeedd/Profile%20Page/otherprofilepage.dart';
import 'package:vistafeedd/Profile%20Page/profilepage.dart';

class PostDetails extends StatefulWidget {
  final String UID;
  PostDetails({required this.UID});
  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String pfp = '';
  late VideoPlayerController _controller1;
  String usernames = '';
  String bio = '';
  Future<void> fetchpfp() async {
    final docsnap =
        await _firestore.collection('User Details').doc(widget.UID).get();
    if (docsnap.exists) {
      setState(() {
        pfp = docsnap.data()?['Profile Pic'];
        usernames = docsnap.data()?['Name'];
        bio = docsnap.data()?['Bio'];
      });
    }
  }

  List<dynamic> following = [];
  List<dynamic> followers = [];
  Future<void> fetchfollowing() async {
    final docsnap =
        await _firestore.collection('Following').doc(widget.UID).get();
    if (docsnap.exists) {
      setState(() {
        following = docsnap.data()?['Following ID'] ?? [];
      });
    }
    if (kDebugMode) {
      print('Following: $following');
    }
  }

  Future<void> fetchfollower() async {
    final docsnap =
        await _firestore.collection('Followers').doc(widget.UID).get();
    if (docsnap.exists) {
      setState(() {
        followers = docsnap.data()?['Followers ID'] ?? [];
      });
    }
    if (kDebugMode) {
      print('Follower: $followers');
    }
  }

  List<dynamic> PIDS = [];
  List<dynamic> PostImages = [];
  Future<void> fetchPosts() async {
    List<dynamic> postIDList = [];
    List<dynamic> matchingPostIds =
        []; // To store multiple matching post IDs if needed
    List<dynamic> matchingPostImages = [];

    final docSnap =
        await _firestore.collection('Global Post IDs').doc('Posts').get();
    if (docSnap.exists) {
      postIDList = docSnap.data()?['Post IDs'] ?? [];
    }

    if (kDebugMode) {
      print("Fetched Post IDs: $postIDList");
    }

    for (String postId in postIDList) {
      final postSnap =
          await _firestore.collection('Global Post').doc(postId).get();
      if (postSnap.exists) {
        if (postSnap.data()?['Uploaded UID'] == widget.UID) {
          matchingPostIds.add(postSnap.data()?['postid']);
          matchingPostImages.add(postSnap.data()?['Image Link']);
        }
      }
    }

    setState(() {
      PIDS = matchingPostIds;
      PostImages = matchingPostImages;
    });
    if (kDebugMode) {
      print('Matching Post IDs: $matchingPostImages');
    }
  }

  List<dynamic> RIDS = [];
  List<dynamic> ReelVideos = [];
  List<dynamic> ReelThumbnail = [];
  Future<void> fetchReels() async {
    List<dynamic> postIDList = [];
    List<dynamic> matchingPostIds =
        []; // To store multiple matching post IDs if needed
    List<dynamic> matchingPostImages = [];
    List<dynamic> matchingreelImages = [];

    final docSnap = await _firestore.collection('Reels ID').doc('RID').get();
    if (docSnap.exists) {
      postIDList = docSnap.data()?['IDs'] ?? [];
    }

    if (kDebugMode) {
      print("Fetched Reel IDs: $postIDList");
    }

    for (String postId in postIDList) {
      final postSnap =
          await _firestore.collection('Global Reels').doc(postId).get();
      if (postSnap.exists) {
        if (postSnap.data()?['Uploaded UID'] == widget.UID) {
          matchingPostIds.add(postSnap.data()?['reelid']);
          matchingPostImages.add(postSnap.data()?['Video ID']);
          matchingreelImages.add(postSnap.data()?['Thumbnail']);
        }
      }
    }

    setState(() {
      RIDS = matchingPostIds;
      ReelVideos = matchingPostImages;
      ReelThumbnail = matchingreelImages;
    });
    if (kDebugMode) {
      print('Matching Reel IDs: $matchingPostImages');
    }
  }

  List<dynamic> isliked = [];

  Future<void> fetchlikes() async {
    await fetchPosts(); // Ensure posts are fetched and postuid is populated

    if (PIDS.isEmpty) {
      if (kDebugMode) {
        print("postuid is empty. No posts to fetch likes for.");
      }
      return;
    }

    for (int i = 0; i < PIDS.length; i++) {
      final docsnap =
          await _firestore.collection('Post Likes').doc(PIDS[i]).get();

      if (docsnap.exists) {
        final likes = docsnap.data()?['likes'] ?? [];
        isliked.add(likes.contains(_auth.currentUser!.uid));
      } else {
        isliked.add(false); // If doc doesn't exist, assume not liked
      }
    }

    if (kDebugMode) {
      print('Liked: $isliked');
    } // Should now print true/false values
  }

  final TextEditingController _commentController = TextEditingController();
  int number = 0;
  Future<void> generateAndPrint8DigitNumber() async {
    Random random = Random();
    // Generate a random number between 10000000 and 99999999 (inclusive)
    setState(() {
      number = 10000000 + random.nextInt(90000000);
    });
    print('Generated 8-digit number: $number');
  }

  Future<void> writecomment(String postid) async {
    await generateAndPrint8DigitNumber();
    int cid = number;
    await _firestore.collection('Comment IDs').doc(postid).set({
      'IDs': FieldValue.arrayUnion([cid])
    }, SetOptions(merge: true));
    await _firestore.collection('Comment Details').doc(cid.toString()).set({
      'Comment ID': cid,
      'Comment Text': _commentController.text,
      'Comment Owner': _auth.currentUser!.uid,
      'Post ID': postid,
      'Comment Date': FieldValue.serverTimestamp(),
      'Likes': []
    });
  }

  List<dynamic> commenttext = [];
  List<dynamic> commentdate = [];
  List<dynamic> commentuid = [];
  List<dynamic> commentname = [];
  List<dynamic> commentpfp = [];
  List<dynamic> commentid = [];
  Future<void> fetchcomment(String PostID) async {
    if (kDebugMode) {
      print('PID Comment $PostID');
    }
    commentid.clear();
    // commentdate.clear();
    commentdate.clear();
    commentuid.clear();
    commenttext.clear();
    commentname.clear();
    commentpfp.clear();
    final docsnap =
        await _firestore.collection('Comment IDs').doc(PostID).get();
    if (docsnap.exists) {
      setState(() {
        commentid = docsnap.data()?['IDs'] ?? [];
      });
    }
    for (int i = 0; i < commentid.length; i++) {
      final Docsnap = await _firestore
          .collection('Comment Details')
          .doc(commentid[i].toString())
          .get();
      if (Docsnap.exists) {
        setState(() {
          commenttext.add(Docsnap.data()?['Comment Text']);
          commentuid.add(Docsnap.data()?['Comment Owner']);
          commentdate.add(Docsnap.data()?[
              'Comment Date']); // Assuming you meant to fetch 'Comment Date'
        });
      }
    }
    for (int j = 0; j < commentuid.length; j++) {
      final usersnap =
          await _firestore.collection('User Details').doc(commentuid[j]).get();
      if (usersnap.exists) {
        setState(() {
          commentname.add(usersnap.data()?['Name']);
          commentpfp.add(usersnap.data()?['Profile Pic']);
        });
      }
    }
    if (kDebugMode) {
      print("CID $commentname");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  bool isLoading = true;
  Future<void> fetchData() async {
    await fetchpfp();
    await fetchfollowing();
    await fetchfollower();
    await fetchPosts();
    await fetchReels();
    await fetchlikes();
    setState(() {
      isLoading = false; // Set loading to false once data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text(
              'Posts',
              style: GoogleFonts.poppins(color: Colors.white),
            )
          ],
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: PIDS.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                pfp,
                                height: 35,
                                width: 35,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          usernames,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Image(
                      image: NetworkImage(PostImages[index]),
                      width: MediaQuery.sizeOf(context).width * 0.99,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        isliked.length > index
                            ? isliked[index]
                                ? InkWell(
                                    onDoubleTap: () async {
                                      if (isliked[index]) {
                                        await _firestore
                                            .collection('Post Likes')
                                            .doc(PIDS[index])
                                            .set({
                                          'likes': FieldValue.arrayRemove(
                                              [_auth.currentUser!.uid])
                                        }, SetOptions(merge: true));
                                      }
                                      setState(() {
                                        isliked[index] = false;
                                      });
                                    },
                                    onTap: () async {
                                      if (isliked[index]) {
                                        await _firestore
                                            .collection('Post Likes')
                                            .doc(PIDS[index])
                                            .set({
                                          'likes': FieldValue.arrayRemove(
                                              [_auth.currentUser!.uid])
                                        }, SetOptions(merge: true));
                                      }
                                      setState(() {
                                        isliked[index] = false;
                                      });
                                    },
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: SvgPicture.string(
                                        '<svg aria-label="Unlike" fill="red" height="24" viewBox="0 0 48 48" width="24"><path d="M34.6 3.1c-4.5 0-7.9 1.8-10.6 5.6-2.7-3.7-6.1-5.5-10.6-5.5C6 3.1 0 9.6 0 17.6c0 7.3 5.4 12 10.6 16.5.6.5 1.3 1.1 1.9 1.7l2.3 2c4.4 3.9 6.6 5.9 7.6 6.5.5.3 1.1.5 1.6.5s1.1-.2 1.6-.5c1-.6 2.8-2.2 7.8-6.8l2-1.8c.7-.6 1.3-1.2 2-1.7C42.7 29.6 48 25 48 17.6c0-8-6-14.5-13.4-14.5z"></path></svg>',
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onDoubleTap: () async {
                                      if (!isliked[index]) {
                                        await _firestore
                                            .collection('Post Likes')
                                            .doc(PIDS[index])
                                            .set({
                                          'likes': FieldValue.arrayUnion(
                                              [widget.UID])
                                        }, SetOptions(merge: true));
                                      }
                                      setState(() {
                                        isliked[index] = true;
                                      });
                                    },
                                    onTap: () async {
                                      if (!isliked[index]) {
                                        await _firestore
                                            .collection('Post Likes')
                                            .doc(PIDS[index])
                                            .set({
                                          'likes': FieldValue.arrayUnion(
                                              [widget.UID])
                                        }, SetOptions(merge: true));
                                      }
                                      setState(() {
                                        isliked[index] = true;
                                      });
                                    },
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: SvgPicture.string(
                                        '<svg aria-label="Like" fill="white" height="24" viewBox="0 0 24 24" width="24"><path d="M16.792 3.904A4.989 4.989 0 0 1 21.5 9.122c0 3.072-2.652 4.959-5.197 7.222-2.512 2.243-3.865 3.469-4.303 3.752-.477-.309-2.143-1.823-4.303-3.752C5.141 14.072 2.5 12.167 2.5 9.122a4.989 4.989 0 0 1 4.708-5.218 4.21 4.21 0 0 1 3.675 1.941c.84 1.175.98 1.763 1.12 1.763s.278-.588 1.11-1.766a4.17 4.17 0 0 1 3.679-1.938m0-2a6.04 6.04 0 0 0-4.797 2.127 6.052 6.052 0 0 0-4.787-2.127A6.985 6.985 0 0 0 .5 9.122c0 3.61 2.55 5.827 5.015 7.97.283.246.569.494.853.747l1.027.918a44.998 44.998 0 0 0 3.518 3.018 2 2 0 0 0 2.174 0 45.263 45.263 0 0 0 3.626-3.115l.922-.824c.293-.26.59-.519.885-.774 2.334-2.025 4.98-4.32 4.98-7.94a6.985 6.985 0 0 0-6.708-7.218Z"></path></svg>',
                                      ),
                                    ),
                                  )
                            : SizedBox.shrink(),
                        const SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            await fetchcomment(PIDS[index]);
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.black,
                              builder: (context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: [
                                      // Scrollable content above the TextField
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              // Add your content here
                                              for (int i = 0;
                                                  i < commentid.length;
                                                  i++)
                                                Container(
                                                    padding: EdgeInsets.only(
                                                        top: 20, bottom: 35),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 15,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                _auth.currentUser!
                                                                            .uid ==
                                                                        commentuid[
                                                                            i]
                                                                    ? Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ProfilePage(userid: commentuid[i]),
                                                                        ))
                                                                    : Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              OtherProfilePage(userid: commentuid[i]),
                                                                        ));
                                                              },
                                                              child: Container(
                                                                height: 35,
                                                                width: 35,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              50)),
                                                                ),
                                                                child: ClipOval(
                                                                  child: Image
                                                                      .network(
                                                                    commentpfp[
                                                                        i],
                                                                    height: 35,
                                                                    width: 35,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            InkWell(
                                                                onTap: () {
                                                                  _auth.currentUser!
                                                                              .uid ==
                                                                          commentuid[
                                                                              i]
                                                                      ? Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ProfilePage(userid: commentuid[i]),
                                                                          ))
                                                                      : Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                OtherProfilePage(userid: commentuid[i]),
                                                                          ));
                                                                },
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      commentname[
                                                                          i],
                                                                      style: GoogleFonts.poppins(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          commenttext[
                                                                              i],
                                                                          style: GoogleFonts.poppins(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w300,
                                                                              fontSize: 15),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                )),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Fixed TextField at the bottom
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color:
                                            const Color.fromRGBO(31, 41, 55, 1),
                                        child: TextField(
                                          controller: _commentController,
                                          decoration: InputDecoration(
                                            suffixIcon: InkWell(
                                                onTap: () async {
                                                  if (_commentController
                                                      .text.isNotEmpty) {
                                                    await writecomment(
                                                        PIDS[index].toString());
                                                    _commentController.clear();
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: const Icon(
                                                  Icons.send,
                                                  color: Colors.white,
                                                )),
                                            hintText: 'Comment...',
                                            hintStyle: GoogleFonts.poppins(
                                                color: Colors.white),
                                          ),
                                          style: GoogleFonts.poppins(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: SvgPicture.string(
                                '<svg aria-label="Comment" fill="currentColor" height="24" viewBox="0 0 24 24" width="24"><path d="M20.656 17.008a9.993 9.993 0 1 0-3.59 3.615L22 22Z" fill="none" stroke="white" stroke-linejoin="round" stroke-width="2"></path></svg>'),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
    );
  }
}
