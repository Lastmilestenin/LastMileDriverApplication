import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/Screen/MyProfile/profile.dart';
import 'package:provider/theme/style.dart';
import 'package:provider/Screen/Menu/Menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/Components/listMenu.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'inviteFriends.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String screenName = "SETTINGS";
  String username = '';
  String totalEarned = '0', totalDistance = '0';
  double hoursOnline = 0.0;
  int totalJobs = 0;
  String phoneNumber = '';
  bool isLoading = false;
  String pic;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserData();
  }


  Future _getUserData() async {
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

  Future setUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', userData['name']);
    prefs.setString('totalEarned', userData['money_earned']);
    prefs.setInt('totalJobs', userData['total_jobs']);
    prefs.setDouble('hoursOnline', userData['hours_online']);
    prefs.setString('totalDistance', userData['total_distance']);
    prefs.setString('phoneNumber', userData['phone_number']);

    print('USERNAME: ' + userData['name']);
    setState(() {
      username = userData['name'];
      pic = userData['profile_pic'];
      print(username);
      totalEarned = userData['money_earned'];
      print('totalEarned ' + totalEarned.toString());
      totalJobs = userData['total_jobs'];
      print('totalJobs ' + totalJobs.toString());
      hoursOnline = userData['hours_online'];
      print('hoursOnline ' + hoursOnline.toString());
      totalDistance = userData['total_distance'];
      print('totalDistance ' + totalDistance.toString());
      phoneNumber = userData['phone_number'];
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        iconTheme: IconThemeData(color: blackColor),
        backgroundColor: whiteColor,
        title: Text(
          'Settings',
          style: TextStyle(color: blackColor),
        ),
      ),
      drawer: new MenuScreens(
          // activeScreenName: screenName
          ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
              color: backgroundColor,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return Profile();
                        },
                      ));
                    },
                    child: Container(
                      color: whiteColor,
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Row(
                        //mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(50.0),
                            child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.transparent,
                                backgroundImage: CachedNetworkImageProvider(
                                  pic == null?
                                  "https://source.unsplash.com/1600x900/?portrait":pic,
                                )),
                          ),
                          Container(
                            width: screenSize.width - 70,
                            padding: EdgeInsets.only(left: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          username,
                                          style: textBoldBlack,
                                        ),
                                      ),
                                      // Container(
                                      //     child: Text("Gold Member",style: TextStyle(
                                      //       fontSize: 12,
                                      //       color: greyColor2
                                      //     ),)
                                      // ),
                                    ],
                                  ),
                                ),
                                Container(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color:
                                          CupertinoColors.lightBackgroundGray,
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
//                ListsMenu(
//                  title: "100 Point * Member",
//                  onPress: (){
//
//                  },
//                ),
                  // ListsMenu(
                  //   title: "Reviews",
                  //   icon: Icons.star,
                  //   backgroundIcon: Colors.cyan,
                  //   onPress: () {},
                  // ),
                  ListsMenu(
                    title: "Share the app",
                    icon: Icons.people,
                    backgroundIcon: primaryColor,
                    onPress: () {
                      setState(() {
                        isLoading = true;
                      });
                      final RenderBox box = context.findRenderObject();

                      Share.share('Hellow World',
                              subject: 'This is the end',
                              sharePositionOrigin:
                                  box.localToGlobal(Offset.zero) & box.size)
                          .whenComplete(() {
                        setState(() {
                          isLoading = false;
                        });
                      });
                      // Navigator.of(context).push(new MaterialPageRoute<Null>(
                      //     builder: (BuildContext context) {
                      //       return InviteFriends();
                      //     },
                      //     fullscreenDialog: true));
                    },
                  ),
                  ListsMenu(
                    title: "Notification",
                    icon: Icons.notifications_active,
                    backgroundIcon: primaryColor,
                    onPress: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/notification', (Route<dynamic> route) => false);
                    },
                  ),
                  ListsMenu(
                    title: "Terms & Privacy Policy",
                    icon: Icons.description,
                    backgroundIcon: Colors.deepPurple,
                    onPress: () {},
                  ),
                  ListsMenu(
                    title: "Contact us",
                    icon: Icons.help,
                    backgroundIcon: primaryColor,
                    onPress: () {},
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
