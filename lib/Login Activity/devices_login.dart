import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
class LoggedInDevices extends StatefulWidget {
  final String name;
  LoggedInDevices({required this.name});

  @override
  State<LoggedInDevices> createState() => _LoggedInDevicesState();
}

class _LoggedInDevicesState extends State<LoggedInDevices> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  String _devicename='';
  Future<void> fetchdevicedetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    // For Android devices, use AndroidDeviceInfo
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        _devicename=androidInfo.device;
      });
      if (kDebugMode) {
        // Print the device model in debug mode
        print('Running on ${androidInfo.device}');
      }
    } else if(defaultTargetPlatform==TargetPlatform.iOS){
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        _devicename=iosInfo.utsname.sysname;
      });
      // Handle other platforms if necessary (iOS or others)
      if (kDebugMode) {
        print('Running on ${iosInfo.utsname.sysname}');
        // print('Not running on Android device');
      }
    }}
  bool _iswrite=false;
  List<dynamic> _sessionid=[];
  List<dynamic> _deviceid=[];
  List<dynamic> dateoflogin=[];
  List<dynamic> modelname=[];
  List<dynamic> area1=[];
  List<dynamic> area2=[];
  List<dynamic> devicetype=[];
  bool _isloading=true;
  Future<void> checksessionid() async {
    setState(() {
      _isloading=true;
    });
    await fetchdevicedetails();
    List sids = [];
    List deviceid = [];
    List sessionid = [];
    final docsnap = await _firestore.collection('Session IDs').doc(_auth.currentUser!.uid).get();

    if (docsnap.exists) {
      setState(() {
        sids = docsnap.data()?['Session ID'];
      });
    }

    setState(() {
      _sessionid = sids;
    });

    print('SIDS $_sessionid');

    for (int i = 0; i < sids.length; i++) {
      final Docsnap = await _firestore.collection('Session Details').doc(sids[i]).get();

      if (Docsnap.exists) {
        setState(() {
          deviceid.add(Docsnap.data()?['Device ID']);
          sessionid.add(Docsnap.data()?['Session ID']);
          area1.add(Docsnap.data()?['Area']);
          area2.add(Docsnap.data()?['Country Name']);
          modelname.add(Docsnap.data()?['Model Name']);
          devicetype.add(Docsnap.data()?['Device Type']);
          // Fetch and format the 'Last Accessed' date
          DateTime lastAccessed = (Docsnap.data()?['Last Accessed'] as Timestamp).toDate();

          // Format the date (MM-dd-yyyy)
          String formattedDate = DateFormat('MMM dd,yyyy').format(lastAccessed);
          setState(() {
            dateoflogin.add(formattedDate);
          });
        });
      }
    }

    setState(() {
      _deviceid = deviceid;
    });
    setState(() {
      _isloading=false;
    });
    print('Formatted Date of Login $dateoflogin');
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checksessionid();
    fetchdevicedetails();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.name,style: GoogleFonts.poppins(color: CupertinoColors.white,fontSize: 15),),
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: CupertinoColors.white,),
        ),
      ),
      body:_isloading?const Center(
        child: CircularProgressIndicator(
          color: CupertinoColors.white,
        ),
      ): Padding(padding: const EdgeInsets.only(left: 30,right: 30),
      child: ListView.builder(
        itemCount: _sessionid.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 100,
                  decoration:  BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(
                      color: Colors.grey, // Set the border color to grey
                      width: 1.0, // You can adjust the border width
                    ),
                  ),
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          Icon(devicetype[index]=='IOS'? Icons.apple_rounded: Icons.android,color: CupertinoColors.white,),
                          const SizedBox(
                            width: 30,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(modelname[index],style: GoogleFonts.poppins(
                                color: CupertinoColors.white
                              ),),
                              Row(
                                children: [
                                  Text('${area1[index]}, ${area2[index]} ${dateoflogin[index]}',style: GoogleFonts.poppins(
                                      color: Colors.grey,fontWeight: FontWeight.w300,
                                  ),),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                 _devicename==_deviceid[index]? Text('This Device',style: GoogleFonts.poppins(
                                    color: Colors.green,fontWeight: FontWeight.w500,
                                  ),):Container(),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },),
      )
    );
  }
}
