import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MyProfile/profile.dart';
import '../../theme/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../MyProfile/myProfile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MenuScreens extends StatefulWidget {
  @override
  _MenuScreensState createState() => _MenuScreensState();
}

class _MenuScreensState extends State<MenuScreens> {
  String userID;
  String username;
  String hoursOnline = "0";
  String totalDistance;
  int totalJobs;
  String dist;
  String activeScreenName = '';
  String userImage = '';
  String earn;

  @override
  void initState() {
    _getUserDatafirebASE();
    super.initState();


  }

  Future _getUserDatafirebASE() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID');

    await Firestore.instance
        .collection('LM_Driver')
        .document(userID)
        .get()
        .then((DocumentSnapshot snap) {
      print('USER DATA: ' + snap.data.toString());
      setUserData(snap.data);
    });
  }

  getDefaultPic() async {
    final ref = FirebaseStorage.instance.ref().child('user_default.png');
// no need of the file extension, the name will do fine.
    setState(() async {
      userImage = await ref.getDownloadURL();
      print('GETTING DEFAULT PIC' + userImage.toString());
    });
  }


  Future setUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    final FirebaseAuth _auth = FirebaseAuth.instance;
//
//    final FirebaseUser currentUser = await _auth.currentUser();
//
//    DocumentReference docRef = Firestore.instance
//        .collection('LM_Driver')
//        .document(currentUser.uid);
//    if(docRef[])
    prefs.setString('username', userData['name']);
    prefs.setString('totalEarned', userData['money_earned']);
    prefs.setInt('totalJobs', userData['total_jobs']);
    prefs.setDouble('hoursOnline', userData['hours_online']);
    prefs.setString('totalDistance', userData['total_distance']);
    prefs.setString('phoneNumber', userData['phone_number']);
    prefs.setString('email', userData['email']);


    print('USERNAME: ' + userData['name']);

    setState(() {
      if (userData['profile_pic'] == null) {
        getDefaultPic();
      } else {
        prefs.setString('profilePic' , userData['profile_pic']);
        userImage = prefs.getString('profilePic');
      }
    });
    getUserData();
  }


  getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // String userID = prefs.getString('userID');
    // String username = prefs.getString('username');
    // String totalDistance = prefs.getString('totalDistance');
    // int totalJobs = prefs.getInt('totalJobs');

    setState(() {
      userID = prefs.getString('userID');
      username = prefs.getString('username');
      totalDistance = prefs.getString('totalDistance');
      totalJobs = prefs.getInt('totalJobs');
      earn = double.parse(prefs.getString('totalEarned')).toStringAsFixed(2);
      if(totalDistance.length < 4 && totalDistance.length > 2){
        setState(() {
          dist = totalDistance.substring(0,3);
        });
      }else if(totalDistance.length < 3 && totalDistance.length > 1)
      {
        setState(() {
          dist = totalDistance.substring(0,2);
        });
      }
      else if(totalDistance.length < 5 && totalDistance.length > 3)
      {
        setState(() {
          dist = totalDistance.substring(0,4);
        });
      }
      else if(totalDistance.length < 6 && totalDistance.length > 4)
      {
        setState(() {
          dist = totalDistance.substring(0,5);
        });
      }
      else if(totalDistance.length < 2 && totalDistance.length > 0)
      {
        setState(() {
          dist = totalDistance.substring(0,1);
        });
      }
      else{
        setState(() {
          dist = totalDistance.substring(0,6);
        });
      }
    });
  }

  navigatorRemoveUntil(BuildContext context, String router) {
    Navigator.of(context)
        .pushNamed('/$router');
  }

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                left: 20.0, top: 30.0, right: 20.0, bottom: 0.0),
            color: Color.fromRGBO(60, 111, 102, 1),
            height: 180.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(new MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return Profile();
                            },
                            fullscreenDialog: true));
                      },
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(50.0),
                        child: new ClipRRect(
                            borderRadius: new BorderRadius.circular(100.0),
                            child: new Container(
                              height: 50.0,
                              width: 50.0,
                              color: primaryColor,
                              child: CachedNetworkImage(
                                imageUrl:
                                     userImage != null
                                         ? userImage
                                         :
                                    "https://source.unsplash.com/1600x900/?portrait",
                                fit: BoxFit.cover,
                              ),
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(new MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return MyProfile();
                            },
                            fullscreenDialog: true));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              username,
                              style: textBoldWhite,
                            ),
                            // Container(
                            //   padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                            //   decoration: BoxDecoration(
                            //     color: whiteColor,
                            //     borderRadius: BorderRadius.circular(10.0),
                            //   ),
                            //   child: Text("Gold Member",style: TextStyle(
                            //     fontSize: 11,
                            //     color: primaryColor,
                            //   ),),
                            // )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Container(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: <Widget>[
                        //       Icon(
                        //         Icons.access_time,
                        //         color: greyColor,
                        //       ),
                        //       Text(
                        //         hoursOnline.toString(),
                        //         style: heading18,
                        //       ),
                        //       Text(
                        //         "Hours online",
                        //         style: TextStyle(
                        //           fontSize: 11,
                        //           color: greyColor,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.poll,
                                color: greyColor,
                              ),
                              Text(
                                dist.toString() == null?'0 KM':dist.toString(),
                                style: heading18,
                              ),
                              Text(
                                "Total Distance",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.euro,
                                color: greyColor,
                              ),
                              Text(
                                earn.toString() + ' Euro' == null?'0 Euro':earn.toString() + ' Euro',
                                style: heading18,
                              ),
                              Text(
                                "Total Earning",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.content_paste,
                                color: greyColor,
                              ),
                              Text(
                                totalJobs.toString(),
                                style: heading18,
                              ),
                              Text(
                                "Total Jobs",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),

//          UserAccountsDrawerHeader(
//            margin: EdgeInsets.all(0.0),
//            accountName: new Text("John",style: headingWhite,),
//            accountEmail: new Text("100 point - Gold member"),
//            currentAccountPicture: new CircleAvatar(
//                backgroundColor: Colors.white,
//                child: new Image(
//                    width: 100.0,
//                    image: new AssetImage('assets/image/taxi-driver.png',)
//                )
//            ),
//            onDetailsPressed: (){
//              Navigator.pop(context);
//              Navigator.of(context).push(new MaterialPageRoute<Null>(
//                  builder: (BuildContext context) {
//                    return MyProfile();
//                  },
//                  fullscreenDialog: true));
//            },
//          ),
          new MediaQuery.removePadding(
            context: context,
            // DrawerHeader consumes top MediaQuery padding.
            removeTop: true,
            child: new Expanded(
              child: new ListView(
                //padding: const EdgeInsets.only(top: 8.0),
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      // The initial contents of the drawer.
                      new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context, 'home');
                            },
                            child: new Container(
                              height: 60.0,
                              color:
                                  this.activeScreenName.compareTo("HOME") == 0
                                      ? greyColor
                                      : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(
                                      FontAwesomeIcons.home,
                                      color: blackColor,
                                    ),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text(
                                      AppLocalizations.of(context)
                                          .translate('menu_home'),
                                      // 'Home',
                                      style: headingBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // new GestureDetector(
                          //   onTap: () {
                          //     Navigator.pop(context);
                          //     navigatorRemoveUntil(context, 'request');
                          //   },
                          //   child: new Container(
                          //     height: 60.0,
                          //     color:
                          //         this.activeScreenName.compareTo("REQUEST") ==
                          //                 0
                          //             ? greyColor
                          //             : whiteColor,
                          //     child: new Row(
                          //       children: <Widget>[
                          //         new Expanded(
                          //           flex: 1,
                          //           child: Icon(
                          //             FontAwesomeIcons.firstOrder,
                          //             color: blackColor,
                          //           ),
                          //         ),
                          //         new Expanded(
                          //           flex: 3,
                          //           child: new Text(
                          //             'Request',
                          //             style: headingBlack,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // new GestureDetector(
                          //   onTap: () {
                          //     Navigator.pop(context);
                          //     navigatorRemoveUntil(context, 'my_wallet');
                          //   },
                          //   child: new Container(
                          //     height: 60.0,
                          //     color: this
                          //                 .activeScreenName
                          //                 .compareTo("MY WALLET") ==
                          //             0
                          //         ? greyColor
                          //         : whiteColor,
                          //     child: new Row(
                          //       children: <Widget>[
                          //         new Expanded(
                          //           flex: 1,
                          //           child: Icon(
                          //             FontAwesomeIcons.wallet,
                          //             color: blackColor,
                          //           ),
                          //         ),
                          //         new Expanded(
                          //           flex: 3,
                          //           child: new Text(
                          //             'My Wallet',
                          //             style: headingBlack,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context, 'history');
                            },
                            child: new Container(
                              height: 60.0,
                              color:
                                  this.activeScreenName.compareTo("HISTORY") ==
                                          0
                                      ? greyColor
                                      : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(
                                      FontAwesomeIcons.history,
                                      color: blackColor,
                                    ),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text(
                                      'History',
                                      style: headingBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context, 'notification');
                            },
                            child: new Container(
                              height: 60.0,
                              color: this
                                          .activeScreenName
                                          .compareTo("NOTIFICATIONS") ==
                                      0
                                  ? greyColor
                                  : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(
                                      FontAwesomeIcons.bell,
                                      color: blackColor,
                                    ),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text(
                                      'Notifications',
                                      style: headingBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context, 'setting');
                            },
                            child: new Container(
                              height: 60.0,
                              color:
                                  this.activeScreenName.compareTo("SETTINGS") ==
                                          0
                                      ? greyColor
                                      : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(
                                      FontAwesomeIcons.cogs,
                                      color: blackColor,
                                    ),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text(
                                      'Settings',
                                      style: headingBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () async{
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              FirebaseAuth _auth = FirebaseAuth.instance;
                              _auth.signOut();
                              prefs.clear();
                              Navigator.pop(context);
                              navigatorRemoveUntil(context, 'logout');
                            },
                            child: new Container(
                              height: 60.0,
                              color: whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(
                                      FontAwesomeIcons.signOutAlt,
                                      color: blackColor,
                                    ),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text(
                                      'Logout',
                                      style: headingBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // The drawer's "details" view.
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class MenuItems {
//   String name;
//   IconData icon;
//   MenuItems({this.icon, this.name});
// }

// class MenuScreens extends StatelessWidget {
//   final String activeScreenName;
//   final String username, totalDistance;
//   final int totalJobs;
//   final double hoursOnline;

//   MenuScreens(
//       {this.activeScreenName,
//       this.username = '',
//       this.totalDistance = '',
//       this.totalJobs = 0,
//       this.hoursOnline = 0.0});

//   navigatorRemoveUntil(BuildContext context, String router) {
//     Navigator.of(context)
//         .pushNamedAndRemoveUntil('/$router', (Route<dynamic> route) => false);
//   }

// }
