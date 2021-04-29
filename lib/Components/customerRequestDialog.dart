import 'package:flutter/material.dart';
import 'package:provider/components/CustomShowDialog.dart';
import 'package:provider/theme/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomerRequestDialog extends StatelessWidget {
  final String title;
  final Map<String, dynamic> requestData;
  final VoidCallback onTap, onAccept, onDecline, onReview;

  CustomerRequestDialog(
      {this.title,
      this.requestData,
      this.onTap,
      this.onAccept,
      this.onDecline,
      this.onReview});

  @override
  Widget build(BuildContext context) {
    return new CustomAlertDialog(
      content: new Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        // width: 280.0,
        // height: 240.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // dialog top
            Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
            new Expanded(
              flex: 3,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Container(
                      // margin: EdgeInsets.only(bottom: 20.0),
                      child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(
                        title != null ? title : '',
                        style: headingBlack,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Text(
                              requestData != null &&
                                      requestData['userFullName'] != ""
                                  ? requestData['userFullName'].toString()
                                  : 'Name not found',
                              style: textStyleActiveBlack,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.my_location,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                requestData != null &&
                                        requestData['placeFrom'] != ""
                                    ? requestData['placeFrom'].toString()
                                    : 'Place not found',
                                style: textStyleActiveBlack,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                requestData != null &&
                                        requestData['placeTo'] != ""
                                    ? requestData['placeTo'].toString()
                                    : 'Place Not Found',
                                style: textStyleActiveBlack,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.indent, color: Colors.black),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Text(
                              requestData != null &&
                                      requestData['serviceName'] != null
                                  ? requestData['serviceName'].toString()
                                  : 'Service not found',
                              style: textStyleActiveBlack,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.cogs, color: Colors.black),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                requestData != null && requestData['notes'] != ""
                                    ? requestData['notes'].toString()
                                    : '-',
                                style: textStyleActiveBlack,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                      elevation: 0.0,
                      color: Colors.yellow,
                      child: Text(
                        'Request Details',
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontFamily: "OpenSans",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: onReview,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: new GestureDetector(
                    onTap: onDecline,
                    child: new Container(
                      width: 110.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.red,
                          borderRadius: new BorderRadius.only(
                              bottomLeft: Radius.circular(10.0))),
                      child: new Center(
                        child: new Text(
                          "Decline",
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: new GestureDetector(
                    onTap: onAccept,
                    child: new Container(
                      width: 110.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: primaryColor,
                          borderRadius: new BorderRadius.only(
                              bottomRight: Radius.circular(10.0))),
                      child: new Center(
                        child: new Text(
                          "Accept",
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
