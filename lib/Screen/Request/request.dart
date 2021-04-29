import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/Components/loading.dart';
import 'package:provider/theme/style.dart';
import 'package:provider/Screen/Menu/Menu.dart';
import 'requestDetail.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final String screenName = "REQUEST";

  navigateToDetail(String requestID) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RequestDetail(
              requestID: requestID,
            )));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Request',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: whiteColor,
          elevation: 2.0,
          iconTheme: IconThemeData(color: blackColor),
        ),
        drawer: new MenuScreens(
            // activeScreenName: screenName
            ),
        body: Container(
            child: Scrollbar(
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('requests')
                        .where('isAccepted', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return LoadingBuilder();
                      }
                      // if (snapshot.data.documents.length == 0) {
                      //   return Center(
                      //     child: Text('No requests are requested until now'),
                      //   );
                      // }
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot requestHistoryObject =
                                snapshot.data.documents[index];
                            return GestureDetector(
                                onTap: () {
                                  print('$index');
                                  print('${requestHistoryObject.documentID}');
                                  navigateToDetail(
                                      requestHistoryObject.documentID);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      requestHistoryObject[
                                                              'userFullName']
                                                          .toString(),
                                                      style: textBoldBlack,
                                                    ),
                                                    Text(
                                                      "08 Jan 2019 at 12:00 PM",
                                                      style: textGrey,
                                                    ),
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
                                                      "Euro " +
                                                          requestHistoryObject[
                                                                  'servicePrice']
                                                              .toString(),
                                                      style: textBoldBlack,
                                                    ),
                                                    Text(
                                                      requestHistoryObject[
                                                          'distance'],
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
                                                        "PICK UP".toUpperCase(),
                                                        style: textGreyBold,
                                                      ),
                                                      Text(
                                                        requestHistoryObject[
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
                                                        requestHistoryObject[
                                                            'placeTo'],
                                                        style: textStyle,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                        Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: ButtonTheme(
                                            minWidth: screenSize.width,
                                            height: 45.0,
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          5.0)),
                                              elevation: 0.0,
                                              color: primaryColor,
                                              child: Text(
                                                'Accept',
                                                style: headingWhite,
                                              ),
                                              onPressed: () {
//                      Navigator.of(context).pushReplacementNamed('/history');
                                                // navigateToDetail();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                          });
                    }))));
  }
}
