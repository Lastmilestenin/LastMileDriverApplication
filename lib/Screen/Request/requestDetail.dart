import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/Components/loading.dart';
import 'package:provider/Screen/Message/MessageScreen.dart';
import 'package:provider/theme/style.dart';
import 'pickUp.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RequestDetail extends StatefulWidget {
  final String requestID;

  RequestDetail({this.requestID});

  @override
  _RequestDetailState createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String yourReview;
  double ratingScore;
  String customerName, distance, placeFrom, placeTo, notes;
  String price;
  bool dataIsSet = false;

  @override
  void initState() {
    super.initState();
    print('ID: ' + widget.requestID);
    getRequestDetails();
  }

  Future getRequestDetails() async {
    await Firestore.instance
        .collection('requests')
        .document(widget.requestID)
        .get()
        .then((DocumentSnapshot snap) {
      print('reqeust Data: ' + snap.data.toString());
      setRequestData(snap.data);
    });
  }

  Future setRequestData(Map<String, dynamic> requestData) async {
    print('SOME THING: ' + requestData.toString());

    DocumentReference docRef =
    Firestore.instance.collection('requests').document(widget.requestID);
    var distance1 = requestData['distance'].toString();
    distance1 = distance1.split(' ')[0];
    var calculateprice = 8 + (2 * double.parse(distance1));
    Map<String, dynamic> data = {
      'servicePrice':  calculateprice.toString(),
      // prefs.clear();
    };

    docRef.updateData(data).then((document) {
      print('UPdating request information');
    });

    if(mounted) {
      setState(() {
        customerName = requestData['userFullName'];
        distance = requestData['distance'].toString();
        placeFrom = requestData['placeFrom'];
        placeTo = requestData['placeTo'];
        notes = requestData['notes'];
        price = calculateprice.toString();
        dataIsSet = true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return !dataIsSet
        ? Container(color: Colors.white, child: Center(child: LoadingBuilder()))
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'Request Detail',
                style: TextStyle(color: blackColor),
              ),
              backgroundColor: whiteColor,
              elevation: 0.0,
              iconTheme: IconThemeData(color: blackColor),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: ButtonTheme(
                minWidth: screenSize.width,
                height: 45.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  elevation: 0.0,
                  color: primaryColor,
                  child: Text(
                    'Go to pick up'.toUpperCase(),
                    style: headingWhite,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            PickUp(requestID: widget.requestID)));
                  },
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: GestureDetector(
                onTap: () =>
                    FocusScope.of(context).requestFocus(new FocusNode()),
                child: Container(
                  color: greyColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            )),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://firebasestorage.googleapis.com/v0/b/road-side-assist-1562842759870.appspot.com/o/user_default.png?alt=media&token=fc1e0ce4-9836-4793-ab68-f613d1a522d5',
                                  fit: BoxFit.cover,
                                  width: 40.0,
                                  height: 40.0,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    customerName,
                                    style: textBoldBlack,
                                  ),
                                  Text(
                                    "08 Jan 2019 at 12:00 PM",
                                    style: textGrey,
                                  ),
                                  // Container(
                                  //   child: Row(
                                  //     children: <Widget>[
                                  //       Container(
                                  //         height: 25.0,
                                  //         padding: EdgeInsets.all(5.0),
                                  //         alignment: Alignment.center,
                                  //         decoration: BoxDecoration(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(10.0),
                                  //             color: primaryColor),
                                  //         child: Text(
                                  //           'ApplePay',
                                  //           style: textBoldWhite,
                                  //         ),
                                  //       ),
                                  //       SizedBox(width: 10),
                                  //       Container(
                                  //         height: 25.0,
                                  //         padding: EdgeInsets.all(5.0),
                                  //         alignment: Alignment.center,
                                  //         decoration: BoxDecoration(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(10.0),
                                  //             color: primaryColor),
                                  //         child: Text(
                                  //           'Discount',
                                  //           style: textBoldWhite,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    'Euro ' + price.toString(),
                                    style: textBoldBlack,
                                  ),
                                  Text(
                                    distance,
                                    style: textGrey,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          color: whiteColor,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "PICK UP".toUpperCase(),
                                      style: textGreyBold,
                                    ),
                                    Text(
                                      placeFrom,
                                      style: textStyle,
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Delivery".toUpperCase(),
                                      style: textGreyBold,
                                    ),
                                    Text(
                                      placeTo,
                                      style: textStyle,
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "note".toUpperCase(),
                                      style: textGreyBold,
                                    ),
                                    Text(
                                      notes == "" ? ' - ' : notes,
                                      style: textStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        padding: EdgeInsets.all(10),
                        color: whiteColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Bill Details (Cash Payment)".toUpperCase(),
                              style: textGreyBold,
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 8.0),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    "Ride Fare",
                                    style: textStyle,
                                  ),
                                  new Text(
                                    'Euro ' + price.toString(),
                                    style: textBoldBlack,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 8.0),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    "Taxes",
                                    style: textStyle,
                                  ),
                                  new Text(
                                    "Euro 0.0",
                                    style: textBoldBlack,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    "Discount",
                                    style: textStyle,
                                  ),
                                  new Text(
                                    "Euro 0.0",
                                    style: textBoldBlack,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: screenSize.width - 50.0,
                              height: 1.0,
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 8.0),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    "Total Bill",
                                    style: heading18Black,
                                  ),
                                  new Text(
                                    'Euro ' + price.toString(),
                                    style: heading18Black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: whiteColor,
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                print('ok');
                              },
                              child: Container(
                                height: 60,
                                width: 100,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.call,
                                      color: whiteColor,
                                    ),
                                    Text('Call',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: whiteColor,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print('ok');
                                Navigator.of(context)
                                    .push(new MaterialPageRoute<Null>(
                                        builder: (BuildContext context) {
                                          return ChatScreen();
                                        },
                                        fullscreenDialog: true));
                              },
                              child: Container(
                                height: 60,
                                width: 100,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.mail,
                                      color: whiteColor,
                                    ),
                                    Text('Message',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: whiteColor,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     print('ok');
                            //   },
                            //   child: Container(
                            //     height: 60,
                            //     width: 100,
                            //     padding: EdgeInsets.all(5),
                            //     decoration: BoxDecoration(
                            //         color: greyColor2,
                            //         borderRadius: BorderRadius.circular(5.0)),
                            //     child: Column(
                            //       children: <Widget>[
                            //         Icon(
                            //           Icons.delete,
                            //           color: whiteColor,
                            //         ),
                            //         Text('Cancel',
                            //             style: TextStyle(
                            //                 fontSize: 18,
                            //                 color: whiteColor,
                            //                 fontWeight: FontWeight.bold))
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
