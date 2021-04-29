import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/style.dart';

class SetStatusOnline extends StatefulWidget {
  @override
  _SetStatusOnlineState createState() => _SetStatusOnlineState();
}

class _SetStatusOnlineState extends State<SetStatusOnline>
    with SingleTickerProviderStateMixin {
  Animation fadeAnimation;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
            body: new Container(
              decoration: new BoxDecoration(color: whiteColor),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          child: FadeTransition(
                              opacity: fadeAnimation,
                              child: Image.asset(
                                "assets/image/6409.jpg",
                                height: 200.0,
                              )),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Set your Status Online',
                          style: heading35Black,
                        ),
                        Container(
                          padding: new EdgeInsets.only(left: 60.0, right: 60.0),
                          child: new Text(
                            'Choose your location to start find the request around you.',
                            style: textStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 30),
                        ButtonTheme(
                          minWidth: screenSize.width * 0.43,
                          height: 45.0,
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0)),
                            elevation: 0.0,
                            color: primaryColor,
                            child: new Text(
                              'Use My Location'.toUpperCase(),
                              style: headingWhite,
                            ),
                            onPressed: () async {
                              LocationData myLocation;
                              String error;
                              Location location = new Location();
                              try {
                                myLocation = await location.getLocation();
                              } on Exception catch (e) {
                                error = 'please grant permission';
                                print(error);
                              }
                              LatLng myCurrentLocation = LatLng(
                                  myLocation.latitude, myLocation.longitude);

                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String userID = prefs.getString('userID');
                              DocumentReference docRef = Firestore.instance
                                  .collection('LM_Driver')
                                  .document(userID);
                              Map<String, dynamic> data = {
                                'isShowLocation': false,
                                'position': {
                                  'latitude': myCurrentLocation.latitude,
                                  'longitude': myCurrentLocation.longitude,
                                }
                              };
                              print('updated data: ' + data.toString());
                              docRef.updateData(data).then((document) {
                                print('onPressed setting it up');
                              }).whenComplete(() async {
                                print('onPressed task completed');
                              }).catchError((error) {
                                print('onPressed error faced');
                              });

                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/home', (Route<dynamic> route) => false);
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home', (Route<dynamic> route) => false);
                          },
                          child: Text(
                            'Skip for now',
                            style: textGrey,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
