import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/Screen/Request/pickUp.dart';
import 'package:provider/Screen/Request/pickuplast.dart';
import 'package:provider/Screen/SplashScreen/SplashScreen.dart';
import 'package:provider/app_localizations.dart';
import 'package:provider/data/globalvariables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screen/Home/home.dart';
import 'theme/style.dart';
import 'router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/data/globalvariables.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String userID = prefs.getString('userID');
  // prefs.remove('requestID');
  String requestID = prefs.getString('requestID');
  String requestIDs = prefs.getString('requestIDs');
  var completeProfile = prefs.getBool('complete_profile')??false;


  runApp(MyApp(
    userID: userID,
    requestID: requestID,
    requestIDs: requestIDs,
  ));
}
class MyApp extends StatefulWidget {
  final String userID;
  final String requestID;
  final String requestIDs;var completeProfile;

  MyApp({this.userID, this.requestID,this.requestIDs});

  @override
  MyApps createState() => MyApps();
}
class MyApps extends State<MyApp>{

  var completeprofile=false;
  @override
  void initState() {
    checkprofile();
    super.initState();
    setRequest();
    //   driverLocationListener();


    // getDriverCurrentLocation();

  }
  checkprofile()async{
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser currentUser = await _auth.currentUser();
    if(currentUser !=null){
      Firestore.instance
          .collection('LM_Driver')
          .document(currentUser.uid)
          .get()
          .then((DocumentSnapshot snap) {
        if(snap.data['email']!=null && snap.data['profile_pic']!=null)
          Globals.completeProfile=true;

      });
    }
  }


  // Position current;
  //
  //
  // Future getRequestDetails() async {
  //   Position position =  await Geolocator()
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   current = position;
  //   setState(() {
  //     Globals.loc = position;});
  //  if(widget.requestIDs!=null){
  //    var collectionRef = Firestore.instance.collection('requests');
  //    var doc = await collectionRef.document(widget.requestIDs).get();
  //    if(doc.exists){
  //      await Firestore.instance
  //          .collection('requests')
  //          .document(widget.requestIDs)
  //          .get()
  //          .then((DocumentSnapshot snap) {
  //        print('reqeust Data: ' + snap.data.toString());
  //        setRequestData(snap.data);
  //      });
  //    }else
  //    {
  //
  //      await Firestore.instance
  //          .collection('temp')
  //          .document(widget.requestIDs)
  //          .get()
  //          .then((DocumentSnapshot snap) {
  //        print('reqeust Data: ' + snap.data.toString());
  //        setRequestData(snap.data);
  //      });
  //    }
  //
  //
  //
  //  }
  // }
  Position current;
  Future setRequest() async {
    Position position =  await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    current = position;
    setState(() {
      Globals.loc = current;

    });
  }
  @override
  Widget build(BuildContext context) {



    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LM_Driver',
      theme: appTheme,
      onGenerateRoute: (RouteSettings settings) => getRoute(settings),
      home: SplashScreen(userID:widget.userID,requestID: widget.requestID,requestIDs:widget.requestIDs,completeProfile:completeprofile,),
      supportedLocales: [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }

  // getRouter() {
  //
  //   if (widget.userID == null) {
  //     return SplashScreen(requestID: widget.requestID,requestIDs: widget.requestIDs,);
  //   } else {
  //     if (widget.requestID == null) {
  //       return HomeScreen();
  //     } else {
  //       if(widget.requestIDs == null)
  //         {
  //           return PickUp(
  //             requestID: widget.requestID,
  //             screenName: 'HOME',
  //           );
  //         }else
  //         fromloc != null && toloc != null?
  //        PickUpLast(
  //         requestID: widget.requestID,
  //         requestIDone: widget.requestIDs,
  //         from:fromloc ,
  //         to: toloc,
  //         screenName: 'HOME',
  //       ):
  //           getRequestDetails();
  //
  //     }
  //   }
  // }
}
