import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vistafeedd/HomePage/homepage.dart';
import 'package:video_player/video_player.dart';
import 'package:vistafeedd/Post%20Details%20Page/postdetails.dart';
import 'package:vistafeedd/Profile%20Page%20Details/followerspage.dart';
import 'package:vistafeedd/Profile%20Page%20Details/followingpage.dart';
import 'package:vistafeedd/Profile%20Page/Profile_Card.dart';
import 'package:vistafeedd/Reels%20Section%20Page/reelviewingpage.dart';
import 'package:vistafeedd/Story%20Page/stories.dart';
class OtherProfilePage extends StatefulWidget {
  final String userid;
  OtherProfilePage({required this.userid});

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String pfp = '';
  late VideoPlayerController _controller1;
  String usernames = '';
  String bio = '';
  bool isprivate = false;
  bool isverified = false;
  String Link='';
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
        Link=docsnap.data()?['Link'];
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
      print('Follower owner: $followers');
    }
  }

  List<dynamic> PIDS = [];
  List<dynamic> PostImages = [];
  List<dynamic> followersonly=[];
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
          followersonly.add(postSnap.data()?['Followers Only']);
        }
      }
    }

    setState(() {
      PIDS = matchingPostIds;
      PostImages = matchingPostImages;
    });
    if (kDebugMode) {
      print('Matching Post IDs: $followersonly');
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
        if (postSnap.data()?['Uploaded UID'] == widget.userid) {
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
  List<dynamic> storyviewers=[];
  Future<void> fetchstories() async {
    final docsnap = await _firestore.collection('Stories').doc(widget.userid).get();
    if (docsnap.exists) {
      storyURL = docsnap.data()?['Story Link'] ?? '';
      Timestamp? timestamp = docsnap.data()?['Upload Date'];
      uploaddate = timestamp?.toDate();
      storyviewers=(docsnap.data()?['Viewers']);
    }
    print('Viewers $storyviewers');
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when widget is disposed
    super.dispose();
  }

  void _startAnimationAndNavigate()async {
    await fetchstories();
    _controller.forward(); // Start rotation
    // Delay navigation until after the animation completes (5 seconds)
    if(storyURL!=''){
      Future.delayed(Duration(seconds: 5), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryPage(
              PFP: pfp,
              username:usernames,
              storylink: storyURL,
              UploadDate:uploaddate,
              UID: widget.userid,
            ),
          ),
        );
      });
    }else{
      final imageProvider = Image.network(pfp).image;
      showImageViewer(context, imageProvider, onViewerDismissed: () {
        if (kDebugMode) {
          print("dismissed");
        }
      });
    }
  }
  bool ispostsecttion=true;
  bool isreelsection=false;
  bool istaggedsection=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  usernames,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(
                  width: 10,
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
        actions: [
          Row(
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileCard(name: usernames, pfp: pfp, bio: bio),));
                },
                child: SvgPicture.string('<svg aria-label="Share" class="x1lliihq x1n2onr6 xyb1xck" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Share</title><line fill="none" stroke="white" stroke-linejoin="round" stroke-width="2" x1="22" x2="9.218" y1="3" y2="10.083"></line><polygon fill="none" points="11.698 20.334 22 3.001 2 3.001 9.218 10.084 11.698 20.334" stroke="white" stroke-linejoin="round" stroke-width="2"></polygon></svg>'),
                  
              ),
               const SizedBox(
                width: 10,
              ),
            ],
          )
           ],
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
                  child: GestureDetector(
                    onTap: _startAnimationAndNavigate,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer rotating container with gradient border
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient:storyviewers.contains(_auth.currentUser!.uid)? const LinearGradient(
                                colors: [
                                  Colors.green,
                                  Colors.yellow
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ):const LinearGradient(
                                colors: [
                                  Color(0xFF833AB4), // Purple
                                  Color(0xFFF77737), // Orange
                                  Color(0xFFE1306C), // Red
                                  Color(0xFFC13584), // Magenta
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        // Inner static container with the profile picture
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
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
                      ],
                    ),
                  )
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FollowerPage(followerslist: followers, username: usernames,UID:widget.userid),));
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FollowingPage(followerslist: following, username: usernames,UID:widget.userid
                    ),));
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
           Link!=''? Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 30,
                    ),
                    const Icon(Icons.link,color: Colors.white,),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap:()async{
                        await launchUrl(Uri.parse('https://$Link'));
                      },
                      child: Text(
                        Link,
                        style: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ):Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // const SizedBox(
                //   width: 30,
                // ),
                InkWell(
                  onTap: ()async{
                    if(followers.contains(_auth.currentUser!.uid)){
                      await _firestore.collection('Followers').doc(widget.userid).set(
                          {
                            'Followers ID':FieldValue.arrayRemove([_auth.currentUser!.uid])
                          },SetOptions(merge: true));
                      await _firestore.collection('Following').doc(_auth.currentUser!.uid).set(
                          {
                            'Following ID':FieldValue.arrayRemove([widget.userid])
                          },SetOptions(merge: true));
                      setState(() {
                        followers.remove(_auth.currentUser!.uid);
                      });
                    }else{
                      await _firestore.collection('Followers').doc(widget.userid).set(
                          {
                            'Followers ID':FieldValue.arrayUnion([_auth.currentUser!.uid])
                          },SetOptions(merge: true));
                      await _firestore.collection('Following').doc(_auth.currentUser!.uid).set(
                          {
                            'Following ID':FieldValue.arrayUnion([widget.userid])
                          },SetOptions(merge: true));
                      setState(() {
                        followers.add(_auth.currentUser!.uid);
                      });
                    }
                  },
                  child: Container(
                    height: 35,
                    width: MediaQuery.sizeOf(context).width / 2.5,
                    decoration:  BoxDecoration(
                        color:!followers.contains(_auth.currentUser!.uid)?Color.fromRGBO(0, 149, 246, 7): Color.fromRGBO(54, 54, 54, 7),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Center(
                      child: Text( //b follows a but a doesnot follow b
                        //following - me but followers not me followback
                        followers.contains(_auth.currentUser!.uid)?'Following':following.contains(_auth.currentUser!.uid)&&!followers.contains(_auth.currentUser!.uid)?
                        'Follow Back':'Follow',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
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
                      'Message',
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
                          child:followers.contains(_auth.currentUser!.uid)? Image(
                            image: NetworkImage(PostImages[i]),
                            height: 150,
                            width: MediaQuery.of(context).size.width / 3 - 20,  // Same as width to maintain aspect ratio
                            fit: BoxFit.cover,
                          ):!followersonly[i]?Image(
                            image: NetworkImage(PostImages[i]),
                            height: 150,
                            width: MediaQuery.of(context).size.width / 3 - 20,  // Same as width to maintain aspect ratio
                            fit: BoxFit.cover,
                          ):Container()
                          ,
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ReelViewing(ReelVideoID: ReelVideos[i],thumbnail: ReelThumbnail[i],RID: RIDS[i],),));
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
