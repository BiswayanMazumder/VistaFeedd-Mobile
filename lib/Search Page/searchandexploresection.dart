import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vistafeedd/HomePage/homepage.dart';
import 'package:vistafeedd/Post%20Details%20Page/postdetails.dart';
import 'package:vistafeedd/Profile%20Page/profilepage.dart';
class SearchAndExplorePage extends StatefulWidget {
  const SearchAndExplorePage({super.key});

  @override
  State<SearchAndExplorePage> createState() => _SearchAndExplorePageState();
}

class _SearchAndExplorePageState extends State<SearchAndExplorePage> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String pfp = '';
  List<dynamic>PIDS=[];
  List<dynamic> PostUIDS=[];
  List<dynamic> PostLinks=[];
  Future<void>fetchposts()async{
    final docsnap=await _firestore.collection('Global Post IDs').doc('Posts').get();
    if(docsnap.exists){
      setState(() {
        PIDS=(docsnap.data()?['Post IDs']);
      });
    }
    for(int i=0;i<PIDS.length;i++){
      final Docsnap=await _firestore.collection('Global Post').doc(PIDS[i]).get();
      if(Docsnap.exists){
        setState(() {
          PostLinks.add(Docsnap.data()?['Image Link']);
          PostUIDS.add(Docsnap.data()?['Uploaded UID']);
        });
      }
    }
    if (kDebugMode) {
      print("uploaded UID $PostUIDS");
    }
  }
  Future<void> fetchpfp() async {
    final docsnap = await _firestore.collection('User Details').doc(_auth.currentUser!.uid).get();
    if (docsnap.exists) {
      pfp = docsnap.data()?['Profile Pic'];
      // usernames = docsnap.data()?['Name'];
    }
  }
  bool _isLoading=false;
  Future<void> fetchdata() async {
    await fetchposts();
    // await fetchdata();
    await fetchpfp();
    setState(() {
      _isLoading = false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdata();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title:  Container(
          width: MediaQuery.sizeOf(context).width,
          // height: 40,
          color: const Color.fromRGBO(31, 41, 55, 1),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: GoogleFonts.poppins(
                color: Colors.white
              )
            ),
            // enabled: false,
            style: GoogleFonts.poppins(
              color: Colors.white
            ),
          ),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));
              },
              child: SvgPicture.string(
                  '<svg aria-label="Home" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Home</title><path d="M9.005 16.545a2.997 2.997 0 0 1 2.997-2.997A2.997 2.997 0 0 1 15 16.545V22h7V11.543L12 2 2 11.543V22h7.005Z" fill="none" stroke="white" stroke-linejoin="round" stroke-width="2"></path></svg>'),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SearchAndExplorePage(),));
              },
              child: SvgPicture.string('<svg aria-label="Search" class="x1lliihq x1n2onr6 x5n08af" fill="white" height="24" role="img" viewBox="0 0 24 24" width="24"><title>Search</title><path d="M18.5 10.5a8 8 0 1 1-8-8 8 8 0 0 1 8 8Z" fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="3"></path><line fill="none" stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="3" x1="16.511" x2="21.643" y1="16.511" y2="21.643"></line></svg>'
              ) ),
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
      body:_isLoading?const Center(child:
        CircularProgressIndicator(
          color: Colors.white,
        ),) :SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children:  [
                for(int i=0;i<PIDS.length;i++)
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: InkWell(
                      onTap: (){
                        if (kDebugMode) {
                          print("PIDS ${PIDS[i]}");
                        }

                      },
                        child: Image(image: NetworkImage(PostLinks[i]))),
                  ),

              ],
            ),
          ],
        ),
      )
    );
  }
}
