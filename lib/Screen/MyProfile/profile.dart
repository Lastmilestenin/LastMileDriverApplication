import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/Screen/MyProfile/EditProfile.dart';
import 'package:provider/Screen/MyProfile/myProfile.dart';
import 'package:provider/Screen/Settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/style.dart';
import 'chart.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username = '';
  String totalEarned = '0', totalDistance = '0';
  double hoursOnline = 0.0;
  int totalJobs = 0;
  String phoneNumber = '', email = '';
  String pic;

  @override
  void initState() {
    _getUserData();
    // TODO: implement initState
    super.initState();


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
    prefs.setString('email', userData['email']);


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
      email = userData['email'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: blackColor,
          ),
          onPressed: () => Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => SettingsScreen())),
        ),
        iconTheme: IconThemeData(color: blackColor),
        backgroundColor: backgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.mode_edit),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute<Null>(
                builder: (BuildContext context) {
                  return EditProfile();
                },
              ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: backgroundColor,
          child: Column(
            children: <Widget>[
              Center(
                child: Stack(
                  children: <Widget>[
                    Material(
                      elevation: 10.0,
                      color: Colors.white,
                      shape: CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                pic == null?
                                "https://source.unsplash.com/1600x900/?portrait":pic,
                              )),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10.0,
                      left: 25.0,
                      height: 15.0,
                      width: 15.0,
                      child: Container(
                        width: 15.0,
                        height: 15.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: greenColor,
                            border:
                                Border.all(color: Colors.white, width: 2.0)),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      username,
                      style: TextStyle(color: blackColor, fontSize: 35.0),
                    ),
                    // Text(
                    //   "Client since 2016",
                    //   style: TextStyle(color: blackColor, fontSize: 13.0),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Container(
              //   color: whiteColor,
              //   child: LineChartWallet(),
              // ),
              SizedBox(height: 20),
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border(
                              bottom: BorderSide(
                                  width: 1.0, color: backgroundColor))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Username',
                            style: textStyle,
                          ),
                          Text(
                            username,
                            style: textGrey,
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border(
                              bottom: BorderSide(
                                  width: 1.0, color: backgroundColor))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Phone Number',
                            style: textStyle,
                          ),
                          Text(
                            phoneNumber,
                            style: textGrey,
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border(
                              bottom: BorderSide(
                                  width: 1.0, color: backgroundColor))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Email',
                            style: textStyle,
                          ),
                          Text(
                            email,
                            style: textGrey,
                          )
                        ],
                      ),
                    ),
                    // Container(
                    //   height: 50,
                    //   padding: EdgeInsets.all(15),
                    //   decoration: BoxDecoration(
                    //       color: whiteColor,
                    //       border: Border(
                    //           bottom: BorderSide(
                    //               width: 1.0, color: backgroundColor))),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: <Widget>[
                    //       Text(
                    //         'Birthday',
                    //         style: textStyle,
                    //       ),
                    //       Text(
                    //         "Apirl 27, 1996",
                    //         style: textGrey,
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
