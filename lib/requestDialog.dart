import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/data/globalvariables.dart';
import 'package:provider/theme/style.dart';

class RequestDialog extends StatelessWidget {
  final String title;
  final Map<String, dynamic> requestData;
  final VoidCallback onTap, onAccept, onDecline, onReview;
  RequestDialog(
      {this.title,
        this.requestData,
        this.onTap,
        this.onAccept,
        this.onDecline,
        this.onReview});
  @override
  Widget build(BuildContext context) {
    return
       Container(
        // height: MediaQuery.of(context).size.height*5,
         child: SingleChildScrollView(
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top:18.0),
                child: Center(
                  child: Text(title != null ? title : '',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                ),
              ),

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
                    Icon(FontAwesomeIcons.indent, color: Colors.black),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text("Delivery Price :" + Globals.base.toString() + " Euro",
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
                child: GestureDetector(
                  onTap: onReview,
                  child: new Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      border: Border.all(
                        color: Colors.lightGreen,
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Center(
                        child: new Text("Request Details",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.normal,
                                fontSize: 15.0))),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: new GestureDetector(
                  onTap: onDecline,
                  child: new Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      border: Border.all(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Center(
                        child: new Text("Decline",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.normal,
                                fontSize: 15.0))),
                  ),

                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: new GestureDetector(
                  onTap: onAccept,
                  child: new Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(60, 111, 102, 1),
                      border: Border.all(
                        color: Color.fromRGBO(60, 111, 102, 1),
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Center(
                        child: new Text("Accept",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.normal,
                                fontSize: 15.0))),
                  ),
                ),
              ),
              SizedBox(height: 20,)

            ],
    ),
         ),
       );
  }
}
