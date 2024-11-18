import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistafeedd/Profile%20Page/otherprofilepage.dart';
import 'package:vistafeedd/Profile%20Page/profilepage.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Recent searches data
  List<dynamic> UIDS = [];
  List<dynamic> Name = [];
  List<dynamic> PFP = [];
  bool _isloading=false;
  @override
  void initState() {
    super.initState();
    fetchdata();
  }
  Future<void>fetchdata()async{
    setState(() {
      _isloading=true;
    });
    await fetchrecentsearches();
    setState(() {
      _isloading=false;
    });
  }
  // Search function to get results from Firestore
  void _search() async {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      QuerySnapshot snapshot = await _firestore
          .collection('User Details')
          .where('Name', isGreaterThanOrEqualTo: query)
          .where('Name', isLessThanOrEqualTo: query + '\uf8ff') // Case-insensitive search
          .get();

      setState(() {
        _searchResults = snapshot.docs;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  // Function to handle recent search writing
  Future<void> writerecentsearch(String UID) async {
    await _firestore.collection('Recent Searches').doc(_auth.currentUser!.uid).set(
      {
        'UIDS': FieldValue.arrayUnion([UID])
      },
      SetOptions(merge: true),
    );
  }

  // Fetch recent searches
  Future<void> fetchrecentsearches() async {
    final docsnap = await _firestore.collection('Recent Searches').doc(_auth.currentUser!.uid).get();
    if (docsnap.exists) {
      setState(() {
        UIDS = docsnap.data()?['UIDS'] ?? [];
      });
    }
    for (int i = 0; i < UIDS.length; i++) {
      final Usersnap = await _firestore.collection('User Details').doc(UIDS[i]).get();
      if (Usersnap.exists) {
        setState(() {
          Name.add(Usersnap.data()?['Name']);
          PFP.add(Usersnap.data()?['Profile Pic']);
        });
      }
    }
    if (kDebugMode) {
      print('UIDS: $UIDS');
    }
  }

  // Function to clear recent searches from Firestore and UI
  Future<void> clearAllRecentSearches() async {
    await _firestore.collection('Recent Searches').doc(_auth.currentUser!.uid).update(
      {
        'UIDS': FieldValue.delete(),
      },
    );

    // Clear the UI state
    setState(() {
      UIDS.clear();
      Name.clear();
      PFP.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchResult()));
          },
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            color: const Color.fromRGBO(31, 41, 55, 1),
            child: TextField(
              controller: _searchController,
              onChanged: (text) => _search(),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.poppins(color: Colors.white),
              ),
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ),
      ),
      body:_isloading?const Center(
        child: CircularProgressIndicator(color: CupertinoColors.white,),
      ):SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 35),
            // If the search field is empty, show recent searches
            if (_searchController.text.isEmpty) ...[
              Row(
                children: [
                  const SizedBox(width: 20),
                  Text(
                    'Recents',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromRGBO(0, 149, 246, 7),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () async {
                      await clearAllRecentSearches();  // Clear all recent searches from Firestore and UI
                    },
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 20),
              // Display recent searches
              for (int j = 0; j < UIDS.length; j++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 30, left: 20),
                  child: InkWell(
                    onTap: () {
                      (_auth.currentUser!.uid == UIDS[j])
                          ? Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userid: UIDS[j])))
                          : Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfilePage(userid: UIDS[j])));
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(PFP[j]),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          Name[j],
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: ()async{
                            await _firestore.collection('Recent Searches').doc(_auth.currentUser!.uid).set({
                              'UIDS':FieldValue.arrayRemove([UIDS[j]])
                            },SetOptions(merge: true));
                            setState(() {
                              UIDS.removeAt(j);
                            });
                            if (kDebugMode) {
                              print(UIDS[j]);
                            }
                          },
                          child: const Icon(Icons.cancel_outlined,color: CupertinoColors.white,),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            // If the search field is not empty, show the search results
            if (_searchResults.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var user = _searchResults[index].data() as Map<String, dynamic>;
                  String uid = _searchResults[index].id;
                  String name = user['Name'] ?? 'No Name';
                  String profilePicUrl = user['Profile Pic'] ?? ''; // Assuming 'Profile Pic' is the field name

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ListTile(
                      onTap: () async {
                        writerecentsearch(uid); // Add the clicked user to recent searches
                        (_auth.currentUser!.uid == uid)
                            ? Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userid: uid)))
                            : Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfilePage(userid: uid)));
                      },
                      leading: profilePicUrl.isNotEmpty
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(profilePicUrl),
                        radius: 30,
                      )
                          : const CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 30,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        name,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      tileColor: Colors.black,
                    ),
                  );
                },
              ),
            ] else if (_searchController.text.isNotEmpty) ...[
              Center(
                child: Text(
                  'No results found.',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
