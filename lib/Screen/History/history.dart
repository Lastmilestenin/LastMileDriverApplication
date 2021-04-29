import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/Components/loading.dart';
import 'package:provider/theme/style.dart';
import 'package:provider/Screen/Menu/Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:cached_network_image/cached_network_image.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String driverID = '';
  final String screenName = "HISTORY";
  DateTime selectedDate;
  List<dynamic> event = [];
  String image;
  String selectedMonth = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  navigateToDetail(String id) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HistoryDetail(
          id: id,
        )));
  }

  getUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      driverID = prefs.getString('userID');
      image = prefs.getString('profilePic');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'History',
            style: TextStyle(color: blackColor,fontFamily: 'Avenir',),
          ),
          backgroundColor: whiteColor,
          elevation: 2.0,
          iconTheme: IconThemeData(color: blackColor),
        ),
        drawer: MenuScreens(
          // activeScreenName: screenName
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              // Container(
              //   height: 120.0,
              //   margin: EdgeInsets.symmetric(horizontal: 16.0),
              //   child: CalendarCarousel(
              //     weekendTextStyle: TextStyle(
              //       color: Colors.red,
              //     ),
              //     headerTextStyle: TextStyle(color: Colors.black45),
              //     inactiveWeekendTextStyle: TextStyle(color: Colors.black45),
              //     headerMargin: EdgeInsets.all(0.0),
              //     thisMonthDayBorderColor: Colors.grey,
              //     weekFormat: true,
              //     height: 150.0,
              //     selectedDateTime: DateTime.now(),
              //     selectedDayBorderColor: blue1,
              //     selectedDayButtonColor: blue2,
              //     todayBorderColor: primaryColor,
              //     todayButtonColor: primaryColor,
              //     onDayPressed: (DateTime date, List<dynamic> events) {
              //       this.setState(() => selectedDate = date);
              //       print(selectedDate);
              //     },
              //     onCalendarChanged: (DateTime date) {
              //       this.setState(
              //           () => selectedMonth = DateFormat.yMMM().format(date));
              //       print(selectedMonth);
              //     },
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.all(20.0),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: <Widget>[
              //       Material(
              //         elevation: 5.0,
              //         borderRadius: BorderRadius.circular(8.0),
              //         color: Colors.deepPurple,
              //         child: Container(
              //           padding: EdgeInsets.all(10.0),
              //           height: 80,
              //           width: screenSize.width * 0.4,
              //           child: Row(
              //             children: <Widget>[
              //               Icon(
              //                 Icons.content_paste,
              //                 size: 30.0,
              //               ),
              //               SizedBox(
              //                 width: 10,
              //               ),
              //               Container(
              //                   child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: <Widget>[
              //                   Text(
              //                     "Job",
              //                     style: heading18,
              //                   ),
              //                   Text(
              //                     "20",
              //                     style: headingWhite,
              //                   )
              //                 ],
              //               )),
              //             ],
              //           ),
              //         ),
              //       ),
              //       SizedBox(
              //         width: 10.0,
              //       ),
              //       Material(
              //         elevation: 5.0,
              //         borderRadius: BorderRadius.circular(8.0),
              //         color: Colors.deepPurple,
              //         child: Container(
              //           padding: EdgeInsets.all(10.0),
              //           height: 80,
              //           width: screenSize.width * 0.4,
              //           child: Row(
              //             children: <Widget>[
              //               Icon(
              //                 Icons.attach_money,
              //                 size: 30.0,
              //               ),
              //               SizedBox(
              //                 width: 10,
              //               ),
              //               Container(
              //                   child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: <Widget>[
              //                   Text(
              //                     "Earning",
              //                     style: heading18,
              //                   ),
              //                   Text(
              //                     "20",
              //                     style: headingWhite,
              //                   )
              //                 ],
              //               )),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Expanded(
                child: Scrollbar(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('journey_history')
                          .where('acceptedByID', isEqualTo: driverID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return LoadingBuilder();
                        }
                        if (snapshot.data.documents.length == 0) {
                          return Center(
                            child: Text('You did not perform a job until now',style: TextStyle(fontFamily: 'Avenir',),),
                          );
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot journeyHistoryObject =
                              snapshot.data.documents[index];
                              return GestureDetector(
                                  onTap: () {
                                    print('$index');
                                    print('${journeyHistoryObject.documentID}');
                                    navigateToDetail(
                                        journeyHistoryObject.documentID);
                                  },
                                  child: Card(
                                    margin: EdgeInsets.all(10.0),
                                    elevation: 10.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.0)),
                                    child: Container(
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
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        50.0),
                                                    child: CachedNetworkImage(
                                                      imageUrl: image == null?
                                                      'https://source.unsplash.com/1600x900/?portrait':image,
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
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: <Widget>[
                                                      Text(
                                                        journeyHistoryObject[
                                                        'userFullName'],
                                                        style: textBoldBlack,
                                                      ),
                                                      Text(
                                                        journeyHistoryObject[
                                                        'date'] + ' at ' + journeyHistoryObject[
                                                        'time'],
                                                        style: textGrey,
                                                      ),
                                                      SizedBox(height: 5,),
                                                      journeyHistoryObject[
                                                      'isCancel'] == true?
                                                      Text(
                                                        'Cancelled',
                                                        style: cancelStyle,
                                                      ):
                                                      Text(
                                                        'Completed',
                                                        style: completeStyle,
                                                      )
                                                      // Container(
                                                      //   child: Row(
                                                      //     children: <Widget>[
                                                      //       Container(
                                                      //         height: 25.0,
                                                      //         padding:
                                                      //             EdgeInsets
                                                      //                 .all(5.0),
                                                      //         alignment:
                                                      //             Alignment
                                                      //                 .center,
                                                      //         decoration: BoxDecoration(
                                                      //             borderRadius:
                                                      //                 BorderRadius
                                                      //                     .circular(
                                                      //                         10.0),
                                                      //             color:
                                                      //                 primaryColor),
                                                      //         child: Text(
                                                      //           'ApplePay',
                                                      //           style:
                                                      //               textBoldWhite,
                                                      //         ),
                                                      //       ),
                                                      //       SizedBox(width: 10),
                                                      //       Container(
                                                      //         height: 25.0,
                                                      //         padding:
                                                      //             EdgeInsets
                                                      //                 .all(5.0),
                                                      //         alignment:
                                                      //             Alignment
                                                      //                 .center,
                                                      //         decoration: BoxDecoration(
                                                      //             borderRadius:
                                                      //                 BorderRadius
                                                      //                     .circular(
                                                      //                         10.0),
                                                      //             color:
                                                      //                 primaryColor),
                                                      //         child: Text(
                                                      //           'Discount',
                                                      //           style:
                                                      //               textBoldWhite,
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
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      Text(
                                                        'Euro ' +
                                                            journeyHistoryObject[
                                                            'servicePrice']
                                                                .toString(),
                                                        style: textBoldBlack,
                                                      ),
                                                      Text(
                                                        journeyHistoryObject[
                                                        'distance'].toString(),
                                                        style: textGrey,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: <Widget>[
                                                        Text(
                                                          "PICK UP"
                                                              .toUpperCase(),
                                                          style: textGreyBold,
                                                        ),
                                                        Text(
                                                          journeyHistoryObject[
                                                          'placeFrom'],
                                                          style: textStyle,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(),
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: <Widget>[
                                                        Text(
                                                          "Delivery"
                                                              .toUpperCase(),
                                                          style: textGreyBold,
                                                        ),
                                                        Text(
                                                          journeyHistoryObject[
                                                          'placeTo'],
                                                          style: textStyle,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  )
                                // historyItem()
                              );
                            });
                      }),
                ),
              ),
            ],
          ),
        ));
  }

  Widget historyItem() {
    return Card(
      margin: EdgeInsets.all(10.0),
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
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
                        'https://source.unsplash.com/1600x900/?portrait',
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
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Olivia Nastya',
                          style: textBoldBlack,
                        ),
                        Text(
                          "08 Jan 2019 at 12:00 PM",
                          style: textGrey,
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 25.0,
                                padding: EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: primaryColor),
                                child: Text(
                                  'ApplePay',
                                  style: textBoldWhite,
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                height: 25.0,
                                padding: EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: primaryColor),
                                child: Text(
                                  'Discount',
                                  style: textBoldWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "Euro 250.0",
                          style: textBoldBlack,
                        ),
                        Text(
                          "2.2 Km",
                          style: textGrey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
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
                            "2536 Flying Taxicabs",
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
                            "2536 Flying Taxicabs",
                            style: textStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}