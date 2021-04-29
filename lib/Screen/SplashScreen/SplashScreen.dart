import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/Screen/Home/home.dart';
import 'package:provider/Screen/Login/login.dart';
import 'package:provider/Screen/MyProfile/myProfile.dart';
import 'package:provider/Screen/Request/pickUp.dart';
import 'package:provider/Screen/Request/pickuplast.dart';
import 'package:provider/Screen/SignUp/signup2.dart';
import 'package:provider/data/globalvariables.dart';
import 'package:provider/theme/style.dart' as prefix0;
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final String userID;
  final String requestID;
  final String requestIDs;
  var completeProfile;

  SplashScreen({this.userID, this.requestID,this.requestIDs, this.completeProfile});
  @override
  static String tok;
  static List<String> toke = new List();
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  Position currentLocation;
  Position current;
  var fromlat,fromlong,tolat,tolong;
  LatLng fromloc,toloc;
  String _message = '';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final databaseReference = FirebaseDatabase.instance.reference().child('pricing');

  Animation animation,
      delayedAnimation,
      muchDelayAnimation,
      transfor,
      fadeAnimation;
  AnimationController animationController;
  @override
  void initState() {
    checkprofile();
    getprice();
    super.initState();
    // Future.delayed(Duration.zero, () {
    //   this.getMessage();
    //   this._registerOnFirebase();
    // });
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    animation = Tween(begin: 0.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));

    transfor = BorderRadiusTween(
        begin: BorderRadius.circular(125.0),
        end: BorderRadius.circular(0.0))
        .animate(
        CurvedAnimation(parent: animationController, curve: Curves.ease));
    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    animationController.forward();
   // getRequestDetails();


  }
  checkprofile()async{
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser currentUser = await _auth.currentUser();




    if (currentUser == null) {
      //if(widget.completeProfile){
      new Timer(new Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=> SignupScreen2()));

      });

    }else if(!Globals.completeProfile){
      new Timer(new Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=> MyProfile()));

      });
    }

    else {
      if (widget.requestID == null) {
        new Timer(new Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=> HomeScreen()));

        });
      }
      else {
        if(widget.requestIDs == null)
        {
          setRequest();
          new Timer(new Duration(seconds: 2), () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=> PickUp(
              requestID: widget.requestID,
              screenName: 'HOME',
            )));

          });

        }else{
          getRequestDetails();
        }

      }
    }



  }
  getprice(){
    databaseReference.once().then((DataSnapshot snapshot) {
      if(snapshot.value!=null){
        Globals.base=snapshot.value['base'];
        Globals.Km=snapshot.value['Km'];
        Globals.min=snapshot.value['min'];
      }
      print('Data : ${snapshot.value}');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  void nav(){
    new Timer(new Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=> SignupScreen2()));

    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
            body: new Container(
              decoration: new BoxDecoration(color: Colors.white),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Flexible(
                    flex: 1,
                    child: new Center(
                      child: FadeTransition(
                          opacity: fadeAnimation,
                          child: Image.asset(
                            "assets/Picture1.png",
                            height: 100.0,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
  Position current1;
  Future setRequest() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Position position =  await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    current1 = position;
    setState(() {
      Globals.loc = current1;
      Globals.two = pref.getString('requestIDs');
    });
  }

  _registerOnFirebase() {
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.getToken().then((token) => SplashScreen.tok = token);
  }
  void getMessage(){
    var platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      _firebaseMessaging
          .requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }
    else{
      _firebaseMessaging.configure(
          onMessage: (Map<String, dynamic> message) async {
            print('received message');
            setState(() => _message = message["notification"]["body"]);
          }, onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        setState(() => _message = message["notification"]["body"]);
      }, onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        setState(() => _message = message["notification"]["body"]);
      });
    }

  }


  Future getRequestDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Position position =  await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    current = position;
    setState(() {
      Globals.two = pref.getString('requestIDs');
      Globals.loc = position;});
    if(widget.requestIDs!=null){
      var collectionRef = Firestore.instance.collection('requests');
      var doc = await collectionRef.document(widget.requestIDs).get();
      if(doc.exists){
        await Firestore.instance
            .collection('requests')
            .document(widget.requestIDs)
            .get()
            .then((DocumentSnapshot snap) {
          print('reqeust Data: ' + snap.data.toString());
          setRequestData(snap.data);
        });
      }else
      {

        await Firestore.instance
            .collection('temp')
            .document(widget.requestIDs)
            .get()
            .then((DocumentSnapshot snap) {
          print('reqeust Data: ' + snap.data.toString());
          setRequestData(snap.data);
        });
      }



    }
  }
  Future setRequestData(Map<String, dynamic> requestData) async {
    Position position =  await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    current = position;
    print('SOME THING: ' + requestData.toString());
    setState(() {
      Globals.loc = current;
      if(requestData != null){
        fromlat = requestData['positionFrom']['latitude'];
        fromlong = requestData['positionFrom']['longitude'];
        tolat = requestData['positionTo']['latitude'];
        tolong = requestData['positionTo']['longitude'];
        fromloc = LatLng(fromlat,fromlong);
        toloc = LatLng(tolat,tolong);
        g();
      }
      else{
        new Timer(new Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=> HomeScreen()));
        });
      }
    });
  }
   g(){
     new Timer(new Duration(seconds: 2), () {
       Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=> PickUpLast(
         requestID: widget.requestID,
         requestIDone: widget.requestIDs,
         from:fromloc ,
         to: toloc,
         screenName: 'HOME',
       )));

     });
  }
}
