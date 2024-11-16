import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistafeedd/HomePage/homepage.dart';
import 'package:video_player/video_player.dart';
import 'package:vistafeedd/Login%20And%20Signup%20Page/loginpage.dart';
import 'package:vistafeedd/Post%20Details%20Page/postdetails.dart';
import 'package:vistafeedd/Profile%20Page%20Details/followerspage.dart';
import 'package:vistafeedd/Profile%20Page%20Details/followingpage.dart';
import 'package:vistafeedd/Reels%20Section%20Page/reelviewingpage.dart';
import 'package:vistafeedd/Search%20Page/searchandexploresection.dart';
import 'package:vistafeedd/Story%20Page/Create_Story.dart';
import 'package:vistafeedd/Story%20Page/stories.dart';
import 'package:vistafeedd/Upload%20Post/CreatePost.dart';
class ProfilePage extends StatefulWidget {
  final String userid;
  ProfilePage({required this.userid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String pfp = '';
  late VideoPlayerController _controller1;
  String usernames = '';
  String bio = '';
  bool isprivate = false;
  bool isverified = false;
  Future<void> fetchpfp() async {
    final docsnap = await _firestore
        .collection('User Details')
        .doc(widget.userid)
        .get();
    if (docsnap.exists) {
      setState(() {
        pfp = docsnap.data()?['Profile Pic'];
        usernames = docsnap.data()?['Name'];
        bio = docsnap.data()?['Bio'];
        isprivate = docsnap.data()?['Private Account'];
        isverified = docsnap.data()?['Verified'];
      });
    }
    if (kDebugMode) {
      print('Verified $isverified');
    }
  }

  List<dynamic> following = [];
  List<dynamic> followers = [];
  Future<void> fetchfollowing() async {
    final docsnap = await _firestore
        .collection('Following')
        .doc(widget.userid)
        .get();
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
    final docsnap = await _firestore
        .collection('Followers')
        .doc(widget.userid)
        .get();
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
        if (postSnap.data()?['Uploaded UID'] == widget.userid) {
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
  List<dynamic> ReelThumbnail=[];
  Future<void> fetchReels() async {
    List<dynamic> postIDList = [];
    List<dynamic> matchingPostIds =
    []; // To store multiple matching post IDs if needed
    List<dynamic> matchingPostImages = [];
    List<dynamic> matchingreelImages = [];

    final docSnap =
    await _firestore.collection('Reels ID').doc('RID').get();
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
        if (postSnap.data()?['Uploaded UID'] == _auth.currentUser?.uid) {
          matchingPostIds.add(postSnap.data()?['reelid']);
          matchingPostImages.add(postSnap.data()?['Video ID']);
          matchingreelImages.add(postSnap.data()?['Thumbnail']);
        }
      }
    }

    setState(() {
      RIDS = matchingPostIds;
      ReelVideos = matchingPostImages;
      ReelThumbnail=matchingreelImages;
    });
    if (kDebugMode) {
      print('Matching Reel IDs: $matchingPostImages');
    }
  }
  String storyURL = '';
  DateTime? uploaddate;
  Future<void> fetchstories() async {
    final docsnap = await _firestore.collection('Stories').doc(widget.userid).get();
    if (docsnap.exists) {
      storyURL = docsnap.data()?['Story Link'] ?? '';
      Timestamp? timestamp = docsnap.data()?['Upload Date'];
      uploaddate = timestamp?.toDate();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchpfp();
    fetchfollowing();
    fetchfollower();
    fetchPosts();
    fetchReels();
    fetchstories();
  }
  bool ispostsecttion=true;
  bool isreelsection=false;
  bool istaggedsection=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateStory(),));
                },
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: SvgPicture.string('<svg aria-label="New post" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>New post</title><path d="M2 12v3.45c0 2.849.698 4.005 1.606 4.944.94.909 2.098 1.608 4.946 1.608h6.896c2.848 0 4.006-.7 4.946-1.608C21.302 19.455 22 18.3 22 15.45V8.552c0-2.849-.698-4.006-1.606-4.945C19.454 2.7 18.296 2 15.448 2H8.552c-2.848 0-4.006.699-4.946 1.607C2.698 4.547 2 5.703 2 8.552Z" fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="6.545" x2="17.455" y1="12.001" y2="12.001"></line><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="12.003" x2="12.003" y1="6.545" y2="17.455"></line></svg>'),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: ()async{
                  await _auth.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                },
                child: const SizedBox(
                  height: 22,
                  width: 22,
                  child: Icon(Icons.login,color: Colors.red,)
                  // SvgPicture.string('<svg aria-label="Settings" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" '
                  //     'role="img" viewBox="0 0 24 24" width="24"><title>Settings</title><line fill="none" stroke="white" stroke-linecap="round" '
                  //     'stroke-linejoin="round" stroke-width="2" x1="3" x2="21" y1="4" y2="4"></line><line fill="none" stroke="white" stroke-linecap="round" '
                  //     'stroke-linejoin="round" stroke-width="2" x1="3" x2="21" y1="12" y2="12"></line><line fill="none" stroke="white" stroke-linecap="round" '
                  //     'stroke-linejoin="round" stroke-width="2" x1="3" x2="21" y1="20" y2="20"></line></svg>'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          )
        ],
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isprivate
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: SvgPicture.string(
                        '<svg xmlns="http://www.w3.org/2000/svg" fill="#FFFFFF" viewBox="0 0 50 50" width="20px" height="20px"><path d="M 25 3 C 18.363281 3 13 8.363281 13 15 L 13 20 L 9 20 C 7.355469 20 6 21.355469 6 23 L 6 47 C 6 48.644531 7.355469 50 9 50 L 41 50 C 42.644531 50 44 48.644531 44 47 L 44 23 C 44 21.355469 42.644531 20 41 20 L 37 20 L 37 15 C 37 8.363281 31.636719 3 25 3 Z M 25 5 C 30.566406 5 35 9.433594 35 15 L 35 20 L 15 20 L 15 15 C 15 9.433594 19.433594 5 25 5 Z M 9 22 L 41 22 C 41.554688 22 42 22.445313 42 23 L 42 47 C 42 47.554688 41.554688 48 41 48 L 9 48 C 8.445313 48 8 47.554688 8 47 L 8 23 C 8 22.445313 8.445313 22 9 22 Z M 25 30 C 23.300781 30 22 31.300781 22 33 C 22 33.898438 22.398438 34.6875 23 35.1875 L 23 38 C 23 39.101563 23.898438 40 25 40 C 26.101563 40 27 39.101563 27 38 L 27 35.1875 C 27.601563 34.6875 28 33.898438 28 33 C 28 31.300781 26.699219 30 25 30 Z"/></svg>'),
                  )
                : Container(),
            const SizedBox(
              width: 10,
            ),
            Text(
              usernames,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 55,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: SvgPicture.string(
                  '<svg aria-label="Home" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Home</title><path d="M9.005 16.545a2.997 2.997 0 0 1 2.997-2.997A2.997 2.997 0 0 1 15 16.545V22h7V11.543L12 2 2 11.543V22h7.005Z" fill="none" stroke="white" stroke-linejoin="round" stroke-width="2"></path></svg>'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchAndExplorePage(),));
              },
              child: SvgPicture.string(
                  '<svg aria-label="Search" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Search</title><path d="M19 10.5A8.5 8.5 0 1 1 10.5 2a8.5 8.5 0 0 1 8.5 8.5Z" fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="16.511" x2="22" y1="16.511" y2="22"></line></svg>'),
            ),
            InkWell(
              onTap: (){},
              child: SizedBox(
                height: 22,
                width: 22,
                child: SvgPicture.string('<svg aria-label="New post" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>New post</title><path d="M2 12v3.45c0 2.849.698 4.005 1.606 4.944.94.909 2.098 1.608 4.946 1.608h6.896c2.848 0 4.006-.7 4.946-1.608C21.302 19.455 22 18.3 22 15.45V8.552c0-2.849-.698-4.006-1.606-4.945C19.454 2.7 18.296 2 15.448 2H8.552c-2.848 0-4.006.699-4.946 1.607C2.698 4.547 2 5.703 2 8.552Z" fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="6.545" x2="17.455" y1="12.001" y2="12.001"></line><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="12.003" x2="12.003" y1="6.545" y2="17.455"></line></svg>'),
              ),
            ),
            // InkWell(
            //   onTap: () {},
            //   child: SvgPicture.string(
            //       '<svg aria-label="Explore" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Explore</title><polygon fill="none" points="13.941 13.953 7.581 16.424 10.06 10.056 16.42 7.585 13.941 13.953" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></polygon><polygon fill-rule="evenodd" points="10.06 10.056 13.949 13.945 7.581 16.424 10.06 10.056"></polygon><circle cx="12.001" cy="12.005" fill="none" r="10.5" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></circle></svg>'),
            // ),
            InkWell(
              onTap: () {},
              child: SvgPicture.string(
                  '<svg aria-label="Reels" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Reels</title><line fill="none" stroke="white" stroke-linejoin="round" stroke-width="2" x1="2.049" x2="21.95" y1="7.002" y2="7.002"></line><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="13.504" x2="16.362" y1="2.001" y2="7.002"></line><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="7.207" x2="10.002" y1="2.11" y2="7.002"></line><path d="M2 12.001v3.449c0 2.849.698 4.006 1.606 4.945.94.908 2.098 1.607 4.946 1.607h6.896c2.848 0 4.006-.699 4.946-1.607.908-.939 1.606-2.096 1.606-4.945V8.552c0-2.848-.698-4.006-1.606-4.945C19.454 2.699 18.296 2 15.448 2H8.552c-2.848 0-4.006.699-4.946 1.607C2.698 4.546 2 5.704 2 8.552Z" fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path><path d="M9.763 17.664a.908.908 0 0 1-.454-.787V11.63a.909.909 0 0 1 1.364-.788l4.545 2.624a.909.909 0 0 1 0 1.575l-4.545 2.624a.91.91 0 0 1-.91 0Z" fill-rule="evenodd"></path></svg>'),
            ),
            // InkWell(
            //   onTap: () {},
            //   child: SvgPicture.string(
            //       '<svg aria-label="Messenger" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Messenger</title><path d="M12.003 2.001a9.705 9.705 0 1 1 0 19.4 10.876 10.876 0 0 1-2.895-.384.798.798 0 0 0-.533.04l-1.984.876a.801.801 0 0 1-1.123-.708l-.054-1.78a.806.806 0 0 0-.27-.569 9.49 9.49 0 0 1-3.14-7.175 9.65 9.65 0 0 1 10-9.7Z" fill="none" stroke="white" stroke-miterlimit="10" stroke-width="1.739"></path><path d="M17.79 10.132a.659.659 0 0 0-.962-.873l-2.556 2.05a.63.63 0 0 1-.758.002L11.06 9.47a1.576 1.576 0 0 0-2.277.42l-2.567 3.98a.659.659 0 0 0 .961.875l2.556-2.049a.63.63 0 0 1 .759-.002l2.452 1.84a1.576 1.576 0 0 0 2.278-.42Z" fill-rule="evenodd"></path></svg>'),
            // ),
            // InkWell(
            //   onTap: () {},
            //   child: SvgPicture.string(
            //       '<svg aria-label="Notifications" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Notifications</title><path d="M16.792 3.904A4.989 4.989 0 0 1 21.5 9.122c0 3.072-2.652 4.959-5.197 7.222-2.512 2.243-3.865 3.469-4.303 3.752-.477-.309-2.143-1.823-4.303-3.752C5.141 14.072 2.5 12.167 2.5 9.122a4.989 4.989 0 0 1 4.708-5.218 4.21 4.21 0 0 1 3.675 1.941c.84 1.175.98 1.763 1.12 1.763s.278-.588 1.11-1.766a4.17 4.17 0 0 1 3.679-1.938m0-2a6.04 6.04 0 0 0-4.797 2.127 6.052 6.052 0 0 0-4.787-2.127A6.985 6.985 0 0 0 .5 9.122c0 3.61 2.55 5.827 5.015 7.97.283.246.569.494.853.747l1.027.918a44.998 44.998 0 0 0 3.518 3.018 2 2 0 0 0 2.174 0 45.263 45.263 0 0 0 3.626-3.115l.922-.824c.293-.26.59-.519.885-.774 2.334-2.025 4.98-4.32 4.98-7.94a6.985 6.985 0 0 0-6.708-7.218Z"></path></svg>'),
            // ),
            InkWell(

              child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
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
            )
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: InkWell(
                    onTap: () {
                      if(storyURL!=''){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => StoryPage(
                            PFP: pfp,
                            username: usernames,
                            storylink: storyURL,
                            UploadDate: uploaddate,
                            UID: widget.userid),));
                      }else{
                        final imageProvider = Image.network(pfp).image;
                        showImageViewer(context, imageProvider, onViewerDismissed: () {
                          if (kDebugMode) {
                            print("dismissed");
                          }
                        });
                      }
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          pfp,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${PIDS.length+RIDS.length}',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                    Text(
                      'posts',
                      style: GoogleFonts.poppins(color: Colors.white),
                    )
                  ],
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FollowerPage(
                        followerslist: followers,
                        UID: widget.userid,
                        username: usernames),));
                  },
                  child: Column(
                    children: [
                      Text(
                        '${followers.length}',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                      Text(
                        'followers',
                        style: GoogleFonts.poppins(color: Colors.white),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FollowingPage(followerslist: following, username: usernames,UID:widget.userid,),));
                  },
                  child: Column(
                    children: [
                      Text(
                        '${following.length}',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                      Text(
                        'following',
                        style: GoogleFonts.poppins(color: Colors.white),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Row(
                  children: [
                    Text(
                      usernames,
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    isverified
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: Image(
                                image: NetworkImage(
                                    'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Ficons8-verified-badge-48.png?alt=media&token=db0c0b9f-2f66-4401-a60b-11268ef68b2b')))
                        : Container()
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Text(
                  bio,
                  style: GoogleFonts.poppins(color: Colors.white),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // const SizedBox(
                //   width: 30,
                // ),
                Container(
                  height: 35,
                  width: MediaQuery.sizeOf(context).width / 2.5,
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(54, 54, 54, 7),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  width: MediaQuery.sizeOf(context).width / 2.5,
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(54, 54, 54, 7),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: Text(
                      'Share Profile',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    height: 25,
                    width: 25,
                    child: Column(
                      children: [
                        InkWell(
                          onTap:(){
                            setState(() {
                              if(!ispostsecttion){
                                setState(() {
                                  ispostsecttion=true;
                                  isreelsection=false;
                                  istaggedsection=false;
                                });
                              }
                            });
                          },
                          child: SvgPicture.string(
                             ispostsecttion? '<svg aria-label="" class="x1lliihq x1n2onr6 x5n08af" fill="white" '
                                 'height="40" role="img" viewBox="0 0 24 24" width="40"><title></title><rect fill="none" height="18"'
                                 ' stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" width="18" x="3" y="3">'
                                 '</rect><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" '
                                 'x1="9.015" x2="9.015" y1="3" y2="21"></line><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round"'
                                 ' stroke-width="2" x1="14.985" x2="14.985" y1="3" y2="21"></line><line fill="none" stroke="white" stroke-linecap="round" '
                                 'stroke-linejoin="round" stroke-width="2" x1="21" x2="3" y1="9.015" y2="9.015"></line><line fill="none" stroke="white" '
                                 'stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="21" x2="3" y1="14.985" y2="14.985"></line></svg>':
                             '<svg aria-label="" class="x1lliihq x1n2onr6 x5n08af" fill="#A5A4A1" '
                                 'height="40" role="img" viewBox="0 0 24 24" width="40"><title></title><rect fill="none" height="18"'
                                 ' stroke="#A5A4A1" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" width="18" x="3" y="3">'
                                 '</rect><line fill="none" stroke="#A5A4A1" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" '
                                 'x1="9.015" x2="9.015" y1="3" y2="21"></line><line fill="none" stroke="#A5A4A1" stroke-linecap="round" stroke-linejoin="round"'
                                 ' stroke-width="2" x1="14.985" x2="14.985" y1="3" y2="21"></line><line fill="none" stroke="#A5A4A1" stroke-linecap="round" '
                                 'stroke-linejoin="round" stroke-width="2" x1="21" x2="3" y1="9.015" y2="9.015"></line><line fill="none" stroke="#A5A4A1" '
                                 'stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="21" x2="3" y1="14.985" y2="14.985"></line></svg>'
                          )

                        )
                        // const SizedBox(
                        //   height: 2,
                        // ),
                        // Container(
                        //   height: 2,
                        //   width: 30,
                        //   color: Colors.white,
                        // )
                      ],
                    )),
                SizedBox(
                  height: 25,
                  width: 25,
                  child: InkWell(
                    onTap: () {
                      if(!isreelsection){
                       setState(() {
                         ispostsecttion=false;
                         isreelsection=true;
                         istaggedsection=false;
                       });
                      }
                    },
                    child: SvgPicture.string(
                       !isreelsection? '<svg aria-label="Reels" class="x1lliihq x1n2onr6 x5n08af" fill="#A5A4A1" '
                            'height="24" role="img" viewBox="0 0 24 24" width="24"><title>Reels</title>'
                            '<line fill="none" stroke="#A5A4A1" stroke-linejoin="round" stroke-width="2" x1="2.049" x2="21.95"'
                            ' y1="7.002" y2="7.002"></line><line fill="none" stroke="#A5A4A1" stroke-linecap="round" stroke-linejoin="round"'
                            ' stroke-width="2" x1="13.504" x2="16.362" y1="2.001" y2="7.002"></line><line fill="none" stroke="#A5A4A1" '
                            'stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="7.207" x2="10.002" y1="2.11" y2="7.002">'
                            '</line><path d="M2 12.001v3.449c0 2.849.698 4.006 1.606 4.945.94.908 2.098 1.607 4.946 1.607h6.896c2.848 0 4.006-.699 4.'
                            '946-1.607.908-.939 1.606-2.096 1.606-4.945V8.552c0-2.848-.698-4.006-1.606-4.945C19.454 2.699 18.296 2 15.448 2H8.552c-2.8'
                            '48 0-4.006.699-4.946 1.607C2.698 4.546 2 5.704 2 8.552Z" fill="none" stroke="#A5A4A1" stroke-linecap="round" stroke-linejoin="round" '
                            'stroke-width="2"></path><path d="M9.763 17.664a.908.908 0 0 1-.454-.787V11.63a.909.909 0 0 1 1.364-.788l4.545 2.624a.909.909 0 0 1 '
                            '0 1.575l-4.545 2.624a.91.91 0 0 1-.91 0Z" fill-rule="evenodd"></path></svg>':
                       '<svg aria-label="Reels" class="x1lliihq x1n2onr6 x5n08af" fill="white" '
                           'height="24" role="img" viewBox="0 0 24 24" width="24"><title>Reels</title>'
                           '<line fill="none" stroke="white" stroke-linejoin="round" stroke-width="2" x1="2.049" x2="21.95"'
                           ' y1="7.002" y2="7.002"></line><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round"'
                           ' stroke-width="2" x1="13.504" x2="16.362" y1="2.001" y2="7.002"></line><line fill="none" stroke="white" '
                           'stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="7.207" x2="10.002" y1="2.11" y2="7.002">'
                           '</line><path d="M2 12.001v3.449c0 2.849.698 4.006 1.606 4.945.94.908 2.098 1.607 4.946 1.607h6.896c2.848 0 4.006-.699 4.'
                           '946-1.607.908-.939 1.606-2.096 1.606-4.945V8.552c0-2.848-.698-4.006-1.606-4.945C19.454 2.699 18.296 2 15.448 2H8.552c-2.8'
                           '48 0-4.006.699-4.946 1.607C2.698 4.546 2 5.704 2 8.552Z" fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" '
                           'stroke-width="2"></path><path d="M9.763 17.664a.908.908 0 0 1-.454-.787V11.63a.909.909 0 0 1 1.364-.788l4.545 2.624a.909.909 0 0 1 '
                           '0 1.575l-4.545 2.624a.91.91 0 0 1-.91 0Z" fill-rule="evenodd"></path></svg>'
                    ),
                  ),
                ),
                SizedBox(
                    height: 25,
                    width: 25,
                    child:InkWell(
                      onTap: (){
                        if(!istaggedsection){
                          setState(() {
                            ispostsecttion=false;
                            isreelsection=false;
                            istaggedsection=true;
                          });
                        }
                      },
                      child: SvgPicture.string(
                         !istaggedsection? '<svg aria-label="" class="x1lliihq x1n2onr6 x1roi4f4" fill="#A5A4A1" height="12" role="img" viewBox="0 0 24 24"'
                              ' width="12"><title></title><path d="M10.201 3.797 12 1.997l1.799 1.8a1.59 1.59 0 0 0 1.124.465h5.259A1.818 1.'
                              '818 0 0 1 22 6.08v14.104a1.818 1.818 0 0 1-1.818 1.818H3.818A1.818 1.818 0 0 1 2 20.184V6.08a1.818 1.818 0 0 1 1.818-1.'
                              '818h5.26a1.59 1.59 0 0 0 1.123-.465Z" fill="none" stroke="#A5A4A1" stroke-linecap="round" stroke-linejoin="round" stroke-width="2">'
                              '</path><path d="M18.598 22.002V21.4a3.949 3.949 0 0 0-3.948-3.949H9.495A3.949 3.949 0 0 0 5.546 21.4v.603" fill="none" stroke="#A5A4A1"'
                              ' stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path><circle cx="12.072" cy="11.075" fill="none" r="3.556"'
                              ' stroke="#A5A4A1" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></circle></svg>':
                         '<svg aria-label="" class="x1lliihq x1n2onr6 x1roi4f4" fill="white" height="12" role="img" viewBox="0 0 24 24"'
                             ' width="12"><title></title><path d="M10.201 3.797 12 1.997l1.799 1.8a1.59 1.59 0 0 0 1.124.465h5.259A1.818 1.'
                             '818 0 0 1 22 6.08v14.104a1.818 1.818 0 0 1-1.818 1.818H3.818A1.818 1.818 0 0 1 2 20.184V6.08a1.818 1.818 0 0 1 1.818-1.'
                             '818h5.26a1.59 1.59 0 0 0 1.123-.465Z" fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2">'
                             '</path><path d="M18.598 22.002V21.4a3.949 3.949 0 0 0-3.948-3.949H9.495A3.949 3.949 0 0 0 5.546 21.4v.603" fill="none" stroke="white"'
                             ' stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path><circle cx="12.072" cy="11.075" fill="none" r="3.556"'
                             ' stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></circle></svg>'
                      ))
                  ,
                    )

                  ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
              ispostsecttion?  Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.start,  // Align items to the start (left side)
                    runAlignment: WrapAlignment.start,  // Align rows to the top
                    spacing: 10.0,  // Space between items horizontally
                    runSpacing: 10.0,  // Space between lines vertically
                    children: List.generate(PIDS.length, (i) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 3 - 20,  // Adjust to fit 3 items per row
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetails(
                              UID: widget.userid,
                            ),));
                          },
                          child: Image(
                            image: NetworkImage(PostImages[i]),
                            height: 150,
                            width: MediaQuery.of(context).size.width / 3 - 20,  // Same as width to maintain aspect ratio
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                  ),
                ):
                isreelsection?Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.start,  // Align items to the start (left side)
                    runAlignment: WrapAlignment.start,  // Align rows to the top
                    spacing: 10.0,  // Space between items horizontally
                    runSpacing: 10.0,  // Space between lines vertically
                    children: List.generate(RIDS.length, (i) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 3 - 20,  // Adjust to fit 3 items per row
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ReelViewing(ReelVideoID: ReelVideos[i],
                              thumbnail: ReelThumbnail[i],
                              RID: RIDS[i],),));
                          },
                          child: Image(
                            image: NetworkImage(ReelThumbnail[i]),
                            height: 150,
                            width: MediaQuery.of(context).size.width / 3 - 20,  // Same as width to maintain aspect ratio
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                  ),
                ):Container()
                ,
              ],
            )


          ],
        ),
      ),
    );
  }
}
