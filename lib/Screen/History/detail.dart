import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/Components/loading.dart';
import 'package:provider/theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistoryDetail extends StatefulWidget {
  final String id;

  HistoryDetail({this.id});

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String yourReview;
  double ratingScore;

  String customerName, distance, placeFrom, placeTo, notes, customerImage,date,time,cancelReason;
  var servicePrice;
  bool isDataSet = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHistoryDetail();
  }

  Future getHistoryDetail() async {
    await Firestore.instance
        .collection('journey_history')
        .document(widget.id)
        .get()
        .then((DocumentSnapshot snap) {
      // print('USER DATA: ' + snap.data.toString());
      setHistoryData(snap.data);
    });
  }

  Future setHistoryData(Map<String, dynamic> historyData) async {
    print('History Data: ' + historyData.toString());
    print('NAME : ' + historyData['userFullName'].toString());
    setState(() {
      customerName = historyData['userFullName'].toString();
      distance = historyData['distance'].toString();
      placeFrom = historyData['placeFrom'].toString();
      placeTo = historyData['placeTo'].toString();
      notes = historyData['notes'].toString();
      servicePrice = historyData['servicePrice'];
      date = historyData['date'];
      time = historyData['time'];
      cancelReason = historyData['cancelReason'];
      customerImage =
          "https://firebasestorage.googleapis.com/v0/b/road-side-assist-1562842759870.appspot.com/o/user_default.png?alt=media&token=fc1e0ce4-9836-4793-ab68-f613d1a522d5";
      isDataSet = true;
    });
    // setState(() {
    //   if (userData['profile_pic'] == null) {
    //     getDefaultPic();
    //   } else {
    //     userImage = userData['profile_pic'];
    //   }
    //   username = userData['name'];
    //   print(username);
    //   totalEarned = userData['money_earned'];
    //   print('totalEarned ' + totalEarned.toString());
    //   totalJobs = userData['total_jobs'];
    //   print('totalJobs ' + totalJobs.toString());
    //   hoursOnline = userData['hours_online'];
    //   print('hoursOnline ' + hoursOnline.toString());
    //   totalDistance = userData['total_distance'];
    //   print('totalDistance ' + totalDistance.toString());
    //   phoneNumber = userData['phone_number'];
    //   email = userData['email'];
    //   nameController.text = username;
    //   emailController.text = email;
    //   phoneController.text = phoneNumber;
    // });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      // bottomNavigationBar: ButtonTheme(
      //   minWidth: screenSize.width,
      //   height: 45.0,
      //   child: RaisedButton(
      //     elevation: 0.0,
      //     color: primaryColor,
      //     child: Text(
      //       'Submit',
      //       style: headingWhite,
      //     ),
      //     onPressed: () {
      //       Navigator.of(context).pushReplacementNamed('/history');
      //       //and
      //       Navigator.popAndPushNamed(context, '/history');
      //     },
      //   ),
      // ),
      body: !isDataSet
          ? Center(
              child: LoadingBuilder(),
            )
          : Scrollbar(
              child: SingleChildScrollView(
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
                                    imageUrl: customerImage,
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
                                     date + ' at ' + time,
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
                                      "Euro " + servicePrice.toString(),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "notes".toUpperCase(),
                                        style: textGreyBold,
                                      ),
                                      Text(
                                        notes == "" ? " - " : notes,
                                        style: textStyle,
                                      ),
                                    ],
                                  ),
                                ),
                                cancelReason == 'No'?
                                    Container():
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Cancel Reason".toUpperCase(),
                                            style: textGreyBoldcancel,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width/1.3,
                                            child: Text(
                                              cancelReason == "" ? " - " : cancelReason,textAlign: TextAlign.start,
                                              style: textStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                                      "Fare",
                                      style: textStyle,
                                    ),
                                    new Text(
                                      "Euro " + servicePrice.toString(),
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
                                      "Euro " + servicePrice.toString(),
                                      style: heading18Black,
                                    ),
                                  ],
                                ),
                              ),


                            ],
                          ),
                        ),
//                   Form(
//                       key: formKey,
//                       child: Container(
//                         //margin: EdgeInsets.all(10.0),
//                         padding: EdgeInsets.all(10.0),
//                         color: whiteColor,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             RatingBar(
//                               itemBuilder: (context, index) => Icon(
//                                 Icons.star,
//                                 color: Colors.amber,
//                               ),
//                               itemSize: 20.0,
//                               itemCount: 5,
//                               glowColor: Colors.white,
//                               onRatingUpdate: (rating) {
//                                 ratingScore = rating;
//                                 print(rating);
//                               },
//                             ),
//                             Container(
//                               padding: EdgeInsets.only(top: 10.0),
//                               child: SizedBox(
//                                 height: 100.0,
//                                 child: TextField(
//                                   style: textStyle,
//                                   decoration: InputDecoration(
//                                     hintText: "Write your review",
// //                                hintStyle: TextStyle(
// //                                  color: Colors.black38,
// //                                  fontFamily: 'Akrobat-Bold',
// //                                  fontSize: 16.0,
// //                                ),
//                                     border: OutlineInputBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(5.0)),
//                                   ),
//                                   maxLines: 2,
//                                   keyboardType: TextInputType.multiline,
//                                   onChanged: (String value) {
//                                     setState(() => yourReview = value);
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
