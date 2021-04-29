import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math'show asin, atan2, cos, pi, sin, sqrt;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:provider/API.dart';
import 'package:provider/Screen/JourneyEnd/journeyEnd.dart';
import 'package:provider/Screen/Request/pickuplast.dart';
import 'package:provider/Screen/Request/requestDetail.dart';
import 'package:provider/Screen/SplashScreen/SplashScreen.dart';
import 'package:provider/data/Model/get_routes_request_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/data/globalvariables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/customDialogInput.dart';
import '../../requestDialog.dart';
import '../../theme/style.dart';
import '../../Components/slidingUpPanel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;
import '../../google_map_helper.dart';
import '../../Networking/Apis.dart';
import '../../data/Model/direction_model.dart';
import 'stepsPartView.dart';
import 'package:provider/Components/loading.dart';
import 'imageSteps.dart';
import 'package:http/http.dart' as http;

class PickUp extends StatefulWidget {
  final String requestID;
  final String screenName;
  final String username;


  PickUp({@required this.requestID, this.screenName = "",this.username});

  @override
  _PickUpState createState() => _PickUpState();
}

class _PickUpState extends State<PickUp> {
  TextEditingController noteController = new TextEditingController();
  var apis = Apis();
  var userName;
  var endpoints;
  List<dynamic> dist = new List();
  List<dynamic> poilat = new List();
  List<dynamic> poilong = new List();

  GoogleMapController _mapController;
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};


  Map<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;
  PolylineId selectedPolyline;
  bool checkPlatform = Platform.isIOS;
  Position currentLocation;
  // Position loc;

  // LatLng currentLocation = LatLng(26.257142, 50.6416393);
  // LatLng fromLocation = LatLng(39.155232, -95.473636);
  // LatLng toLocation = LatLng(39.115153, -95.638949);
  String point;
  String distance2;
  String distance, duration;
  List<Routes> routesData;

  String customerName, placeFrom, placeTo, notes,date,time;
  var price;
  // LatLng currentLocation;
  static LatLng fromLocation;
  static LatLng toLocation;
  bool dataIsSet = false, getOtherDirections = false;
  double fromLocationLatitude,
      fromLocationLongitude,
      toLocationLatitude,
      toLocationLongitude;

  String instructions, stepDuration, imageManeuver;
  bool isJourneyStarted = false, isPickedUp = false, isJourneyEnded = false;
  var order_id;
  var vendor_id;
  Position driverPosition;
  final GMapViewHelper _gMapViewHelper = GMapViewHelper();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  var userImage;
  String totalEarned = '0', totalDistance = '0';
  double hoursOnline = 0.0;
  int totalJobs = 0;
  var current;
  final Set<Polyline> polyline = {};


  @override
  void initState() {
    getCurrentLocation();
    getRequestDetails();
    _getUserData();
    getLiveRequests();
    super.initState();
//    driverLocationListener();

    print('request ID: ' + widget.requestID);

    // getDriverCurrentLocation();

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
                if(fromLocation!=null){
                  setPolylines(current, fromLocation);
                }
              }else{
                if(toLocation!=null){
                  setPolylines(current,toLocation);
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

  // driverLocationListener() {
  //   var geolocator = Geolocator();
  //   var locationOptions =
  //       LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  //   String userID;
  //   updateCamera(Globals.loc);
  // }

  updateCamera(Position position) {
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16.0,
          tilt: 75.0,
          bearing: position.accuracy,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    print('setting the map');
    this._mapController = controller;
    setState(() {
      _mapController = controller;
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(Globals.loc.latitude, Globals.loc.longitude),
            zoom: 15.0,
          ),
        ),
      );
    });
    // getDriverCurrentLocation();
    addMarker();
   // getRouterBeforeJourneyStart();
    // getRouter();
  }

  Future getRequestDetails() async {
    var collectionRef = Firestore.instance.collection('requests');
    var doc = await collectionRef.document(widget.requestID).get();
    if(doc.exists){
      await Firestore.instance
          .collection('requests')
          .document(widget.requestID)
          .get()
          .then((DocumentSnapshot snap) {
        print('reqeust Data: ' + snap.data.toString());
        setRequestData(snap.data);
      });
    }
    else{
      await Firestore.instance
          .collection('temp')
          .document(widget.requestID)
          .get()
          .then((DocumentSnapshot snap) {
        print('reqeust Data: ' + snap.data.toString());
        setRequestData(snap.data);
      });
    }
  }

  Future setRequestData(Map<String, dynamic> requestData) async {

    DocumentReference docRef =
    Firestore.instance.collection('requests').document(widget.requestID);
    // var distance1 = requestData['distance'].toString();
    // distance1 = distance1.split(' ')[0];
    // var calculateprice = 8 + (2 * double.parse(distance1));
    Map<String, dynamic> data = {
      //'servicePrice':  calculateprice.toString(),
      'servicePrice':  double.parse(Globals.base.toString()),
      // prefs.clear();
    };

    docRef.updateData(data).then((document) {
      print('UPdating request information');
    }).whenComplete(() async {
      print('updated request information');
    }).catchError((error) {
      print('request update...error');
    });

    //requestData['servicePrice'] = 10+2*int.parse(distance);
    setState(() {
      order_id= requestData['order_id'];
      vendor_id=requestData['vendor_id'];
      isJourneyStarted = requestData['isJourneyStarted'];
      isPickedUp = requestData['isPickedUp'];
      isJourneyEnded = requestData['isJourneyEnded'];
      customerName = requestData['userFullName'];
      distance = requestData['distance'].toString();
      placeFrom = requestData['placeFrom'].toString();
      placeTo = requestData['placeTo'].toString();
      notes = requestData['notes'];
      date = requestData['date'];
      time = requestData['time'];
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
    if(dataIsSet=true){
      double distanceInMetersFrom = await Geolocator().distanceBetween(fromLocationLatitude, fromLocationLongitude, fromLocationLatitude, fromLocationLongitude);
      double distanceInMetersto = await Geolocator().distanceBetween(toLocationLatitude, toLocationLongitude, toLocationLatitude, toLocationLongitude);
      double toradius=distanceInMetersto*(pi/180);
      double fromradius=distanceInMetersFrom*(pi/180);
      if (fromradius==toradius){
        dataIsSet = true;
      }
      else{
        dataIsSet=false;
        Text(
            'Lund py charo'
        );
      }
    }
    else{
      dataIsSet=false;
    }

  }

  updatePickup() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference docRef =
        Firestore.instance.collection('requests').document(widget.requestID);
    DocumentReference requestRef =
    Firestore.instance.collection('requests').document(widget.requestID);
    requestRef.get().then((requestData){
      Map<String, dynamic> data = requestData.data;
      Firestore.instance
          .collection('temp')
          .document(widget.requestID)
          .setData(data)
          .whenComplete(() {
        requestRef.delete().whenComplete((){
//          int totalJobs;
//          String totalDistance;
//          String earned;
//
//          totalJobs = prefs.getInt('totalJobs');
//          totalDistance = prefs.getString('totalDistance');
//          earned = prefs.getString('totalEarned');
//          var a = distance.split(" ");
//          var d = double.parse(totalDistance) + double.parse(a[0]);
//          var c = int.parse(earned) + int.parse(price);
//          String earn = c.toString();
//          String dist = d.toString();
//          Map<String, dynamic> req = new HashMap();
//          req['total_distance'] = dist;
//          req['total_jobs'] = totalJobs + 1;
//          req['money_earned'] = earn;

//          Firestore.instance.collection('LM_Driver').document(user.uid).updateData(req);
          print('deleting request');
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
  }

  endJourney() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('requestID');
    DocumentReference docRef =
        Firestore.instance.collection('requests').document(widget.requestID);
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
  }


  addJourneyHistory() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    String requestID = widget.requestID;
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

          showDialog(
              context: context,
              child: dialogLoadingRequest(),
              barrierDismissible: false);

          totalJobs = prefs.getInt('totalJobs');
          totalDistance = prefs.getString('totalDistance');
          earned = prefs.getString('totalEarned');
          var pri = double.parse(price);
          var ear = double.parse(earned);
          var a = distance.split(" ");
          var d = double.parse(totalDistance) + double.parse(a[0]);
          //var c = pri + ear ;
          var c = double.parse(Globals.base.toString()) + ear ;
          String earn = c.toString();
          String dist = d.toString();
          Map<String, dynamic> req = new HashMap();
          req['total_distance'] = dist;
          req['total_jobs'] = totalJobs + 1;
          req['money_earned'] = earn;

          Firestore.instance.collection('LM_Driver').document(user.uid).updateData(req);
          print('deleting request');
        });
      });
    });
  }
  int calculateDistance(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1); // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    //d=( d * 1000);
    d = d * 1000;

    return d.ceil();
  }
  double deg2rad(double deg) {
    return deg * (pi / 180);
  }
//void distancefrom() async{
//  double distanceInMeters = await Geolocator().distanceBetween(, _lngFrom, 52.3546274, 4.8285838);
//
//}
  double rad2deg(double rad) {
    return (rad * 180) / pi;
  }
  // void getDriverCurrentLocation() {
  //   var geolocator = Geolocator()..forceAndroidLocationManager;
  //   var locationOptions =
  //       LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
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



  Future _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID');

    userName = prefs.getString('username');
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
    prefs.setString('profilePic', userData['profile_pic']);

    print('USERNAME: ' + userData['name']);
    if (userData['profile_pic'] == null) {
      final ref = FirebaseStorage.instance.ref().child('user_default.png');
// no need of the file extension, the name will do fine.
      // var userImageURL = await ref.getDownloadURL();
      var userImageURL =
          "https://firebasestorage.googleapis.com/v0/b/road-side-assist-1562842759870.appspot.com/o/user_default.png?alt=media&token=fc1e0ce4-9836-4793-ab68-f613d1a522d5";
      print('GETTING DEFAULT PIC' + userImage.toString());
      setState(() {
        userImage = userImageURL;
      });
    } else {
      setState(() {
        userImage = userData['profile_pic'];
      });
    }
    setState(() {

      totalEarned = userData['money_earned'];
      print('totalEarned ' + totalEarned.toString());
      totalJobs = userData['total_jobs'];
      print('totalJobs ' + totalJobs.toString());
      hoursOnline = userData['hours_online'];
      print('hoursOnline ' + hoursOnline.toString());
      totalDistance = userData['total_distance'];
      print('totalDistance ' + totalDistance.toString());
      isShowLocation = userData['isShowLocation'];
      print('isShowLocation ' + isShowLocation.toString());
      isDataSet = true;
    });
  }






  addMarker() {
    print('INSIDE ADD MARKER: ' + fromLocation.toString());
    final MarkerId _markerFrom = MarkerId("fromLocation");
    final MarkerId _markerTo = MarkerId("toLocation");
    markers[_markerFrom] = GMapViewHelper.createMaker(
        markerIdVal: "fromLocation",
        icon: checkPlatform
            ? "assets/image/gps_point_24.png"
            : "assets/image/gps_point.png",
        lat: fromLocation.latitude,
        lng: fromLocation.longitude,
        markerDescription: 'Pickup point');

    markers[_markerTo] = GMapViewHelper.createMaker(
        markerIdVal: "toLocation",
        icon: checkPlatform
            ? "assets/image/ic_marker_32.png"
            : "assets/image/ic_marker_128.png",
        lat: toLocation.latitude,
        lng: toLocation.longitude,
        markerDescription: 'Delivery point');
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
          toLocation: fromLocation,
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

    distance = routesData[0].legs[0].distance.text.toString();
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

  bool isShowLocation = false;
  String requestIDs = '';
  String userID = '';
  bool isDataSet = false;
  bool isDialogOpen = false;

  StreamSubscription<dynamic> requestsListeners;
  List<Map<String, dynamic>> listRequest = List<Map<String, dynamic>>();

  bool bottoms = false;
  getLiveRequests() {
    CollectionReference reference = Firestore.instance.collection('requests');
    requestsListeners = reference
    // .where('isJourneyCancelled', isEqualTo: 'false')
        .where('isAccepted', isEqualTo: false)
        .snapshots()
        .listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((docChange) async{
        Map<String, dynamic> data = docChange.document.data;
        DocumentSnapshot document = docChange.document;
        var fromLocationLatitudeone = data['positionFrom']['latitude'];
        var fromLocationLongitudeone = data['positionFrom']['longitude'];
        var toLocationLatitudeone = data['positionTo']['latitude'];
        var toLocationLongitudeone = data['positionTo']['longitude'];
        double distanceInMetersFrom = await Geolocator().distanceBetween(double.parse(fromLocationLatitude.toString()),
            double.parse(fromLocationLongitude.toString()), double.parse(fromLocationLatitudeone.toString()), double.parse(fromLocationLongitudeone.toString()));
        double distanceInMetersto = await Geolocator().distanceBetween(double.parse(toLocationLatitude.toString()),
            double.parse(toLocationLongitude.toString()),double.parse( toLocationLatitudeone.toString()), double.parse(toLocationLongitudeone.toString()));
        double toradius=distanceInMetersto*(pi/180);
        double fromradius=distanceInMetersFrom*(pi/180);
        if (fromradius<=10000 && toradius <= 10000){
          if (docChange.type != "removed" && docChange.type != "modified") {
            if (isShowLocation) {
              if (isDialogOpen) {
                if(!bottoms){
                  Navigator.pop(context);
                }
                // Navigator.pop(context);
                setState(() {
                  isDialogOpen = true;
                });
              }


              if (data['isJourneyCancelled'] == false && isDialogOpen == false) {
                setState(() {
                  isDialogOpen = true;
                  requestIDs = document.documentID;
                 // Globals.two = requestIDs;
                  print('NEW DATA SHIT: ' + data['placeTo'].toString());

//                var ref =Firestore.instance.collection('request').getDocuments();
                  if(data['isAccepted'] == false)
                  {

                    showModalBottomSheet(
                       // enableDrag: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0),topRight: Radius.circular(24.0)),
                        ),
                        context: context,
                        isDismissible: false,
                        builder: (BuildContext bc){
                          return dialogInfo(data);
                        }
                    );



                  }

//                showDialog(
//                    context: context,
//                    child: dialogInfo(data),
//                    barrierDismissible: false);
                  listRequest.add(data);
                  print('LIST: ' + listRequest.toString());
                  print("------------------------------------------------");
                });
              }else{
                setState(() {
                  isDialogOpen = false;
                  bottoms = false;
                });
              }
            }
          }
        }

      });
    });
  }
  checkupdate(String reqid)async{
    DocumentReference reference = Firestore.instance.collection('requests').document(reqid);
    await reference.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      setState(() {
        var data =snapshot.data;
        if(data['isAccepted']==false){
          setState(() {
            var panel=data['order_id'];
            if(panel != null){
              API.driverstatuschange(userID, data['order_id'], 'accept', data['vendor_id']);
            }
            // isDialogOpen = false;
            requestsListeners.cancel();
          });
          print('ACCEPTED REQUEST');
          acceptRequest();
          setState(() {
            Globals.pik = true;
            Globals.two = requestIDs;
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => PickUpLast(
                  requestID: widget.requestID,
                  requestIDone: requestIDs,
                  from: fromLocation,
                  to: toLocation,
                  screenName: 'HOME',
                )),
                (Route<dynamic> route) => false,
          );
        }else{
          Fluttertoast.showToast(
              msg: "This Request has been Accepted by Another Driver",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.red,
              textColor: Colors.white);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),);
        }
      });
    });

  }

  bottomSheet(){
    return showModalBottomSheet(
        //enableDrag: true,
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
                              'Cancel Ride',
                              style: headingWhite,
                            ),
                            onPressed: () {
                              //SharedPreferences pref = await SharedPreferences.getInstance();

                              if(noteController.text.isNotEmpty){
                                if(order_id != null){
                                  API.driverstatuschange(userID,order_id, 'cancelled',vendor_id);
                                }

                                // pref.remove('requestID');
                                cancelRequest();
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

  dialogInfo(data) {


    return RequestDialog(
      title: "Request",
      requestData: data,
      onReview: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RequestDetail(
              requestID: requestIDs,
            )));
        // Navigator.pushNamed(context, '/review_trip');
      },
      onDecline: () {
        setState(() {
          isDialogOpen = true;
          bottoms = true;
        });
        Navigator.of(context).pop();
      },
      onAccept: () {
        setState(() {
          checkupdate(requestIDs);

        });
        // setState(() {
        //  // Globals.two = requestIDs;
        //   // isDialogOpen = false;
        //   requestsListeners.cancel();
        // });
        //Navigator.of(context).pop();

        // Navigator.pushReplacement(context, PickUp(
        //           requestID: requestID,
        //           screenName: 'HOME',
        //         ));
        // Navigator.of(context).push(MaterialPageRoute(
        //     builder: (context) => PickUp(
        //           requestID: requestID,
        //           screenName: 'HOME',
        //         )));
      },
      onTap: () {
        setState(() {
          isDialogOpen = false;
        });
        Navigator.of(context).pop();
        // Navigator.push(context, RequestDetail());
      },
    );
  }
  acceptRequest() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   prefs.setString("requestIDs", requestIDs);
   Globals.two = prefs.getString("requestIDs");
    DocumentReference docRef =
    Firestore.instance.collection('requests').document(requestIDs);
    Map<String, dynamic> data = {
      'isAccepted': true,
      'isJourneyStarted': true,
      'acceptedByName': userName,
      'acceptedByID': userID,
      'isCancel': false,
    };
    print('updated data: ' + data.toString());
    docRef.updateData(data).then((document) {
      print('UPdating request information');
    }).whenComplete(() async {
      print('updated request information');
    }).catchError((error) {
      print('request update...error');
    });
  }
  cancelRequest()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var collectionRef = Firestore.instance.collection('requests');
    var doc =  await collectionRef.document(widget.requestID).get();
        //.whenComplete((){
      if(doc.exists ){

        DocumentReference docRef =
        Firestore.instance.collection('requests').document(widget.requestID);
        Map<String, dynamic> data = {
          'isCancel': true,
        };
        //isPickedUp =false;

        Firestore.instance
            .collection('requests')
            .document(widget.requestID)
            .updateData(data).whenComplete(() async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          FirebaseUser user = await FirebaseAuth.instance.currentUser();

          String requestID = widget.requestID;
          DocumentReference requestRef =
          Firestore.instance.collection('requests').document(requestID);
          requestRef.get().then((requestData) {
            Map<String, dynamic> data = requestData.data;
            Firestore.instance
                .collection('journey_history')
                .document(requestID)
                .setData(data)
                .whenComplete(() {
              requestRef.delete();
              Map<String, dynamic> data1 = {
                'cancelReason': noteController.text,
              };
              Firestore.instance
                  .collection('journey_history')
                  .document(requestID)
                  .updateData(data1);
            });
          });
        });

        isDialogOpen=false;
        bottoms=false;
        polyLines.clear();
        polyLines.remove(data);
        print('updated data: ' + data.toString());
        docRef.updateData(data).then((document) {
          print('UPdating request information');
        }).whenComplete(() async {
          print('updated request information');
        }).catchError((error) {
          print('request update...error');
        });
        prefs.setString("requestID", null);
        Navigator.of(context)
            .pushNamedAndRemoveUntil(
            '/home',
                (Route<dynamic>
            route) =>
            false);
      }
      else{
        DocumentReference docRef =
        Firestore.instance.collection('temp').document(widget.requestID);

        Map<String, dynamic> data = {
          'isCancel': true,
        };
        //isPickedUp =false;

        Firestore.instance
            .collection('temp')
            .document(widget.requestID)
            .updateData(data).whenComplete(() async {

          String requestID = widget.requestID;
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
            });
          });
        });

        isDialogOpen=false;
        bottoms=false;
        polyLines.clear();
        polyLines.remove(data);
        print('updated data: ' + data.toString());
        docRef.updateData(data).then((document) {
          print('UPdating request information');
        }).whenComplete(() async {
          print('updated request information');
        }).catchError((error) {
          print('request update...error');
        });
        prefs.setString("requestID", null);
        Navigator.of(context)
            .pushNamedAndRemoveUntil(
            '/home',
                (Route<dynamic>
            route) =>
            false);
      }
    //});

  }

  void getRouter() async {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    final PolylineId polylineId = PolylineId(polylineIdVal);
    polyLines.clear();
   // endpoints = polyLines[0].points;
    var router;

    await apis
        .getRoutes(
      getRoutesRequest: GetRoutesRequestModel(
          fromLocation: fromLocation, toLocation: toLocation, mode: "driving"),
    )
        .then((data) {
      if (data != null) {
        router = data.result.routes[0].overviewPolyline.points;
        routesData = data.result.routes;
      //  poi.add(data.result.routes[0].overviewPolyline.points);
      }
    }).catchError((error) {
      print("DiscoveryActionHandler::GetRoutesRequest > $error");
    });

    distance = routesData[0].legs[0].distance.text.toString();
    duration = routesData[0].legs[0].duration.text;

    polyLines[polylineId] = GMapViewHelper.createPolyline(
      polylineIdVal: polylineIdVal,
      router: router,
      formLocation: fromLocation,
      toLocation: toLocation,
    );
    setState(() {


      instructions = routesData[0].legs[0].steps[0].htmlInstructions;
      stepDuration = routesData[0].legs[0].steps[0].duration.text;
      imageManeuver = getImageSteps(routesData[0].legs[0].steps[0].maneuver);
      updateCamera(Globals.loc);
//      var b= polyLines[0].polylineId.value;

      // setState(() {
      //   int a= polyLines[polylineId].points.length;
      //   for(int i = 0; i < a;)
      //   {
      //     poilat.add(polyLines[polylineId].points[i].latitude);
      //     poilong.add(polyLines[polylineId].points[i].longitude);
      //     i =i+20;
      //   }
      //   double totalDistance = 0;
      //   for(var i = 0; i < poilat.length-1; i++){
      //     totalDistance += calculateDistance(poilat[i], poilong[i], poilat[i+1], poilong[i+1]);
      //
      //     dist.add(totalDistance);
      //   }
      // });
      //  polyLines[0].points.

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

  @override
  Widget build(BuildContext context) {
    print('dataIsSet main widget');
    return !dataIsSet
        ? LoadingBuilder()
        : SafeArea(
          child: Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _buildInfoLayer(),
                  Positioned(
                    top: 30.0,
                    left: 0.0,
                    child: _buildStepDirection(),
                  )
                ],
              ),
            ),
        );
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
  Widget _buildStepDirection() {
    final screenSize = MediaQuery.of(context).size;
    print('stepDuration: ' + stepDuration.toString());
    return stepDuration != null
        ? Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: screenSize.width,
            alignment: Alignment.center,
            // color: greenColor,
            child: Row(
              children: <Widget>[
                // Expanded(
                //   flex: 1,
                //   child: Image.asset(imageManeuver, width: 20.0),
                // ),
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
                // Html(
                //   padding: EdgeInsets.only(
                //     left: 10.0,
                //     right: 10.0,
                //     top: 15.0,
                //   ),
                //   data: """ ${instructions.trim()} """,
                //   linkStyle: textStyle,
                // ),
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

    final panel =  Container(
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
                              //' / Euro ' + price.toString(),
                              ' / Euro ' + Globals.base.toString(),
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
                  //           : 'Get Directions from Pickup to Delivery Spot',
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
                        )
                      : Text(
                          'Delivery'.toUpperCase(),
                          style: headingWhite,
                        ),
                  onPressed: () {
                    // print('DO SOMETHING');
                    setState(() {
                      if (!isPickedUp) {
                        isPickedUp = true;
                        updatePickup();
                        setState(() {
                          fromLocation=toLocation;
                          if(order_id != null){
                            API.driverstatuschange(userID,order_id, 'pickedup',vendor_id);
                          }

                        });
                        // getOtherDirections = true;
                       // getRouter();
                      } else {
                        setState(() {
                          if(order_id!=null){
                             API.driverstatuschange(userID,order_id, 'delivered',vendor_id);
                          }

                        });
                        isJourneyEnded = true;
                        // print('JOURNEY IS ENDING NOW');
                        endJourney();
                        addJourneyHistory();


                        // Navigator.of(context).pushNamedAndRemoveUntil(
                        //     '/home', (Route<dynamic> route) => false);
                        // getOtherDirections = false;
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
            //           shrinkWrap: true,
            //           itemCount: routesData[0].legs[0].steps.length,
            //           itemBuilder: (BuildContext context, index) {
            //             return StepsPartView(
            //               instructions: routesData[0]
            //                   .legs[0]
            //                   .steps[index]
            //                   .htmlInstructions,
            //               duration:
            //                   routesData[0].legs[0].steps[index].duration.text,
            //               imageManeuver: getImageSteps(
            //                   routesData[0].legs[0].steps[index].maneuver),
            //             );
            //           },
            //         )
            //       : Container(
            //           child: LoadingBuilder(),
            //         ),
            // )
          ],
        ));

    return SlidingUpPanel(
      maxHeight: maxHeight,
      minHeight: minHeight,
      parallaxEnabled: true,
      parallaxOffset: .5,
      panel:Globals.loc ==null? Center(child:Container(),) : panel,
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
    print('driverPosition: ' + driverPosition.toString());
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
    //         context: context,
    //         onMapCreated: _onMapCreated,
    //         currentLocation:
    //         LatLng(Globals.loc.latitude, Globals.loc.longitude),
    //         markers: markers,
    //         onTap: (_) {})
    //     : SizedBox(
    //         height: MediaQuery.of(context).size.height,
    //         child: _gMapViewHelper.buildMapView(
    //             context: context,
    //             onMapCreated: _onMapCreated,
    //             currentLocation:
    //                 LatLng(Globals.loc.latitude, Globals.loc.longitude),
    //             markers: markers,
    //             polyLines: polyLines,
    //             onTap: (_) {}),
    //       );
  }
}
