import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vistafeedd/Profile%20Page/otherprofilepage.dart';
import 'package:vistafeedd/Profile%20Page/profilepage.dart';
import 'package:vistafeedd/Search%20Page/searchandexploresection.dart';
import 'package:vistafeedd/Story%20Page/stories.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<dynamic> following = [];
  List<dynamic> postimages = [];
  List<dynamic> postuid = [];
  List<dynamic> postusername = [];
  List<dynamic> postcaption = [];
  List<dynamic> postdate = [];
  List<dynamic> postuserpfps = [];
  List<dynamic> likedusers = [];
  List<dynamic> verification = [];
  List<dynamic> PID = [];
  List<dynamic> isliked = [];
  List<dynamic> savedposts = [];
  List<dynamic> storiesurl = [];
  List<dynamic> storiesuploaderuid = [];
  List<dynamic> storiesuploaddate = [];
  List<dynamic> storiesuploadname = [];
  List<dynamic> storiesuploadpfp = [];
  List<DateTime?> uploaddates=[];
  String pfp = '';
  String usernames = '';
  String PFP = '';
  String username = '';
  String storyURL = '';
  DateTime? uploaddate;

// Fetch the list of following users
  Future<void> fetchfollowing() async {
    final docsnap = await _firestore.collection('Following').doc(_auth.currentUser!.uid).get();
    if (docsnap.exists) {
      following = docsnap.data()?['Following ID'] ?? [];
    }
  }

// Fetch the posts from the followed users only
  Future<void> fetchposts() async {
    await fetchfollowing();
    List postID = [];

    try {
      final docsnap = await _firestore.collection('Global Post IDs').doc('Posts').get();
      if (docsnap.exists) {
        postID = docsnap.data()?['Post IDs'] ?? [];
      }

      List<dynamic> tempPostImages = [];
      List<dynamic> tempPostUid = [];
      List<dynamic> tempPostCaption = [];
      List<dynamic> tempPostDate = [];
      List<dynamic> temppostid = [];

      for (int i = 0; i < postID.length; i++) {
        final postdata = await _firestore.collection('Global Post').doc(postID[i]).get();
        if (postdata.exists) {
          final postUid = postdata.data()?['Uploaded UID'];
          if (following.contains(postUid)) {
            final imageLink = postdata.data()?['Image Link'];
            if (imageLink is List) {
              tempPostImages.addAll(imageLink);
            } else if (imageLink is String) {
              tempPostImages.add(imageLink);
            }
            tempPostUid.add(postUid ?? '');
            temppostid.add(postdata.data()?['postid'] ?? '');
            tempPostCaption.add(postdata.data()?['Caption'] ?? '');
            tempPostDate.add(postdata.data()?['Upload Date'] ?? '');
          }
        }
      }

      postimages = tempPostImages;
      postuid = tempPostUid;
      postcaption = tempPostCaption;
      postdate = tempPostDate;
      PID = temppostid;

    } catch (e) {
      print('Posts error: $e');
    }
  }

// Fetch user details for the posts (e.g., username, profile picture)
  Future<void> fetchpostuserdetails() async {
    try {
      await fetchposts();
      for (int i = 0; i < postuid.length; i++) {
        final docsnap = await _firestore.collection('User Details').doc(postuid[i]).get();
        if (docsnap.exists) {
          postusername.add(docsnap.data()?['Name']);
          postuserpfps.add(docsnap.data()?['Profile Pic']);
          verification.add(docsnap.data()?['Verified']);
        }
      }
    } catch (e) {
      print("User details error: $e");
    }
  }

  Future<void> fetchpfp() async {
    final docsnap = await _firestore.collection('User Details').doc(_auth.currentUser!.uid).get();
    if (docsnap.exists) {
      pfp = docsnap.data()?['Profile Pic'];
      usernames = docsnap.data()?['Name'];
    }
  }

  Future<void> fetchlikes() async {
    await fetchposts();
    if (PID.isEmpty) {
      print("postuid is empty. No posts to fetch likes for.");
      return;
    }

    for (int i = 0; i < PID.length; i++) {
      final docsnap = await _firestore.collection('Post Likes').doc(PID[i]).get();
      if (docsnap.exists) {
        final likes = docsnap.data()?['likes'] ?? [];
        isliked.add(likes.contains(_auth.currentUser!.uid));
      } else {
        isliked.add(false);
      }
    }
  }

  Future<void> fetchsavedposts() async {
    final docsnap = await _firestore.collection('Saved Posts').doc(_auth.currentUser!.uid).get();
    if (docsnap.exists) {
      savedposts = (docsnap.data()?['POST IDs']);
    }
  }

  Future<void> fetchpfps() async {
    final docsnap = await _firestore.collection('User Details').doc(_auth.currentUser!.uid).get();
    if (docsnap.exists) {
      PFP = docsnap.data()?['Profile Pic'];
      username = docsnap.data()?['Name'];
    }
  }

  Future<void> fetchstories() async {
    final docsnap = await _firestore.collection('Stories').doc(_auth.currentUser!.uid).get();
    if (docsnap.exists) {
      storyURL = docsnap.data()?['Story Link'] ?? '';
      Timestamp? timestamp = docsnap.data()?['Upload Date'];
      uploaddate = timestamp?.toDate();
    }
    if (kDebugMode) {
      print('Story Link $storyURL');
    }
  }

  // import 'package:cloud_firestore/cloud_firestore.dart';

  // List<DateTime?> uploaddates = [];

  Future<void> fetchotherstories() async {
    await fetchfollowing();
    for (int i = 0; i < following.length; i++) {
      final docsnap = await _firestore.collection('Stories').doc(following[i]).get();
      if (docsnap.exists) {
        storiesurl.add(docsnap.data()?['Story Link']);
        storiesuploaderuid.add(docsnap.data()?['Uploader UID']);

        // Check if the 'Upload Date' field exists and convert from Timestamp to DateTime
        var uploadDate = docsnap.data()?['Upload Date'];
        if (uploadDate != null && uploadDate is Timestamp) {
          uploaddates.add(uploadDate.toDate()); // Convert to DateTime
        } else {
          uploaddates.add(null); // Add null if no valid upload date exists
        }
      }
    }
    for (int i = 0; i < storiesuploaderuid.length; i++) {
      final Docsnap = await _firestore.collection('User Details').doc(storiesuploaderuid[i]).get();
      if (Docsnap.exists) {
        storiesuploadname.add(Docsnap.data()?['Name']);
        storiesuploadpfp.add(Docsnap.data()?['Profile Pic']);
      }
    }
  }


  Future<void> fetchdata() async {
    await fetchpostuserdetails();
    await fetchfollowing();
    await fetchpfp();
    await fetchlikes();
    await fetchsavedposts();
    await fetchpfps();
    await fetchstories();
    await fetchotherstories();
    setState(() {
      _isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _isLoading
            ? Container()
            : Container(
                width: MediaQuery.sizeOf(context).width,
                height: 55,
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: SvgPicture.string(
                          '<svg aria-label="Home" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Home</title><path d="M22 23h-6.001a1 1 0 0 1-1-1v-5.455a2.997 2.997 0 1 0-5.993 0V22a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V11.543a1.002 1.002 0 0 1 .31-.724l10-9.543a1.001 1.001 0 0 1 1.38 0l10 9.543a1.002 1.002 0 0 1 .31.724V22a1 1 0 0 1-1 1Z"></path></svg>'),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SearchAndExplorePage(),));
                      },
                      child: SvgPicture.string(
                          '<svg aria-label="Search" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Search</title><path d="M19 10.5A8.5 8.5 0 1 1 10.5 2a8.5 8.5 0 0 1 8.5 8.5Z" fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="16.511" x2="22" y1="16.511" y2="22"></line></svg>'),
                    ),
                    InkWell(
                      onTap: () {},
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: SvgPicture.string(
                            '<svg aria-label="New post" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>New post</title><path d="M2 12v3.45c0 2.849.698 4.005 1.606 4.944.94.909 2.098 1.608 4.946 1.608h6.896c2.848 0 4.006-.7 4.946-1.608C21.302 19.455 22 18.3 22 15.45V8.552c0-2.849-.698-4.006-1.606-4.945C19.454 2.7 18.296 2 15.448 2H8.552c-2.848 0-4.006.699-4.946 1.607C2.698 4.547 2 5.703 2 8.552Z" fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="6.545" x2="17.455" y1="12.001" y2="12.001"></line><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="12.003" x2="12.003" y1="6.545" y2="17.455"></line></svg>'),
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
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePage(userid: _auth.currentUser!.uid),
                            ));
                      },
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Image(
            image: NetworkImage(
                'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.'
                'com/o/Assets%2FScreenshot%202024-11-12%20202233.png?alt=media&token=a52fef3a-6953-4592-90f7-ee9fb950516e'),
            width: 100,
          ),
          backgroundColor: Colors.black,
          actions: [
            Row(
              children: [
                InkWell(
                  onTap: () {},
                  child: SvgPicture.string(
                      '<svg aria-label="Notifications" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Notifications</title><path d="M16.792 3.904A4.989 4.989 0 0 1 21.5 9.122c0 3.072-2.652 4.959-5.197 7.222-2.512 2.243-3.865 3.469-4.303 3.752-.477-.309-2.143-1.823-4.303-3.752C5.141 14.072 2.5 12.167 2.5 9.122a4.989 4.989 0 0 1 4.708-5.218 4.21 4.21 0 0 1 3.675 1.941c.84 1.175.98 1.763 1.12 1.763s.278-.588 1.11-1.766a4.17 4.17 0 0 1 3.679-1.938m0-2a6.04 6.04 0 0 0-4.797 2.127 6.052 6.052 0 0 0-4.787-2.127A6.985 6.985 0 0 0 .5 9.122c0 3.61 2.55 5.827 5.015 7.97.283.246.569.494.853.747l1.027.918a44.998 44.998 0 0 0 3.518 3.018 2 2 0 0 0 2.174 0 45.263 45.263 0 0 0 3.626-3.115l.922-.824c.293-.26.59-.519.885-.774 2.334-2.025 4.98-4.32 4.98-7.94a6.985 6.985 0 0 0-6.708-7.218Z"></path></svg>'),
                ),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {},
                  child: SvgPicture.string(
                      '<svg aria-label="Messenger" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Messenger</title><path d="M12.003 2.001a9.705 9.705 0 1 1 0 19.4 10.876 10.876 0 0 1-2.895-.384.798.798 0 0 0-.533.04l-1.984.876a.801.801 0 0 1-1.123-.708l-.054-1.78a.806.806 0 0 0-.27-.569 9.49 9.49 0 0 1-3.14-7.175 9.65 9.65 0 0 1 10-9.7Z" fill="none" stroke="white" stroke-miterlimit="10" stroke-width="1.739"></path><path d="M17.79 10.132a.659.659 0 0 0-.962-.873l-2.556 2.05a.63.63 0 0 1-.758.002L11.06 9.47a1.576 1.576 0 0 0-2.277.42l-2.567 3.98a.659.659 0 0 0 .961.875l2.556-2.049a.63.63 0 0 1 .759-.002l2.452 1.84a1.576 1.576 0 0 0 2.278-.42Z" fill-rule="evenodd"></path></svg>'),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            )
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                   Align(
                     alignment: Alignment.bottomLeft,
                     child: SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius:storyURL!=''? 37:35,
                                    backgroundColor:storyURL!=''? Colors.green:Colors.black,
                                    child: InkWell(
                                      onTap: (){
                                        if(storyURL!=''){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) =>StoryPage(
                                            PFP: PFP,
                                            UploadDate: uploaddate,
                                            storylink: storyURL,
                                            username: username,
                                            UID: _auth.currentUser!.uid,
                                          )));
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(PFP),
                                      ),
                                    ),
                                  ),
                                 storyURL!=null?  Positioned(
                                      right: 2,
                                      top: 50,
                                      child:CircleAvatar(
                                        backgroundColor: Colors.blue,radius: 10,
                                        child: InkWell(
                                          onTap: (){},
                                          child:const Icon(Icons.add,color: Colors.white,size: 15,) ,
                                        ),) ):Container()
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text('Your story',style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12
                              ),)
                            ],
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          for(int i=0;i<storiesuploaderuid.length;i++)
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 37,
                                          backgroundColor:Colors.green,
                                          child: InkWell(
                                            onTap: (){

                                              Navigator.push(context, MaterialPageRoute(builder: (context) =>StoryPage(
                                                PFP: storiesuploadpfp[i],
                                                UploadDate: uploaddates[i],
                                                storylink: storiesurl[i],
                                                username: storiesuploadname[i],
                                                UID: storiesuploaderuid[i],
                                              )));

                                            },
                                            child: CircleAvatar(
                                              radius: 35,
                                              backgroundColor: Colors.white,
                                              backgroundImage: NetworkImage(storiesuploadpfp[i]),
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(storiesuploadname[i],style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12
                                    ),)
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            )
                        ],
                                         ),
                     ),
                   ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: postuid.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OtherProfilePage(
                                                    userid: postuid[index]),
                                          ));
                                    },
                                    child: ClipOval(
                                      child: Image.network(
                                        postuserpfps[index],
                                        height: 35,
                                        width: 35,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OtherProfilePage(
                                                        userid: postuid[index]),
                                              ));
                                        },
                                        child: Text(
                                          '   ${postusername[index]}  ',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      verification[index]
                                          ? const SizedBox(
                                              width: 15,
                                              height: 15,
                                              child: Image(
                                                  image: NetworkImage(
                                                      'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Ficons8-verified-badge-48.png?alt=media&token=db0c0b9f-2f66-4401-a60b-11268ef68b2b')))
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: Container(
                                width: 0.99 * MediaQuery.sizeOf(context).width,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: ZoomOverlay(
                                    modalBarrierColor:
                                        Colors.black12, // Optional
                                    minScale: 0.5, // Optional
                                    maxScale: 3.0, // Optional
                                    animationCurve: Curves
                                        .fastOutSlowIn, // Defaults to fastOutSlowIn which mimics IOS instagram behavior
                                    animationDuration: const Duration(
                                        milliseconds:
                                            300), // Defaults to 100 Milliseconds. Recommended duration is 300 milliseconds for Curves.fastOutSlowIn
                                    twoTouchOnly: true, // Defaults to false
                                    onScaleStart:
                                        () {}, // optional VoidCallback
                                    onScaleStop: () {}, // optional VoidCallback
                                    child: Image(
                                        image:
                                            NetworkImage(postimages[index]))),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                InkWell(
                                    onTap: () async {
                                      // First, fire the Firebase like/unlike operation
                                      if (isliked[index]) {
                                        // Unliking
                                        await _firestore
                                            .collection('Post Likes')
                                            .doc(PID[index])
                                            .set({
                                          'likes': FieldValue.arrayRemove(
                                              [_auth.currentUser!.uid])
                                        }, SetOptions(merge: true));

                                        // After the Firebase operation is complete, update the state
                                        setState(() {
                                          isliked[index] = false;
                                        });
                                      } else {
                                        // Liking
                                        await _firestore
                                            .collection('Post Likes')
                                            .doc(PID[index])
                                            .set({
                                          'likes': FieldValue.arrayUnion(
                                              [_auth.currentUser!.uid])
                                        }, SetOptions(merge: true));

                                        // After the Firebase operation is complete, update the state
                                        setState(() {
                                          isliked[index] = true;
                                        });
                                      }
                                    },
                                    child: isliked[index]
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: SvgPicture.string(
                                                '<svg aria-label="Unlike" fill="red" height="24" viewBox="0 0 48 48" width="24"><path d="M34.6 3.1c-4.5 0-7.9 1.8-10.6 5.6-2.7-3.7-6.1-5.5-10.6-5.5C6 3.1 0 9.6 0 17.6c0 7.3 5.4 12 10.6 16.5.6.5 1.3 1.1 1.9 1.7l2.3 2c4.4 3.9 6.6 5.9 7.6 6.5.5.3 1.1.5 1.6.5s1.1-.2 1.6-.5c1-.6 2.8-2.2 7.8-6.8l2-1.8c.7-.6 1.3-1.2 2-1.7C42.7 29.6 48 25 48 17.6c0-8-6-14.5-13.4-14.5z"></path></svg>'),
                                          )
                                        : SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: SvgPicture.string(
                                                '<svg aria-label="Like" fill="white" height="24" viewBox="0 0 24 24" width="24"><path d="M16.792 3.904A4.989 4.989 0 0 1 21.5 9.122c0 3.072-2.652 4.959-5.197 7.222-2.512 2.243-3.865 3.469-4.303 3.752-.477-.309-2.143-1.823-4.303-3.752C5.141 14.072 2.5 12.167 2.5 9.122a4.989 4.989 0 0 1 4.708-5.218 4.21 4.21 0 0 1 3.675 1.941c.84 1.175.98 1.763 1.12 1.763s.278-.588 1.11-1.766a4.17 4.17 0 0 1 3.679-1.938m0-2a6.04 6.04 0 0 0-4.797 2.127 6.052 6.052 0 0 0-4.787-2.127A6.985 6.985 0 0 0 .5 9.122c0 3.61 2.55 5.827 5.015 7.97.283.246.569.494.853.747l1.027.918a44.998 44.998 0 0 0 3.518 3.018 2 2 0 0 0 2.174 0 45.263 45.263 0 0 0 3.626-3.115l.922-.824c.293-.26.59-.519.885-.774 2.334-2.025 4.98-4.32 4.98-7.94a6.985 6.985 0 0 0-6.708-7.218Z"></path></svg>'),
                                          )),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  child: SvgPicture.string(
                                      '<svg aria-label="Comment" fill="white" height="24" viewBox="0 0 24 24" width="24"><path d="M20.656 17.008a9.993 9.993 0 1 0-3.59 3.615L22 22Z" fill="none" stroke="white" stroke-linejoin="round" stroke-width="2"></path></svg>'),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  // onTap: ()async{
                                  //   if(savedposts[index].contains(PID[index])){
                                  //     await _firestore.collection('Saved Posts').doc(_auth.currentUser!.uid).set(
                                  //         {
                                  //           'POST IDs':FieldValue.arrayUnion([PID[index]])
                                  //         },SetOptions(merge: true));
                                  //   }else{
                                  //     await _firestore.collection('Saved Posts').doc(_auth.currentUser!.uid).set(
                                  //         {
                                  //           'POST IDs':FieldValue.arrayRemove([PID[index]])
                                  //         },SetOptions(merge: true));
                                  //   }
                                  // },
                                  child: SvgPicture.string(savedposts
                                          .contains(PID[index])
                                      ? '<svg aria-label="Remove" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Remove</title><path d="M20 22a.999.999 0 0 1-.687-.273L12 14.815l-7.313 6.912A1 1 0 0 1 3 21V3a1 1 0 0 1 1-1h16a1 1 0 0 1 1 1v18a1 1 0 0 1-1 1Z"></path></svg>'
                                      : '<svg aria-label="Save" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Save</title><polygon fill="none" points="20 21 12 13.44 4 21 4 3 20 3 20 21" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></polygon></svg>'),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OtherProfilePage(
                                                  userid: postuid[index]),
                                        ));
                                  },
                                  child: Text(
                                    postusername[index],
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      postcaption[index],
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ));
  }
}
