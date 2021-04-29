import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/API.dart';
import 'package:provider/Screen/Home/myActivity.dart';
import 'package:provider/Screen/MyProfile/ProfileModel.dart';
import 'package:provider/Screen/Request/pickUp.dart';
import 'package:provider/Screen/Request/requestDetail.dart';
import 'package:provider/Screen/SplashScreen/SplashScreen.dart';
import 'package:provider/data/globalvariables.dart';
import 'package:provider/requestDialog.dart';
import 'package:provider/theme/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:provider/Components/loading.dart';
import 'package:provider/Screen/Menu/Menu.dart';
import 'package:provider/data/Model/placeItem.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart' as prefix0;
import 'package:shared_preferences/shared_preferences.dart';
import 'radioSelectMapType.dart';
import 'package:provider/data/Model/mapTypeModel.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import '../../Components/itemRequest.dart';
import '../../google_map_helper.dart';
import '../../data/Model/direction_model.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final String screenName = "HOME";
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  CircleId selectedCircle;
  GoogleMapController _mapController;
  Map<String, dynamic> iscancel;
  String currentLocationName;
  String newLocationName;
  String _placemark = '';
  GoogleMapController mapController;
  PlaceItemRes fromAddress;
  PlaceItemRes toAddress;
  bool checkPlatform = Platform.isIOS;
  double distance = 0;
  bool nightMode = false;
  VoidCallback showPersBottomSheetCallBack;
  List<MapTypeModel> sampleData = new List<MapTypeModel>();
  PersistentBottomSheetController _controller;
  List<Map<String, dynamic>> listRequest = List<Map<String, dynamic>>();

  List<Routes> routesData;
  final GMapViewHelper _gMapViewHelper = GMapViewHelper();
  Map<PolylineId, Polyline> _polyLines = <PolylineId, Polyline>{};
  PolylineId selectedPolyline;
  bool isShowDefault = false;
  Position currentLocation;
  Position _lastKnownPosition;
  var userImage;
  String username = '';
  var totalEarned = '0', totalDistance = '0';
  double hoursOnline = 0.0;
  int totalJobs = 0;
  bool isShowLocation = false;
  String requestID = '';
  String userID = '';
  bool isDataSet = false;
  bool isDialogOpen = false;
  StreamSubscription<dynamic> requestsListener;
  bool bottoms = false;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    moveCameraToMyLocation();
    super.initState();
    moveCameraToMyLocation1();
    _initLastKnownLocation();
    _initCurrentLocation();
    _getUserData();
    _registerOnFirebase();

    //Timer.periodic(Duration(seconds: 20), (timer) {
      print(DateTime.now());

   // });


    showPersBottomSheetCallBack = _showBottomSheet;
    sampleData.add(MapTypeModel(1, true, 'assets/style/maptype_nomal.png',
        'Nomal', 'assets/style/nomal_mode.json'));
    sampleData.add(MapTypeModel(2, false, 'assets/style/maptype_silver.png',
        'Silver', 'assets/style/sliver_mode.json'));
    sampleData.add(MapTypeModel(3, false, 'assets/style/maptype_dark.png',
        'Dark', 'assets/style/dark_mode.json'));
    sampleData.add(MapTypeModel(4, false, 'assets/style/maptype_night.png',
        'Night', 'assets/style/night_mode.json'));
    sampleData.add(MapTypeModel(5, false, 'assets/style/maptype_netro.png',
        'Netro', 'assets/style/netro_mode.json'));
    sampleData.add(MapTypeModel(6, false, 'assets/style/maptype_aubergine.png',
        'Aubergine', 'assets/style/aubergine_mode.json'));

    // listRequest = [
    //   {
    //     "id": '0',
    //     "avatar": "https://source.unsplash.com/1600x900/?portrait",
    //     "userName": "Mohamad Jalal",
    //     "date": '08 Jan 2019 at 12:00 PM',
    //     "price": 15,
    //     "distance": "10km",
    //     "addFrom": "Bahrain Polytechnic",
    //     "addTo": "Zayani Motors",
    //     "locationForm": LatLng(26.1554571, 50.5808198),
    //     "locationTo": LatLng(26.1290691, 50.5989158),
    //   },
    //   {
    //     "id": '1',
    //     "avatar": "https://source.unsplash.com/1600x900/?portrait",
    //     "userName": "Jawad Ali",
    //     "date": '08 Jan 2019 at 12:00 PM',
    //     "price": 10,
    //     "distance": "11km",
    //     "addFrom": "Exhibition Road",
    //     "addTo": "Montreal Garage",
    //     "locationForm": LatLng(26.2321207, 50.5765531),
    //     "locationTo": LatLng(26.2578034, 50.6445869),
    //   },
    //   {
    //     "id": '2',
    //     "avatar": "https://source.unsplash.com/1600x900/?portrait",
    //     "userName": "Ali Al Mahdi",
    //     "date": '08 Jan 2019 at 12:00 PM',
    //     "price": 12,
    //     "distance": "19km",
    //     "addFrom": "Arad Garage",
    //     "addTo": "Behbehani Motors",
    //     "locationForm": LatLng(26.257142, 50.6416393),
    //     "locationTo": LatLng(26.155251, 50.6073443),
    //   },
    // ];


    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    // StreamSubscription<Position> positionStream = geolocator
    //     .getPositionStream(locationOptions)
    //     .listen((Position position) async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   setState(() {
    //     userID = prefs.getString('userID');
    //   });
    //   // userID = prefs.getString('userID');
    //   print('USERID : ' + userID);
    //   DocumentReference docRef =
    //       Firestore.instance.collection('LM_Driver').document(userID);
    //   Map<String, dynamic> data = {
    //     'position': {
    //       'latitude': position.latitude,
    //       'longitude': position.longitude,
    //     }
    //   };
    //   print('updated data: ' + data.toString());
    //   docRef.updateData(data).then((document) {
    //     print('updating driver location');
    //   }).whenComplete(() async {
    //     print('updated drivewr location');
    //   }).catchError((error) {
    //     print('driver location update...error');
    //   });
    //   // print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
    // });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _initLastKnownLocation();
    _initCurrentLocation();
    if (currentLocation != null) {
      moveCameraToMyLocation();
      moveCameraToMyLocation1();
    }

    // location.onLocationChanged().listen((location) async {
    //   // LocationData location = LatLng(location["latitude"], location["longitude"]),

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String userID = prefs.getString('userID');
    // print('USERID : ' + userID);
    // DocumentReference docRef =
    //     Firestore.instance.collection('LM_Driver').document(userID);
    // Map<String, dynamic> data = {
    //   'position': {
    //     'latitude': location.latitude,
    //     'longitude': location.longitude,
    //   }
    // };
    // print('updated data: ' + data.toString());
    // docRef.updateData(data).then((document) {
    //   print('updating driver location');
    // }).whenComplete(() async {
    //   print('updated drivewr location');
    // }).catchError((error) {
    //   print('driver location update...error');
    // });
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _registerOnFirebase() async {
    FirebaseUser currentUser = await _auth.currentUser();
    if (currentUser != null) {
      final uid = currentUser.uid;
      _firebaseMessaging.subscribeToTopic('all');
      _firebaseMessaging.getToken().then((token) {
        final FirebaseDatabase database = FirebaseDatabase.instance;
        database.reference().child('DriverTokens').child(uid);
        Map<String, Object> createDoc = new HashMap();
        createDoc['token'] = token.toString();
        database.reference().child('DriverTokens').child(uid).set(createDoc);
      });
    }
  }
  checkAcceptance(String reqid)async{
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
           requestsListener.cancel();
         });
         print('ACCEPTED REQUEST');
         acceptRequest();
         Navigator.pushAndRemoveUntil(
           context,
           MaterialPageRoute(
               builder: (context) => PickUp(
                 requestID: requestID,
                 screenName: 'HOME',
                 username: username,

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

  getLiveRequests() {
    CollectionReference reference = Firestore.instance.collection('requests');
    requestsListener = reference
        // .where('isJourneyCancelled', isEqualTo: 'false')
        .where('isAccepted', isEqualTo: false)
        .snapshots()
        .listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((docChange) {
        Map<String, dynamic> data = docChange.document.data;
        DocumentSnapshot document = docChange.document;


        if (docChange.type != "removed" && docChange.type != "modified") {
          if (isShowLocation) {
            if (isDialogOpen) {
              if(!bottoms){
                //Navigator.pop(context);
              }
             // Navigator.pop(context);
             //  setState(() {
             //    isDialogOpen = true;
             //  });
            }


             if (data['isJourneyCancelled'] == false && isDialogOpen == false) {
              setState(() {
                isDialogOpen = true;
                requestID = document.documentID;
                print('NEW DATA SHIT: ' + data['placeTo'].toString());

//                var ref =Firestore.instance.collection('request').getDocuments();
                if(data['isAccepted'] == false)
                  {
                    var key=document.documentID;

                    showModalBottomSheet(
                      //  enableDrag: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0),topRight: Radius.circular(24.0)),
                        ),
                        context: context,
                        isDismissible: false,

                        builder: (BuildContext bc){
                          return dialogInfo(data);
                        },
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
      });
    });
  }

  acceptRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("requestID", requestID);
    DocumentReference docRef =
        Firestore.instance.collection('requests').document(requestID);
    Map<String, dynamic> data = {
      'isAccepted': true,
      'isJourneyStarted': true,
      'acceptedByName': username,
      'acceptedByID': userID,
      'isCancel': false,
     // prefs.clear();
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
   Map<String, dynamic> requestData;
  dialogInfo(data) {
    return RequestDialog(

      title: "Request",
      requestData: data,
      onReview: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RequestDetail(
                  requestID: requestID,
                )));
        // Navigator.pushNamed(context, '/review_trip');
      },
      onDecline: () {
        setState(() {
          isDialogOpen = false;
          bottoms = true;
        });
        Navigator.of(context).pop();
      },
      onAccept: () {
        setState(() {
          checkAcceptance(requestID);
        });
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

  Future _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID');

    await Firestore.instance
        .collection('LM_Driver')
        .document(userID)
        .get()
        .then((DocumentSnapshot snap) {
      print('USER DATA: ' + snap.data.toString());
      setUserData(snap.data);
    });
  }

  Future getPic(Map<String, dynamic> userData) async {
    var userImageURL;
    if (userData['profile_pic'] == null) {
      print('IT IS NULL');
      final ref = FirebaseStorage.instance.ref().child('user_default');
// no need of the file extension, the name will do fine.
      userImageURL = await ref.getDownloadURL();
      print('IT IS AN IMAGE URL ' + userImage.toString());
    } else {
      userImageURL = userData['profile_pic'];
      print('IT IS A NULL ' + userImage.toString());
    }
    setState(() {
      userImage = userImageURL;
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
      username = userData['name'];
      print(username);
      totalEarned = double.parse(userData['money_earned']).toStringAsFixed(2);
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

    getLiveRequests();
  }

  ///Get last known location
  Future<void> _initLastKnownLocation() async {
    Position position;
    try {
      final Geolocator geolocator = Geolocator()
        ..forceAndroidLocationManager = true;
      position = await geolocator?.getLastKnownPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      print('initLastKnowLocation: ' + position.toString());
    } on PlatformException {
      position = null;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _lastKnownPosition = position;
    });
  }

  /// Get current location
  _initCurrentLocation() async {

    try {
      Geolocator()
        ..forceAndroidLocationManager = true
        ..getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        )?.then((position) {
          if (mounted) {
            currentLocation = position;
            setState(() {
              Globals.loc = currentLocation;
            });
            print('_initCurrentLocation: MOUNTED');
            if (currentLocation != null) {
              print('_initCurrentLocation: ' + currentLocation.toString());
              moveCameraToMyLocation();
              moveCameraToMyLocation1();
            }
          }
        })?.catchError((e) {});
    } on PlatformException {}

    if (currentLocation != null) {
      List<Placemark> placemarks = await Geolocator()?.placemarkFromCoordinates(
          currentLocation?.latitude, currentLocation?.longitude);
      if (placemarks != null && placemarks.isNotEmpty) {
        final Placemark pos = placemarks[0];
        setState(() {
          _placemark = pos.name + ', ' + pos.thoroughfare;
          print('PLACE: ' + _placemark);
          currentLocationName = _placemark;
        });
      }
    }
  }

  void moveCameraToMyLocation() {
    // setState(() {
    //   Globals.loc = currentLocation;
    // });
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(
        CameraPosition(
          bearing: currentLocation.heading,
          target: LatLng(currentLocation?.latitude, currentLocation?.longitude),
          zoom: 17.0,
        ),
      ),
    );
  }
  void moveCameraToMyLocation1() {
    // setState(() {
    //   Globals.loc = currentLocation;
    // });
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(
        CameraPosition(
          bearing: currentLocation.heading,
          target: LatLng(currentLocation?.latitude, currentLocation?.longitude),
          zoom: 17.0,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    this._mapController = controller;
    moveCameraToMyLocation();
    // addMarker(listRequest[0]['locationForm'], listRequest[0]['locationTo']);
  }

  Future<String> _getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void _setMapStyle(String mapStyle) {
    setState(() {
      nightMode = true;
      _mapController.setMapStyle(mapStyle);
    });
  }

  void changeMapType(int id, String fileName) {
    print(fileName);
    if (fileName == null) {
      setState(() {
        nightMode = false;
        _mapController.setMapStyle(null);
      });
    } else {
      _getFileData(fileName).then(_setMapStyle);
    }
  }

  void _showBottomSheet() async {
    setState(() {
      showPersBottomSheetCallBack = null;
    });
    _controller = await _scaffoldKey.currentState.showBottomSheet((context) {
      return new Container(
          height: 300.0,
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Map type",
                        style: heading18Black,
                      ),
                    ),
                    Container(
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: blackColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: new GridView.builder(
                    itemCount: sampleData.length,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      return new InkWell(
                        highlightColor:Color.fromRGBO(60, 111, 102, 1),
                        splashColor: Color.fromRGBO(60, 111, 102, 1),
                        onTap: () {
                          _closeModalBottomSheet();
                          sampleData
                              .forEach((element) => element.isSelected = false);
                          sampleData[index].isSelected = true;
                          changeMapType(
                              sampleData[index].id, sampleData[index].fileName);
                        },
                        child: new MapTypeItem(sampleData[index]),
                      );
                    },
                  ),
                )
              ],
            ),
          ));
    });
  }

  void _closeModalBottomSheet() {
    if (_controller != null) {
      _controller.close();
      _controller = null;
    }
  }

  addMarker(LatLng locationForm, LatLng locationTo) {
    _markers.clear();
    final MarkerId _markerFrom = MarkerId("fromLocation");
    final MarkerId _markerTo = MarkerId("toLocation");
    _markers[_markerFrom] = GMapViewHelper.createMaker(
      markerIdVal: "fromLocation",
      icon: checkPlatform
          ? "assets/image/gps_point_24.png"
          : "assets/image/gps_point.png",
      lat: locationForm.latitude,
      lng: locationForm.longitude,
    );

    _markers[_markerTo] = GMapViewHelper.createMaker(
      markerIdVal: "toLocation",
      icon: checkPlatform
          ? "assets/image/ic_marker_32.png"
          : "assets/image/ic_marker_128.png",
      lat: locationTo.latitude,
      lng: locationTo.longitude,
    );
    _gMapViewHelper?.cameraMove(
        fromLocation: locationForm,
        toLocation: locationTo,
        mapController: _mapController);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: new MenuScreens(
            // activeScreenName: screenName,
            // username: username,
            // hoursOnline: hoursOnline,
            // totaldistaDistance: totalDistance,
            // totalJobs: totalJobs
            ),
        body: Container(
          color: whiteColor,
          child: Stack(
            children: <Widget>[
              _buildMapLayer(),
              Positioned(
                  top: 100,
                  // bottom: isShowDefault == false ? 330 : 250,
                  right: 10,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.my_location,
                        size: 20.0,
                        color: blackColor,
                      ),
                      onPressed: () {
                        _initCurrentLocation();
                      },
                    ),
                  )),
              Positioned(
                  top: 50,
                  right: 10,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.layers,
                        size: 20.0,
                        color: blackColor,
                      ),
                      onPressed: () {
                        _showBottomSheet();
                      },
                    ),
                  )),
              Positioned(
                  top: 50,
                  left: 10,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.menu,
                        size: 20.0,
                        color: blackColor,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                    ),
                  )),
              Align(
                alignment: Alignment.bottomCenter,
                child:
                    // isShowDefault == false
                    //     ? Container(
                    //         height: 330,
                    //         child: TinderSwapCard(
                    //             orientation: AmassOrientation.TOP,
                    //             totalNum: listRequest.length,
                    //             stackNum: 3,
                    //             maxWidth: MediaQuery.of(context).size.width,
                    //             minWidth: MediaQuery.of(context).size.width * 0.9,
                    //             maxHeight: MediaQuery.of(context).size.width * 0.9,
                    //             minHeight: MediaQuery.of(context).size.width * 0.85,
                    //             cardBuilder: (context, index) => ItemRequest(
                    //                   // avatar: listRequest[index]['avatar'],
                    //                   avatar:
                    //                       "https://firebasestorage.googleapis.com/v0/b/road-side-assist-1562842759870.appspot.com/o/user%2Fscaled_5a08aee1-599e-4666-8574-4f00a0e10a822542926262350624315.jpg?alt=media&token=bb1ec446-2c09-488e-a49e-b6cc84ef8fab",
                    //                   // userName: listRequest[index]['userFullName'],
                    //                   userName: "fsgf",
                    //                   // date: listRequest[index]['date'],
                    //                   // price: listRequest[index]['servicePrice']
                    //                   //     .toString(),
                    //                   price: '123123',
                    //                   // distance: listRequest[index]['distance'],
                    //                   distance: 'asdasd',

                    //                   addFrom: 'Isa Town',
                    //                   // addFrom: listRequest[index]['positionFrom']
                    //                   //     .toString(),
                    //                   addTo: 'Bahrain Polytechnic',
                    //                   // addTo:
                    //                   //     listRequest[index]['positionTo'].toString(),
                    //                   // locationForm: listRequest[index]
                    //                   //     ['positionFrom'],
                    //                   locationForm: LatLng(26.332, 50.6129),
                    //                   // locationTo: listRequest[index]['positionTo'],
                    //                   locationTo: LatLng(26.232, 50.6029),

                    //                   onTap: () {
                    //                     Navigator.of(context).push(MaterialPageRoute(
                    //                         builder: (context) => RequestDetail()));
                    //                   },
                    //                 ),
                    //             swipeUpdateCallback:
                    //                 (DragUpdateDetails details, Alignment align) {
                    //               /// Get swiping card's position
                    //               //                          print(details);
                    //             },
                    //             swipeCompleteCallback:
                    //                 (CardSwipeOrientation orientation, int index) {
                    //               /// Get orientation & index of swiped card!
                    //               print('index $index');
                    //               print('aaa ${listRequest.length}');
                    //               setState(() {
                    //                 if (index == listRequest.length - 1) {
                    //                   setState(() {
                    //                     // isShowDefault = true;
                    //                   });
                    //                 } else {
                    //                   addMarker(
                    //                       listRequest[index + 1]['locationForm'],
                    //                       listRequest[index + 1]['locationTo']);
                    //                 }
                    //               });
                    //             }),
                    //       )
                    // :
                    isDataSet == false
                        ? Center(
                            child: LoadingBuilder(),
                          )
                        : MyActivity(
                            // userImage: 'https://source.unsplash.com/1600x900/?portrait',
                            userImage: userImage,
                            userName: username,
                            totalEarned: totalEarned.toString(),
                            hoursOnline: hoursOnline,
                            totalDistance: totalDistance,
                            totalJob: totalJobs,
                            statusOnline: isShowLocation,
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapLayer() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: _gMapViewHelper.buildMapView(
          context: context,
          onMapCreated: _onMapCreated,
          currentLocation: LatLng(
              currentLocation != null
                  ? currentLocation?.latitude
                  : _lastKnownPosition?.latitude ?? 51.1657,
              currentLocation != null
                  ? currentLocation?.longitude
                  : _lastKnownPosition?.longitude ?? 10.4515),
          markers: _markers,
          polyLines: _polyLines,
          onTap: (_) {}),
    );
  }
}
