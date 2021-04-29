import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:location/location.dart';
import 'package:provider/API.dart';
import 'package:provider/Components/customDialogInput.dart';
import 'package:provider/Screen/JourneyEnd/journeyEnd.dart';
import 'package:provider/Screen/Request/pickUp.dart';
import 'package:provider/data/Model/get_routes_request_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/data/globalvariables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/style.dart';
import '../../Components/slidingUpPanel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../google_map_helper.dart';
import '../../Networking/Apis.dart';
import '../../data/Model/direction_model.dart';
import 'stepsPartView.dart';
import 'package:provider/Components/loading.dart';
import 'imageSteps.dart';
import 'package:http/http.dart' as http;

class PickUpLast extends StatefulWidget {
  final String requestID;
  final String requestIDone;
  final String screenName;
  final LatLng from,to;

  PickUpLast({@required this.requestID,@required this.requestIDone,this.from,this.to ,this.screenName = ""});

  @override
  _PickUpState createState() => _PickUpState();
}

class _PickUpState extends State<PickUpLast> {
  var apis = Apis();
  GoogleMapController _mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var current;
  final Set<Polyline> polyline = {};

  Map<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;
  PolylineId selectedPolyline;
  bool checkPlatform = Platform.isIOS;
  Position currentLocation;

  // LatLng currentLocation = LatLng(26.257142, 50.6416393);
  // LatLng fromLocation = LatLng(39.155232, -95.473636);
  // LatLng toLocation = LatLng(39.115153, -95.638949);
  String userID = '';

  String distance, duration;
  String distance1;
  List<Routes> routesData;
  bool ride1 = true;

  String customerName, placeFrom, placeTo, notes;
  String price , globalprice;
  String customerName1, placeFrom1, placeTo1, notes1;
  String price1;
  TextEditingController noteController = new TextEditingController();
  // LatLng currentLocation;
  LatLng fromLocation;
  LatLng toLocation;
  LatLng fromLocation1;
  LatLng toLocation1;
  bool dataIsSet = false, getOtherDirections = false;
  double fromLocationLatitude,
      fromLocationLongitude,
      toLocationLatitude,
      toLocationLongitude;
  double fromLocationLatitude1,
      fromLocationLongitude1,
      toLocationLatitude1,
      toLocationLongitude1;
  var order_id;
  var vendor_id;
  var order_id1;
  var vendor_id1;
  String instructions, stepDuration, imageManeuver;
  bool isJourneyStarted = false, isPickedUp = false, isJourneyEnded = false, isPick = true,isdeliver =false;
  bool isJourneyStarted1 = false, isPickedUp1 = false, isJourneyEnded1 = false, isPick1 = true,isdeliver1 =false;
  Position driverPosition;
  final GMapViewHelper _gMapViewHelper = GMapViewHelper();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  String point;
  String distance2;
  var MfromLocation;
  var MtoLocation;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
   // print('request ID: ' + widget.requestID);
    getRequestDetails();
    // getDriverCurrentLocation();
  }
  void getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();
      current=new LatLng(location.latitude, location.longitude);
      //updateMarkerAndCircle(location);
      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
            newLocalData.time;
            if (_mapController != null) {
              _mapController.animateCamera(CameraUpdate.newCameraPosition(
                  new CameraPosition(
                      bearing: newLocalData.heading,
                      target: LatLng(newLocalData.latitude, newLocalData.longitude),
                      tilt: 0,

                      zoom: 18.00)));
              current=new LatLng(newLocalData.latitude, newLocalData.longitude);
                if(isPickedUp==false){
                  if(MfromLocation!=null){
                      setPolylines(current, MfromLocation);
                  }
                }else{
                  if(MtoLocation!=null){
                    setPolylines(current,MtoLocation);
                  }
                }



              // updateMarkerAndCircle(newLocalData);

            }
          });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }

  }
  setPolylines(LatLng A, LatLng B) async {
    //flag = false;
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${A.latitude},${A.longitude}&destination=${B.latitude},${B.longitude}&key=AIzaSyBR7rrSUi4o118-vGLhDI_f6buJOnZr900";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    point = values["routes"][0]["overview_polyline"]["points"];
    distance2 = values["routes"][0]["legs"][0]["distance"]["text"];
    setState(() {
      polyline.add(Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: convertToLatLng(decodePoly(point)),
          width: 6,
          color:  Color.fromRGBO(60, 111, 102, 1),
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));

    });
    return values["routes"][0]["overview_polyline"]["points"];
  }
  static List<LatLng> convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }
  static List decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negative then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }


  // driverLocationListener() {
  //   var geolocator = Geolocator();
  //   var locationOptions =
  //   LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  //   String userID;
  //
  //
  //     updateCamera(Globals.loc);
  //
  // }

  updateCamera(Position position) {
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16.0,
          tilt: 75.0,
           bearing: position.speed,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    print('setting the map');
    this._mapController = controller;
    if(fromLocation!=null &&fromLocation1!=null &&toLocation!=null &&toLocation1!=null){
      addMarker();
    }else{
      getRequestDetails();
    }
    // getDriverCurrentLocation();


    // getRouter();
  }

  Future getRequestDetails() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    userID=user.uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var one = prefs.getString('requestID');
    var collectionRef = Firestore.instance.collection('requests');

     var doc = await collectionRef.document(Globals.two).get();
         //.whenComplete(() {
       if(doc.exists ){
         Firestore.instance
             .collection('requests')
             .document(Globals.two)
             .get()
             .then((DocumentSnapshot snap) {
           print('reqeust Data: ' + snap.data.toString());
           setRequestData(snap.data);
         });
       }
       else{
         Firestore.instance
             .collection('temp')
             .document(Globals.two)
             .get()
             .then((DocumentSnapshot snap) {
           print('reqeust Data: ' + snap.data.toString());
           setRequestData(snap.data);
         });
       }
     //});



    var collectionRef1 = Firestore.instance.collection('requests');
    var doc1;
    doc1 =  collectionRef1.document(one).get().whenComplete(() {
      if(doc1!=null){
        Firestore.instance
            .collection('requests')
            .document(one)
            .get()
            .then((DocumentSnapshot snap) {
          print('reqeust Data: ' + snap.data.toString());
          setRequestData1(snap.data);
        });
      }
      else{
        Firestore.instance
            .collection('temp')
            .document(one)
            .get()
            .then((DocumentSnapshot snap) {
          print('reqeust Data: ' + snap.data.toString());
          setRequestData1(snap.data);
        });
      }
    });



  }

  Future setRequestData(Map<String, dynamic> requestData) async {
    // print('SOME THING FROM PICK UP: ' + requestData.toString());

    DocumentReference docRef =
    Firestore.instance.collection('requests').document(Globals.two);
    var distance2 = requestData['distance'].toString();
    distance2 = distance2.split(' ')[0];
    var calculateprice = 8 + (2 * double.parse(distance2));
    Map<String, dynamic> data = {
     // 'servicePrice':  calculateprice.toString(),
      'servicePrice':  Globals.base.toString(),
      // prefs.clear();
    };

    docRef.updateData(data).then((document) {
      print('UPdating request information');
    }).whenComplete(() async {
      print('updated request information');
    }).catchError((error) {
      print('request update...error');
    });

    setState(() {
      if(requestData['serviceTypeID']==null){
        order_id= requestData['order_id'];
        vendor_id=requestData['vendor_id'];
      }
      isJourneyStarted = requestData['isJourneyStarted'];
      isPickedUp = requestData['isPickedUp'];
      isJourneyEnded = requestData['isJourneyEnded'];
      customerName = requestData['userFullName'];
      distance = requestData['distance'].toString();
      placeFrom = requestData['placeFrom'];
      placeTo = requestData['placeTo'];
      notes = requestData['notes'];
      //price = calculateprice.toString();
      price = Globals.base.toString();
      print('FROM LOCATION: ' + requestData['positionFrom'].toString());
      fromLocationLatitude = double.parse(requestData['positionFrom']['latitude'].toString());
      print('fromLocationLatitude: ' + fromLocationLatitude.toString());
      fromLocationLongitude = double.parse(requestData['positionFrom']['longitude'].toString());
      toLocationLatitude = double.parse(requestData['positionTo']['latitude'].toString());
      toLocationLongitude = double.parse(requestData['positionTo']['longitude'].toString());
      fromLocation = LatLng(fromLocationLatitude, fromLocationLongitude);
      print('fromLocation: ' + fromLocation.toString());
      toLocation = LatLng(toLocationLatitude, toLocationLongitude);
      print('toLocation: ' + toLocation.toString());

      print('ALL IS SET');
      // toLocation = requestData['positionTo'];
      // print()
      dataIsSet = true;

    });
  }

  Future setRequestData1(Map<String, dynamic> requestData) async {
     //requestData['servicePrice'] = 10+2*int.parse(distance);
    // print('SOME THING FROM PICK UP: ' + requestData.toString());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var one = prefs.getString('requestID');
    DocumentReference docRef =
    Firestore.instance.collection('requests').document(Globals.two);
    // var distance2 = requestData['distance'].toString();
    // distance2 = distance2.split(' ')[0];
 //   var calculateprice = 8 + (2 * double.parse(distance2));
    Map<String, dynamic> data = {
      //'servicePrice':  calculateprice.toString(),
      'servicePrice':  Globals.base.toString(),
      // prefs.clear();
    };

    docRef.updateData(data).then((document) {
      print('UPdating request information');
    }).whenComplete(() async {
      print('updated request information');
    }).catchError((error) {
      print('request update...error');
    });

    setState(() {
      if(requestData['serviceTypeID']==null){
        order_id1= requestData['order_id'];
        vendor_id1=requestData['vendor_id'];
      }
      isJourneyStarted1 = requestData['isJourneyStarted'];
      isPickedUp1 = requestData['isPickedUp'];
      isJourneyEnded1 = requestData['isJourneyEnded'];
      customerName1 = requestData['userFullName'];
      distance1 = requestData['distance'].toString();
      placeFrom1 = requestData['placeFrom'];
      placeTo1 = requestData['placeTo'];
      notes1 = requestData['notes'];
      //price1 = calculateprice.toString();
      price1 = Globals.base.toString();
      globalprice = price1;
      print('FROM LOCATION: ' + requestData['positionFrom'].toString());
      fromLocationLatitude1 = double.parse(requestData['positionFrom']['latitude'].toString());
      print('fromLocationLatitude: ' + fromLocationLatitude1.toString());
      fromLocationLongitude1 = double.parse(requestData['positionFrom']['longitude'].toString());
      toLocationLatitude1 = double.parse(requestData['positionTo']['latitude'].toString());
      toLocationLongitude1 = double.parse(requestData['positionTo']['longitude'].toString());
      fromLocation1 = LatLng(fromLocationLatitude1, fromLocationLongitude1);
      print('fromLocation: ' + fromLocation1.toString());
      toLocation1 = LatLng(toLocationLatitude1, toLocationLongitude1);
      print('toLocation: ' + toLocation1.toString());

      print('ALL IS SET');
      // toLocation = requestData['positionTo'];
      // print()
      dataIsSet = true;
      addMarker();
      setState(() {
        MfromLocation=fromLocation1;
      });
      //getRouterBeforeJourneyStart();

    });
  }

  updatePickup() async{
    int totalJobs;
    String totalDistance;
    String earnedD;

    var a,c,d,job;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var one = prefs.getString('requestID');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference docRef =
    Firestore.instance.collection('requests').document(Globals.two);
    DocumentReference docRef1 =
    Firestore.instance.collection('requests').document(one);
    DocumentReference requestRef =
    Firestore.instance.collection('requests').document(Globals.two);
    requestRef.get().then((requestData) {

      Map<String, dynamic> data = requestData.data;
      Firestore.instance
          .collection('temp')
          .document(Globals.two)
          .setData(data)
          .whenComplete(() {
        requestRef.delete().whenComplete(() {
          //Firestore.instance.collection('LM_Driver').document(user.uid).updateData(req);
          print('deleting request');
          DocumentReference requestRefone =
          Firestore.instance.collection('requests').document(one);
          requestRefone.get().then((requestData1) {
            Map<String, dynamic> data1 = requestData1.data;
            Firestore.instance
                .collection('temp')
                .document(one)
                .setData(data1)
                .whenComplete(() {
              requestRefone.delete().whenComplete(() {

                int totalJobs1 = prefs.getInt('totalJobs');
              //  int.parse(job);
                earnedD = prefs.getString('totalEarned');
                String totalDistance1 = d.toString();
                String earned1 = earnedD;
                String ff1 = requestData1['distance'];
                //data

                var a1 = ff1.split(" ");
                var d1 = double.parse(totalDistance1) + double.parse(a1[0]);
               // var ds = d1 + d;
                var c1 = int.parse(earned1) + int.parse(price);
                //var cs = c1 + c;
                String earn1 = c1.toString();
                String dist1 = d1.toString();
                Map<String, dynamic> req1 = new HashMap();
                req1['total_distance'] = dist1;
               // req1['total_jobs'] = totalJobs1 + 1;
               // req1['money_earned'] = earn1;

                Firestore.instance.collection('LM_Driver').document(user.uid).updateData(req1);
                print('deleting request');
              });
            });
          });
        });
      });
    });


    Map<String, dynamic> data = {
      'isPickedUp': true,
    };
    print('pickup data: ' + data.toString());
    docRef.updateData(data).then((document) {
      print('UPdating pickup information');
    }).whenComplete(() async {
      print('updated pickup information');
    }).catchError((error) {
      print('request pickup...error');
    });
    docRef1.updateData(data).then((document) {
      print('UPdating pickup information');
    }).whenComplete(() async {
      print('updated pickup information');
    }).catchError((error) {
      print('request pickup...error');
    });
  }

  endJourney() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var one = prefs.getString('requestID');

    DocumentReference docRef =
    Firestore.instance.collection('requests').document(Globals.two);
    Map<String, dynamic> data = {
      'isJourneyEnded': true,
    };


    print('ended journey data: ' + data.toString());
    docRef.updateData(data).then((document) {
      print('UPdating ended journey');
    }).whenComplete(() async {
      print('updated ended journey');
    }).catchError((error) {
      print('ended journey...error');
    });


    DocumentReference docRefone =
    Firestore.instance.collection('requests').document(one);
    Map<String, dynamic> dataone = {
      'isJourneyEnded': true,
    };
    docRefone.updateData(dataone).then((document) {
      print('UPdating ended journey');
    }).whenComplete(()  {
      Globals.two = null;
       prefs.remove('requestIDs');
       prefs.remove('requestID');
      print('updated ended journey');
    }).catchError((error) {
      print('ended journey...error');
    });


  }
  dialogLoadingRequest() {
    return CustomDialogInput(
      title: "Thankyou",
      buttonName: "ok",

      onPressed: () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(
            '/home',
                (Route<dynamic>
            route) =>
            false);

        // print();
        // print('Option');
      },
    );
  }
  addJourneyHistory() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var one = prefs.getString('requestID');

    String requestID = Globals.two;
    String requestIDs = one;
    DocumentReference requestRef =
    Firestore.instance.collection('temp').document(requestID);
    requestRef.get().then((requestData) {

      Map<String, dynamic> data = requestData.data;
      Firestore.instance
          .collection('journey_history')
          .document(requestID)
          .setData(data)
          .whenComplete(() {
        requestRef.delete().whenComplete(() {
          Map<String, dynamic> data1 = {
            'cancelReason': 'No',
          };
          Firestore.instance
              .collection('journey_history')
              .document(requestID)
              .updateData(data1);
          int totalJobs;
          String totalDistance;
          String earned;

//          setState(() {
//            totalJobs = prefs.getInt('totalJobs');
//            totalDistance = prefs.getString('totalDistance');
//            earned = prefs.getString('totalEarned');
//            String ff = requestData['distance'];
//            //data
//            a = ff.split(" ");
//            d = double.parse(totalDistance) + double.parse(a[0]);
//            c = int.parse(earned) + int.parse(price);
//            job = totalJobs + 1;
//          });
//          String earn = c.toString();
//          String dist = d.toString();
//          Map<String, dynamic> req = new HashMap();
//          req['total_distance'] = dist;
//          req['total_jobs'] = job;
//          req['money_earned'] = earn;
//
//          print('deleting request');
        });
      });
    });


    DocumentReference requestRefone =
    Firestore.instance.collection('temp').document(requestIDs);
    requestRefone.get().then((requestData) {

      Map<String, dynamic> data = requestData.data;
      Firestore.instance
          .collection('journey_history')
          .document(requestIDs)
          .setData(data)
          .whenComplete(() {
        requestRefone.delete().whenComplete(() {
          Map<String, dynamic> data2 = {
            'cancelReason': 'No',
          };
          Firestore.instance
              .collection('journey_history')
              .document(requestIDs)
              .updateData(data2);
          int totalJobs;
          String totalDistance;
          String earned;

          showDialog(
              context: context,
              child: dialogLoadingRequest(),
              barrierDismissible: false);


          totalJobs = prefs.getInt('totalJobs');
          totalDistance = prefs.getString('totalDistance');
          earned = prefs.getString('totalEarned');
          var pri = double.parse(price);
          var pri1 = double.parse(price1);
          var ear = double.parse(earned);
          var a = distance.split(" ");
          var b = distance1.split(" ");
          var d = double.parse(totalDistance) + double.parse(a[0]) + double.parse(b[0]);
          var c = pri + ear + pri1;
          String earn = c.toString();
          var dist = d.toString();
          Map<String, dynamic> req = new HashMap();
          req['total_distance'] = dist.toString();
          req['total_jobs'] = totalJobs + 2;
          req['money_earned'] = earn;

          Firestore.instance.collection('LM_Driver').document(user.uid).updateData(req);
          print('deleting request');




          // totalJobs = prefs.getInt('totalJobs');
          // totalDistance = prefs.getString('totalDistance');
          // earned = prefs.getString('totalEarned');
          // var a = distance.split(" ");
          // var d = double.parse(totalDistance) + double.parse(a[0]);
          // var c = int.parse(earned) + int.parse(price);
          // String earn = c.toString();
          // String dist = d.toString();
          // Map<String, dynamic> req = new HashMap();
          // req['total_distance'] = dist;
          // req['total_jobs'] = totalJobs + 1;
          // req['money_earned'] = earn;
          //
          // Firestore.instance.collection('LM_Driver').document(user.uid).updateData(req);
          print('deleting request');
        });
      });
    });
  }

  // void getDriverCurrentLocation() {
  //   var geolocator = Geolocator()..forceAndroidLocationManager;
  //   var locationOptions =
  //   LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  //
  //   geolocator
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
  //       .then((Position position) {
  //     setState(() {
  //       currentLocation = position;
  //       //LatLng(position.latitude, position.longitude);
  //       print('CURRENT LOCATION DRIVER: ' + currentLocation.toString());
  //     });
  //   }).catchError((e) {
  //     print('GETTING CURRENT LOCATION ERROR: ' + e.toString());
  //   });
  // }

  addMarker() {
    final MarkerId _markerFrom = MarkerId("fromLocation");
    final MarkerId _markerTo = MarkerId("toLocation");
    final MarkerId _markerFromone = MarkerId("fromLocationone");
    final MarkerId _markerToone = MarkerId("toLocationone");
    markers[_markerFrom] = GMapViewHelper.createMaker(
        markerIdVal: "fromLocation",
        icon: checkPlatform
            ? "assets/image/gps_point_24.png"
            : "assets/image/gps_point.png",
        lat: fromLocation1.latitude,
        lng: fromLocation1.longitude,
        markerDescription: 'Pickup point');

    markers[_markerTo] = GMapViewHelper.createMaker(
        markerIdVal: "toLocation",
        icon: checkPlatform
            ? "assets/image/ic_marker_32.png"
            : "assets/image/ic_marker_128.png",
        lat: toLocation1.latitude,
        lng: toLocation1.longitude,
        markerDescription: 'Drop off point');
    markers[_markerFromone] = GMapViewHelper.createMaker(
        markerIdVal: "fromLocationone",
        icon: checkPlatform
            ? "assets/image/gps_point_24.png"
            : "assets/image/gps_point.png",
        lat: fromLocation.latitude,
        lng: fromLocation.longitude,
        markerDescription: 'Pickup point');

    markers[_markerToone] = GMapViewHelper.createMaker(
        markerIdVal: "toLocationone",
        icon: checkPlatform
            ? "assets/image/ic_marker_32.png"
            : "assets/image/ic_marker_128.png",
        lat: toLocation.latitude,
        lng: toLocation.longitude,
        markerDescription: 'Drop off point');
  }

  void getRouterBeforeJourneyStart() async {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    final PolylineId polylineId = PolylineId(polylineIdVal);
    polyLines.clear();
    var router;

    print('DRIVER LOCATION: ' + driverPosition.toString());

    await apis
        .getRoutes(
      getRoutesRequest: GetRoutesRequestModel(
          fromLocation:
          LatLng(Globals.loc.latitude, Globals.loc.longitude),
          toLocation: fromLocation1,
          mode: "driving"),
    )
        .then((data) {
      print('BEFORE JOURNEY ROUTER: ' + data.toString());
      if (data != null) {
        router = data.result.routes[0].overviewPolyline.points;
        routesData = data.result.routes;
      }
    }).catchError((error) {
      print("DiscoveryActionHandler::GetRoutesRequest > $error");
    });

    distance = routesData[0].legs[0].distance.text;
    duration = routesData[0].legs[0].duration.text;

    polyLines[polylineId] = GMapViewHelper.createPolyline(
      polylineIdVal: polylineIdVal,
      router: router,
      formLocation: LatLng(Globals.loc.latitude, Globals.loc.longitude),
      toLocation: fromLocation1,
    );

    // getDriverCurrentLocation();

    setState(() {
      instructions = routesData[0].legs[0].steps[0].htmlInstructions;
      stepDuration = routesData[0].legs[0].steps[0].duration.text;
      imageManeuver = getImageSteps(routesData[0].legs[0].steps[0].maneuver);
      updateCamera(Globals.loc);
      // var a = polyLines.length;
      // setState(() {
      //   for(int i = 0; i < a; i= i + 20)
      //   {
      //     poilat.add(polyLines[0].points[i].latitude);
      //     poilong.add(polyLines[0].points[i].longitude);
      //   }
      //   double totalDistance = 0;
      //   for(var i = 0; i < poilat.length-1; i++){
      //     totalDistance += calculateDistance(poilat[i], poilong[i], poilat[i+1], poilong[i+1]);
      //   }
      // });
      //  polyLines[0].points.

      print('IMAGE MANUEVER: ' + imageManeuver);

      // _mapController?.animateCamera(
      //   CameraUpdate?.newCameraPosition(
      //     CameraPosition(
      //       target: LatLng(driverPosition.latitude, driverPosition.longitude),
      //       zoom: 20.0,
      //       tilt: 75.0,
      //       bearing: driverPosition.heading,
      //     ),
      //   ),
      // );
    });
    // _gMapViewHelper.cameraMove(
    //     fromLocation: currentLocation,
    //     toLocation: fromLocation,
    //     mapController: _mapController);
  }

  void getRouter() async {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    final PolylineId polylineId = PolylineId(polylineIdVal);
   // polyLines.clear();
    var router;

    await apis
        .getRoutes(
      getRoutesRequest: GetRoutesRequestModel(
          fromLocation: LatLng(Globals.loc.latitude, Globals.loc.longitude), toLocation: toLocation1, mode: "driving"),
    )
        .then((data) {
      if (data != null) {
        router = data.result.routes[0].overviewPolyline.points;
        routesData = data.result.routes;
      }
    }).catchError((error) {
      print("DiscoveryActionHandler::GetRoutesRequest > $error");
    });

    distance = routesData[0].legs[0].distance.text;
    duration = routesData[0].legs[0].duration.text;

    polyLines[polylineId] = GMapViewHelper.createPolyline(
      polylineIdVal: polylineIdVal,
      router: router,
      formLocation:LatLng(Globals.loc.latitude, Globals.loc.longitude),
      toLocation: toLocation1,
    );
    setState(() {
      instructions = routesData[0].legs[0].steps[0].htmlInstructions;
      stepDuration = routesData[0].legs[0].steps[0].duration.text;
      imageManeuver = getImageSteps(routesData[0].legs[0].steps[0].maneuver);
      updateCamera(Globals.loc);
//  _mapController?.animateCamera(
//           CameraUpdate?.newCameraPosition(
//             CameraPosition(
//               target: positionDriver,
//               zoom: 15.0,
//             ),
//           ),
//         );
    });

    // _gMapViewHelper.cameraMove(
    //     fromLocation: fromLocation,
    //     toLocation: toLocation,
    //     mapController: _mapController);
  }






  void getDeliverRouter() async {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    final PolylineId polylineId = PolylineId(polylineIdVal);
  //  polyLines.clear();
    var router;

    await apis
        .getRoutes(
      getRoutesRequest: GetRoutesRequestModel(
          fromLocation: LatLng(Globals.loc.latitude, Globals.loc.longitude), toLocation: toLocation, mode: "driving"),
    )
        .then((data) {
      if (data != null) {
        router = data.result.routes[0].overviewPolyline.points;
        routesData = data.result.routes;
      }
    }).catchError((error) {
      print("DiscoveryActionHandler::GetRoutesRequest > $error");
    });

    distance = routesData[0].legs[0].distance.text;
    duration = routesData[0].legs[0].duration.text;

    polyLines[polylineId] = GMapViewHelper.createPolyline(
      polylineIdVal: polylineIdVal,
      router: router,
      formLocation: LatLng(Globals.loc.latitude, Globals.loc.longitude),
      toLocation: toLocation,
    );
    setState(() {
      instructions = routesData[0].legs[0].steps[0].htmlInstructions;
      stepDuration = routesData[0].legs[0].steps[0].duration.text;
      imageManeuver = getImageSteps(routesData[0].legs[0].steps[0].maneuver);
      updateCamera(Globals.loc);
//  _mapController?.animateCamera(
//           CameraUpdate?.newCameraPosition(
//             CameraPosition(
//               target: positionDriver,
//               zoom: 15.0,
//             ),
//           ),
//         );
    });

    // _gMapViewHelper.cameraMove(
    //     fromLocation: fromLocation,
    //     toLocation: toLocation,
    //     mapController: _mapController);
  }





  cancelRequest(String requestID,String notreqid,int id)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username');
    var doc;
    var collectionRef = Firestore.instance.collection('requests');
    doc =  collectionRef.document(requestID).get().whenComplete((){
      if(doc != null){

//        DocumentReference docRef =
//        Firestore.instance.collection('requests').document(requestID);
        Map<String, dynamic> data = {
          'isCancel': true,
        };
        //isPickedUp =false;

        Firestore.instance
            .collection('requests')
            .document(requestID)
            .updateData(data).whenComplete(()  {
          DocumentReference requestRef =
          Firestore.instance.collection('requests').document(requestID);
          requestRef.get().then((requestData) {
            Map<String, dynamic> data = requestData.data;
            Firestore.instance
                .collection('journey_history')
                .document(requestID)
                .setData(data)
                .whenComplete((){
              requestRef.delete();
              Map<String, dynamic> data1 = {
                'cancelReason': noteController.text,
              };
              Firestore.instance
                  .collection('journey_history')
                  .document(requestID)
                  .updateData(data1);
              if(id == 1){
                prefs.setString('requestID',notreqid);
                prefs.remove('requestIDs');
                Globals.two = null;
              }
              else{
                prefs.remove('requestIDs');
                Globals.two = null;
              }
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => PickUp(
                      requestID: notreqid,
                      screenName: 'HOME',
                      username: username,

                    )),
                    (Route<dynamic> route) => false,
              );
            });
          });
        });

//        isDialogOpen=false;
//        bottoms=false;
        polyLines.clear();
        polyLines.remove(data);
//        print('updated data: ' + data.toString());
//        docRef.updateData(data).then((document) {
//          print('UPdating request information');
//        }).whenComplete(() async {
//          print('updated request information');
//        }).catchError((error) {
//          print('request update...error');
//        });
//        prefs.setString("requestID", null);
//        Navigator.of(context)
//            .pushNamedAndRemoveUntil(
//            '/home',
//                (Route<dynamic>
//            route) =>
//            false);
      }
      else{
        DocumentReference docRef =
        Firestore.instance.collection('temp').document(requestID);

        Map<String, dynamic> data = {
          'isCancel': true,
        };
        //isPickedUp =false;

        Firestore.instance
            .collection('temp')
            .document(requestID)
            .updateData(data).whenComplete(()  {

          DocumentReference requestRef =
          Firestore.instance.collection('temp').document(requestID);
          requestRef.get().then((requestData) {
            Map<String, dynamic> data = requestData.data;
            Firestore.instance
                .collection('journey_history')
                .document(requestID)
                .setData(data)
                .whenComplete(() {
              requestRef.delete();
              if(id == 1){
                prefs.setString('requestID',notreqid);
                prefs.remove('requestIDs');
                Globals.two = null;

              }
              else{
                prefs.remove('requestIDs');
                Globals.two = null;

              }
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => PickUp(
                      requestID: notreqid,
                      screenName: 'HOME',
                      username: username,

                    )),
                    (Route<dynamic> route) => false,
              );
            });
          });
        });

//        isDialogOpen=false;
//        bottoms=false;
        polyLines.clear();
        polyLines.remove(data);
//        print('updated data: ' + data.toString());
//        docRef.updateData(data).then((document) {
//          print('UPdating request information');
//        }).whenComplete(() async {
//          print('updated request information');
//        }).catchError((error) {
//          print('request update...error');
//        });
//        prefs.setString("requestID", null);
//        Navigator.of(context)
//            .pushNamedAndRemoveUntil(
//            '/home',
//                (Route<dynamic>
//            route) =>
//            false);
      }
    });






  }


  void getPickRouter() async {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    final PolylineId polylineId = PolylineId(polylineIdVal);
    //polyLines.clear();
    var router;

    print('DRIVER LOCATION: ' + driverPosition.toString());

    await apis
        .getRoutes(
      getRoutesRequest: GetRoutesRequestModel(
          fromLocation:
          LatLng(Globals.loc.latitude, Globals.loc.longitude),
          toLocation: fromLocation,
          mode: "driving"),
    )
        .then((data) {
//          setState(() {
//            isPick = false;
//          });
      print('BEFORE JOURNEY ROUTER: ' + data.toString());
      if (data != null) {
        router = data.result.routes[0].overviewPolyline.points;
        routesData = data.result.routes;
      }
    }).catchError((error) {
      print("DiscoveryActionHandler::GetRoutesRequest > $error");
    });

    distance = routesData[0].legs[0].distance.text;
    duration = routesData[0].legs[0].duration.text;

    polyLines[polylineId] = GMapViewHelper.createPolyline(
      polylineIdVal: polylineIdVal,
      router: router,
      formLocation: LatLng(Globals.loc.latitude, Globals.loc.longitude),
      toLocation: fromLocation,
    );

    // getDriverCurrentLocation();

    setState(() {
      instructions = routesData[0].legs[0].steps[0].htmlInstructions;
      stepDuration = routesData[0].legs[0].steps[0].duration.text;
      imageManeuver = getImageSteps(routesData[0].legs[0].steps[0].maneuver);
      updateCamera(Globals.loc);
      print('IMAGE MANUEVER: ' + imageManeuver);

      // _mapController?.animateCamera(
      //   CameraUpdate?.newCameraPosition(
      //     CameraPosition(
      //       target: LatLng(driverPosition.latitude, driverPosition.longitude),
      //       zoom: 20.0,
      //       tilt: 75.0,
      //       bearing: driverPosition.heading,
      //     ),
      //   ),
      // );
    });
    // _gMapViewHelper.cameraMove(
    //     fromLocation: currentLocation,
    //     toLocation: fromLocation,
    //     mapController: _mapController);
  }

  @override
  Widget build(BuildContext context) {
    print('dataIsSet main widget');
    return !dataIsSet
        ? Container()
        : Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildInfoLayer(),
          // Positioned(
          //   top: 30.0,
          //   left: 0.0,
          //   child: _buildStepDirection(),
          // )
        ],
      ),
    );
  }


   bottomSheet(){
    return showModalBottomSheet(
       // enableDrag: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0),topRight: Radius.circular(24.0)),
        ),
        context: context,
        isDismissible: true,

        builder: (BuildContext bc){
          return Wrap(
            children: [
              SingleChildScrollView(
                child: Container(
//            height: MediaQuery.of(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10,),
                      Text('Cancel Ride ', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      SizedBox(height: 10,),
                      Visibility(
                        visible: ride1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('From: ', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Container(
                                    width: MediaQuery.of(context).size.width/1.5,
                                    child: Text(placeFrom1),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 5,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('To: ', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Container(
                                    width: MediaQuery.of(context).size.width/1.5,
                                    child: Text(placeTo1),
                                  )
                                ],
                              ),
                            ),
                            Center(
                              child: ButtonTheme(
                                height: 45.0,
                                minWidth: MediaQuery.of(context).size.width - 50,
                                child: RaisedButton.icon(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(5.0)),
                                  elevation: 0.0,
                                  color: primaryColor,
                                  icon: new Text(''),
                                  label: new Text(
                                    'Cancel Ride One',
                                    style: headingWhite,
                                  ),
                                  onPressed: () async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();


                                    if(noteController.text.isNotEmpty){
                                      var one = pref.getString('requestID');
                                      if(order_id !=null){
                                        API.driverstatuschange(userID,order_id, 'cancelled',vendor_id);
                                      }

                                      cancelRequest(one,Globals.two,1);

                                    }else{
                                      Fluttertoast.showToast(
                                          msg:
                                          "Please write your reason to cancel the ride",
                                          toastLength:
                                          Toast.LENGTH_LONG,
                                          gravity:
                                          ToastGravity.CENTER,
                                          timeInSecForIos: 3,
                                          backgroundColor:
                                          Colors.blue,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                    // Navigator.of(context).pushReplacement(
                                    //     new MaterialPageRoute(
                                    //         builder: (context) => WalkthroughScreen()));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('From: ', style: TextStyle(fontWeight: FontWeight.bold),),
                            Container(
                              width: MediaQuery.of(context).size.width/1.5,
                              child: Text(placeFrom),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('To: ', style: TextStyle(fontWeight: FontWeight.bold),),
                            Container(
                              width: MediaQuery.of(context).size.width/1.5,
                              child: Text(placeTo),
                            )
                          ],
                        ),
                      ),
                      Center(
                        child: ButtonTheme(
                          height: 45.0,
                          minWidth: MediaQuery.of(context).size.width - 50,
                          child: RaisedButton.icon(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0)),
                            elevation: 0.0,
                            color: primaryColor,
                            icon: new Text(''),
                            label: new Text(
                              'Cancel Ride Two',
                              style: headingWhite,
                            ),
                            onPressed: ()async {
                              SharedPreferences pref = await SharedPreferences.getInstance();

                              if(noteController.text.isNotEmpty){
                                var one = pref.getString('requestID');
                                if(order_id1 != null){
                                  API.driverstatuschange(userID,order_id1, 'cancelled',vendor_id1);
                                }
                                cancelRequest(Globals.two,one,2);
                              }else{
                                Fluttertoast.showToast(
                                    msg:
                                    "Please write your reason to cancel the ride",
                                    toastLength:
                                    Toast.LENGTH_LONG,
                                    gravity:
                                    ToastGravity.CENTER,
                                    timeInSecForIos: 3,
                                    backgroundColor:
                                    Colors.blue,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                              // Navigator.of(context).pushReplacement(
                              //     new MaterialPageRoute(
                              //         builder: (context) => WalkthroughScreen()));
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 15,),
                      Container(
                        width: MediaQuery.of(context).size.width - 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)
                        ),
                        child: TextFormField(
                          maxLines: 4,
                          controller: noteController,
                          decoration: InputDecoration(
                            // border: InputBorder.none,
                              labelText: 'Note'
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),

                    ],
                  ),
                ),
              )
            ],
          );
        }


    );
  }

  Widget _buildStepDirection() {
    final screenSize = MediaQuery.of(context).size;
    print('stepDuration: ' + stepDuration.toString());
    return stepDuration != null
        ? Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: screenSize.width,
      alignment: Alignment.center,
      color: greenColor,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Image.asset(imageManeuver, width: 20.0),
          ),
          // IconButton(
          //   icon: Icon(
          //     Icons.arrow_upward,
          //     color: blackColor,
          //   ),
          //   onPressed: () {},
          // ),
          // Container(
          //   padding: EdgeInsets.only(left: 5.0, right: 5.0),
          //   child: Text(
          //     stepDuration ?? '',
          //     style: textStyle,
          //   ),
          //   //     Text(
          //   //   "500 miles",
          //   //   style: textBoldBlack,
          //   // ),
          // ),
          Html(
            padding: EdgeInsets.only(
              left: 5.0,
              right: 5.0,
              top: 15.0,
            ),
            data: """ ${instructions.trim()} """,
            linkStyle: textStyle,
          ),
          // Text(
          //   "Head southwest on Madison St",
          //   style: textStyle,
          // )
        ],
      ),
    )
        : Container();
    // : Text('text direction');
  }

  Widget _buildInfoLayer() {
    final screenSize = MediaQuery.of(context).size;
    final maxHeight = 0.20 * screenSize.height;
    final minHeight = 130.0;

    print('routesData: ' + routesData.toString());

    final panel = Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              duration ?? '',
                              style: headingBlack,
                            ),
                            Text(
                              //' / EURO ' + globalprice.toString(),
                              ' / EURO ' + Globals.base.toString(),
                              style: headingBlack,
                            ),

                            Spacer(),
                            InkWell(
                              onTap: bottomSheet,
                              child: Row(
                                children: [
                                  Text(
                                    "Cancel Ride",
                                    style: headingBlack3,
                                  ),
                                  SizedBox(width: 5,),

                                  Icon(Icons.cancel),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          distance ?? '',
                          style: textStyle,
                        ),
                      ],
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     print("Reset");
                  //     if (!getOtherDirections) {
                  //       getRouter();

                  //       // getRouterBeforeJourneyStart();
                  //     } else {
                  //       getRouterBeforeJourneyStart();

                  //       // getRouter();
                  //     }
                  //     setState(() {
                  //       getOtherDirections = !getOtherDirections;
                  //     });
                  //   },
                  //   child: Container(
                  //     height: 40,
                  //     width: 40,
                  //     margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(50.0),
                  //       color: primaryColor,
                  //     ),
                  //     child: Tooltip(
                  //       message: getOtherDirections
                  //           ? 'Get Directions to Pickup Spot'
                  //           : 'Get Directions from Pickup to Drop off Spot',
                  //       child: Icon(
                  //         MdiIcons.directionsFork,
                  //         color: whiteColor,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   width: 70.0,
                  //   child: ButtonTheme(
                  //     minWidth: 50,
                  //     height: 35.0,
                  //     child: RaisedButton(
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: new BorderRadius.circular(30.0)),
                  //       elevation: 0.0,
                  //       color: redColor,
                  //       child: Text(
                  //         'Exit'.toUpperCase(),
                  //         style: heading18,
                  //       ),
                  //       onPressed: () {
                  //         Navigator.of(context).pop();
                  //       },
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
//          Container(
//            padding: EdgeInsets.only(top: 10.0),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                GestureDetector(
//                  onTap: (){
//                    print("Reset");
//                  },
//                  child: Container(
//                    height: 40,
//                    width: 40,
//                    margin: EdgeInsets.only(left: 10.0,right: 10.0),
//                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(50.0),
//                      color: primaryColor,
//                    ),
//                    child: Icon(Icons.arrow_back_ios,color: whiteColor,),
//                  ),
//                ),
//                GestureDetector(
//                  onTap: (){
//                    print("Reset");
//                  },
//                  child: Container(
//                    height: 40,
//                    width: 40,
//                    margin: EdgeInsets.only(left: 10.0,right: 10.0),
//                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(50.0),
//                      color: primaryColor,
//                    ),
//                    child: Icon(Icons.arrow_forward_ios,color: whiteColor,),
//                  ),
//                ),
//              ],
//            ),
//          ),
            Container(
              padding: EdgeInsets.only(top: 10.0),
              child: ButtonTheme(
                minWidth: screenSize.width,
                height: 35.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  elevation: 0.0,
                  color: Color.fromRGBO(60, 111, 102, 1),
                  child: isPickedUp == false
                      ? Text(
                    'PICK UP'.toUpperCase(),
                    style: headingWhite,
                  ):
                  isPick == false ?
                  Text(
                    'PICK UP Second'.toUpperCase(),
                    style: headingWhite,
                  )
                      : isdeliver == false && isPick == true ?
                  Text(
                    'Delivery'.toUpperCase(),
                    style: headingWhite,
                  )
                  :Text(
                    'Delivery Second'.toUpperCase(),
                    style: headingWhite,
                  ),
                  onPressed: () {
                    // print('DO SOMETHING');
                    setState(() {
                      if (!isPickedUp) {
                        isPickedUp = true;
                        if(order_id !=null){
                          API.driverstatuschange(userID,order_id, 'pickedup',vendor_id);
                        }
                        MtoLocation=fromLocation;
                        //getPickRouter();
                        updatePickup();

                        globalprice = price;
                        isPick = false;

                      //  getOtherDirections = true;

                      } else if(!isPick){
                        if(order_id1 != null){
                          API.driverstatuschange(userID,order_id1, 'pickedup',vendor_id1);
                        }
                        globalprice = price1;
                        isPick = true;
                        MtoLocation=toLocation1;
                       // getRouter();
                      }
                      else{
                        if(!isdeliver){
                          if(order_id != null){
                            API.driverstatuschange(userID,order_id, 'delivered',vendor_id);
                          }
                          MtoLocation=toLocation;
                         // getDeliverRouter();
                          isdeliver = true;
                          setState(() {
                            globalprice = price;
                            ride1 = false;
                          });
                        }else
                        {
                          isJourneyEnded = true;
                          // print('JOURNEY IS ENDING NOW');
                          if(order_id1 != null){
                            API.driverstatuschange(userID,order_id1, 'delivered',vendor_id1);
                          }
                          endJourney();
                          addJourneyHistory();
                        }
                      }
                    });
                    // Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (context) => PickUp()));
                  },
                ),
              ),
            ),
            // Divider(),
            // Expanded(
            //   child: routesData != null
            //       ? ListView.builder(
            //     shrinkWrap: true,
            //     itemCount: routesData[0].legs[0].steps.length,
            //     itemBuilder: (BuildContext context, index) {
            //       return StepsPartView(
            //         instructions: routesData[0]
            //             .legs[0]
            //             .steps[index]
            //             .htmlInstructions,
            //         duration:
            //         routesData[0].legs[0].steps[index].duration.text,
            //         imageManeuver: getImageSteps(
            //             routesData[0].legs[0].steps[index].maneuver),
            //       );
            //     },
            //   )
            //       : Container(
            //     child: LoadingBuilder(),
            //   ),
            // )
          ],
        ));

    return SlidingUpPanel(
      maxHeight: maxHeight,
      minHeight: minHeight,
      parallaxEnabled: true,
      parallaxOffset: .5,
      panel: panel,
      body: _buildMapLayer(),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
      onPanelSlide: (double pos) => setState(() {}),
    );
  }
  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 10.4746,
  );

  Widget _buildMapLayer() {
    return  GoogleMap(
      padding: EdgeInsets.only(top: 200,bottom: 200),
      myLocationEnabled: true,
      mapType: MapType.normal,
      initialCameraPosition: initialLocation,
      markers: Set<Marker>.of(markers.values),
      onMapCreated:_onMapCreated,
      // onMapCreated: (GoogleMapController controller) {
      //   _mapController = controller;
      // },
      polylines: polyline,

      //  markers: Set<Marker>.of(markers.values),
      //polylines: polyline,
    );


    // print('driverPosition: ' + driverPosition.toString());
    // return Globals.loc == null
    //     ? _gMapViewHelper.buildMapView(
    //     context: context,
    //     onMapCreated: _onMapCreated,
    //     currentLocation:
    //     LatLng(Globals.loc.latitude, Globals.loc.longitude),
    //     markers: markers,
    //     onTap: (_) {})
    //     : SizedBox(
    //   height: MediaQuery.of(context).size.height,
    //   child: _gMapViewHelper.buildMapView(
    //       context: context,
    //       onMapCreated: _onMapCreated,
    //       currentLocation:
    //       LatLng(Globals.loc.latitude, Globals.loc.longitude),
    //       markers: markers,
    //       polyLines: polyLines,
    //       onTap: (_) {}),
    // );

  }
}